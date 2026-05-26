import 'package:flutter/material.dart';

import '../../../models/goal.dart';
import '../../../models/task.dart';
import 'task_dialog_form.dart';

class TaskDialogData {
  const TaskDialogData({
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    required this.goalId,
    required this.status,
    required this.color,
    required this.notes,
  });

  final String title;
  final DateTime startTime;
  final int durationMinutes;
  final String? goalId;
  final TaskStatus status;
  final int color;
  final String notes;
}

class TaskDialogResult {
  const TaskDialogResult._({this.data, this.delete = false});

  const TaskDialogResult.save(TaskDialogData data)
    : this._(data: data, delete: false);

  const TaskDialogResult.delete() : this._(delete: true);

  final TaskDialogData? data;
  final bool delete;
}

class TaskDialog {
  static Future<TaskDialogResult?> show(
    BuildContext context, {
    required DateTime selectedDate,
    required List<Goal> goals,
    ScheduleTask? task,
    int? defaultHour,
    int? defaultMinute,
  }) {
    return showDialog<TaskDialogResult>(
      context: context,
      builder: (_) => TaskDialogForm(
        selectedDate: selectedDate,
        goals: goals,
        initialHour: task?.startTime.hour ?? defaultHour ?? 9,
        initialMinute: task?.startTime.minute ?? defaultMinute ?? 0,
        task: task,
      ),
    );
  }
}
