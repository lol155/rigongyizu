import 'package:flutter/material.dart';

import '../../../models/task.dart';
import '../../../utils/app_colors.dart';
import 'task_block_colors.dart';

class OverlapSheet {
  static Future<void> show(
    BuildContext context, {
    required List<ScheduleTask> tasks,
    required ValueChanged<ScheduleTask> onTaskTap,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
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
              const Text(
                '该时段的任务',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...tasks.map((task) => _OverlapTaskItem(task: task, onTap: () {
                    Navigator.pop(ctx);
                    onTaskTap(task);
                  })),
            ],
          ),
        );
      },
    );
  }
}

class _OverlapTaskItem extends StatelessWidget {
  const _OverlapTaskItem({required this.task, required this.onTap});

  final ScheduleTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusLabel = TaskBlockColors.statusLabel(task.status);
    final statusIcon = TaskBlockColors.statusIcon(task.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: TaskBlockColors.background(task.color, task.status),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: TaskBlockColors.accent(task.color, task.status),
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TaskBlockColors.text(task.color, task.status),
                      decoration: TaskBlockColors.usesLineThrough(task.status)
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${task.startTime.hour.toString().padLeft(2, '0')}:${task.startTime.minute.toString().padLeft(2, '0')}-${task.endTime.hour.toString().padLeft(2, '0')}:${task.endTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: TaskBlockColors.text(
                        task.color,
                        task.status,
                      ).withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (statusLabel != null && statusIcon != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TaskBlockColors.statusBadgeBackground(task.status),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 12,
                      color: TaskBlockColors.statusBadgeForeground(task.status),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: TaskBlockColors.statusBadgeForeground(
                          task.status,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, color: AppColors.text3),
          ],
        ),
      ),
    );
  }
}
