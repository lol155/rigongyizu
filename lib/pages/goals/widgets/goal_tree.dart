import 'package:flutter/material.dart';

import '../../../models/goal.dart';
import 'goal_tree_badges.dart';
import 'goal_tree_components.dart';

typedef GoalChildrenResolver = List<Goal> Function(String parentId);

class GoalTree extends StatelessWidget {
  const GoalTree({
    super.key,
    required this.rootGoals,
    required this.childrenOf,
    required this.expansionMap,
    required this.onToggleExpand,
    required this.onToggleDone,
    required this.onAddToSchedule,
    required this.onAddSubGoal,
    required this.onEditGoal,
  });

  final List<Goal> rootGoals;
  final GoalChildrenResolver childrenOf;
  final Map<String, bool> expansionMap;
  final ValueChanged<String> onToggleExpand;
  final ValueChanged<Goal> onToggleDone;
  final ValueChanged<Goal> onAddToSchedule;
  final ValueChanged<String> onAddSubGoal;
  final ValueChanged<Goal> onEditGoal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rootGoals
          .map(
            (goal) => _GoalTreeNode(
              goal: goal,
              depth: 0,
              childrenOf: childrenOf,
              expansionMap: expansionMap,
              onToggleExpand: onToggleExpand,
              onToggleDone: onToggleDone,
              onAddToSchedule: onAddToSchedule,
              onAddSubGoal: onAddSubGoal,
              onEditGoal: onEditGoal,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _GoalTreeNode extends StatelessWidget {
  const _GoalTreeNode({
    required this.goal,
    required this.depth,
    required this.childrenOf,
    required this.expansionMap,
    required this.onToggleExpand,
    required this.onToggleDone,
    required this.onAddToSchedule,
    required this.onAddSubGoal,
    required this.onEditGoal,
  });

  final Goal goal;
  final int depth;
  final GoalChildrenResolver childrenOf;
  final Map<String, bool> expansionMap;
  final ValueChanged<String> onToggleExpand;
  final ValueChanged<Goal> onToggleDone;
  final ValueChanged<Goal> onAddToSchedule;
  final ValueChanged<String> onAddSubGoal;
  final ValueChanged<Goal> onEditGoal;

  @override
  Widget build(BuildContext context) {
    final isExpanded = expansionMap[goal.id] ?? false;
    final children = childrenOf(goal.id);
    final isDone = goal.status == GoalStatus.completed;
    final goalColor = Color(goal.color);
    final priorityMeta = goalPriorityMeta(goal.priority);
    final pct = goal.progressPct.clamp(0.0, 1.0);
    final deadlineText = goal.deadline != null
        ? '${goal.deadline!.month}/${goal.deadline!.day}'
        : '';
    final remainingDays = goal.remainingDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoalTreeCard(
          goal: goal,
          depth: depth,
          isExpanded: isExpanded,
          isDone: isDone,
          pct: pct,
          goalColor: goalColor,
          priorityMeta: priorityMeta,
          deadlineText: deadlineText,
          remainingDays: remainingDays,
          hasChildren: children.isNotEmpty,
          onToggleExpand: () => onToggleExpand(goal.id),
          onToggleDone: () => onToggleDone(goal),
          onEditGoal: () => onEditGoal(goal),
        ),
        if (isExpanded) ...[
          GoalTreeExpandedActions(
            depth: depth,
            onAddToSchedule: () => onAddToSchedule(goal),
            onAddSubGoal: () => onAddSubGoal(goal.id),
          ),
          ...children.map(
            (child) => _GoalTreeNode(
              goal: child,
              depth: depth + 1,
              childrenOf: childrenOf,
              expansionMap: expansionMap,
              onToggleExpand: onToggleExpand,
              onToggleDone: onToggleDone,
              onAddToSchedule: onAddToSchedule,
              onAddSubGoal: onAddSubGoal,
              onEditGoal: onEditGoal,
            ),
          ),
          GoalTreeAddSubGoalTile(
            depth: depth,
            onTap: () => onAddSubGoal(goal.id),
          ),
        ],
      ],
    );
  }
}
