import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/goal.dart';
import '../../../providers/goals_provider.dart';
import '../../../utils/app_colors.dart';

class AddSubGoalDialog {
  static Future<void> show(
    BuildContext context, {
    required WidgetRef ref,
    required Goal parentGoal,
  }) {
    final titleController = TextEditingController();

    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('添加子目标', textAlign: TextAlign.center),
          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: '子目标名称',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
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
                try {
                  await ref.read(goalsProvider.notifier).addGoal(
                        Goal(
                          id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          parentId: parentGoal.id,
                          color: parentGoal.color,
                        ),
                      );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                } catch (error) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('添加子目标失败：$error')),
                    );
                  }
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }
}
