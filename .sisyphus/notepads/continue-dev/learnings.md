## 2026-04-25 Task: session-bootstrap
- Plan read fully before execution.
- Wave 1 can run in parallel, but Task 1 cleanup goes first for immediate progress recovery.
- Notepad directory initialized after missing-path check.
Cleanup note: removed stale backup/model files and dead members without changing runtime behavior.

## 2026-04-25 Task: model-unit-tests
- Model tests now cover round-trip map serialization, enum index persistence, and fromMap fallback defaults across all four model types.
- Time-based model assertions stay stable by testing ScheduleTask.endTime directly and using a future deadline with a small buffer for Goal.remainingDays.

## 2026-04-25 Task: notification-timezone
- `flutter_local_notifications` 21.x uses named `zonedSchedule()` args with `AndroidScheduleMode`, and repeating morning/evening reminders should be scheduled from a timezone-initialized `tz.local` location.
2026-04-25: Centralized repeated palette tokens into AppColors static constants to keep UI files lean and avoid duplicated color literals.

2026-04-25: Finished the remaining color-token cleanup by swapping schedule/goals/template manage pages to AppColors and theme-aware backgrounds.
2026-04-25: DataService reads now skip malformed Hive records per-entry, and bulk task/goal replacement is safer when implemented as putAll-first with stale-key cleanup instead of clear-then-rewrite.
2026-04-25: Riverpod provider scaffolding works cleanly with `AsyncNotifierProvider` over a small `AppDataStore` abstraction, keeping DataService-backed entity state testable before any page migration; template composition is easiest as built-in + custom providers merged through computed providers.
2026-04-25: For Riverpod page migrations, user-visible collections must come from `ref.watch(...)`-driven rebuilds rather than cached `ref.read(...).valueOrNull` getters, and widget tests that now hit the settings/data store need Hive initialization before pumping the app.
2026-04-25: `schedule_page.dart` day-view extraction stays behavior-safe when `DayView` owns only local presentation refresh, while task mutations still flow through the existing Riverpod persistence callbacks from the page.
2026-04-25: Shared task color mapping can live beside the extracted `TaskBlock` widget so week/day/overlap schedule surfaces reuse identical styling during structural splits.
2026-04-25: Week/month schedule extraction stays behavior-safe when page state remains in , and week-view row count must be driven by the shared 6-24 window () so late-evening slots remain reachable.
2026-04-25: Week/month schedule extraction stays behavior-safe when page state remains in SchedulePage, and week-view row count must be driven by the shared 6-24 window (_totalHours) so late-evening slots remain reachable.
2026-04-25: Schedule dialog/sheet extraction stays behavior-safe when the new files return UI intent/results and `SchedulePage` remains the single owner of Riverpod task persistence.
2026-04-25: Extending schedule task editing is safest when `TaskDialog` returns full task intent (`status`, `notes`, timing, goal, color) and shared status-aware styling helpers live with `TaskBlock` so day/week/overlap views stay visually consistent.
2026-04-26: Import refresh is most reliable when the profile page reloads all Riverpod-backed collections (`tasks`, `goals`, `journals`, `templates`) and then re-runs `appBootstrapProvider`; this keeps imported data visible immediately without a restart.
2026-04-26: Journal edits should flow through `journalsProvider.notifier.upsertJournal(...)` from the detail UI, then close the sheet/dialog so the updated provider state redraws all journal surfaces consistently.
2026-04-26: Goals page extraction stays behavior-safe when `GoalsPage` keeps all goal/task dialogs and Riverpod mutations, while new `GoalTree`/`GanttChart` widgets receive current goals plus intent callbacks for rendering only.
2026-04-26: Goal dialogs extract cleanly when each dialog file owns its own `showDialog` state and still receives the page `WidgetRef`; that keeps validation, defaults, and provider-backed save flows unchanged while shrinking `goals_page.dart`.
2026-04-26: Goal progress stays consistent when `GoalsNotifier` derives `progressPct` from child-goal progress plus related task completion and listens to `tasksProvider` updates, while the shared goal dialog handles both create/edit fields without moving save ownership out of Riverpod.
2026-04-26: Day-view swipe UX feels smoother when the grid follows horizontal drags a bit and date changes animate from the swipe direction; goal priority is clearer when each goal card shows a compact colored priority badge near progress.
2026-04-26: Goal deletion is safer when the edit dialog asks for confirmation and the provider removes descendant goals together, so deleted parents do not leave orphaned subgoals behind.
2026-04-26: Profile actions stop feeling dead-end when "给个好评" shares a ready-made recommendation text and "关于" opens a real about page with app purpose, version, and data/privacy notes.
2026-04-26: For the Task 17 blocker, the safest minimal fix was to drop the hardcoded light scaffold background and let the theme manage scaffold coloring.
2026-04-26: Review charts are easiest to keep stable when they reuse the page's existing journal list to derive both weekly bar totals and a compact 7-day trend line, instead of introducing new state.
2026-04-26: Journal page size cleanup stays behavior-safe when list state remains in `JournalListPage` and extracted header/card/detail/dialog widgets only render UI plus intent callbacks.
2026-04-26: Schedule size cleanup stays behavior-safe when `SchedulePage` keeps Riverpod mutations, while extracted header/timeline/dialog helper files own presentation-only logic and shared task-status colors move to a dedicated helper imported by every schedule surface.
2026-04-26: Final schedule/goals line-count cleanup stays behavior-safe when recursive tree cards and task-dialog field groups move into domain-local helper widgets, leaving provider-backed actions and dialog result assembly in the original entry widgets.
- Schedule page shell extraction can trim page/controller files under checklist limits without touching provider flow or day/week/month behavior.
2026-04-26: Review page line-count cleanup stays behavior-safe when metrics remain derived from the same journal list and charts/heatmap/recent cards move into review-local rendering widgets only.
2026-04-26: Profile line-count cleanup stays behavior-safe when section cards/header/stats move into `lib/pages/profile_page/` helpers while import/export/share/about actions remain owned by `ProfilePage`.
2026-04-26: Fixed short schedule-block overflow safely by making `TaskBlock` branch on actual content height via `LayoutBuilder`, keeping the title visible and only showing status badge/time when enough vertical space exists.
2026-04-26: F3 QA recheck passed practical web-server smoke once proxy vars were unset; Playwright could load the localhost app, confirm the schedule page rendered real seeded content, and switch bottom-nav state into the goals page without console errors.
2026-04-26: Backup restore now stays aligned with `DataService.exportAll()` by parsing all four exported collections first, then replacing tasks/goals/journals/templates via bulk box replacement so stale local records do not survive import.
2026-04-26: Final color-token cleanup was safest when shared palette lists, journal badge colors, and the repeated subtle gray handle/border token moved into `AppColors`, leaving visual output unchanged while removing literal duplication from page widgets.
2026-04-26: Persistence/notification actions are safer when storage writes stop swallowing Hive failures, notification calls throw before fake success, and `ProfilePage` turns those exceptions into failure snackbars instead of always reporting success.
2026-04-26: Settings stale-state cleanup was safest when mutable `AppSettings` runtime values were removed, `SettingsState.defaults()` became constant-based, and persistence read/write flowed only through the Riverpod settings provider plus Hive storage.
2026-04-26: Schedule shell prop-drilling shrinks cleanly when `SchedulePage` assembles one immutable view-state object plus one action bundle, letting scaffold/content stay presentation-oriented without re-forwarding dozens of individual fields.
2026-04-26: After persistence errors started propagating, the safest UX fix for dialog-driven writes was to keep success closes/snackbars unchanged but wrap each save/delete in local try/catch so failures surface in-place and dialogs stay open for retry.
2026-04-26: Final color cleanup stayed minimal by moving the task-dialog palette list behind `AppColors` and swapping the remaining goal-delete red literals to `AppColors.danger`, preserving identical visuals while removing the last duplicate tokens.
2026-04-26: The last persistence-hole fixes were safest when toggle/reorder-style actions captured a local `ScaffoldMessenger` first, then wrapped provider writes in try/catch so fast status/theme interactions report failures without disturbing the success path.
2026-04-26: F1 compliance cleanup stayed low-risk by wiring recurring reminders through a single startup helper, raising `DataService` coverage with schema/replacement/metadata cases, and recording analyze/test evidence under `.sisyphus/evidence/`.
2026-04-26: The last schedule page size trim was safest when shared behavior stayed in `SchedulePage` and only tiny repeated scaffolds/journal-check helpers were collapsed, cutting lines without moving mutation ownership.
2026-04-26: The profile sections size trim was safest when constructor boilerplate and tiny render wrappers were collapsed in place, keeping all callbacks and layout behavior unchanged while dropping the file under the line limit.
2026-04-26: The last F2 dialog-flow fixes stayed low-risk when journal save and template delete each captured a local messenger, wrapped the provider write in try/catch, and left the current sheet/page open on failure for immediate retry.
2026-04-26: Remaining color-gate cleanup was safest when the review chart/heatmap palette and the shared muted border token moved into `AppColors`, while goal add-to-schedule reused `inactiveBg(context)` instead of duplicating the light chip background literal.
2026-04-26: The remaining F1 cleanup stayed behavior-safe by restoring legacy sync `DataService` write/delete signatures as compatibility wrappers over awaited async variants with explicit Hive error wrapping, while the last schedule/demo/priority palette literals moved into `AppColors` constants and maps.
2026-04-26: The final palette cleanup was just replacing the shared `0xFFFF6B35` default/fallback ints in task/goal models and task dialog state with `AppColors.primaryValue`, which preserved behavior while removing the last cited literal duplication.
