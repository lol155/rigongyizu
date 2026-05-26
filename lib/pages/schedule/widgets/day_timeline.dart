import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/task.dart';
import '../../../utils/app_colors.dart';
import 'now_line.dart';
import 'task_block.dart';

class DayTimeline extends StatefulWidget {
  const DayTimeline({
    super.key,
    required this.selectedDate,
    required this.hourHeight,
    required this.startHour,
    required this.endHour,
    required this.totalHours,
    required this.tasksToday,
    required this.onChangeDate,
    required this.onShowTaskDialog,
    required this.onShowOverlapSheet,
    required this.onToggleTaskDone,
    required this.onPersistTasks,
  });

  final DateTime selectedDate;
  final double hourHeight;
  final int startHour;
  final int endHour;
  final int totalHours;
  final List<ScheduleTask> tasksToday;
  final ValueChanged<int> onChangeDate;
  final Future<void> Function(
    ScheduleTask? task, {
    int? defaultHour,
    int? defaultMinute,
  }) onShowTaskDialog;
  final ValueChanged<List<ScheduleTask>> onShowOverlapSheet;
  final Future<void> Function(ScheduleTask task) onToggleTaskDone;
  final Future<void> Function() onPersistTasks;

  @override
  State<DayTimeline> createState() => _DayTimelineState();
}

class _DayTimelineState extends State<DayTimeline> {
  double _swipeOffset = 0;

  @override
  void didUpdateWidget(covariant DayTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldDate = DateUtils.dateOnly(oldWidget.selectedDate);
    final newDate = DateUtils.dateOnly(widget.selectedDate);
    if (oldDate != newDate) {
      _swipeOffset = 0;
    }
  }

  void _handleSwipeUpdate(DragUpdateDetails details) {
    setState(() {
      _swipeOffset = math.max(
        -120.0,
        math.min(120.0, _swipeOffset + (details.primaryDelta ?? 0)),
      );
    });
  }

  void _handleSwipeEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldSwitch = _swipeOffset.abs() > 48 || velocity.abs() > 300;

    if (shouldSwitch) {
      widget.onChangeDate(_swipeOffset < 0 ? 1 : -1);
    }

    setState(() {
      _swipeOffset = 0;
    });
  }

  List<List<ScheduleTask>> _groupByOverlap(List<ScheduleTask> tasks) {
    if (tasks.isEmpty) {
      return const [];
    }

    final sorted = List<ScheduleTask>.from(tasks)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Use interval-based merging: collect all time intervals,
    // find connected components (overlapping chains).
    final groups = <List<ScheduleTask>>[];

    for (final task in sorted) {
      final taskStart = task.startTime.hour * 60 + task.startTime.minute;
      final taskEnd = taskStart + task.durationMinutes;

      // Find a group whose ANY member overlaps with this task
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
        // No overlap with any existing group → new group
        groups.add([task]);
      } else {
        // Check if this task also overlaps with any LATER groups → merge them
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

  void _refreshTimeline() {
    setState(() {});
  }

  List<Widget> _buildTaskBlocks(List<List<ScheduleTask>> overlapGroups) {
    final widgets = <Widget>[];

    for (final group in overlapGroups) {
      const maxVisible = 3;
      final visible = group.take(maxVisible).toList();
      final overflow = group.length - maxVisible;
      final columnCount = visible.length;

      for (var index = 0; index < visible.length; index++) {
        final task = visible[index];
        final startMinute =
            task.startTime.hour * 60 + task.startTime.minute - widget.startHour * 60;
        final top = startMinute / 60.0 * widget.hourHeight;
        final height = task.durationMinutes / 60.0 * widget.hourHeight;

        widgets.add(
          TaskBlock(
            key: ValueKey(task.id),
            task: task,
            top: top,
            height: height,
            leftPos: 44.0,
            columnIndex: index,
            columnCount: columnCount,
            hourHeight: widget.hourHeight,
            startHour: widget.startHour,
            endHour: widget.endHour,
            onEditTask: (updatedTask) => widget.onShowTaskDialog(updatedTask),
            onToggleDone: (updatedTask) => widget.onToggleTaskDone(updatedTask),
            onTaskChanged: _refreshTimeline,
            onPersist: widget.onPersistTasks,
          ),
        );
      }

      if (overflow > 0) {
        // Place the "+N more" button below all visible task blocks in this group
        final maxEndMinute = visible.fold<int>(0, (max, t) {
          final end = t.startTime.hour * 60 + t.startTime.minute + t.durationMinutes - widget.startHour * 60;
          return end > max ? end : max;
        });
        final belowY = maxEndMinute / 60.0 * widget.hourHeight;

        widgets.add(
          Positioned(
            top: belowY + 2,
            left: 48.0,
            child: GestureDetector(
              onTap: () => widget.onShowOverlapSheet(group),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.inactiveBg(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+$overflow 更多',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.text2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final gridHeight = widget.totalHours * widget.hourHeight;
    final overlapGroups = _groupByOverlap(widget.tasksToday);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      width: double.maxFinite,
      height: gridHeight,
      child: GestureDetector(
        onHorizontalDragUpdate: _handleSwipeUpdate,
        onHorizontalDragEnd: _handleSwipeEnd,
        onTapUp: (details) {
          final y = details.localPosition.dy;
          if (y < 0 || y > gridHeight) {
            return;
          }

          final hourPosition = y / widget.hourHeight;
          final hour = widget.startHour + hourPosition.floor();
          final minute = ((hourPosition - hourPosition.floor()) * 60).round();
          widget.onShowTaskDialog(
            null,
            defaultHour: hour,
            defaultMinute: (minute ~/ 15) * 15,
          );
        },
        child: Transform.translate(
          offset: Offset(_swipeOffset * 0.12, 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ...List.generate(widget.totalHours + 1, (index) {
                final hour = widget.startHour + index;
                return Positioned(
                  top: index * widget.hourHeight,
                  left: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 40,
                        child: index < widget.totalHours
                            ? Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  '${hour.toString().padLeft(2, '0')}:00',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.text3,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      Expanded(
                        child: Container(
                          height: index < widget.totalHours ? widget.hourHeight : 0,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.shade300,
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              NowLine(
                selectedDate: widget.selectedDate,
                startHour: widget.startHour,
                totalHours: widget.totalHours,
                hourHeight: widget.hourHeight,
              ),
              ..._buildTaskBlocks(overlapGroups),
              if (widget.tasksToday.isEmpty)
                Positioned(
                  top: widget.hourHeight * 2,
                  left: 44,
                  right: 16,
                  child: Center(
                    child: Text(
                      '点击时间段添加任务',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.text3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
