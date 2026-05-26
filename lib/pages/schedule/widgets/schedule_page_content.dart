import 'package:flutter/material.dart';

import '../../../models/task.dart';
import 'day_view.dart';
import 'month_view.dart';
import 'week_view.dart';

class SchedulePageViewState {
  const SchedulePageViewState({
    required this.currentView,
    required this.selectedDate,
    required this.isFullscreen,
    required this.zoomLevel,
    required this.hourHeight,
    required this.startHour,
    required this.endHour,
    required this.totalHours,
    required this.tasks,
    required this.tasksToday,
    required this.hasTodayReflection,
    required this.hasTodayReview,
    required this.formattedDate,
    required this.totalCount,
  });

  final int currentView;
  final DateTime selectedDate;
  final bool isFullscreen;
  final double zoomLevel;
  final double hourHeight;
  final int startHour;
  final int endHour;
  final int totalHours;
  final List<ScheduleTask> tasks;
  final List<ScheduleTask> tasksToday;
  final bool hasTodayReflection;
  final bool hasTodayReview;
  final String formattedDate;
  final int totalCount;
}

class SchedulePageActions {
  const SchedulePageActions({
    required this.onChangeDate,
    required this.onViewChanged,
    required this.onZoomLevelChanged,
    required this.onToggleFullscreen,
    required this.onShowTaskDialog,
    required this.onShowOverlapSheet,
    required this.onToggleTaskDone,
    required this.onPersistTasks,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onSelectDayFromWeek,
    required this.onAddTaskFromWeek,
    required this.onOpenTaskFromWeek,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDateFromMonth,
  });

  final ValueChanged<int> onChangeDate;
  final ValueChanged<int> onViewChanged;
  final ValueChanged<double> onZoomLevelChanged;
  final VoidCallback onToggleFullscreen;
  final Future<void> Function(
    ScheduleTask? task, {
    int? defaultHour,
    int? defaultMinute,
  }) onShowTaskDialog;
  final ValueChanged<List<ScheduleTask>> onShowOverlapSheet;
  final Future<void> Function(ScheduleTask task) onToggleTaskDone;
  final Future<void> Function() onPersistTasks;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final ValueChanged<DateTime> onSelectDayFromWeek;
  final Future<void> Function(DateTime date, int hour) onAddTaskFromWeek;
  final Future<void> Function(DateTime date, ScheduleTask task) onOpenTaskFromWeek;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDateFromMonth;
}

class SchedulePageContent extends StatelessWidget {
  const SchedulePageContent({
    super.key,
    required this.viewState,
    required this.actions,
  });

  final SchedulePageViewState viewState;
  final SchedulePageActions actions;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        if (viewState.currentView == 0)
          DayView(
            selectedDate: viewState.selectedDate,
            isFullscreen: viewState.isFullscreen,
            zoomLevel: viewState.zoomLevel,
            hourHeight: viewState.hourHeight,
            startHour: viewState.startHour,
            endHour: viewState.endHour,
            totalHours: viewState.totalHours,
            tasksToday: viewState.tasksToday,
            hasTodayReflection: viewState.hasTodayReflection,
            hasTodayReview: viewState.hasTodayReview,
            onChangeDate: actions.onChangeDate,
            onZoomLevelChanged: actions.onZoomLevelChanged,
            onToggleFullscreen: actions.onToggleFullscreen,
            onShowTaskDialog: actions.onShowTaskDialog,
            onShowOverlapSheet: actions.onShowOverlapSheet,
            onToggleTaskDone: actions.onToggleTaskDone,
            onPersistTasks: actions.onPersistTasks,
          ),
        if (viewState.currentView == 1)
          WeekView(
            selectedDate: viewState.selectedDate,
            tasks: viewState.tasks,
            startHour: viewState.startHour,
            totalHours: viewState.totalHours,
            onPreviousWeek: actions.onPreviousWeek,
            onNextWeek: actions.onNextWeek,
            onSelectDay: actions.onSelectDayFromWeek,
            onAddTask: actions.onAddTaskFromWeek,
            onOpenTask: actions.onOpenTaskFromWeek,
            onToggleTaskDone: actions.onToggleTaskDone,
          ),
        if (viewState.currentView == 2)
          MonthView(
            selectedDate: viewState.selectedDate,
            tasks: viewState.tasks,
            onPreviousMonth: actions.onPreviousMonth,
            onNextMonth: actions.onNextMonth,
            onSelectDate: actions.onSelectDateFromMonth,
          ),
      ],
    );
  }
}
