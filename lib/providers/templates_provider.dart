import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reflection_template.dart';
import '../widgets/reflection_dialog.dart';
import 'data_store.dart';

final builtInTemplatesProvider = Provider<List<ReflectionTemplate>>((ref) {
  return ReflectionDialog.builtInTemplates.map(_cloneTemplate).toList(growable: false);
});

final templatesProvider = AsyncNotifierProvider<TemplatesNotifier, List<ReflectionTemplate>>(
  TemplatesNotifier.new,
);

final allTemplatesProvider = Provider<AsyncValue<List<ReflectionTemplate>>>((ref) {
  final builtIns = ref.watch(builtInTemplatesProvider);
  final customState = ref.watch(templatesProvider);

  return customState.whenData((customTemplates) {
    return List<ReflectionTemplate>.unmodifiable([
      ...builtIns,
      ...customTemplates,
    ]);
  });
});

final reflectionTemplatesProvider = Provider<AsyncValue<List<ReflectionTemplate>>>((ref) {
  return ref.watch(allTemplatesProvider).whenData(
        (templates) => templates
            .where((template) => template.type == TemplateType.reflection)
            .toList(growable: false),
      );
});

final reviewTemplatesProvider = Provider<AsyncValue<List<ReflectionTemplate>>>((ref) {
  return ref.watch(allTemplatesProvider).whenData(
        (templates) => templates
            .where((template) => template.type == TemplateType.review)
            .toList(growable: false),
      );
});

class TemplatesNotifier extends AsyncNotifier<List<ReflectionTemplate>> {
  @override
  Future<List<ReflectionTemplate>> build() {
    return ref.read(dataStoreProvider).loadCustomTemplates();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  Future<void> addTemplate(ReflectionTemplate template) async {
    final current = await future;
    await ref.read(dataStoreProvider).saveTemplate(template);
    state = AsyncData(List<ReflectionTemplate>.unmodifiable([...current, template]));
  }

  Future<void> upsertTemplate(ReflectionTemplate template) async {
    final current = await future;
    final index = current.indexWhere((item) => item.id == template.id);
    final next = [...current];

    if (index == -1) {
      next.add(template);
    } else {
      next[index] = template;
    }

    await ref.read(dataStoreProvider).saveTemplate(template);
    state = AsyncData(List<ReflectionTemplate>.unmodifiable(next));
  }

  Future<void> deleteTemplate(String id) async {
    final current = await future;
    await ref.read(dataStoreProvider).deleteTemplate(id);
    state = AsyncData(
      List<ReflectionTemplate>.unmodifiable(
        current.where((item) => item.id != id),
      ),
    );
  }
}

ReflectionTemplate _cloneTemplate(ReflectionTemplate template) {
  return ReflectionTemplate(
    id: template.id,
    name: template.name,
    type: template.type,
    icon: template.icon,
    isBuiltIn: template.isBuiltIn,
    questions: List<String>.from(template.questions),
  );
}
