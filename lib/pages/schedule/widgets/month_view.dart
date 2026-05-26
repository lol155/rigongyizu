import 'package:flutter/material.dart';

import '../../../models/task.dart';
import '../../../utils/app_colors.dart';

class MonthView extends StatelessWidget {
  const MonthView({
    super.key,
    required this.selectedDate,
    required this.tasks,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  final DateTime selectedDate;
  final List<ScheduleTask> tasks;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;

  static const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  @override
  Widget build(BuildContext context) {
    final year = selectedDate.year;
    final month = selectedDate.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday;
    final isDark = AppColors.isDark(context);
    final cells = <Widget>[];

    for (var index = 1; index < startWeekday; index++) {
      cells.add(const SizedBox());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isToday = _isToday(date);
      final isPast = _isPast(date);
      final dayTasks = tasks.where((task) {
        return task.date.year == date.year &&
            task.date.month == date.month &&
            task.date.day == date.day;
      }).toList();
      final doneCount = dayTasks
          .where((task) => task.status == TaskStatus.done)
          .length;
      final hasTasks = dayTasks.isNotEmpty;
      final allDone = hasTasks && doneCount == dayTasks.length;

      // Cell colors based on state
      final Color cellBg;
      final Color dayTextColor;
      final Color badgeBg;
      final Color badgeFg;

      if (isToday) {
        cellBg = AppColors.primary;
        dayTextColor = Colors.white;
        badgeBg = Colors.white.withValues(alpha: 0.3);
        badgeFg = Colors.white;
      } else if (isPast) {
        if (allDone) {
          // Past, all tasks done — soft green archival
          cellBg = isDark
              ? AppColors.success.withValues(alpha: 0.15)
              : const Color(0xFFECFDF5);
          dayTextColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534);
          badgeBg = AppColors.success.withValues(alpha: isDark ? 0.25 : 0.2);
          badgeFg = isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534);
        } else if (hasTasks) {
          // Past, has incomplete tasks — muted warm
          cellBg = isDark
              ? const Color(0xFF334155)
              : const Color(0xFFF8FAFC);
          dayTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
          badgeBg = AppColors.inactiveBg(context);
          badgeFg = isDark ? const Color(0xFF94A3B8) : AppColors.text2;
        } else {
          // Past, no tasks — very muted
          cellBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAFA);
          dayTextColor = isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1);
          badgeBg = Colors.transparent;
          badgeFg = Colors.transparent;
        }
      } else {
        // Future dates
        if (hasTasks && !allDone) {
          // Future with pending tasks — light orange highlight to draw attention
          cellBg = isDark
              ? AppColors.primary.withValues(alpha: 0.12)
              : const Color(0xFFFFF7ED);
          dayTextColor = isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C);
          badgeBg = AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15);
          badgeFg = isDark ? const Color(0xFFFDBA74) : AppColors.primary;
        } else if (allDone) {
          // Future, all done — green tint
          cellBg = isDark
              ? AppColors.success.withValues(alpha: 0.12)
              : const Color(0xFFECFDF5);
          dayTextColor = isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534);
          badgeBg = AppColors.success.withValues(alpha: isDark ? 0.25 : 0.2);
          badgeFg = isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534);
        } else {
          // Future, no tasks — clean white
          cellBg = isDark ? const Color(0xFF1E293B) : Colors.white;
          dayTextColor = isDark ? const Color(0xFFE2E8F0) : Colors.black;
          badgeBg = Colors.transparent;
          badgeFg = Colors.transparent;
        }
      }

      cells.add(
        GestureDetector(
          onTap: () => onSelectDate(date),
          child: Container(
            decoration: BoxDecoration(
              color: cellBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    color: dayTextColor,
                  ),
                ),
                if (hasTasks)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$doneCount/${dayTasks.length}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: badgeFg,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: onPreviousMonth,
              ),
              Text(
                '$year年$month月',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: onNextMonth,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: _weekdays.map((weekday) {
              return Expanded(
                child: Center(
                  child: Text(
                    weekday,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.text3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 1.0,
            children: cells,
          ),
        ),
      ],
    );
  }
}
