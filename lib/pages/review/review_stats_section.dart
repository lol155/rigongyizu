import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class ReviewStatsSection extends StatelessWidget {
  const ReviewStatsSection({
    super.key,
    required this.reflectionCount,
    required this.reviewCount,
    required this.weekCount,
    required this.streak,
    this.onReflectionTap,
    this.onReviewTap,
  });

  final int reflectionCount;
  final int reviewCount;
  final int weekCount;
  final int streak;
  final VoidCallback? onReflectionTap;
  final VoidCallback? onReviewTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _ReviewStatCard(label: '反思次数', value: '$reflectionCount', color: AppColors.primary, onTap: onReflectionTap),
            const SizedBox(width: 10),
            _ReviewStatCard(label: '复盘次数', value: '$reviewCount', color: AppColors.success, onTap: onReviewTap),
          ],
        ),
        const SizedBox(width: 10),
        Row(
          children: [
            _ReviewStatCard(label: '本周记录', value: '$weekCount', color: AppColors.blue),
            const SizedBox(width: 10),
            _ReviewStatCard(label: '连续天数', value: '$streak', color: AppColors.purple),
          ],
        ),
      ],
    );
  }
}

class _ReviewStatCard extends StatelessWidget {
  const _ReviewStatCard({
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text2)),
        ],
      ),
    );

    if (onTap != null) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: card,
        ),
      );
    }
    return Expanded(child: card);
  }
}
