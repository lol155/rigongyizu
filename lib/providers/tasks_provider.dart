import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import 'data_store.dart';

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<ScheduleTask>>(
  TasksNotifier.new,
);

class TasksNotifier extends AsyncNotifier<List<ScheduleTask>> {
  @override
  Future<List<ScheduleTask>> build() {
    return ref.read(dataStoreProvider).loadTasks();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  Future<void> setAll(List<ScheduleTask> tasks) async {
    final next = List<ScheduleTask>.unmodifiable(tasks);
    await ref.read(dataStoreProvider).saveTasks(next);
    state = AsyncData(next);
  }

  Future<void> addTask(ScheduleTask task) async {
    final current = await future;
    final next = [...current, task];
    await ref.read(dataStoreProvider).saveTasks(next);
    state = AsyncData(List<ScheduleTask>.unmodifiable(next));
  }

  Future<void> updateTask(ScheduleTask task) async {
    final current = await future;
    final next = current
        .map((item) => item.id == task.id ? task : item)
        .toList(growable: false);
    await ref.read(dataStoreProvider).saveTasks(next);
    state = AsyncData(next);
  }

  Future<void> upsertTask(ScheduleTask task) async {
    final current = await future;
    final index = current.indexWhere((item) => item.id == task.id);
    final next = [...current];

    if (index == -1) {
      next.add(task);
    } else {
      next[index] = task;
    }

    await ref.read(dataStoreProvider).saveTasks(next);
    state = AsyncData(List<ScheduleTask>.unmodifiable(next));
  }

  Future<void> deleteTask(String id) async {
    final current = await future;
    final next = current.where((item) => item.id != id).toList(growable: false);
    await ref.read(dataStoreProvider).saveTasks(next);
    state = AsyncData(next);
  }
}
