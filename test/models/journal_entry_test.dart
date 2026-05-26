import 'package:flutter_test/flutter_test.dart';
import 'package:rigongyizu/models/journal_entry.dart';

void main() {
  group('JournalEntry', () {
    test('toMap serializes type as enum index', () {
      final entry = JournalEntry(
        id: 'entry-1',
        type: JournalType.review,
        templateId: 'template-1',
        templateName: 'Weekly review',
        date: DateTime.utc(2026, 4, 25),
        time: DateTime.utc(2026, 4, 25, 21, 30),
        content: 'Shipped tests',
      );

      final map = entry.toMap();

      expect(map['type'], JournalType.review.index);
    });

    test('toMap preserves date and time as ISO-8601 strings', () {
      final entry = JournalEntry(
        id: 'entry-1',
        type: JournalType.reflection,
        templateId: 'template-1',
        templateName: 'Daily reflection',
        date: DateTime.utc(2026, 4, 25),
        time: DateTime.utc(2026, 4, 25, 21, 30),
        content: 'Shipped tests',
      );

      final map = entry.toMap();

      expect(map['date'], DateTime.utc(2026, 4, 25).toIso8601String());
      expect(map['time'], DateTime.utc(2026, 4, 25, 21, 30).toIso8601String());
    });

    test('fromMap round-trips all fields', () {
      final original = JournalEntry(
        id: 'entry-1',
        type: JournalType.review,
        templateId: 'template-1',
        templateName: 'Weekly review',
        date: DateTime.utc(2026, 4, 25),
        time: DateTime.utc(2026, 4, 25, 21, 30),
        content: 'Shipped tests',
      );

      final restored = JournalEntry.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.templateId, original.templateId);
      expect(restored.templateName, original.templateName);
      expect(restored.date, original.date);
      expect(restored.time, original.time);
      expect(restored.content, original.content);
    });

    test('fromMap defaults type to reflection when missing', () {
      final restored = JournalEntry.fromMap({
        'id': 'entry-1',
        'templateId': 'template-1',
        'templateName': 'Daily reflection',
        'date': DateTime.utc(2026, 4, 25).toIso8601String(),
        'time': DateTime.utc(2026, 4, 25, 21, 30).toIso8601String(),
        'content': 'Shipped tests',
      });

      expect(restored.type, JournalType.reflection);
    });

    test('fromMap restores enum value from type index', () {
      final restored = JournalEntry.fromMap({
        'id': 'entry-1',
        'type': JournalType.review.index,
        'templateId': 'template-1',
        'templateName': 'Weekly review',
        'date': DateTime.utc(2026, 4, 25).toIso8601String(),
        'time': DateTime.utc(2026, 4, 25, 21, 30).toIso8601String(),
        'content': 'Shipped tests',
      });

      expect(restored.type, JournalType.review);
    });
  });
}
