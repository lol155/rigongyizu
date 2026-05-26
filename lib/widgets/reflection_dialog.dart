import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_entry.dart';
import '../models/reflection_template.dart';
import '../providers/journals_provider.dart';
import '../providers/templates_provider.dart';
import '../utils/app_colors.dart';

class ReflectionDialog {
  static final List<ReflectionTemplate> builtInTemplates = [
    ReflectionTemplate(
      id: 'daily_reflection',
      name: '每日反思',
      type: TemplateType.reflection,
      icon: '☀️',
      isBuiltIn: true,
      questions: ['今天最重要的3件事是什么？', '昨天有什么值得保持的？', '今天的心情如何？', '一句话总结今天的目标'],
    ),
    ReflectionTemplate(
      id: 'weekly_review',
      name: '每周回顾',
      type: TemplateType.reflection,
      icon: '📋',
      isBuiltIn: true,
      questions: ['本周最大的成就是什么？', '本周最大的收获是什么？', '有什么需要改进的？', '下周最重要的目标是什么？'],
    ),
    ReflectionTemplate(
      id: 'quick_review',
      name: '快速复盘',
      type: TemplateType.review,
      icon: '⚡',
      isBuiltIn: true,
      questions: ['一句话总结今天'],
    ),
    ReflectionTemplate(
      id: 'detail_review',
      name: '详细复盘',
      type: TemplateType.review,
      icon: '🔍',
      isBuiltIn: true,
      questions: ['今天做得好的是什么？', '需要改进的是什么？', '时间分配合理吗？', '明天要怎么调整？'],
    ),
    ReflectionTemplate(
      id: 'kpt_review',
      name: 'KPT复盘',
      type: TemplateType.review,
      icon: '🧠',
      isBuiltIn: true,
      questions: ['Keep（保持）：什么做得好，值得继续？', 'Problem（问题）：遇到了什么问题？', 'Try（尝试）：接下来打算怎么改？'],
    ),
  ];

  static Future<void> showReflection(BuildContext context) {
    return _showTemplatePicker(context, reflectionTemplatesProvider);
  }

  static Future<void> showReview(BuildContext context) {
    return _showTemplatePicker(context, reviewTemplatesProvider);
  }

  static Future<void> _showTemplatePicker(
    BuildContext context,
    ProviderListenable<AsyncValue<List<ReflectionTemplate>>> templatesSource,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final templatesAsync = ref.watch(templatesSource);

          return templatesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('模板加载失败：$error', textAlign: TextAlign.center),
            ),
            data: (templates) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  ...templates.map((template) => _templateItem(ctx, template)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _templateItem(BuildContext sheetCtx, ReflectionTemplate template) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(sheetCtx);
        _showFillForm(sheetCtx, template);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(sheetCtx),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
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
                  const SizedBox(height: 2),
                  Text('${template.questions.length}个问题', style: const TextStyle(fontSize: 12, color: AppColors.text2)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.text3),
          ],
        ),
      ),
    );
  }

  static Future<void> _showFillForm(BuildContext context, ReflectionTemplate template) async {
    final controllers = List.generate(template.questions.length, (_) => TextEditingController());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                       height: 4,
                       margin: const EdgeInsets.only(bottom: 12),
                       decoration: const BoxDecoration(
                         color: AppColors.borderSubtle,
                         borderRadius: BorderRadius.all(Radius.circular(2)),
                       ),
                     ),
                    Text('${template.icon} ${template.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    ...template.questions.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${entry.key + 1}. ${entry.value}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: controllers[entry.key],
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: '写下你的想法...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(ctx);
                          final answers = controllers.map((controller) => controller.text.trim()).toList();
                          if (answers.every((answer) => answer.isEmpty)) {
                            return;
                          }

                          final content = template.questions.asMap().entries
                              .map((entry) => '${entry.key + 1}. ${entry.value}\n${answers[entry.key]}')
                              .join('\n\n');

                          try {
                            await ref.read(journalsProvider.notifier).addJournal(
                                  JournalEntry(
                                    id: 'journal_${DateTime.now().millisecondsSinceEpoch}',
                                    type: template.type == TemplateType.reflection
                                        ? JournalType.reflection
                                        : JournalType.review,
                                    templateId: template.id,
                                    templateName: template.name,
                                    date: DateTime.now(),
                                    time: DateTime.now(),
                                    content: content,
                                  ),
                                );

                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                          } catch (error) {
                            messenger.showSnackBar(
                              SnackBar(content: Text('保存记录失败：$error')),
                            );
                          }
                        },
                        child: const Text('保存', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
