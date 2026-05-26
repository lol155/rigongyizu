import 'package:flutter_test/flutter_test.dart';
import 'package:rigongyizu/models/goal.dart';

void main() {
  group('Goal', () {
    test('toMap serializes status as enum index', () {
      final goal = Goal(
        id: 'goal-1',
        title: 'Ship tests',
        status: GoalStatus.completed,
      );

      final map = goal.toMap();

      expect(map['status'], GoalStatus.completed.index);
    });

    test('fromMap round-trips all fields', () {
      final original = Goal(
        id: 'goal-1',
        title: 'Ship tests',
        description: 'Cover model behavior',
        deadline: DateTime.utc(2026, 5, 1, 18),
        priority: 2,
        color: 0xFF654321,
        status: GoalStatus.completed,
        parentId: 'goal-parent',
        progressPct: 0.75,
      );

      final restored = Goal.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.deadline, original.deadline);
      expect(restored.priority, original.priority);
      expect(restored.color, original.color);
      expect(restored.status, original.status);
      expect(restored.parentId, original.parentId);
      expect(restored.progressPct, original.progressPct);
    });

    test('fromMap uses defaults for omitted optional values', () {
      final restored = Goal.fromMap({
        'id': 'goal-1',
        'title': 'Ship tests',
      });

      expect(restored.description, '');
      expect(restored.deadline, isNull);
      expect(restored.priority, 0);
      expect(restored.color, 0xFFFF6B35);
      expect(restored.status, GoalStatus.inProgress);
      expect(restored.parentId, isNull);
      expect(restored.progressPct, 0.0);
    });

    test('remainingDays returns -1 without a deadline', () {
      final goal = Goal(id: 'goal-1', title: 'Ship tests');

      expect(goal.remainingDays, -1);
    });

    test('remainingDays reflects future deadlines in whole days', () {
      final goal = Goal(
        id: 'goal-1',
        title: 'Ship tests',
        deadline: DateTime.now().add(const Duration(days: 3, minutes: 1)),
      );

      expect(goal.remainingDays, 3);
    });
  });
}
