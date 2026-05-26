import 'package:flutter_test/flutter_test.dart';
import 'package:rigongyizu/models/task.dart';

void main() {
  group('ScheduleTask', () {
    test('toMap serializes status as enum index', () {
      final task = ScheduleTask(
        id: 'task-1',
        title: 'Write tests',
        date: DateTime.utc(2026, 4, 25),
        startTime: DateTime.utc(2026, 4, 25, 9),
        status: TaskStatus.done,
      );

      final map = task.toMap();

      expect(map['status'], TaskStatus.done.index);
    });

    test('fromMap round-trips all fields', () {
      final original = ScheduleTask(
        id: 'task-1',
        title: 'Write tests',
        date: DateTime.utc(2026, 4, 25),
        startTime: DateTime.utc(2026, 4, 25, 9, 30),
        durationMinutes: 45,
        goalId: 'goal-1',
        status: TaskStatus.postponed,
        color: 0xFF123456,
        notes: 'Bring examples',
      );

      final restored = ScheduleTask.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.date, original.date);
      expect(restored.startTime, original.startTime);
      expect(restored.durationMinutes, original.durationMinutes);
      expect(restored.goalId, original.goalId);
      expect(restored.status, original.status);
      expect(restored.color, original.color);
      expect(restored.notes, original.notes);
    });

    test('fromMap uses defaults for omitted optional values', () {
      final restored = ScheduleTask.fromMap({
        'id': 'task-1',
        'title': 'Write tests',
        'date': DateTime.utc(2026, 4, 25).toIso8601String(),
        'startTime': DateTime.utc(2026, 4, 25, 9).toIso8601String(),
      });

      expect(restored.durationMinutes, 60);
      expect(restored.goalId, isNull);
      expect(restored.status, TaskStatus.pending);
      expect(restored.color, 0xFFFF6B35);
      expect(restored.notes, '');
    });

    test('endTime adds duration minutes to startTime', () {
      final task = ScheduleTask(
        id: 'task-1',
        title: 'Write tests',
        date: DateTime.utc(2026, 4, 25),
        startTime: DateTime.utc(2026, 4, 25, 9, 15),
        durationMinutes: 50,
      );

      expect(task.endTime, DateTime.utc(2026, 4, 25, 10, 5));
    });

    test('fromMap restores enum value from status index', () {
      final restored = ScheduleTask.fromMap({
        'id': 'task-1',
        'title': 'Write tests',
        'date': DateTime.utc(2026, 4, 25).toIso8601String(),
        'startTime': DateTime.utc(2026, 4, 25, 9).toIso8601String(),
        'status': TaskStatus.cancelled.index,
      });

      expect(restored.status, TaskStatus.cancelled);
    });
  });
}
