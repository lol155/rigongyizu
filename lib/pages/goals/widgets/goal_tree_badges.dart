import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

GoalPriorityMeta goalPriorityMeta(int priority) {
  if (priority >= 3) {
    return const GoalPriorityMeta(
      label: '高优先',
      background: AppColors.goalPriorityHighBg,
      foreground: AppColors.goalPriorityHighFg,
    );
  }

  if (priority == 2) {
    return const GoalPriorityMeta(
      label: '中优先',
      background: AppColors.goalPriorityMediumBg,
      foreground: AppColors.goalPriorityMediumFg,
    );
  }

  return const GoalPriorityMeta(
    label: '低优先',
    background: AppColors.goalPriorityLowBg,
    foreground: AppColors.goalPriorityLowFg,
  );
}

class GoalActionButton extends StatelessWidget {
  const GoalActionButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderMuted),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.text2),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalPriorityMeta {
  const GoalPriorityMeta({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

class GoalPriorityBadge extends StatelessWidget {
  const GoalPriorityBadge({super.key, required this.meta});

  final GoalPriorityMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: meta.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: meta.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            meta.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: meta.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
