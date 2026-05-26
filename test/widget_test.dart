import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rigongyizu/main.dart';
import 'package:rigongyizu/models/goal.dart';
import 'package:rigongyizu/services/data_service.dart';

import 'providers/provider_test_helper.dart';

void main() {
  setUpProviderStorage(null, (_) async {
    await DataService.saveGoalAsync(
      Goal(
        id: 'test-goal',
        title: 'Test goal',
        deadline: DateTime.utc(2026, 4, 25),
      ),
    );
  });

  testWidgets('App renders bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RigongyizuApp()));
    await tester.pumpAndSettle();

    expect(find.text('日程'), findsWidgets);
    expect(find.text('目标'), findsWidgets);
    expect(find.text('复盘'), findsWidgets);
    expect(find.text('我的'), findsWidgets);
  });
}
