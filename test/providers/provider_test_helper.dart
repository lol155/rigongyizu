import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rigongyizu/providers/data_store.dart';
import 'package:rigongyizu/services/data_service.dart';

void setUpProviderStorage(WidgetTester? tester, Future<void> Function(Directory dir) body) {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('provider_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(DataService.taskBox);
    await Hive.openBox(DataService.goalBox);
    await Hive.openBox(DataService.journalBox);
    await Hive.openBox(DataService.templateBox);
    await Hive.openBox(DataServiceStore.settingsBox);
    await body(tempDir);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });
}
