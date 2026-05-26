import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';
import 'goals_provider.dart';
import 'tasks_provider.dart';

final appBootstrapProvider = FutureProvider<void>((ref) async {
  final tasks = await ref.read(tasksProvider.future);
  final goals = await ref.read(goalsProvider.future);

  if (tasks.isNotEmpty || goals.isNotEmpty) {
    return;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  await ref.read(goalsProvider.notifier).setAll(_buildDemoGoals(today));
  await ref.read(tasksProvider.notifier).setAll(_buildDemoTasks(today));
});

List<Goal> _buildDemoGoals(DateTime today) {
  return [
    Goal(
      id: 'g1',
      title: '🎨 学习Flutter开发',
      deadline: today.add(const Duration(days: 30)),
      priority: 3,
      color: AppColors.primaryValue,
    ),
    Goal(
      id: 'g2',
      title: '💪 健康管理',
      deadline: today.add(const Duration(days: 90)),
      priority: 2,
      color: AppColors.successValue,
    ),
    Goal(
      id: 'g3',
      title: '📚 年读24本书',
      deadline: today.add(const Duration(days: 250)),
      priority: 1,
      color: AppColors.blueValue,
    ),
    Goal(id: 'g1_1', title: 'Dart语言基础', parentId: 'g1', color: AppColors.primaryValue),
    Goal(id: 'g1_2', title: 'Widget体系', parentId: 'g1', color: AppColors.primaryValue),
    Goal(id: 'g2_1', title: '每周运动3次', parentId: 'g2', color: AppColors.successValue),
    Goal(id: 'g3_1', title: '本月读完《原子习惯》', parentId: 'g3', color: AppColors.blueValue),
  ];
}

List<ScheduleTask> _buildDemoTasks(DateTime today) {
  return [
    ScheduleTask(
      id: 'd1',
      title: '晨跑 30分钟',
      date: today,
      startTime: DateTime(today.year, today.month, today.day, 7, 0),
      durationMinutes: 30,
      color: AppColors.successValue,
      goalId: 'g2',
    ),
    ScheduleTask(
      id: 'd2',
      title: '完成原型设计',
      date: today,
      startTime: DateTime(today.year, today.month, today.day, 9, 0),
      durationMinutes: 120,
      color: AppColors.primaryValue,
      goalId: 'g1',
    ),
    ScheduleTask(
      id: 'd3',
      title: '阅读《原子习惯》',
      date: today,
      startTime: DateTime(today.year, today.month, today.day, 12, 30),
      durationMinutes: 60,
      color: AppColors.blueValue,
      goalId: 'g3',
    ),
    ScheduleTask(
      id: 'd4',
      title: '写周报',
      date: today,
      startTime: DateTime(today.year, today.month, today.day, 14, 0),
      durationMinutes: 90,
      color: AppColors.purpleValue,
    ),
    ScheduleTask(
      id: 'd5',
      title: '英语口语练习',
      date: today,
      startTime: DateTime(today.year, today.month, today.day, 16, 0),
      durationMinutes: 45,
      color: AppColors.warningValue,
    ),
    ScheduleTask(
      id: 'd6',
      title: '复盘今日进度',
      date: today,
      startTime: DateTime(today.year, today.month, today.day, 21, 0),
      durationMinutes: 30,
      color: AppColors.text2Value,
    ),
  ];
}
