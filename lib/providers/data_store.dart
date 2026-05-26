import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/goal.dart';
import '../models/journal_entry.dart';
import '../models/reflection_template.dart';
import '../models/task.dart';
import '../services/data_service.dart';
import '../utils/app_colors.dart';

abstract class AppDataStore {
  Future<List<ScheduleTask>> loadTasks();
  Future<void> saveTasks(List<ScheduleTask> tasks);
  Future<void> saveTask(ScheduleTask task);
  Future<void> deleteTask(String id);

  Future<List<Goal>> loadGoals();
  Future<void> saveGoals(List<Goal> goals);
  Future<void> saveGoal(Goal goal);
  Future<void> deleteGoal(String id);

  Future<List<JournalEntry>> loadJournals();
  Future<void> saveJournal(JournalEntry journal);
  Future<void> deleteJournal(String id);

  Future<List<ReflectionTemplate>> loadCustomTemplates();
  Future<void> saveTemplate(ReflectionTemplate template);
  Future<void> deleteTemplate(String id);

  Future<SettingsState> loadSettings();
  Future<void> saveSettings(SettingsState settings);
}

final dataStoreProvider = Provider<AppDataStore>((ref) {
  return const DataServiceStore();
});

@immutable
class SettingsState {
  static const ThemeMode defaultThemeMode = ThemeMode.system;
  static const Color defaultSeedColor = AppColors.primary;

  final ThemeMode themeMode;
  final Color seedColor;

  const SettingsState({
    required this.themeMode,
    required this.seedColor,
  });

  static SettingsState defaults() => SettingsState(
        themeMode: defaultThemeMode,
        seedColor: defaultSeedColor,
      );

  SettingsState copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

class DataServiceStore implements AppDataStore {
  static const String settingsBox = 'settings';
  static const String themeModeKey = 'themeMode';
  static const String seedColorKey = 'seedColor';

  const DataServiceStore();

  @override
  Future<List<ScheduleTask>> loadTasks() async => DataService.getTasks();

  @override
  Future<void> saveTasks(List<ScheduleTask> tasks) async {
    await DataService.saveAllTasksAsync(tasks);
  }

  @override
  Future<void> saveTask(ScheduleTask task) async {
    await DataService.saveTaskAsync(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await DataService.deleteTaskAsync(id);
  }

  @override
  Future<List<Goal>> loadGoals() async => DataService.getGoals();

  @override
  Future<void> saveGoals(List<Goal> goals) async {
    await DataService.saveAllGoalsAsync(goals);
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    await DataService.saveGoalAsync(goal);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await DataService.deleteGoalAsync(id);
  }

  @override
  Future<List<JournalEntry>> loadJournals() async => DataService.getJournals();

  @override
  Future<void> saveJournal(JournalEntry journal) async {
    await DataService.saveJournalAsync(journal);
  }

  @override
  Future<void> deleteJournal(String id) async {
    await DataService.deleteJournalAsync(id);
  }

  @override
  Future<List<ReflectionTemplate>> loadCustomTemplates() async {
    return DataService.getCustomTemplates();
  }

  @override
  Future<void> saveTemplate(ReflectionTemplate template) async {
    await DataService.saveTemplateAsync(template);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await DataService.deleteTemplateAsync(id);
  }

  @override
  Future<SettingsState> loadSettings() async {
    final defaults = SettingsState.defaults();
    final box = await _openSettingsBox();
    final storedMode = box.get(themeModeKey) as int?;
    final storedSeedColor = box.get(seedColorKey) as int?;

    final settings = SettingsState(
      themeMode: _themeModeFromIndex(storedMode) ?? defaults.themeMode,
      seedColor: Color(storedSeedColor ?? defaults.seedColor.toARGB32()),
    );
    return settings;
  }

  @override
  Future<void> saveSettings(SettingsState settings) async {
    final box = await _openSettingsBox();
    await box.put(themeModeKey, settings.themeMode.index);
    await box.put(seedColorKey, settings.seedColor.toARGB32());
  }

  Future<Box<dynamic>> _openSettingsBox() async {
    if (Hive.isBoxOpen(settingsBox)) {
      return Hive.box(settingsBox);
    }

    try {
      return await Hive.openBox(settingsBox);
    } catch (_) {
      await Hive.deleteBoxFromDisk(settingsBox);
      return Hive.openBox(settingsBox);
    }
  }

  ThemeMode? _themeModeFromIndex(int? index) {
    if (index == null || index < 0 || index >= ThemeMode.values.length) {
      return null;
    }

    return ThemeMode.values[index];
  }
}
