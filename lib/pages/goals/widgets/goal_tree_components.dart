import 'package:flutter/material.dart';

import '../../../models/goal.dart';
import '../../../utils/app_colors.dart';
import 'goal_tree_badges.dart';

class GoalTreeCard extends StatelessWidget {
  const GoalTreeCard({
    super.key,
    required this.goal,
    required this.depth,
    required this.isExpanded,
    required this.isDone,
    required this.pct,
    required this.goalColor,
    required this.priorityMeta,
    required this.deadlineText,
    required this.remainingDays,
    required this.hasChildren,
    required this.onToggleExpand,
    required this.onToggleDone,
    required this.onEditGoal,
  });

  final Goal goal;
  final int depth;
  final bool isExpanded;
  final bool isDone;
  final double pct;
  final Color goalColor;
  final GoalPriorityMeta priorityMeta;
  final String deadlineText;
  final int remainingDays;
  final bool hasChildren;
  final VoidCallback onToggleExpand;
  final VoidCallback onToggleDone;
  final VoidCallback onEditGoal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16 + depth * 20.0, 8, 16, 0),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggleExpand,
          onLongPress: onEditGoal,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onToggleDone,
                      child: Icon(
                        isDone
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked,
                        color: isDone ? AppColors.success : goalColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? AppColors.text3 : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GoalPriorityBadge(meta: priorityMeta),
                    const SizedBox(width: 8),
                    Text(
                      '${(pct * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: goalColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.inactiveBg(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: pct,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: goalColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (deadlineText.isNotEmpty)
                      Text(
                        '截止: $deadlineText',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.text2,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (remainingDays >= 0)
                      Text(
                        '剩余 $remainingDays天',
                        style: TextStyle(
                          fontSize: 11,
                          color: remainingDays <= 3
                              ? AppColors.danger
                              : AppColors.text2,
                          fontWeight: remainingDays <= 3
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (hasChildren)
                      Icon(
                        isExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 18,
                        color: AppColors.text3,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GoalTreeExpandedActions extends StatelessWidget {
  const GoalTreeExpandedActions({
    super.key,
    required this.depth,
    required this.onAddToSchedule,
    required this.onAddSubGoal,
  });

  final int depth;
  final VoidCallback onAddToSchedule;
  final VoidCallback onAddSubGoal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(32 + depth * 20.0, 4, 16, 0),
      child: Row(
        children: [
          GoalActionButton(
            emoji: '📅',
            label: '加到日程',
            onTap: onAddToSchedule,
          ),
          const SizedBox(width: 8),
          GoalActionButton(
            emoji: '➕',
            label: '子目标',
            onTap: onAddSubGoal,
          ),
        ],
      ),
    );
  }
}

class GoalTreeAddSubGoalTile extends StatelessWidget {
  const GoalTreeAddSubGoalTile({
    super.key,
    required this.depth,
    required this.onTap,
  });

  final int depth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(32 + depth * 20.0, 4, 16, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.borderSubtle,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '+ 添加子目标',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.text2),
          ),
        ),
      ),
    );
  }
}
