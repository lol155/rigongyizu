import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rigongyizu/models/journal_entry.dart';
import 'package:rigongyizu/providers/journals_provider.dart';
import 'package:rigongyizu/services/data_service.dart';

import 'provider_test_helper.dart';

void main() {
  setUpProviderStorage(null, (_) async {});

  test('loads journals and persists add/update/delete operations', () async {
    final existing = JournalEntry(
      id: 'journal-1',
      type: JournalType.reflection,
      templateId: 'daily_reflection',
      templateName: '每日反思',
      date: DateTime.utc(2026, 4, 25),
      time: DateTime.utc(2026, 4, 25, 9),
      content: 'Already here',
    );
    await DataService.saveJournalAsync(existing);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect((await container.read(journalsProvider.future)).single.id, 'journal-1');

    final added = JournalEntry(
      id: 'journal-2',
      type: JournalType.review,
      templateId: 'quick_review',
      templateName: '快速复盘',
      date: DateTime.utc(2026, 4, 25),
      time: DateTime.utc(2026, 4, 25, 21),
      content: 'New review',
    );

    await container.read(journalsProvider.notifier).addJournal(added);

    expect(container.read(journalsProvider).requireValue.length, 2);
    expect(DataService.getJournals().map((item) => item.id), contains('journal-2'));

    final updated = JournalEntry(
      id: 'journal-2',
      type: JournalType.review,
      templateId: 'quick_review',
      templateName: '快速复盘',
      date: DateTime.utc(2026, 4, 25),
      time: DateTime.utc(2026, 4, 25, 21),
      content: 'Updated review',
    );

    await container.read(journalsProvider.notifier).upsertJournal(updated);

    expect(
      container.read(journalsProvider).requireValue.firstWhere((item) => item.id == 'journal-2').content,
      'Updated review',
    );
    expect(
      DataService.getJournals().firstWhere((item) => item.id == 'journal-2').content,
      'Updated review',
    );

    await container.read(journalsProvider.notifier).deleteJournal('journal-1');

    expect(container.read(journalsProvider).requireValue.map((item) => item.id), ['journal-2']);
  });
}
