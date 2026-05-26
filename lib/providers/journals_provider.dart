import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_entry.dart';
import 'data_store.dart';

final journalsProvider = AsyncNotifierProvider<JournalsNotifier, List<JournalEntry>>(
  JournalsNotifier.new,
);

class JournalsNotifier extends AsyncNotifier<List<JournalEntry>> {
  @override
  Future<List<JournalEntry>> build() {
    return ref.read(dataStoreProvider).loadJournals();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  Future<void> addJournal(JournalEntry journal) async {
    final current = await future;
    await ref.read(dataStoreProvider).saveJournal(journal);
    state = AsyncData(List<JournalEntry>.unmodifiable([...current, journal]));
  }

  Future<void> upsertJournal(JournalEntry journal) async {
    final current = await future;
    final index = current.indexWhere((item) => item.id == journal.id);
    final next = [...current];

    if (index == -1) {
      next.add(journal);
    } else {
      next[index] = journal;
    }

    await ref.read(dataStoreProvider).saveJournal(journal);
    state = AsyncData(List<JournalEntry>.unmodifiable(next));
  }

  Future<void> deleteJournal(String id) async {
    final current = await future;
    await ref.read(dataStoreProvider).deleteJournal(id);
    state = AsyncData(
      List<JournalEntry>.unmodifiable(
        current.where((item) => item.id != id),
      ),
    );
  }
}
