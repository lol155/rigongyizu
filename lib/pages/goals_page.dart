import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import 'goals/widgets/add_goal_dialog.dart';
import 'goals/widgets/add_subgoal_dialog.dart';
import 'goals/widgets/add_to_schedule_dialog.dart';
import 'goals/widgets/gantt_chart.dart';
import 'goals/widgets/goal_tree.dart';
import '../providers/goals_provider.dart';
import '../utils/app_colors.dart';

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> {
  List<Goal> _goals = const [];
  final Map<String, bool> _expansionMap = {};

  static const List<int> _goalColors = AppColors.goalColorValues;

  List<Goal> get _rootGoals =>
      _goals.where((goal) => goal.parentId == null).toList(growable: false);

  List<Goal> _childrenOf(String parentId) =>
      _goals.where((goal) => goal.parentId == parentId).toList(growable: false);

  Goal _cloneGoal(Goal goal) => Goal.fromMap(goal.toMap());

  void _toggleExpand(String goalId) {
    setState(() {
      _expansionMap[goalId] = !(_expansionMap[goalId] ?? false);
    });
  }

  Future<void> _toggleGoalDone(Goal goal) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = _cloneGoal(goal);
      updated.status = goal.status == GoalStatus.completed
          ? GoalStatus.inProgress
          : GoalStatus.completed;
      await ref.read(goalsProvider.notifier).upsertGoal(updated);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('更新目标状态失败：$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsProvider);

    if (goalsAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (goalsAsync.hasError) {
      return Scaffold(body: Center(child: Text('目标数据加载失败：${goalsAsync.error}')));
    }

    _goals = goalsAsync.requireValue;
    final rootGoals = _rootGoals;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎯 目标进度',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  '项目管理视角，一目了然',
                  style: TextStyle(fontSize: 13, color: AppColors.text2),
                ),
              ],
            ),
          ),
          if (rootGoals.isNotEmpty) GanttChart(goals: rootGoals),
          if (rootGoals.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                children: const [
                  Text('🎯', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 16),
                  Text(
                    '还没有目标',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '点击 + 创建你的第一个目标',
                    style: TextStyle(color: AppColors.text2),
                  ),
                ],
              ),
            )
          else
            GoalTree(
              rootGoals: rootGoals,
              childrenOf: _childrenOf,
              expansionMap: _expansionMap,
              onToggleExpand: _toggleExpand,
              onToggleDone: (goal) {
                _toggleGoalDone(goal);
              },
              onAddToSchedule: (goal) {
                AddToScheduleDialog.show(context, ref: ref, goal: goal);
              },
              onAddSubGoal: (goalId) {
                final parent = _goals.firstWhere((goal) => goal.id == goalId);
                AddSubGoalDialog.show(context, ref: ref, parentGoal: parent);
              },
              onEditGoal: _showEditGoalDialog,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddGoalDialog.show(
            context,
            ref: ref,
            goalColor: _goalColors[_goals.length % _goalColors.length],
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: AppColors.cardBackground(context)),
      ),
    );
  }

  void _showEditGoalDialog(Goal goal) {
    AddGoalDialog.show(
      context,
      ref: ref,
      goalColor: goal.color,
      existingGoal: _cloneGoal(goal),
      onDelete: () => ref.read(goalsProvider.notifier).deleteGoal(goal.id),
    );
  }
}
