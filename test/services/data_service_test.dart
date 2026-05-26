import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rigongyizu/models/goal.dart';
import 'package:rigongyizu/models/journal_entry.dart';
import 'package:rigongyizu/models/reflection_template.dart';
import 'package:rigongyizu/models/task.dart';
import 'package:rigongyizu/services/data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('data_service_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(DataService.taskBox);
    await Hive.openBox(DataService.goalBox);
    await Hive.openBox(DataService.journalBox);
    await Hive.openBox(DataService.templateBox);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DataService', () {
    test('supports normal CRUD behavior', () async {
      final task = _task(id: 'task-1', title: 'Write tests');
      final goal = _goal(id: 'goal-1', title: 'Ship task 5');
      final journal = _journal(id: 'journal-1');
      final template = _template(id: 'template-1');

      await DataService.saveTaskAsync(task);
      await DataService.saveGoalAsync(goal);
      await DataService.saveJournalAsync(journal);
      await DataService.saveTemplateAsync(template);

      expect(DataService.getTasks().map((item) => item.id), ['task-1']);
      expect(DataService.getGoals().map((item) => item.id), ['goal-1']);
      expect(DataService.getJournals().map((item) => item.id), ['journal-1']);
      expect(DataService.getCustomTemplates().map((item) => item.id), ['template-1']);

      final exported = DataService.exportAll();
      expect((exported['tasks'] as List).length, 1);
      expect((exported['goals'] as List).length, 1);
      expect((exported['journals'] as List).length, 1);
      expect((exported['templates'] as List).length, 1);

      await DataService.deleteTaskAsync(task.id);
      await DataService.deleteGoalAsync(goal.id);
      await DataService.deleteJournalAsync(journal.id);
      await DataService.deleteTemplateAsync(template.id);

      expect(DataService.getTasks(), isEmpty);
      expect(DataService.getGoals(), isEmpty);
      expect(DataService.getJournals(), isEmpty);
      expect(DataService.getCustomTemplates(), isEmpty);

      await DataService.saveTaskAsync(task);
      await DataService.saveGoalAsync(goal);

      await DataService.clearAll();

      expect(DataService.getTasks(), isEmpty);
      expect(DataService.getGoals(), isEmpty);
      expect(DataService.getJournals(), isEmpty);
      expect(DataService.getCustomTemplates(), isEmpty);
    });

    test('skips corrupted stored maps during reads', () async {
      await Hive.box(DataService.taskBox)
          .put('valid-task', _task(id: 'valid-task').toMap());
      await Hive.box(DataService.taskBox).put('bad-task', 'broken');
      await Hive.box(DataService.goalBox)
          .put('valid-goal', _goal(id: 'valid-goal').toMap());
      await Hive.box(DataService.goalBox).put('bad-goal', {'id': 'missing-title'});
      await Hive.box(DataService.journalBox)
          .put('valid-journal', _journal(id: 'valid-journal').toMap());
      await Hive.box(DataService.journalBox).put('bad-journal', 123);
      await Hive.box(DataService.templateBox)
          .put('valid-template', _template(id: 'valid-template').toMap());
      await Hive.box(DataService.templateBox).put('bad-template', {'id': 'missing-name'});

      expect(DataService.getTasks().map((item) => item.id), ['valid-task']);
      expect(DataService.getGoals().map((item) => item.id), ['valid-goal']);
      expect(DataService.getJournals().map((item) => item.id), ['valid-journal']);
      expect(DataService.getCustomTemplates().map((item) => item.id), ['valid-template']);
    });

    test('saveAllTasks and saveAllGoals replace records without stale leftovers', () async {
      await Hive.box(DataService.taskBox)
          .put('old-task', _task(id: 'old-task', title: 'Old').toMap());
      await Hive.box(DataService.goalBox)
          .put('old-goal', _goal(id: 'old-goal', title: 'Old').toMap());

      await DataService.saveAllTasksAsync([
        _task(id: 'new-task', title: 'New task'),
      ]);
      await DataService.saveAllGoalsAsync([
        _goal(id: 'new-goal', title: 'New goal'),
      ]);

      expect(DataService.getTasks().map((item) => item.id), ['new-task']);
      expect(DataService.getGoals().map((item) => item.id), ['new-goal']);
    });

    test('saveAllJournals and saveAllTemplates replace records without stale leftovers', () async {
      await Hive.box(DataService.journalBox)
          .put('old-journal', _journal(id: 'old-journal').toMap());
      await Hive.box(DataService.templateBox)
          .put('old-template', _template(id: 'old-template').toMap());

      await DataService.saveAllJournalsAsync([
        _journal(id: 'new-journal'),
      ]);
      await DataService.saveAllTemplatesAsync([
        _template(id: 'new-template'),
      ]);

      expect(DataService.getJournals().map((item) => item.id), ['new-journal']);
      expect(DataService.getCustomTemplates().map((item) => item.id), ['new-template']);
    });

    test('exportAll includes backup metadata', () async {
      final exported = DataService.exportAll();

      expect(exported['version'], '1.0.0');
      expect(DateTime.parse(exported['exportDate'] as String), isA<DateTime>());
    });

    test('importAll restores full exported dataset and replaces stale records', () async {
      await DataService.saveTaskAsync(_task(id: 'backup-task', title: 'Backup task'));
      await DataService.saveGoalAsync(_goal(id: 'backup-goal', title: 'Backup goal'));
      await DataService.saveJournalAsync(_journal(id: 'backup-journal'));
      await DataService.saveTemplateAsync(_template(id: 'backup-template'));

      final backup = DataService.exportAll();

      await DataService.saveTaskAsync(_task(id: 'stale-task', title: 'Stale task'));
      await DataService.saveGoalAsync(_goal(id: 'stale-goal', title: 'Stale goal'));
      await DataService.saveJournalAsync(_journal(id: 'stale-journal'));
      await DataService.saveTemplateAsync(_template(id: 'stale-template'));

      await DataService.importAll(backup);

      expect(DataService.getTasks().map((item) => item.id), ['backup-task']);
      expect(DataService.getGoals().map((item) => item.id), ['backup-goal']);
      expect(DataService.getJournals().map((item) => item.id), ['backup-journal']);
      expect(DataService.getCustomTemplates().map((item) => item.id), ['backup-template']);
    });

    test('importAll rejects invalid backup schema without mutating stored data', () async {
      await DataService.saveTaskAsync(_task(id: 'existing-task', title: 'Existing task'));

      await expectLater(
        DataService.importAll({
          'tasks': 'bad',
          'goals': const [],
          'journals': const [],
          'templates': const [],
        }),
        throwsA(isA<FormatException>()),
      );

      final tasks = DataService.getTasks();
      expect(tasks.map((item) => item.id), ['existing-task']);
      expect(tasks.single.title, 'Existing task');
    });

    test('saveAllTasks failure path throws instead of silently succeeding', () async {
      final existingTask = _task(id: 'existing-task', title: 'Keep me');

      await Hive.box(DataService.taskBox).put(existingTask.id, existingTask.toMap());
      await Hive.close();

      await expectLater(
        DataService.saveAllTasksAsync([
          _task(id: 'new-task', title: 'Should not overwrite'),
        ]),
        throwsA(isA<Object>()),
      );

      Hive.init(tempDir.path);
      await Hive.openBox(DataService.taskBox);
      await Hive.openBox(DataService.goalBox);
      await Hive.openBox(DataService.journalBox);
      await Hive.openBox(DataService.templateBox);

      final tasks = DataService.getTasks();
      expect(tasks.map((item) => item.id), ['existing-task']);
      expect(tasks.single.title, 'Keep me');
    });

    test('clearAll throws when storage is unavailable', () async {
      await Hive.close();

      await expectLater(DataService.clearAll(), throwsA(isA<Object>()));
    });

    test('getTasks throws when the task box is unavailable', () async {
      await Hive.close();

      expect(DataService.getTasks, throwsA(isA<Object>()));
    });
  });
}

ScheduleTask _task({String id = 'task-1', String title = 'Task'}) {
  return ScheduleTask(
    id: id,
    title: title,
    date: DateTime.utc(2026, 4, 25),
    startTime: DateTime.utc(2026, 4, 25, 9),
    durationMinutes: 30,
    notes: 'note',
  );
}

Goal _goal({String id = 'goal-1', String title = 'Goal'}) {
  return Goal(
    id: id,
    title: title,
    description: 'desc',
    deadline: DateTime.utc(2026, 5, 1),
    priority: 1,
    progressPct: 0.25,
  );
}

JournalEntry _journal({String id = 'journal-1'}) {
  return JournalEntry(
    id: id,
    type: JournalType.reflection,
    templateId: 'template-1',
    templateName: 'Daily',
    date: DateTime.utc(2026, 4, 25),
    time: DateTime.utc(2026, 4, 25, 21),
    content: 'content',
  );
}

ReflectionTemplate _template({String id = 'template-1'}) {
  return ReflectionTemplate(
    id: id,
    name: 'Daily',
    type: TemplateType.reflection,
    questions: const ['What happened?'],
  );
}
