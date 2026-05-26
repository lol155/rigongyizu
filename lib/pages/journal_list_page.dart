import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_entry.dart';
import 'journal/journal_formatters.dart';
import 'journal/widgets/journal_card.dart';
import 'journal/widgets/journal_detail_sheet.dart';
import 'journal/widgets/journal_edit_dialog.dart';
import 'journal/widgets/journal_filter_header.dart';
import '../providers/journals_provider.dart';
import '../utils/app_colors.dart';

class JournalListPage extends ConsumerStatefulWidget {
  const JournalListPage({super.key, this.initialFilterType});

  final JournalType? initialFilterType;

  @override
  ConsumerState<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends ConsumerState<JournalListPage> {
  String _searchQuery = '';
  late JournalType? _filterType = widget.initialFilterType;
  final Set<String> _expandedCards = {};
  List<JournalEntry> _journals = const [];

  List<JournalEntry> get _filtered {
    var list = _journals.toList()..sort((a, b) => b.date.compareTo(a.date));
    if (_filterType != null) {
      list = list.where((journal) => journal.type == _filterType).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list
          .where(
            (journal) =>
                journal.content.toLowerCase().contains(query) ||
                journal.templateName.toLowerCase().contains(query),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final journalsAsync = ref.watch(journalsProvider);

    return journalsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('日记加载失败：$error'))),
      data: (_) {
        _journals = journalsAsync.requireValue;
        final items = _filtered;

        return Scaffold(
          backgroundColor: AppColors.background(context),
          body: Column(
            children: [
              JournalFilterHeader(
                totalCount: _journals.length,
                filterType: _filterType,
                onSearchChanged: (value) =>
                    setState(() => _searchQuery = value),
                onFilterTap: (type) {
                  setState(
                    () => _filterType = _filterType == type ? null : type,
                  );
                },
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('📔', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 12),
                            Text(
                              '还没有日记',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text3,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: items.length,
                        itemBuilder: (ctx, index) {
                          final entry = items[index];
                          final isExpanded = _expandedCards.contains(entry.id);

                          return JournalCard(
                            entry: entry,
                            isExpanded: isExpanded,
                            onOpen: () => _showDetail(entry),
                            onToggleExpanded: () =>
                                _toggleExpanded(entry.id, isExpanded),
                            onCopy: () => _copyListEntry(entry),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleExpanded(String entryId, bool isExpanded) {
    setState(() {
      if (isExpanded) {
        _expandedCards.remove(entryId);
      } else {
        _expandedCards.add(entryId);
      }
    });
  }

  void _copyListEntry(JournalEntry entry) {
    _copyText(
      '${entry.templateName}\n${formatJournalDate(entry.date)}\n\n${entry.content}',
      context,
    );
  }

  void _copyDetailEntry(JournalEntry entry, BuildContext sheetContext) {
    _copyText(
      '${entry.templateName}\n${formatJournalDateTime(entry.date, entry.time)}\n\n${entry.content}',
      sheetContext,
    );
  }

  void _copyText(String text, BuildContext messengerContext) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(messengerContext).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 1)),
    );
  }

  void _showDetail(JournalEntry entry) {
    final formattedDateTime = formatJournalDateTime(entry.date, entry.time);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => JournalDetailSheet(
        entry: entry,
        formattedDateTime: formattedDateTime,
        onCopy: () => _copyDetailEntry(entry, sheetCtx),
        onEdit: () => _showEditDialog(sheetCtx, entry),
        onDelete: () => _deleteEntry(sheetCtx, entry.id),
      ),
    );
  }

  Future<void> _deleteEntry(BuildContext sheetCtx, String entryId) async {
    try {
      await ref.read(journalsProvider.notifier).deleteJournal(entryId);
      if (sheetCtx.mounted) {
        Navigator.pop(sheetCtx);
      }
    } catch (error) {
      if (sheetCtx.mounted) {
        ScaffoldMessenger.of(sheetCtx).showSnackBar(
          SnackBar(content: Text('删除日记失败：$error')),
        );
      }
    }
  }

  Future<void> _showEditDialog(
    BuildContext sheetCtx,
    JournalEntry entry,
  ) async {
    await showDialog(
      context: context,
        builder: (dialogCtx) => JournalEditDialog(
          initialContent: entry.content,
          onSave: (updatedContent) async {
            final messenger = ScaffoldMessenger.of(context);

            try {
              await ref
                  .read(journalsProvider.notifier)
                  .upsertJournal(
                    JournalEntry(
                      id: entry.id,
                      type: entry.type,
                      templateId: entry.templateId,
                      templateName: entry.templateName,
                      date: entry.date,
                      time: entry.time,
                      content: updatedContent,
                    ),
                  );

              if (dialogCtx.mounted) {
                Navigator.pop(dialogCtx);
              }
              if (sheetCtx.mounted) {
                Navigator.pop(sheetCtx);
              }
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('日记已保存'),
                  duration: Duration(seconds: 1),
                ),
              );
            } catch (error) {
              messenger.showSnackBar(
                SnackBar(content: Text('保存日记失败：$error')),
              );
            }
          },
        ),
      );
  }
}
