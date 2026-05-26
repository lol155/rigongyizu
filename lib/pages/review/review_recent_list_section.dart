import 'package:flutter/material.dart';

import '../../models/journal_entry.dart';
import '../../utils/app_colors.dart';
import '../journal_list_page.dart';

class ReviewRecentListSection extends StatelessWidget {
  const ReviewRecentListSection({
    super.key,
    required this.recent,
  });

  final List<JournalEntry> recent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('近期记录', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JournalListPage()),
                ),
                child: const Text('查看全部 >', style: TextStyle(fontSize: 13, color: AppColors.primary)),
              ),
            ],
          ),
        ),
        ...recent.take(5).map(
          (journal) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _ReviewRecentListCard(journal: journal),
          ),
        ),
      ],
    );
  }
}

class _ReviewRecentListCard extends StatelessWidget {
  const _ReviewRecentListCard({required this.journal});

  final JournalEntry journal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: journal.type == JournalType.reflection
                        ? AppColors.journalReflectionBg
                        : AppColors.journalReviewBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    journal.templateName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: journal.type == JournalType.reflection
                          ? AppColors.journalReflectionFg
                          : AppColors.journalReviewFg,
                    ),
                  ),
                ),
              Text('${journal.date.month}月${journal.date.day}日', style: const TextStyle(fontSize: 12, color: AppColors.text3)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            journal.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5),
          ),
        ],
      ),
    );
  }
}
