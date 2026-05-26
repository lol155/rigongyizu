import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import '../models/task.dart';
import 'data_store.dart';
import 'tasks_provider.dart';

final goalsProvider = AsyncNotifierProvider<GoalsNotifier, List<Goal>>(
  GoalsNotifier.new,
);

class GoalsNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    ref.listen<AsyncValue<List<ScheduleTask>>>(tasksProvider, (_, next) {
      next.whenData(_syncProgressForTasks);
    });

    final dataStore = ref.read(dataStoreProvider);
    final goals = await dataStore.loadGoals();
    final tasks = await ref.read(tasksProvider.future);
    final next = List<Goal>.unmodifiable(_deriveGoalProgress(goals, tasks));
    if (!_sameGoalSnapshot(goals, next)) {
      await dataStore.saveGoals(next);
    }
    return next;
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  Future<void> setAll(List<Goal> goals) async {
    await _saveWithDerivedProgress(goals);
  }

  Future<void> addGoal(Goal goal) async {
    final current = await future;
    final next = [...current, goal];
    await _saveWithDerivedProgress(next);
  }

  Future<void> updateGoal(Goal goal) async {
    final current = await future;
    final next = current
        .map((item) => item.id == goal.id ? goal : item)
        .toList(growable: false);
    await _saveWithDerivedProgress(next);
  }

  Future<void> upsertGoal(Goal goal) async {
    final current = await future;
    final index = current.indexWhere((item) => item.id == goal.id);
    final next = [...current];

    if (index == -1) {
      next.add(goal);
    } else {
      next[index] = goal;
    }

    await _saveWithDerivedProgress(next);
  }

  Future<void> deleteGoal(String id) async {
    final current = await future;
    final idsToDelete = <String>{id};

    var changed = true;
    while (changed) {
      changed = false;
      for (final goal in current) {
        final parentId = goal.parentId;
        if (parentId != null && idsToDelete.contains(parentId) && idsToDelete.add(goal.id)) {
          changed = true;
        }
      }
    }

    final next = current.where((item) => !idsToDelete.contains(item.id)).toList(growable: false);
    await _saveWithDerivedProgress(next);
  }

  Future<void> _saveWithDerivedProgress(List<Goal> goals) async {
    final tasks = await ref.read(tasksProvider.future);
    final next = List<Goal>.unmodifiable(_deriveGoalProgress(goals, tasks));
    await ref.read(dataStoreProvider).saveGoals(next);
    state = AsyncData(next);
  }

  Future<void> _syncProgressForTasks(List<ScheduleTask> tasks) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final next = List<Goal>.unmodifiable(_deriveGoalProgress(current, tasks));
    if (_sameGoalSnapshot(current, next)) {
      return;
    }

    await ref.read(dataStoreProvider).saveGoals(next);
    state = AsyncData(next);
  }

  List<Goal> _deriveGoalProgress(List<Goal> goals, List<ScheduleTask> tasks) {
    final goalsById = {for (final goal in goals) goal.id: goal};
    final childrenByParent = <String, List<Goal>>{};
    final tasksByGoalId = <String, List<ScheduleTask>>{};

    for (final goal in goals) {
      final parentId = goal.parentId;
      if (parentId != null && goalsById.containsKey(parentId)) {
        childrenByParent.putIfAbsent(parentId, () => <Goal>[]).add(goal);
      }
    }

    for (final task in tasks) {
      final goalId = task.goalId;
      if (goalId != null && goalsById.containsKey(goalId)) {
        tasksByGoalId.putIfAbsent(goalId, () => <ScheduleTask>[]).add(task);
      }
    }

    final computedProgress = <String, double>{};

    double progressFor(Goal goal) {
      final cached = computedProgress[goal.id];
      if (cached != null) {
        return cached;
      }

      if (goal.status == GoalStatus.completed) {
        return computedProgress[goal.id] = 1.0;
      }

      final childValues = (childrenByParent[goal.id] ?? const <Goal>[])
          .map(progressFor)
          .toList(growable: false);
      final relatedTasks = tasksByGoalId[goal.id] ?? const <ScheduleTask>[];
      final taskValues = relatedTasks
          .map((task) => task.status == TaskStatus.done ? 1.0 : 0.0)
          .toList(growable: false);
      final values = [...childValues, ...taskValues];

      if (values.isEmpty) {
        return computedProgress[goal.id] = goal.progressPct.clamp(0.0, 1.0);
      }

      final progress = values.reduce((sum, value) => sum + value) / values.length;
      return computedProgress[goal.id] = progress.clamp(0.0, 1.0);
    }

    return goals
        .map((goal) {
          final next = Goal.fromMap(goal.toMap());
          next.progressPct = progressFor(goal);
          next.status = next.progressPct >= 1.0
              ? GoalStatus.completed
              : GoalStatus.inProgress;
          return next;
        })
        .toList(growable: false);
  }

  bool _sameGoalSnapshot(List<Goal> previous, List<Goal> next) {
    if (identical(previous, next)) {
      return true;
    }

    if (previous.length != next.length) {
      return false;
    }

    for (var index = 0; index < previous.length; index++) {
      final currentGoal = previous[index];
      final nextGoal = next[index];
      if (currentGoal.id != nextGoal.id ||
          currentGoal.title != nextGoal.title ||
          currentGoal.description != nextGoal.description ||
          currentGoal.deadline != nextGoal.deadline ||
          currentGoal.priority != nextGoal.priority ||
          currentGoal.color != nextGoal.color ||
          currentGoal.status != nextGoal.status ||
          currentGoal.parentId != nextGoal.parentId ||
          currentGoal.progressPct != nextGoal.progressPct) {
        return false;
      }
    }

    return true;
  }
}
