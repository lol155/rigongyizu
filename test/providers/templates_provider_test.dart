import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rigongyizu/models/reflection_template.dart';
import 'package:rigongyizu/providers/templates_provider.dart';
import 'package:rigongyizu/services/data_service.dart';

import 'provider_test_helper.dart';

void main() {
  setUpProviderStorage(null, (_) async {});

  test('combines built-in and custom templates while persisting custom changes', () async {
    final custom = ReflectionTemplate(
      id: 'custom-1',
      name: 'My Weekly',
      type: TemplateType.review,
      questions: const ['What worked?'],
    );
    await DataService.saveTemplateAsync(custom);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect((await container.read(templatesProvider.future)).single.id, 'custom-1');

    final allTemplates = container.read(allTemplatesProvider).requireValue;
    expect(allTemplates.any((item) => item.id == 'daily_reflection'), isTrue);
    expect(allTemplates.any((item) => item.id == 'custom-1'), isTrue);

    final added = ReflectionTemplate(
      id: 'custom-2',
      name: 'My Reflection',
      type: TemplateType.reflection,
      questions: const ['What matters today?'],
    );

    await container.read(templatesProvider.notifier).addTemplate(added);

    expect(DataService.getCustomTemplates().map((item) => item.id), contains('custom-2'));
    expect(
      container.read(reflectionTemplatesProvider).requireValue.any((item) => item.id == 'custom-2'),
      isTrue,
    );
  });
}
