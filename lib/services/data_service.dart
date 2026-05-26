import 'dart:async';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';
import '../models/goal.dart';
import '../models/journal_entry.dart';
import '../models/reflection_template.dart';

class DataService {
  static const String taskBox = 'tasks';
  static const String goalBox = 'goals';
  static const String journalBox = 'journals';
  static const String templateBox = 'templates';

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await _openBoxSafely(taskBox);
    await _openBoxSafely(goalBox);
    await _openBoxSafely(journalBox);
    await _openBoxSafely(templateBox);
  }

  // ===== Task =====
  static List<ScheduleTask> getTasks() {
    return _readRecords(taskBox, ScheduleTask.fromMap);
  }

  static void saveTask(ScheduleTask task) {
    unawaited(saveTaskAsync(task));
  }

  static Future<void> saveTaskAsync(ScheduleTask task) {
    return _put(taskBox, task.id, task.toMap(), '保存任务失败');
  }

  static void deleteTask(String id) {
    unawaited(deleteTaskAsync(id));
  }

  static Future<void> deleteTaskAsync(String id) {
    return _delete(taskBox, id, '删除任务失败');
  }

  static void saveAllTasks(List<ScheduleTask> tasks) {
    unawaited(saveAllTasksAsync(tasks));
  }

  static Future<void> saveAllTasksAsync(List<ScheduleTask> tasks) {
    return _replaceAll(
      taskBox,
      {for (final task in tasks) task.id: task.toMap()},
      '批量保存任务失败',
    );
  }

  // ===== Goal =====
  static List<Goal> getGoals() {
    return _readRecords(goalBox, Goal.fromMap);
  }

  static void saveGoal(Goal goal) {
    unawaited(saveGoalAsync(goal));
  }

  static Future<void> saveGoalAsync(Goal goal) {
    return _put(goalBox, goal.id, goal.toMap(), '保存目标失败');
  }

  static void deleteGoal(String id) {
    unawaited(deleteGoalAsync(id));
  }

  static Future<void> deleteGoalAsync(String id) {
    return _delete(goalBox, id, '删除目标失败');
  }

  static void saveAllGoals(List<Goal> goals) {
    unawaited(saveAllGoalsAsync(goals));
  }

  static Future<void> saveAllGoalsAsync(List<Goal> goals) {
    return _replaceAll(
      goalBox,
      {for (final goal in goals) goal.id: goal.toMap()},
      '批量保存目标失败',
    );
  }

  // ===== Journal =====
  static List<JournalEntry> getJournals() {
    return _readRecords(journalBox, JournalEntry.fromMap);
  }

  static void saveJournal(JournalEntry entry) {
    unawaited(saveJournalAsync(entry));
  }

  static Future<void> saveJournalAsync(JournalEntry entry) {
    return _put(journalBox, entry.id, entry.toMap(), '保存日记失败');
  }

  static void deleteJournal(String id) {
    unawaited(deleteJournalAsync(id));
  }

  static Future<void> deleteJournalAsync(String id) {
    return _delete(journalBox, id, '删除日记失败');
  }

  static void saveAllJournals(List<JournalEntry> journals) {
    unawaited(saveAllJournalsAsync(journals));
  }

  static Future<void> saveAllJournalsAsync(List<JournalEntry> journals) {
    return _replaceAll(
      journalBox,
      {for (final journal in journals) journal.id: journal.toMap()},
      '批量保存日记失败',
    );
  }

  // ===== Template =====
  static List<ReflectionTemplate> getCustomTemplates() {
    return _readRecords(templateBox, ReflectionTemplate.fromMap);
  }

  static void saveTemplate(ReflectionTemplate t) {
    unawaited(saveTemplateAsync(t));
  }

  static Future<void> saveTemplateAsync(ReflectionTemplate t) {
    return _put(templateBox, t.id, t.toMap(), '保存模板失败');
  }

  static void deleteTemplate(String id) {
    unawaited(deleteTemplateAsync(id));
  }

  static Future<void> deleteTemplateAsync(String id) {
    return _delete(templateBox, id, '删除模板失败');
  }

  static void saveAllTemplates(List<ReflectionTemplate> templates) {
    unawaited(saveAllTemplatesAsync(templates));
  }

  static Future<void> saveAllTemplatesAsync(List<ReflectionTemplate> templates) {
    return _replaceAll(
      templateBox,
      {for (final template in templates) template.id: template.toMap()},
      '批量保存模板失败',
    );
  }

  // ===== Data management =====
  static Future<void> clearAll() async {
    await _clearBox(taskBox);
    await _clearBox(goalBox);
    await _clearBox(journalBox);
    await _clearBox(templateBox);
  }

  static Map<String, dynamic> exportAll() {
    return {
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'tasks': getTasks().map((t) => t.toMap()).toList(),
      'goals': getGoals().map((g) => g.toMap()).toList(),
      'journals': getJournals().map((j) => j.toMap()).toList(),
      'templates': getCustomTemplates().map((t) => t.toMap()).toList(),
    };
  }

  static Future<void> importAll(Map<String, dynamic> data) async {
    final tasks = _parseRecords(data, 'tasks', ScheduleTask.fromMap);
    final goals = _parseRecords(data, 'goals', Goal.fromMap);
    final journals = _parseRecords(data, 'journals', JournalEntry.fromMap);
    final templates = _parseRecords(data, 'templates', ReflectionTemplate.fromMap);

    await saveAllTasksAsync(tasks);
    await saveAllGoalsAsync(goals);
    await saveAllJournalsAsync(journals);
    await saveAllTemplatesAsync(templates);
  }

  static Future<void> _openBoxSafely(String name) async {
    if (Hive.isBoxOpen(name)) {
      return;
    }

    try {
      await Hive.openBox(name);
    } catch (error) {
      try {
        await Hive.deleteBoxFromDisk(name);
        await Hive.openBox(name);
      } catch (recoveryError) {
        throw StateError('打开数据存储失败（$name）：$recoveryError；原始错误：$error');
      }
    }
  }

  static List<T> _readRecords<T>(
    String boxName,
    T Function(Map<String, dynamic> map) fromMap,
  ) {
    final box = Hive.box(boxName);
    final records = <T>[];

    for (final value in box.values) {
      try {
        records.add(fromMap(Map<String, dynamic>.from(value as Map)));
      } catch (_) {}
    }

    return records;
  }

  static Future<void> _put(String boxName, String key, Map<String, dynamic> value, String message) async {
    try {
      await Hive.box(boxName).put(key, value);
    } catch (error) {
      throw StateError('$message：$error');
    }
  }

  static Future<void> _delete(String boxName, String key, String message) async {
    try {
      await Hive.box(boxName).delete(key);
    } catch (error) {
      throw StateError('$message：$error');
    }
  }

  static Future<void> _replaceAll(String boxName, Map<String, Map<String, dynamic>> records, String message) async {
    try {
      final box = Hive.box(boxName);
      final existingKeys = box.keys.toSet();

      await box.putAll(records);

      final staleKeys = existingKeys.where((key) => !records.containsKey(key)).toList();
      if (staleKeys.isNotEmpty) {
        await box.deleteAll(staleKeys);
      }
    } catch (error) {
      throw StateError('$message：$error');
    }
  }

  static Future<void> _clearBox(String boxName) async {
    try {
      await Hive.box(boxName).clear();
    } catch (error) {
      throw StateError('清空数据失败（$boxName）：$error');
    }
  }

  static List<T> _parseRecords<T>(
    Map<String, dynamic> data,
    String key,
    T Function(Map<String, dynamic> map) fromMap,
  ) {
    final rawRecords = data[key];
    if (rawRecords is! List) {
      throw FormatException('缺少或无效的 $key 字段');
    }

    return rawRecords
        .map((record) {
          if (record is! Map) {
            throw FormatException('无效的 $key 记录');
          }
          return fromMap(Map<String, dynamic>.from(record));
        })
        .toList();
  }

}
