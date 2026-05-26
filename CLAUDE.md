# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

日拱一卒 (rigongyizu) — a Flutter productivity app for goal-driven schedule management with reflection/review cycles. Targets iOS, Android, and macOS. All UI is in Chinese.

## Development Commands

```bash
flutter run                      # Run the app
flutter analyze                  # Static analysis / lint
flutter test                     # Run all tests
flutter test test/models/        # Run tests in a specific directory
flutter test test/models/task_test.dart  # Run a single test file
flutter pub get                  # Install dependencies
flutter build apk                # Build Android APK
```

## Architecture

**State management**: Riverpod (`AsyncNotifier` pattern). Each domain has a provider in `lib/providers/` that extends `AsyncNotifier<List<T>>`, reads from `dataStoreProvider`, and exposes CRUD methods.

**Persistence**: Hive boxes accessed through `DataService` (static methods) and `AppDataStore` interface. Four boxes: `tasks`, `goals`, `journals`, `templates`. Settings stored in a separate `settings` Hive box. Models use `toMap()`/`fromMap()` serialization — no Hive adapters.

**Navigation**: Bottom `NavigationBar` with `IndexedStack` holding 4 tabs: Schedule, Goals, Review, Profile.

## Key Patterns

- **Providers** depend on `dataStoreProvider` for all I/O. The `DataServiceStore` implementation delegates to static `DataService` methods.
- **Models** are plain Dart classes with `toMap()` / `fromMap()` and `copyWith()`. Located in `lib/models/`.
- **Pages** live in `lib/pages/` with subdirectories for complex pages (e.g., `pages/schedule/widgets/`, `pages/goals/widgets/`).
- **Color theme**: Central palette in `lib/utils/app_colors.dart`. Primary color `#FF6B35`. User-configurable seed color via settings.
- **Testing**: Provider tests use `test/providers/provider_test_helper.dart` which sets up temp Hive boxes in `setUp()` and cleans up in `tearDown()`.

## Data Models

- **ScheduleTask**: `id`, `title`, `date`, `startTime`, `duration`, `goalId` (nullable), `status` (pending/done/postponed/cancelled), `color`, `notes`
- **Goal**: `id`, `title`, `description`, `deadline`, `priority`, `color`, `status`, `parentId` (nullable — supports infinite nesting), `progressPct`
- **JournalEntry**: `id`, `type` (reflection/review), `templateId`, `date`, `time`, `content`
- **ReflectionTemplate**: `id`, `name`, `type`, `icon`, `isBuiltIn`, `questions[]`
