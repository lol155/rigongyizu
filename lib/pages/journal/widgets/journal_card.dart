import 'package:flutter/material.dart';

import '../../../models/journal_entry.dart';
import '../../../utils/app_colors.dart';
import '../journal_formatters.dart';

class JournalCard extends StatelessWidget {
  const JournalCard({
    super.key,
    required this.entry,
    required this.isExpanded,
    required this.onOpen,
    required this.onToggleExpanded,
    required this.onCopy,
  });

  final JournalEntry entry;
  final bool isExpanded;
  final VoidCallback onOpen;
  final VoidCallback onToggleExpanded;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final typeColor = entry.type == JournalType.reflection
        ? AppColors.journalReflectionBg
        : AppColors.journalReviewBg;
    final typeTextColor = entry.type == JournalType.reflection
        ? AppColors.journalReflectionFg
        : AppColors.journalReviewFg;
    final typeLabel = entry.type == JournalType.reflection ? '反思' : '复盘';

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: typeTextColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      formatJournalDate(entry.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.text3,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onToggleExpanded,
                      child: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: AppColors.text3,
                      ),
                    ),
                    const SizedBox(width: 2),
                    GestureDetector(
                      onTap: onCopy,
                      child: const Icon(
                        Icons.copy,
                        size: 18,
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              entry.templateName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              entry.content,
              maxLines: isExpanded ? null : 3,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.text2,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
