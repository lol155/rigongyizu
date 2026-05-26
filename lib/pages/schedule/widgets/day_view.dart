import 'package:flutter/material.dart';

import '../../../models/task.dart';
import 'day_timeline.dart';
import 'day_view_metrics.dart';
import 'day_view_sections.dart';

typedef ScheduleTaskDialogCallback = Future<void> Function(
  ScheduleTask? task, {
  int? defaultHour,
  int? defaultMinute,
});

class DayView extends StatefulWidget {
  const DayView({
    super.key,
    required this.selectedDate,
    required this.isFullscreen,
    required this.zoomLevel,
    required this.hourHeight,
    required this.startHour,
    required this.endHour,
    required this.totalHours,
    required this.tasksToday,
    required this.hasTodayReflection,
    required this.hasTodayReview,
    required this.onChangeDate,
    required this.onZoomLevelChanged,
    required this.onToggleFullscreen,
    required this.onShowTaskDialog,
    required this.onShowOverlapSheet,
    required this.onToggleTaskDone,
    required this.onPersistTasks,
  });

  final DateTime selectedDate;
  final bool isFullscreen;
  final double zoomLevel;
  final double hourHeight;
  final int startHour;
  final int endHour;
  final int totalHours;
  final List<ScheduleTask> tasksToday;
  final bool hasTodayReflection;
  final bool hasTodayReview;
  final ValueChanged<int> onChangeDate;
  final ValueChanged<double> onZoomLevelChanged;
  final VoidCallback onToggleFullscreen;
  final ScheduleTaskDialogCallback onShowTaskDialog;
  final ValueChanged<List<ScheduleTask>> onShowOverlapSheet;
  final Future<void> Function(ScheduleTask task) onToggleTaskDone;
  final Future<void> Function() onPersistTasks;

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  int get _doneCount =>
      widget.tasksToday.where((task) => task.status == TaskStatus.done).length;

  @override
  Widget build(BuildContext context) {
    final totalCount = widget.tasksToday.length;
    final freeTimeText = buildFreeTimeText(
      widget.tasksToday,
      startHour: widget.startHour,
      endHour: widget.endHour,
    );
    final freeHours = calculateFreeHours(
      widget.tasksToday,
      totalHours: widget.totalHours,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DayReflectionCard(hasTodayReflection: widget.hasTodayReflection),
        DayScheduleSummary(doneCount: _doneCount, totalCount: totalCount),
        DayViewControls(
          zoomLevel: widget.zoomLevel,
          isFullscreen: widget.isFullscreen,
          onZoomLevelChanged: widget.onZoomLevelChanged,
          onToggleFullscreen: widget.onToggleFullscreen,
        ),
        DayTimeline(
          selectedDate: widget.selectedDate,
          hourHeight: widget.hourHeight,
          startHour: widget.startHour,
          endHour: widget.endHour,
          totalHours: widget.totalHours,
          tasksToday: widget.tasksToday,
          onChangeDate: widget.onChangeDate,
          onShowTaskDialog: widget.onShowTaskDialog,
          onShowOverlapSheet: widget.onShowOverlapSheet,
          onToggleTaskDone: widget.onToggleTaskDone,
          onPersistTasks: widget.onPersistTasks,
        ),
        DayFreeTimeCard(freeTimeText: freeTimeText, freeHours: freeHours),
        DayReviewCard(hasTodayReview: widget.hasTodayReview),
      ],
    );
  }
}
