import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rigongyizu/models/goal.dart';
import 'package:rigongyizu/models/task.dart';
import 'package:rigongyizu/providers/goals_provider.dart';
import 'package:rigongyizu/providers/tasks_provider.dart';
import 'package:rigongyizu/services/data_service.dart';

import 'provider_test_helper.dart';

void main() {
  setUpProviderStorage(null, (_) async {});

  test('loads goals and persists list updates', () async {
    final original = Goal(
      id: 'goal-1',
      title: 'Ship providers',
      deadline: DateTime.utc(2026, 5, 1),
      priority: 2,
    );
    await DataService.saveGoalAsync(original);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect((await container.read(goalsProvider.future)).single.title, 'Ship providers');

    final updated = Goal(
      id: 'goal-1',
      title: 'Ship Riverpod providers',
      deadline: original.deadline,
      priority: 3,
      progressPct: 0.6,
    );

    await container.read(goalsProvider.notifier).updateGoal(updated);

    expect(container.read(goalsProvider).requireValue.single.progressPct, 0.6);
    expect(DataService.getGoals().single.title, 'Ship Riverpod providers');
  });

  test('derives goal progress from child goals and related tasks', () async {
    await DataService.saveAllGoalsAsync([
      Goal(id: 'parent', title: 'Parent goal'),
      Goal(id: 'child-a', title: 'Child A', parentId: 'parent'),
      Goal(id: 'child-b', title: 'Child B', parentId: 'parent'),
    ]);
    await DataService.saveAllTasksAsync([
      ScheduleTask(
        id: 'task-a',
        title: 'Done task',
        date: DateTime.utc(2026, 4, 26),
        startTime: DateTime.utc(2026, 4, 26, 9),
        goalId: 'child-a',
        status: TaskStatus.done,
      ),
      ScheduleTask(
        id: 'task-b',
        title: 'Pending task',
        date: DateTime.utc(2026, 4, 26),
        startTime: DateTime.utc(2026, 4, 26, 10),
        goalId: 'child-b',
      ),
    ]);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final goals = await container.read(goalsProvider.future);
    final goalsById = {for (final goal in goals) goal.id: goal};

    expect(goalsById['child-a']!.progressPct, 1.0);
    expect(goalsById['child-a']!.status, GoalStatus.completed);
    expect(goalsById['child-b']!.progressPct, 0.0);
    expect(goalsById['parent']!.progressPct, 0.5);
    expect(DataService.getGoals().firstWhere((goal) => goal.id == 'parent').progressPct, 0.5);
  });

  test('recomputes progress when related task completion changes', () async {
    await DataService.saveGoalAsync(Goal(id: 'goal-1', title: 'Ship feature'));
    await DataService.saveTaskAsync(
      ScheduleTask(
        id: 'task-1',
        title: 'Finish task',
        date: DateTime.utc(2026, 4, 26),
        startTime: DateTime.utc(2026, 4, 26, 9),
        goalId: 'goal-1',
      ),
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(goalsProvider, (previous, next) {});
    addTearDown(subscription.close);

    await container.read(goalsProvider.future);
    expect(container.read(goalsProvider).requireValue.single.progressPct, 0.0);

    final task = (await container.read(tasksProvider.future)).single;
    await container.read(tasksProvider.notifier).updateTask(
          ScheduleTask(
            id: task.id,
            title: task.title,
            date: task.date,
            startTime: task.startTime,
            durationMinutes: task.durationMinutes,
            goalId: task.goalId,
            status: TaskStatus.done,
            color: task.color,
            notes: task.notes,
          ),
        );
    await Future<void>.delayed(const Duration(milliseconds: 1));

    final goal = container.read(goalsProvider).requireValue.single;
    expect(goal.progressPct, 1.0);
    expect(goal.status, GoalStatus.completed);
  });
}
