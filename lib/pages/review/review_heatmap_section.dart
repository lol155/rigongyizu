import 'package:flutter/material.dart';

import '../../models/journal_entry.dart';
import '../../utils/app_colors.dart';
import 'review_page_metrics.dart';

class ReviewHeatmapSection extends StatelessWidget {
  const ReviewHeatmapSection({
    super.key,
    required this.today,
    required this.journals,
  });

  final DateTime today;
  final List<JournalEntry> journals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔥 活跃热力图', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('近4周', style: TextStyle(fontSize: 12, color: AppColors.text3)),
          const SizedBox(height: 8),
          _ReviewHeatmapGrid(today: today, journals: journals),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('少', style: TextStyle(fontSize: 10, color: AppColors.text3)),
              const SizedBox(width: 4),
              _HeatCell(color: AppColors.inactiveBg(context)),
               const _HeatCell(color: AppColors.heatmapLow),
               const _HeatCell(color: AppColors.heatmapMedium),
               const _HeatCell(color: AppColors.heatmapHigh),
               const _HeatCell(color: AppColors.primary),
              const SizedBox(width: 4),
              const Text('多', style: TextStyle(fontSize: 10, color: AppColors.text3)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewHeatmapGrid extends StatelessWidget {
  const _ReviewHeatmapGrid({
    required this.today,
    required this.journals,
  });

  final DateTime today;
  final List<JournalEntry> journals;

  @override
  Widget build(BuildContext context) {
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final colors = AppColors.reviewHeatmapScale(context);

    return Column(
      children: List.generate(
        4,
        (week) => Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            children: List.generate(7, (dayIndex) {
              final date = weekStart.subtract(Duration(days: (3 - week) * 7 + 6 - dayIndex));
              final count = journalCountOnDay(journals, date);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors[count.clamp(0, 4)],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
    );
  }
}
