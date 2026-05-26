import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import '../models/journal_entry.dart';
import '../models/task.dart';
import '../providers/goals_provider.dart';
import '../providers/journals_provider.dart';
import '../providers/tasks_provider.dart';
import 'schedule/widgets/overlap_sheet.dart';
import 'schedule/widgets/schedule_page_content.dart';
import 'schedule/widgets/schedule_page_scaffold.dart';
import 'schedule/widgets/task_dialog.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  DateTime _selectedDate = DateTime.now();
  int _currentView = 0;
  double _zoomLevel = 0.6;
  bool _isFullscreen = false;
  List<ScheduleTask> _tasks = const [];
  List<Goal> _goals = const [];
  List<JournalEntry> _journals = const [];

  static const double _baseHourHeight = 48;
  static const int _startHour = 6;
  static const int _endHour = 24;
  static const int _totalHours = _endHour - _startHour;

  ScheduleTask _cloneTask(ScheduleTask task) =>
      ScheduleTask.fromMap(task.toMap());

  double get _hourHeight => _baseHourHeight * _zoomLevel;

  List<ScheduleTask> get _tasksForDate => _tasks
      .where(
        (task) =>
            task.date.year == _selectedDate.year &&
            task.date.month == _selectedDate.month &&
            task.date.day == _selectedDate.day,
      )
      .toList();

  bool get _hasTodayReflection => _hasTodayJournal(JournalType.reflection);
  bool get _hasTodayReview => _hasTodayJournal(JournalType.review);

  bool _hasTodayJournal(JournalType type) {
    final now = DateTime.now();
    return _journals.any(
      (journal) =>
          journal.type == type &&
          journal.date.year == now.year &&
          journal.date.month == now.month &&
          journal.date.day == now.day,
    );
  }

  Future<void> _saveTasks(List<ScheduleTask> tasks) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(tasksProvider.notifier)
          .setAll(tasks.map(_cloneTask).toList(growable: false));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('保存日程失败：$error')));
    }
  }

  Future<void> _toggleTaskDone(ScheduleTask task) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = _cloneTask(task);
      updated.status = task.status == TaskStatus.done
          ? TaskStatus.pending
          : TaskStatus.done;
      await ref.read(tasksProvider.notifier).upsertTask(updated);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('更新任务状态失败：$error')));
    }
  }

  String _formatDate(DateTime date) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    final weekday = weekdays[date.weekday - 1];
    final isToday = _isToday(date);
    return '${date.month}月${date.day}日 周$weekday${isToday ? ' · 今天' : ''}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _changeDate(int delta) {
    setState(() {
      _selectedDate = delta == 0
          ? DateTime.now()
          : _selectedDate.add(Duration(days: delta));
    });
  }

  void _setCurrentView(int view) {
    setState(() => _currentView = view);
  }

  void _selectDay(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentView = 0;
    });
  }

  void _changeWeek(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 7 * delta));
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + delta, 1);
    });
  }

  Future<void> _openFromWeek(
    DateTime date, {
    int? defaultHour,
    ScheduleTask? task,
  }) async {
    // Don't switch to day view — just show the dialog directly.
    // Save and restore selectedDate so the dialog gets the right date.
    final previousDate = _selectedDate;
    _selectedDate = date;

    await _showTaskDialog(task, defaultHour: defaultHour);

    // Restore the original date so the week view stays on the same week.
    if (mounted) {
      setState(() {
        _selectedDate = previousDate;
      });
    }
  }

  Future<void> _showTaskDialog(
    ScheduleTask? task, {
    int? defaultHour,
    int? defaultMinute,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await TaskDialog.show(
      context,
      selectedDate: _selectedDate,
      goals: _goals,
      task: task,
      defaultHour: defaultHour,
      defaultMinute: defaultMinute,
    );

    if (result == null) {
      return;
    }

    try {
      if (result.delete && task != null) {
        await ref.read(tasksProvider.notifier).deleteTask(task.id);
        return;
      }

      final data = result.data;
      if (data == null) {
        return;
      }

      if (task != null) {
        // If the date changed, we need to create a new task (date is final).
        final oldDate = DateTime(task.date.year, task.date.month, task.date.day);
        final newDate = DateTime(data.startTime.year, data.startTime.month, data.startTime.day);
        if (oldDate != newDate) {
          // Date changed: delete old, create new
          await ref.read(tasksProvider.notifier).deleteTask(task.id);
          await ref.read(tasksProvider.notifier).addTask(
            ScheduleTask(
              id: task.id,
              title: data.title,
              date: data.startTime,
              startTime: data.startTime,
              durationMinutes: data.durationMinutes,
              goalId: data.goalId,
              status: data.status,
              color: data.color,
              notes: data.notes,
            ),
          );
        } else {
          final updated = _cloneTask(task);
          updated.title = data.title;
          updated.startTime = data.startTime;
          updated.durationMinutes = data.durationMinutes;
          updated.goalId = data.goalId;
          updated.status = data.status;
          updated.color = data.color;
          updated.notes = data.notes;
          await ref.read(tasksProvider.notifier).upsertTask(updated);
        }
        return;
      }

      await ref.read(tasksProvider.notifier).addTask(
        ScheduleTask(
          id: 't_${DateTime.now().millisecondsSinceEpoch}',
          title: data.title,
          date: data.startTime,
          startTime: data.startTime,
          durationMinutes: data.durationMinutes,
          goalId: data.goalId,
          status: data.status,
          color: data.color,
          notes: data.notes,
        ),
      );
    } catch (error) {
      final actionLabel = result.delete
          ? '删除任务失败'
          : (task != null ? '保存任务失败' : '创建任务失败');
      messenger.showSnackBar(
        SnackBar(content: Text('$actionLabel：$error')),
      );
    }
  }

  void _showOverlapSheet(List<ScheduleTask> tasks) {
    OverlapSheet.show(
      context,
      tasks: tasks,
      onTaskTap: (task) => _showTaskDialog(task),
    );
  }

  Widget _loadingScaffold() => const Scaffold(body: Center(child: CircularProgressIndicator()));
  Widget _errorScaffold(Object error) => Scaffold(body: Center(child: Text('日程数据加载失败：$error')));

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final goalsAsync = ref.watch(goalsProvider);
    final journalsAsync = ref.watch(journalsProvider);

    if (tasksAsync.isLoading ||
        goalsAsync.isLoading ||
        journalsAsync.isLoading) {
      return _loadingScaffold();
    }

    if (tasksAsync.hasError) {
      return _errorScaffold(tasksAsync.error!);
    }

    if (goalsAsync.hasError) {
      return _errorScaffold(goalsAsync.error!);
    }

    if (journalsAsync.hasError) {
      return _errorScaffold(journalsAsync.error!);
    }

    _tasks = tasksAsync.requireValue;
    _goals = goalsAsync.requireValue;
    _journals = journalsAsync.requireValue;

    final tasksToday = _tasksForDate;
    final totalCount = tasksToday.length;
    final viewState = SchedulePageViewState(
      currentView: _currentView,
      selectedDate: _selectedDate,
      isFullscreen: _isFullscreen,
      zoomLevel: _zoomLevel,
      hourHeight: _hourHeight,
      startHour: _startHour,
      endHour: _endHour,
      totalHours: _totalHours,
      tasks: _tasks,
      tasksToday: tasksToday,
      hasTodayReflection: _hasTodayReflection,
      hasTodayReview: _hasTodayReview,
      formattedDate: _formatDate(_selectedDate),
      totalCount: totalCount,
    );
    final actions = SchedulePageActions(
      onChangeDate: _changeDate,
      onViewChanged: _setCurrentView,
      onZoomLevelChanged: (level) => setState(() => _zoomLevel = level),
      onToggleFullscreen: () => setState(() => _isFullscreen = !_isFullscreen),
      onShowTaskDialog: _showTaskDialog,
      onShowOverlapSheet: _showOverlapSheet,
      onToggleTaskDone: _toggleTaskDone,
      onPersistTasks: () => _saveTasks(List<ScheduleTask>.from(_tasks)),
      onPreviousWeek: () => _changeWeek(-1),
      onNextWeek: () => _changeWeek(1),
      onSelectDayFromWeek: _selectDay,
      onAddTaskFromWeek: (date, hour) => _openFromWeek(date, defaultHour: hour),
      onOpenTaskFromWeek: (date, task) => _openFromWeek(date, task: task),
      onPreviousMonth: () => _changeMonth(-1),
      onNextMonth: () => _changeMonth(1),
      onSelectDateFromMonth: _selectDay,
    );

    return SchedulePageScaffold(
      viewState: viewState,
      actions: actions,
    );
  }
}
