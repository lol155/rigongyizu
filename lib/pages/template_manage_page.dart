import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reflection_template.dart';
import '../providers/templates_provider.dart';
import '../utils/app_colors.dart';

class TemplateManagePage extends ConsumerStatefulWidget {
  const TemplateManagePage({super.key});

  @override
  ConsumerState<TemplateManagePage> createState() => _TemplateManagePageState();
}

class _TemplateManagePageState extends ConsumerState<TemplateManagePage> {
  @override
  Widget build(BuildContext context) {
    final builtIn = ref.watch(builtInTemplatesProvider);
    final customTemplatesAsync = ref.watch(templatesProvider);

    return customTemplatesAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('模板加载失败：$error'))),
      data: (customTemplates) {
        return Scaffold(
          backgroundColor: AppColors.background(context),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('📝 模板管理', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _showCreateDialog,
                    child: const Text('+ 新建模板'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('内置模板', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...builtIn.map((template) => _templateTile(template, canDelete: false)),
              const SizedBox(height: 16),
              const Text('自定义模板', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (customTemplates.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('还没有自定义模板', style: TextStyle(color: AppColors.text3), textAlign: TextAlign.center),
                )
              else
                ...customTemplates.map((template) => _templateTile(template, canDelete: true)),
            ],
          ),
        );
      },
    );
  }

  Widget _templateTile(ReflectionTemplate template, {bool canDelete = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(template.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(
                  '${template.questions.length}个问题 · ${template.type == TemplateType.reflection ? '反思' : '复盘'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.text2),
                ),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await ref.read(templatesProvider.notifier).deleteTemplate(template.id);
                } catch (error) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('删除模板失败：$error')),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final questions = <String>[];
    var type = TemplateType.reflection;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('创建模板', textAlign: TextAlign.center),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: '模板名称',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('类型: '),
                        ChoiceChip(
                          label: const Text('反思'),
                          selected: type == TemplateType.reflection,
                          onSelected: (_) => setDialogState(() => type = TemplateType.reflection),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('复盘'),
                          selected: type == TemplateType.review,
                          onSelected: (_) => setDialogState(() => type = TemplateType.review),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('问题列表:', style: TextStyle(fontWeight: FontWeight.w600)),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.primary),
                          onPressed: () => setDialogState(() => questions.add('')),
                        ),
                      ],
                    ),
                    ...questions.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Text('${entry.key + 1}. ', style: const TextStyle(fontWeight: FontWeight.w600)),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: '输入问题...',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onChanged: (value) => questions[entry.key] = value,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () => setDialogState(() => questions.removeAt(entry.key)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final normalizedQuestions = questions.where((question) => question.trim().isNotEmpty).toList();
                    if (name.isEmpty || normalizedQuestions.isEmpty) {
                      return;
                    }

                    try {
                      await ref.read(templatesProvider.notifier).addTemplate(
                            ReflectionTemplate(
                              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              type: type,
                              questions: normalizedQuestions,
                            ),
                          );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                    } catch (error) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('创建模板失败：$error')),
                        );
                      }
                    }
                  },
                  child: const Text('创建'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
