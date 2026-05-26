import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/goal.dart';
import '../../../providers/goals_provider.dart';
import '../../../utils/app_colors.dart';

class AddGoalDialog {
  static Future<void> show(
    BuildContext context, {
    required WidgetRef ref,
    required int goalColor,
    Goal? existingGoal,
    Future<void> Function()? onDelete,
  }) {
    final titleController = TextEditingController(text: existingGoal?.title ?? '');
    DateTime? deadline = existingGoal?.deadline;
    int priority = existingGoal?.priority ?? 1;
    final isEditing = existingGoal != null;

    return showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(isEditing ? '编辑目标' : '新建目标', textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEditing) ...[
                    Text(
                      '可修改目标名称、截止日期和优先级',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: '目标名称',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('截止日期: '),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate:
                                deadline ?? DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() => deadline = picked);
                          }
                        },
                        child: Text(
                          deadline != null
                              ? '${deadline!.year}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}'
                              : '选择日期',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('优先级: '),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: priority,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 3, child: Text('🔥 高')),
                            DropdownMenuItem(value: 2, child: Text('📌 中')),
                            DropdownMenuItem(value: 1, child: Text('📎 低')),
                          ],
                          onChanged: (value) {
                            setDialogState(() => priority = value ?? 1);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                if (isEditing && onDelete != null)
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: ctx,
                        builder: (confirmCtx) => AlertDialog(
                          title: const Text('确认删除目标'),
                          content: const Text('删除后将同时移除该目标及其所有子目标，且无法恢复。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(confirmCtx, false),
                              child: const Text('取消'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                              onPressed: () => Navigator.pop(confirmCtx, true),
                              child: const Text('删除'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) {
                        return;
                      }

                      try {
                        await onDelete();
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                      } catch (error) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('删除目标失败：$error')),
                          );
                        }
                      }
                    },
                    child: const Text(
                      '删除',
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) {
                      return;
                    }
                    final goal = Goal(
                      id: existingGoal?.id ?? 'goal_${DateTime.now().millisecondsSinceEpoch}',
                      title: title,
                      description: existingGoal?.description ?? '',
                      deadline: deadline,
                      priority: priority,
                      color: existingGoal?.color ?? goalColor,
                      status: existingGoal?.status ?? GoalStatus.inProgress,
                      parentId: existingGoal?.parentId,
                      progressPct: existingGoal?.progressPct ?? 0.0,
                    );
                    try {
                      await ref.read(goalsProvider.notifier).upsertGoal(goal);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                    } catch (error) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('${isEditing ? '保存目标' : '创建目标'}失败：$error')),
                        );
                      }
                    }
                  },
                  child: Text(isEditing ? '保存' : '创建'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
