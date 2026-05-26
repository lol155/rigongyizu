import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/goal.dart';
import '../../../models/task.dart';
import '../../../providers/tasks_provider.dart';
import '../../../utils/app_colors.dart';

class AddToScheduleDialog {
  static Future<void> show(
    BuildContext context, {
    required WidgetRef ref,
    required Goal goal,
  }) {
    var hour = 9;
    var dur = 60;

    return showDialog(
      context: context,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (dCtx, setDialogState) {
            return AlertDialog(
              title: const Text('添加到今日日程'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  const Text('开始时间:', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [7, 8, 9, 10, 11, 14, 16, 19, 21]
                        .map(
                          (value) => GestureDetector(
                            onTap: () => setDialogState(() => hour = value),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: hour == value
                                    ? Color(goal.color)
                                    : AppColors.inactiveBg(context),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$value:00',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: hour == value ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                  const Text('时长:', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [30, 60, 90, 120]
                        .map(
                          (minutes) => GestureDetector(
                            onTap: () => setDialogState(() => dur = minutes),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: dur == minutes
                                    ? Color(goal.color)
                                    : AppColors.inactiveBg(context),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                minutes >= 60 ? '${minutes ~/ 60}h' : '${minutes}m',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: dur == minutes ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx),
                  child: const Text('取消'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Color(goal.color)),
                  onPressed: () async {
                    final now = DateTime.now();
                    final task = ScheduleTask(
                      id: 't_${DateTime.now().millisecondsSinceEpoch}',
                      title: goal.title,
                      date: now,
                      startTime: DateTime(now.year, now.month, now.day, hour, 0),
                      durationMinutes: dur,
                      goalId: goal.id,
                      color: goal.color,
                    );
                    try {
                      await ref.read(tasksProvider.notifier).addTask(task);
                      if (!context.mounted || !dCtx.mounted) {
                        return;
                      }
                      Navigator.pop(dCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已添加「${goal.title}」到今天 $hour:00')),
                      );
                    } catch (error) {
                      if (dCtx.mounted) {
                        ScaffoldMessenger.of(dCtx).showSnackBar(
                          SnackBar(content: Text('添加到日程失败：$error')),
                        );
                      }
                    }
                  },
                  child: const Text('确认添加'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
