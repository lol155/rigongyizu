import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rigongyizu/models/task.dart';
import 'package:rigongyizu/providers/tasks_provider.dart';
import 'package:rigongyizu/services/data_service.dart';

import 'provider_test_helper.dart';

void main() {
  setUpProviderStorage(null, (_) async {});

  test('loads tasks and persists upsert/delete operations', () async {
    final original = ScheduleTask(
      id: 'task-1',
      title: 'Morning run',
      date: DateTime.utc(2026, 4, 25),
      startTime: DateTime.utc(2026, 4, 25, 7),
      durationMinutes: 30,
    );
    await DataService.saveTaskAsync(original);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect((await container.read(tasksProvider.future)).single.title, 'Morning run');

    final updated = ScheduleTask(
      id: 'task-1',
      title: 'Updated run',
      date: original.date,
      startTime: original.startTime,
      durationMinutes: 45,
      notes: 'persist me',
    );

    await container.read(tasksProvider.notifier).upsertTask(updated);

    expect(container.read(tasksProvider).requireValue.single.durationMinutes, 45);
    expect(DataService.getTasks().single.notes, 'persist me');

    await container.read(tasksProvider.notifier).deleteTask('task-1');

    expect(container.read(tasksProvider).requireValue, isEmpty);
    expect(DataService.getTasks(), isEmpty);
  });
}
