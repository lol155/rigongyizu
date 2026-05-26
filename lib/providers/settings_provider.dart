import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data_store.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() {
    return ref.read(dataStoreProvider).loadSettings();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  Future<void> saveSettings(SettingsState settings) async {
    await ref.read(dataStoreProvider).saveSettings(settings);
    state = AsyncData(settings);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final current = await future;
    await saveSettings(current.copyWith(themeMode: themeMode));
  }

  Future<void> setSeedColor(Color seedColor) async {
    final current = await future;
    await saveSettings(current.copyWith(seedColor: seedColor));
  }
}
