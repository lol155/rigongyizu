import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/task.dart';
import '../../../utils/app_colors.dart';
import 'task_block_colors.dart';

class WeekView extends StatefulWidget {
  const WeekView({
    super.key,
    required this.selectedDate,
    required this.tasks,
    required this.startHour,
    required this.totalHours,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onSelectDay,
    required this.onAddTask,
    required this.onOpenTask,
    required this.onToggleTaskDone,
  });

  final DateTime selectedDate;
  final List<ScheduleTask> tasks;
  final int startHour;
  final int totalHours;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final ValueChanged<DateTime> onSelectDay;
  final Future<void> Function(DateTime date, int hour) onAddTask;
  final Future<void> Function(DateTime date, ScheduleTask task) onOpenTask;
  final Future<void> Function(ScheduleTask task) onToggleTaskDone;

  static const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];
  static const double _timeLabelWidth = 36.0;

  // Zoom presets: (dayWidth, hourHeight)
  static const _zoomLevels = [
    (60.0, 24.0),
    (80.0, 36.0),
    (100.0, 48.0),
    (130.0, 60.0),
    (180.0, 72.0),
  ];
  static const _defaultZoomIndex = 2;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  int _zoomIndex = WeekView._defaultZoomIndex;

  double get _dayWidth => WeekView._zoomLevels[_zoomIndex].$1;
  double get _hourHeight => WeekView._zoomLevels[_zoomIndex].$2;

  late final ScrollController _gridHorizontal;
  late final ScrollController _headerHorizontal;

  @override
  void initState() {
    super.initState();
    _gridHorizontal = ScrollController();
    _headerHorizontal = ScrollController();
    _gridHorizontal.addListener(_syncHeaderToGrid);
  }

  @override
  void dispose() {
    _gridHorizontal.removeListener(_syncHeaderToGrid);
    _gridHorizontal.dispose();
    _headerHorizontal.dispose();
    super.dispose();
  }

  void _syncHeaderToGrid() {
    if (_headerHorizontal.hasClients && _gridHorizontal.hasClients) {
      final offset = _gridHorizontal.offset;
      if ((_headerHorizontal.offset - offset).abs() > 1) {
        _headerHorizontal.jumpTo(offset.clamp(
          0.0,
          _headerHorizontal.position.maxScrollExtent,
        ));
      }
    }
  }

  @override
  void didUpdateWidget(covariant WeekView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_gridHorizontal.hasClients) _gridHorizontal.jumpTo(0);
        if (_headerHorizontal.hasClients) _headerHorizontal.jumpTo(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final monday = widget.selectedDate.subtract(
      Duration(days: widget.selectedDate.weekday - 1),
    );
    final days =
        List.generate(7, (index) => monday.add(Duration(days: index)));
    final weekEnd = monday.add(const Duration(days: 6));
    final gridHeight = widget.totalHours * _hourHeight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header: week navigation + zoom controls
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: widget.onPreviousWeek,
              ),
              Text(
                '${monday.month}月${monday.day}日 - ${weekEnd.month}月${weekEnd.day}日',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: widget.onNextWeek,
              ),
            ],
          ),
        ),
        // Zoom level buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('缩放 ', style: TextStyle(fontSize: 11, color: AppColors.text3)),
              ...WeekView._zoomLevels.asMap().entries.map((entry) {
                final index = entry.key;
                final isActive = index == _zoomIndex;
                const labels = ['XS', 'S', 'M', 'L', 'XL'];
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _zoomIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.inactiveBg(context),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : AppColors.text2,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        // Day headers row — synced with grid horizontal scroll
        SizedBox(
          height: 40,
          child: Row(
            children: [
              const SizedBox(width: WeekView._timeLabelWidth),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  controller: _headerHorizontal,
                  physics: const ClampingScrollPhysics(),
                  children: days.asMap().entries.map((entry) {
                    final index = entry.key;
                    final date = entry.value;
                    final isToday = widget._isToday(date);

                    return SizedBox(
                      width: _dayWidth,
                      child: GestureDetector(
                        onTap: () => widget.onSelectDay(date),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                WeekView._weekdays[index],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isToday ? Colors.white : AppColors.text3,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isToday ? Colors.white : AppColors.text2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        // Grid: time labels + day columns with tasks
        SizedBox(
          height: gridHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed time labels
              SizedBox(
                width: WeekView._timeLabelWidth,
                child: Column(
                  children: List.generate(widget.totalHours, (index) {
                    return SizedBox(
                      height: _hourHeight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '${widget.startHour + index}'.padLeft(2, '0'),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: _hourHeight < 30 ? 7 : 10,
                            color: AppColors.text3,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Scrollable day columns
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  controller: _gridHorizontal,
                  physics: const ClampingScrollPhysics(),
                  children: days.map((date) {
                    return _DayColumn(
                      date: date,
                      dayWidth: _dayWidth,
                      startHour: widget.startHour,
                      totalHours: widget.totalHours,
                      hourHeight: _hourHeight,
                      tasks: widget.tasks,
                      isToday: widget._isToday(date),
                      onTapEmpty: (hour) => widget.onAddTask(date, hour),
                      onTapTask: (task) => widget.onOpenTask(date, task),
                      onToggleDone: widget.onToggleTaskDone,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Groups tasks by overlap — same algorithm as day_timeline.dart
List<List<ScheduleTask>> _groupByOverlap(List<ScheduleTask> tasks, int startHour) {
  if (tasks.isEmpty) return const [];

  final sorted = List<ScheduleTask>.from(tasks)
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  final groups = <List<ScheduleTask>>[];

  for (final task in sorted) {
    final taskStart = task.startTime.hour * 60 + task.startTime.minute;
    final taskEnd = taskStart + task.durationMinutes;

    var targetGroupIndex = -1;
    for (var gi = 0; gi < groups.length; gi++) {
      final group = groups[gi];
      final overlaps = group.any((existing) {
        final existStart =
            existing.startTime.hour * 60 + existing.startTime.minute;
        final existEnd = existStart + existing.durationMinutes;
        return taskStart < existEnd && taskEnd > existStart;
      });
      if (overlaps) {
        targetGroupIndex = gi;
        break;
      }
    }

    if (targetGroupIndex == -1) {
      groups.add([task]);
    } else {
      final mergedTasks = <ScheduleTask>[task];
      for (var gi = groups.length - 1; gi > targetGroupIndex; gi--) {
        final group = groups[gi];
        final overlaps = group.any((existing) {
          final existStart =
              existing.startTime.hour * 60 + existing.startTime.minute;
          final existEnd = existStart + existing.durationMinutes;
          return taskStart < existEnd && taskEnd > existStart;
        });
        if (overlaps) {
          mergedTasks.addAll(group);
          groups.removeAt(gi);
        }
      }
      groups[targetGroupIndex].addAll(mergedTasks);
    }
  }

  return groups;
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.date,
    required this.dayWidth,
    required this.startHour,
    required this.totalHours,
    required this.hourHeight,
    required this.tasks,
    required this.isToday,
    required this.onTapEmpty,
    required this.onTapTask,
    required this.onToggleDone,
  });

  final DateTime date;
  final double dayWidth;
  final int startHour;
  final int totalHours;
  final double hourHeight;
  final List<ScheduleTask> tasks;
  final bool isToday;
  final ValueChanged<int> onTapEmpty;
  final ValueChanged<ScheduleTask> onTapTask;
  final Future<void> Function(ScheduleTask) onToggleDone;

  double get _columnHeight => totalHours * hourHeight;

  List<ScheduleTask> get _dayTasks => tasks.where((task) {
    return task.date.year == date.year &&
        task.date.month == date.month &&
        task.date.day == date.day;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final dayTasks = _dayTasks;
    final overlapGroups = _groupByOverlap(dayTasks, startHour);

    return SizedBox(
      width: dayWidth,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.inactiveBg(context),
            width: 0.5,
          ),
          color: isToday
              ? AppColors.todayHighlight(context)
              : AppColors.cardBackground(context),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Hour grid lines
            ...List.generate(totalHours, (index) {
              return Positioned(
                top: index * hourHeight,
                left: 0,
                right: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => onTapEmpty(startHour + index),
                  child: Container(
                    height: hourHeight,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.inactiveBg(context),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            // Task blocks with overlap resolution
            ..._buildTaskBlocks(overlapGroups),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTaskBlocks(List<List<ScheduleTask>> groups) {
    final widgets = <Widget>[];

    for (final group in groups) {
      final maxVisible = math.min(3, dayWidth < 80 ? 2 : 3);
      final visible = group.take(maxVisible).toList();
      final overflow = group.length - maxVisible;
      final columnCount = visible.length;

      for (var colIndex = 0; colIndex < visible.length; colIndex++) {
        final task = visible[colIndex];
        final startMinute =
            task.startTime.hour * 60 + task.startTime.minute - startHour * 60;
        final top = startMinute / 60.0 * hourHeight;
        final height = task.durationMinutes / 60.0 * hourHeight;

        if (top < 0 || top >= _columnHeight) continue;

        final clampedHeight = height.clamp(14.0, _columnHeight - top);
        final colWidth = (dayWidth - 4) / columnCount;
        final left = 2.0 + colIndex * colWidth;

        widgets.add(
          Positioned(
            top: top,
            left: left,
            width: colWidth - 1,
            height: clampedHeight,
            child: GestureDetector(
              onTap: () => onTapTask(task),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  color: TaskBlockColors.background(task.color, task.status),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: TaskBlockColors.accent(task.color, task.status)
                        .withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with checkbox
                    if (clampedHeight >= 14)
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => onToggleDone(task),
                            child: Icon(
                              task.status == TaskStatus.done
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 8,
                              color: TaskBlockColors.accent(task.color, task.status),
                            ),
                          ),
                          const SizedBox(width: 1),
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: colWidth < 50 ? 6 : 7,
                                fontWeight: FontWeight.w600,
                                color: TaskBlockColors.text(task.color, task.status),
                                decoration: TaskBlockColors.usesLineThrough(task.status)
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    // Time detail
                    if (clampedHeight > 24 && colWidth >= 50)
                      Padding(
                        padding: const EdgeInsets.only(left: 9, top: 1),
                        child: Text(
                          '${task.startTime.hour.toString().padLeft(2, '0')}:${task.startTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 6,
                            color: TaskBlockColors.text(task.color, task.status)
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // "+N more" badge
      if (overflow > 0) {
        final maxEndMinute = visible.fold<int>(0, (max, t) {
          final end = t.startTime.hour * 60 + t.startTime.minute +
              t.durationMinutes -
              startHour * 60;
          return end > max ? end : max;
        });
        final belowY = maxEndMinute / 60.0 * hourHeight;

        widgets.add(
          Positioned(
            top: belowY + 2,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+$overflow',
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
