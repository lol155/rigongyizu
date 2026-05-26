import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rigongyizu/providers/data_store.dart';
import 'package:rigongyizu/providers/settings_provider.dart';

import 'provider_test_helper.dart';

void main() {
  setUpProviderStorage(null, (_) async {});

  test('loads default settings and persists updates through the provider state flow', () async {
    final container = ProviderContainer();
    final reloadedContainer = ProviderContainer();
    addTearDown(container.dispose);
    addTearDown(reloadedContainer.dispose);

    final initial = await container.read(settingsProvider.future);
    expect(initial.themeMode, SettingsState.defaultThemeMode);
    expect(initial.seedColor, SettingsState.defaultSeedColor);

    await container.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);
    await container.read(settingsProvider.notifier).setSeedColor(const Color(0xFF3B82F6));

    final updated = container.read(settingsProvider).requireValue;
    expect(updated.themeMode, ThemeMode.dark);
    expect(updated.seedColor, const Color(0xFF3B82F6));

    final reloaded = await reloadedContainer.read(settingsProvider.future);
    expect(reloaded.themeMode, ThemeMode.dark);
    expect(reloaded.seedColor, const Color(0xFF3B82F6));
  });
}
