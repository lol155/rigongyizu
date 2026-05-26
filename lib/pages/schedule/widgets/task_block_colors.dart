import 'package:flutter/material.dart';

import '../../../models/task.dart';
import '../../../utils/app_colors.dart';

class TaskBlockColors {
  static Color background(int color, [TaskStatus status = TaskStatus.pending]) {
    final base = Color(AppColors.taskBlockBackgroundValues[color] ?? AppColors.taskBlockFallbackBg.toARGB32());
    switch (status) {
      case TaskStatus.pending:
      case TaskStatus.done:
        return base;
      case TaskStatus.postponed:
        return Color.alphaBlend(
          AppColors.warning.withValues(alpha: 0.12),
          base,
        );
      case TaskStatus.cancelled:
        return AppColors.taskBlockCancelledBg;
    }
  }

  static Color text(int color, [TaskStatus status = TaskStatus.pending]) {
    final base = Color(AppColors.taskBlockTextValues[color] ?? AppColors.taskBlockFallbackText.toARGB32());
    switch (status) {
      case TaskStatus.pending:
      case TaskStatus.done:
        return base;
      case TaskStatus.postponed:
        return Color.alphaBlend(
          AppColors.warning.withValues(alpha: 0.35),
          base,
        );
      case TaskStatus.cancelled:
        return AppColors.text2;
    }
  }

  static Color accent(int color, [TaskStatus status = TaskStatus.pending]) {
    switch (status) {
      case TaskStatus.pending:
      case TaskStatus.done:
        return Color(color);
      case TaskStatus.postponed:
        return AppColors.warning;
      case TaskStatus.cancelled:
        return AppColors.text3;
    }
  }

  static double opacity(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 1;
      case TaskStatus.done:
        return 0.45;
      case TaskStatus.postponed:
        return 0.88;
      case TaskStatus.cancelled:
        return 0.6;
    }
  }

  static bool usesLineThrough(TaskStatus status) {
    return status == TaskStatus.done || status == TaskStatus.cancelled;
  }

  static String? statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
      case TaskStatus.done:
        return null;
      case TaskStatus.postponed:
        return '已推迟';
      case TaskStatus.cancelled:
        return '已取消';
    }
  }

  static IconData? statusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
      case TaskStatus.done:
        return null;
      case TaskStatus.postponed:
        return Icons.schedule;
      case TaskStatus.cancelled:
        return Icons.block;
    }
  }

  static Color statusBadgeBackground(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
      case TaskStatus.done:
        return Colors.transparent;
      case TaskStatus.postponed:
        return AppColors.warning.withValues(alpha: 0.14);
      case TaskStatus.cancelled:
        return AppColors.text3.withValues(alpha: 0.18);
    }
  }

  static Color statusBadgeForeground(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
      case TaskStatus.done:
        return Colors.transparent;
      case TaskStatus.postponed:
        return AppColors.warning;
      case TaskStatus.cancelled:
        return AppColors.text2;
    }
  }
}
