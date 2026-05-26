import 'package:flutter_test/flutter_test.dart';
import 'package:rigongyizu/models/reflection_template.dart';

void main() {
  group('ReflectionTemplate', () {
    test('toMap serializes type as enum index', () {
      final template = ReflectionTemplate(
        id: 'template-1',
        name: 'Weekly review',
        type: TemplateType.review,
      );

      final map = template.toMap();

      expect(map['type'], TemplateType.review.index);
    });

    test('fromMap round-trips all fields', () {
      final original = ReflectionTemplate(
        id: 'template-1',
        name: 'Weekly review',
        type: TemplateType.review,
        icon: '📘',
        isBuiltIn: true,
        questions: const ['What worked?', 'What needs work?'],
      );

      final restored = ReflectionTemplate.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.type, original.type);
      expect(restored.icon, original.icon);
      expect(restored.isBuiltIn, original.isBuiltIn);
      expect(restored.questions, orderedEquals(original.questions));
    });

    test('fromMap uses defaults for omitted optional values', () {
      final restored = ReflectionTemplate.fromMap({
        'id': 'template-1',
        'name': 'Daily reflection',
      });

      expect(restored.type, TemplateType.reflection);
      expect(restored.icon, '📝');
      expect(restored.isBuiltIn, isFalse);
      expect(restored.questions, isEmpty);
    });

    test('fromMap defaults type to reflection when missing', () {
      final restored = ReflectionTemplate.fromMap({
        'id': 'template-1',
        'name': 'Daily reflection',
        'icon': '🌅',
      });

      expect(restored.type, TemplateType.reflection);
    });

    test('fromMap restores enum value from type index', () {
      final restored = ReflectionTemplate.fromMap({
        'id': 'template-1',
        'name': 'Weekly review',
        'type': TemplateType.review.index,
        'questions': const ['What worked?'],
      });

      expect(restored.type, TemplateType.review);
    });
  });
}
