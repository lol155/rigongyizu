import 'package:flutter/material.dart';

import '../../../models/task.dart';
import '../../../utils/app_colors.dart';

const presetTaskDurations = [15, 30, 60, 90, 120];
const taskDialogColors = AppColors.taskDialogColorValues;

String taskStatusLabel(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return '待办';
    case TaskStatus.done:
      return '已完成';
    case TaskStatus.postponed:
      return '已推迟';
    case TaskStatus.cancelled:
      return '已取消';
  }
}

IconData taskStatusIcon(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return Icons.radio_button_unchecked;
    case TaskStatus.done:
      return Icons.check_circle;
    case TaskStatus.postponed:
      return Icons.schedule;
    case TaskStatus.cancelled:
      return Icons.cancel;
  }
}

Color taskStatusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return AppColors.blue;
    case TaskStatus.done:
      return AppColors.success;
    case TaskStatus.postponed:
      return AppColors.warning;
    case TaskStatus.cancelled:
      return AppColors.text2;
  }
}
