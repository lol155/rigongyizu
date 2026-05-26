# 日拱一卒 - 继续开发计划（功能完善 + 代码重构）

## TL;DR

> **Quick Summary**: 完善日拱一卒APP的现有功能、修复已知Bug、进行代码架构重构（引入Riverpod状态管理、拆分巨型文件、统一颜色系统）。遵循TDD原则，先写测试再重构。
> 
> **Deliverables**:
> - Riverpod 状态管理系统（替换 prop drilling）
> - 拆分后的 schedule_page（日/周/月视图独立组件）和 goals_page
> - 统一颜色系统（消除7个文件的重复定义）
> - 完善的通知调度系统（真正按时触发）
> - 目标进度自动计算、目标编辑功能
> - 任务多状态支持（推迟/取消）
> - fl_chart 图表替换手绘图表
> - 全面的深色模式支持
> - 测试基础设施 + 核心模块单元测试
> 
> **Estimated Effort**: Large
> **Parallel Execution**: YES - 6 waves
> **Critical Path**: Task 1 → Task 2 → Task 3 → Task 6 → Task 7 → Task 9 → Task 12-16 → Task 17-21 → F1-F4

---

## Context

### Original Request
用户希望继续开发日拱一卒APP，方向为"先把功能做好"——完善现有功能、修复Bug、代码重构。不追求花哨新功能。

### Interview Summary
**Key Discussions**:
- 方向选择：新功能开发 + 体验打磨 + 代码重构（三管齐下）
- APP运行状态：能跑但有问题，用户说不清具体Bug
- 核心原则：先把功能做好，不要花哨新功能
- 测试策略：TDD（先写测试再重构）
- 状态管理：上 Riverpod（已引入 v2.6.1 但完全未使用）

### Code Review Findings
**Critical Issues (5)**:
1. 无真正的状态管理 — 全部用 StatefulWidget + setState + prop drilling
2. 两个巨型文件 — schedule_page.dart (929行), goals_page.dart (718行)
3. 颜色定义严重重复 — 7个文件各自定义 primary/text2/text3
4. 通知系统空壳 — scheduleReminder 只立即显示，不会按时调度
5. 数据操作不安全 — Hive 无错误处理，saveAllTasks 先clear再逐个写

**Feature Gaps (9)**:
6. 目标进度不会自动计算
7. 任务只有 done/pending 两种状态（缺 postponed/cancelled）
8. 无法编辑已有目标
9. fl_chart 引入但未使用，图表是手绘的
10. 周视图只显示12小时
11. 导入数据后需手动重启
12. 任务备注无UI
13. 目标描述无UI
14. 日记编辑持久化不完整

**UX Issues (6)**:
15. 日视图滑动切日期只在时间网格有效
16. 目标优先级不可见
17. 删除目标无确认弹窗
18. .bak 文件残留
19. 未使用代码（models.dart、col字段、空initState）
20. "关于"和"给个好评"无内容

---

## Work Objectives

### Core Objective
将日拱一卒APP从"能用"提升到"好用"——修复已知缺陷、完善核心功能、重构代码架构使后续开发更高效。

### Concrete Deliverables
- Riverpod Provider 体系覆盖全部状态
- schedule_page 拆分为 4-5 个独立组件文件
- goals_page 拆分为 3-4 个独立组件文件
- 统一颜色系统，删除所有重复定义
- 通知系统真正按时调度
- 目标支持编辑、进度自动计算
- 任务支持推迟/取消状态
- fl_chart 替换手绘图表
- 至少 20 个单元测试覆盖核心逻辑
- 所有 .bak 文件和死代码清理

### Definition of Done
- [ ] `flutter analyze` 零错误零警告
- [ ] `flutter test` 全部通过（≥20个测试）
- [ ] 所有页面深色模式正常
- [ ] 通知可按时触发
- [ ] 目标进度自动计算并显示
- [ ] 目标可编辑标题/截止日期/优先级
- [ ] 任务可标记推迟/取消
- [ ] 无 .bak 文件残留
- [ ] 无重复颜色常量定义

### Must Have
- Riverpod 状态管理全面启用
- 测试基础设施（至少覆盖 models + services）
- 颜色系统统一到 AppColors
- 通知按时调度
- 目标进度自动计算
- 目标编辑功能
- 任务推迟/取消状态
- fl_chart 替换手绘图表
- .bak 文件清理

### Must NOT Have (Guardrails)
- ❌ 不引入云同步功能
- ❌ 不引入 AI 智能建议
- ❌ 不引入桌面小组件
- ❌ 不改变主色调（#FF6B35）
- ❌ 不改变数据存储方式（继续用 Hive，不换 SQLite）
- ❌ 不删除任何现有功能
- ❌ 不引入新的第三方库（除了 timezone 用于通知调度）
- ❌ 不做国际化（保持中文）
- ❌ 不过度抽象 — 保持实用主义，不为重构而重构

---

## Verification Strategy

> **ZERO HUMAN INTERVENTION** - ALL verification is agent-executed. No exceptions.

### Test Decision
- **Infrastructure exists**: NO (test/ 目录为空)
- **Automated tests**: YES (TDD)
- **Framework**: flutter_test (built-in)
- **If TDD**: 每个功能任务遵循 RED (failing test) → GREEN (minimal impl) → REFACTOR

### QA Policy
Every task MUST include agent-executed QA scenarios.
Evidence saved to `.sisyphus/evidence/task-{N}-{scenario-slug}.{ext}`.

- **Flutter Widget**: Use `flutter test` — Unit/Widget tests
- **UI Verification**: Use Playwright (playwright skill) — if applicable on web
- **CLI/Build**: Use Bash — `flutter analyze`, `flutter test`, `flutter build`

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Foundation — cleanup + tests + constants):
├── Task 1: 清理残留文件(.bak/models.dart/死代码) [quick]
├── Task 2: 统一颜色系统到AppColors [quick]
├── Task 3: 搭建测试基础设施 + 模型测试 [unspecified-high]
└── Task 4: 添加timezone依赖 + 通知调度修复 [quick]

Wave 2 (Data Layer — Riverpod + DataService):
├── Task 5: DataService重构(错误处理+事务安全) + 测试 [deep]
├── Task 6: Riverpod Provider体系搭建 [deep]
└── Task 7: main.dart + HomePage迁移到Riverpod [unspecified-high]

Wave 3 (File Split — schedule_page + goals_page):
├── Task 8: schedule_page拆分 — 日视图组件 [unspecified-high]
├── Task 9: schedule_page拆分 — 周视图+月视图组件 [unspecified-high]
├── Task 10: schedule_page拆分 — 任务弹窗组件 [quick]
├── Task 11: goals_page拆分 — 目标树+甘特图组件 [unspecified-high]
└── Task 12: goals_page拆分 — 目标弹窗组件 [quick]

Wave 4 (Feature Completion — core gaps):
├── Task 13: 目标进度自动计算 + 目标编辑 [deep]
├── Task 14: 任务多状态(推迟/取消) + 任务备注UI [unspecified-high]
├── Task 15: fl_chart替换复盘页手绘图表 [visual-engineering]
└── Task 16: 周视图扩展到18小时 + 导入后自动刷新 [quick]

Wave 5 (UX Polish):
├── Task 17: 深色模式全面修复 [visual-engineering]
├── Task 18: 日视图滑动优化 + 目标优先级显示 [quick]
├── Task 19: 删除确认弹窗 + 关于页面 + 清理空操作 [quick]
└── Task 20: 日记编辑持久化修复 [quick]

Wave FINAL (Verification):
├── Task F1: Plan compliance audit (oracle)
├── Task F2: Code quality review (unspecified-high)
├── Task F3: Real manual QA (unspecified-high)
└── Task F4: Scope fidelity check (deep)

Critical Path: Task 1 → Task 3 → Task 5 → Task 6 → Task 7 → Task 8-12 → Task 13-16 → Task 17-20 → F1-F4
Parallel Speedup: ~60% faster than sequential
Max Concurrent: 4 (Waves 3 & 4)
```

### Dependency Matrix

| Task | Depends On | Blocks | Wave |
|------|-----------|--------|------|
| 1 | - | 2, 3 | 1 |
| 2 | - | 8, 11, 17 | 1 |
| 3 | - | 5 | 1 |
| 4 | - | - | 1 |
| 5 | 3 | 6 | 2 |
| 6 | 5 | 7 | 2 |
| 7 | 6 | 8-12 | 2 |
| 8 | 2, 7 | - | 3 |
| 9 | 7 | - | 3 |
| 10 | 7 | - | 3 |
| 11 | 2, 7 | - | 3 |
| 12 | 7 | 13 | 3 |
| 13 | 12 | - | 4 |
| 14 | 8, 10 | - | 4 |
| 15 | 7 | - | 4 |
| 16 | 9 | - | 4 |
| 17 | 2, 7 | - | 5 |
| 18 | 8, 11 | - | 5 |
| 19 | 11, 12 | - | 5 |
| 20 | 7 | - | 5 |

### Agent Dispatch Summary

- **Wave 1**: 4 tasks — T1 → `quick`, T2 → `quick`, T3 → `unspecified-high`, T4 → `quick`
- **Wave 2**: 3 tasks — T5 → `deep`, T6 → `deep`, T7 → `unspecified-high`
- **Wave 3**: 5 tasks — T8 → `unspecified-high`, T9 → `unspecified-high`, T10 → `quick`, T11 → `unspecified-high`, T12 → `quick`
- **Wave 4**: 4 tasks — T13 → `deep`, T14 → `unspecified-high`, T15 → `visual-engineering`, T16 → `quick`
- **Wave 5**: 4 tasks — T17 → `visual-engineering`, T18 → `quick`, T19 → `quick`, T20 → `quick`
- **FINAL**: 4 tasks — F1 → `oracle`, F2 → `unspecified-high`, F3 → `unspecified-high`, F4 → `deep`

---

## TODOs

- [x] 1. 清理残留文件和死代码

  **What to do**:
  - 删除 `lib/pages/schedule_page.dart.bak` 和 `lib/pages/schedule_page.dart.bak2`
  - 删除 `lib/models/models.dart`（barrel file，无任何引用）
  - 从 `ScheduleTask` 中删除 `int col = 0;` 字段（标记为 overlap layout 但从未实际使用）
  - 删除 `schedule_page.dart` 和 `goals_page.dart` 中空的 `initState()` 方法
  - 删除 `DataService` 中未使用的 `importAll()` 方法（和 profile_page 的导入逻辑重复）

  **Must NOT do**:
  - 不删除任何实际在使用的功能代码
  - 不改变任何业务逻辑

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 纯删除操作，每个目标都很明确
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 2, 3, 4)
  - **Blocks**: Task 2 (颜色统一时不应有干扰文件)
  - **Blocked By**: None

  **References**:
  - `lib/pages/schedule_page.dart.bak` — 删除目标
  - `lib/pages/schedule_page.dart.bak2` — 删除目标
  - `lib/models/models.dart` — 删除目标（只有4行export，无引用）
  - `lib/models/task.dart:11` — `int col = 0;` 字段删除
  - `lib/pages/schedule_page.dart:59-61` — 空 initState 删除
  - `lib/pages/goals_page.dart:43-45` — 空 initState 删除
  - `lib/services/data_service.dart:111-125` — 未使用的 importAll 方法

  **Acceptance Criteria**:
  - [ ] `find lib -name "*.bak"` 无输出
  - [ ] `lib/models/models.dart` 不存在
  - [ ] `grep -n "int col" lib/models/task.dart` 无匹配
  - [ ] `flutter analyze` 无错误

  **QA Scenarios**:

  ```
  Scenario: 验证清理后项目可正常编译
    Tool: Bash
    Preconditions: 清理操作已完成
    Steps:
      1. 运行 `flutter analyze`
      2. 检查输出中无错误
    Expected Result: "No issues found!" 或仅有 hints
    Failure Indicators: 任何 error 或 warning 级别的问题
    Evidence: .sisyphus/evidence/task-1-analyze.txt
  ```

  **Commit**: YES
  - Message: `chore: clean up .bak files and dead code`
  - Files: `.bak files`, `models.dart`, `task.dart`, `schedule_page.dart`, `goals_page.dart`, `data_service.dart`

- [x] 2. 统一颜色系统到 AppColors

  **What to do**:
  - 扩展 `lib/utils/app_colors.dart`，添加所有被重复定义的颜色常量：
    - `static const Color primary = Color(0xFFFF6B35);`
    - `static const Color primaryLight = Color(0xFFFFA07A);`
    - `static const Color success = Color(0xFF10B981);`
    - `static const Color danger = Color(0xFFEF4444);`
    - `static const Color purple = Color(0xFF8B5CF6);`
    - `static const Color blue = Color(0xFF3B82F6);`
    - `static const Color warning = Color(0xFFF59E0B);`
    - `static const Color text2 = Color(0xFF6B7280);`
    - `static const Color text3 = Color(0xFF9CA3AF);`
  - 为每种颜色添加深色模式变体（可选，但 primary 等关键色必须有）
  - 逐个文件替换所有 `static const Color` 重复定义为 `AppColors.xxx`
  - 涉及文件：schedule_page.dart, goals_page.dart, review_page.dart, profile_page.dart, reflection_dialog.dart, template_manage_page.dart, journal_list_page.dart

  **Must NOT do**:
  - 不改变任何颜色值，只移动定义位置
  - 不引入新的颜色方案

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 纯重构，不涉及逻辑变更
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 3, 4)
  - **Blocks**: Tasks 8, 11, 17 (后续任务需要统一的颜色系统)
  - **Blocked By**: None

  **References**:
  - `lib/utils/app_colors.dart` — 扩展目标，当前只有7个方法
  - `lib/pages/schedule_page.dart:44-49` — 重复定义 `primary, primaryLight, success, danger, text2, text3`
  - `lib/pages/goals_page.dart:20-25` — 重复定义 `primary, success, danger, text2, text3`
  - `lib/pages/review_page.dart:13-19` — 重复定义 `primary, success, purple, blue, text2, text3`
  - `lib/pages/profile_page.dart:32-36` — 重复定义 `primary, primaryLight, text2, text3`
  - `lib/widgets/reflection_dialog.dart:7-10` — 重复定义 `primary, text2, text3`
  - `lib/pages/template_manage_page.dart:16-19` — 重复定义 `primary, bg, text2, text3`（注意 bg 是硬编码的非深色友好值）
  - `lib/pages/journal_list_page.dart:25-28` — 重复定义 `primary, text2, text3`

  **WHY Each Reference Matters**: 每个引用都是一个需要替换的重复定义。executor 需要在每个文件中：删除 static const 声明 → 替换使用处为 AppColors.xxx → 确保导入 app_colors.dart。

  **Acceptance Criteria**:
  - [ ] `grep -rn "static const Color primary" lib/` 无匹配（全部移到 AppColors）
  - [ ] `grep -rn "static const Color text2" lib/` 无匹配
  - [ ] `flutter analyze` 无错误
  - [ ] AppColors 包含所有之前分散定义的颜色

  **QA Scenarios**:

  ```
  Scenario: 验证颜色统一后编译通过
    Tool: Bash
    Preconditions: 替换完成
    Steps:
      1. `flutter analyze`
      2. `grep -rn "static const Color primary" lib/` → 应无输出
      3. `grep -rn "static const Color text2" lib/` → 应无输出
      4. `grep -rn "AppColors.primary" lib/` → 应有多处匹配
    Expected Result: analyze 通过，无重复定义
    Evidence: .sisyphus/evidence/task-2-colors-unified.txt

  Scenario: 验证 template_manage_page 深色模式修复
    Tool: Bash
    Preconditions: bg 硬编码已替换为 AppColors.background(context)
    Steps:
      1. `grep -n "Color(0xFFF8F9FA)" lib/pages/template_manage_page.dart` → 应无输出
      2. 确认使用了 AppColors.background(context) 或 AppColors.cardBackground(context)
    Expected Result: 无硬编码背景色
    Failure Indicators: 仍有 0xFFF8F9FA 硬编码
    Evidence: .sisyphus/evidence/task-2-dark-mode-fix.txt
  ```

  **Commit**: YES
  - Message: `refactor: unify color constants to AppColors`
  - Files: `app_colors.dart`, 所有 7 个页面/widget 文件

- [x] 3. 搭建测试基础设施 + 模型单元测试

  **What to do**:
  - 确认 `test/` 目录结构：创建 `test/models/`, `test/services/`, `test/providers/` 子目录
  - 为每个 Model 编写单元测试（TDD RED 阶段先写测试）：
    - `test/models/task_test.dart`: 测试 ScheduleTask 构造、toMap/fromMap 序列化、endTime 计算、状态切换
    - `test/models/goal_test.dart`: 测试 Goal 构造、toMap/fromMap、remainingDays 计算、多级嵌套
    - `test/models/journal_entry_test.dart`: 测试 JournalEntry 构造、toMap/fromMap
    - `test/models/reflection_template_test.dart`: 测试 ReflectionTemplate 构造、toMap/fromMap
  - 每个测试至少覆盖：正常构造、序列化反序列化一致性、边界值、null 字段处理
  - 运行 `flutter test` 确认全部通过（TDD GREEN 阶段）

  **Must NOT do**:
  - 不引入 mock 库（当前用 Hive 真实测试）
  - 不写 Widget 测试（Wave 2 后再说）
  - 不修改任何业务代码（只写测试）

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 需要理解模型结构写正确的测试，涉及多个文件
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 2, 4)
  - **Blocks**: Task 5 (DataService 测试依赖模型测试模式)
  - **Blocked By**: None

  **References**:
  - `lib/models/task.dart` — ScheduleTask 模型，58行，含 toMap/fromMap/endTime/TaskStatus enum
  - `lib/models/goal.dart` — Goal 模型，59行，含 toMap/fromMap/remainingDays/GoalStatus enum
  - `lib/models/journal_entry.dart` — JournalEntry 模型，44行，含 toMap/fromMap/JournalType enum
  - `lib/models/reflection_template.dart` — ReflectionTemplate 模型，41行，含 toMap/fromMap/TemplateType enum
  - Flutter test 框架：使用 `test()` 和 `expect()` 函数

  **WHY Each Reference Matters**: executor 需要理解每个模型的字段、enum值、计算属性来写有意义的断言。重点测试序列化一致性（Hive 依赖 toMap/fromMap）。

  **Acceptance Criteria**:
  - [ ] `test/models/` 下有 4 个测试文件
  - [ ] `flutter test test/models/` → ALL PASS
  - [ ] 每个模型至少 5 个测试用例（构造、序列化、反序列化、边界值、null处理）
  - [ ] 总测试数 ≥ 20

  **QA Scenarios**:

  ```
  Scenario: 验证模型测试全部通过
    Tool: Bash
    Preconditions: 测试文件已创建
    Steps:
      1. 运行 `flutter test test/models/`
      2. 检查输出中所有测试通过
    Expected Result: "All tests passed!" 且测试数 ≥ 20
    Failure Indicators: 任何测试失败
    Evidence: .sisyphus/evidence/task-3-model-tests.txt

  Scenario: 验证序列化一致性（round-trip）
    Tool: Bash
    Preconditions: toMap/fromMap 测试已包含
    Steps:
      1. 确认每个模型有 `object.toMap() → Model.fromMap() → equals original` 测试
      2. 运行 `flutter test test/models/`
    Expected Result: round-trip 测试通过
    Evidence: .sisyphus/evidence/task-3-serialization.txt
  ```

  **Commit**: YES
  - Message: `test: add test infrastructure and model unit tests`
  - Files: `test/models/task_test.dart`, `test/models/goal_test.dart`, `test/models/journal_entry_test.dart`, `test/models/reflection_template_test.dart`

- [x] 4. 添加 timezone 依赖 + 通知调度修复

  **What to do**:
  - 在 `pubspec.yaml` 添加 `timezone: ^0.9.4` 和 `flutter_native_timezone: ^2.0.0` 依赖
  - 重写 `NotificationService.scheduleReminder()`：
    - 使用 `tz.TZDateTime` 替代 `DateTime` 进行调度
    - 实现 `zonedSchedule()` 方法真正按时触发通知
  - 实现 `scheduleMorningReminder(TimeOfDay time)` — 每天 8:00（可配置）触发
  - 实现 `scheduleEveningReminder(TimeOfDay time)` — 每天 21:00（可配置）触发
  - 在 `init()` 中初始化 timezone 数据
  - 在 HomePage 初始化时调用晨间/晚间提醒调度
  - 为 NotificationService 编写基本测试（测试调度参数）

  **Must NOT do**:
  - 不引入 firebase_messaging 或其他推送服务
  - 不改变通知的 UI 样式

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 依赖添加和单一服务修改，范围明确
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 2, 3)
  - **Blocks**: None
  - **Blocked By**: None

  **References**:
  - `lib/services/notification_service.dart` — 当前71行，`scheduleReminder()` 在第25行只是立即显示
  - `flutter_local_notifications` package — `zonedSchedule()` API 用于定时通知
  - `timezone` package — 提供 `TZDateTime` 用于时区感知调度
  - `lib/main.dart:17` — `NotificationService.init()` 调用位置
  - PRODUCT_SPEC.md — 晨间8:00、晚间21:00提醒规格

  **Acceptance Criteria**:
  - [ ] `pubspec.yaml` 包含 timezone 和 flutter_native_timezone 依赖
  - [ ] `NotificationService.scheduleReminder()` 使用 `zonedSchedule()`
  - [ ] `scheduleMorningReminder()` 和 `scheduleEveningReminder()` 存在且能按时触发
  - [ ] `flutter analyze` 无错误

  **QA Scenarios**:

  ```
  Scenario: 验证通知服务使用 zonedSchedule
    Tool: Bash
    Preconditions: 代码修改完成
    Steps:
      1. `grep -n "zonedSchedule" lib/services/notification_service.dart`
      2. 确认 `scheduleReminder` 方法中使用了 TZDateTime
      3. 确认无 "For now, just show immediately" 注释
    Expected Result: zonedSchedule 存在，无临时变通方案
    Evidence: .sisyphus/evidence/task-4-notification-scheduling.txt

  Scenario: 验证定时提醒方法存在
    Tool: Bash
    Preconditions: 代码修改完成
    Steps:
      1. `grep -n "scheduleMorningReminder" lib/services/notification_service.dart` → 有匹配
      2. `grep -n "scheduleEveningReminder" lib/services/notification_service.dart` → 有匹配
      3. 检查方法签名接受 TimeOfDay 或具体时间参数
    Expected Result: 两个方法都存在且接受时间参数
    Evidence: .sisyphus/evidence/task-4-reminder-methods.txt
  ```

  **Commit**: YES
  - Message: `feat: implement real notification scheduling with timezone support`
  - Files: `pubspec.yaml`, `pubspec.lock`, `notification_service.dart`

- [x] 5. DataService 重构 — 错误处理 + 事务安全 + 测试

  **What to do**:
  - 为所有 Hive 操作添加 try/catch 错误处理：
    - `init()`: 处理 Hive 初始化失败（目录不存在、权限不足等）
    - `getTasks()/getGoals()/getJournals()/getCustomTemplates()`: 处理数据损坏（fromMap 失败时跳过该项而非崩溃）
    - `saveXxx()/deleteXxx()`: 处理写入失败
  - 修复 `saveAllTasks()` 和 `saveAllGoals()` 的事务安全问题：
    - 先写入临时 key，成功后删除旧数据，而非先 clear 再逐个写入
    - 或使用 Hive 的 `putAll()` 批量操作
  - 为 DataService 编写单元测试（使用 Hive 的内存测试模式）：
    - 测试 CRUD 操作正确性
    - 测试数据损坏时的容错性
    - 测试 saveAll 的事务安全性

  **Must NOT do**:
  - 不改变外部 API 签名（保持向后兼容）
  - 不切换到 SQLite

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: 涉及数据层安全性和测试，需要仔细处理边界情况
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 2 (sequential with Task 6)
  - **Blocks**: Task 6
  - **Blocked By**: Task 3 (需要测试模式参考)

  **References**:
  - `lib/services/data_service.dart` — 126行，所有 Hive CRUD 操作
  - `lib/services/data_service.dart:37-43` — `saveAllTasks()` 先 clear() 再逐个 put()，危险
  - `lib/services/data_service.dart:58-64` — `saveAllGoals()` 同样问题
  - `lib/services/data_service.dart:24-27` — `getTasks()` fromMap 可能抛异常
  - `lib/models/task.dart` — ScheduleTask.fromMap() 可能因类型转换失败
  - Hive 测试模式：使用 `Hive.init('test_path')` 或内存模式

  **Acceptance Criteria**:
  - [ ] 所有 DataService 方法有 try/catch 保护
  - [ ] getTasks() 等方法在数据损坏时不崩溃（跳过损坏记录）
  - [ ] saveAllTasks() 使用安全写入策略
  - [ ] `flutter test test/services/data_service_test.dart` → ALL PASS
  - [ ] 测试覆盖：正常CRUD、数据损坏容错、边界空数据

  **QA Scenarios**:

  ```
  Scenario: 验证 DataService 测试通过
    Tool: Bash
    Steps:
      1. `flutter test test/services/data_service_test.dart`
    Expected Result: All tests passed, ≥10 test cases
    Evidence: .sisyphus/evidence/task-5-data-service-tests.txt

  Scenario: 验证数据损坏容错
    Tool: Bash
    Preconditions: 测试中包含损坏数据处理
    Steps:
      1. 确认测试中有 "corrupted data" 或 "invalid map" 相关测试
      2. 运行测试
    Expected Result: getTasks() 不抛异常，跳过损坏记录
    Evidence: .sisyphus/evidence/task-5-corruption-tolerance.txt
  ```

  **Commit**: YES
  - Message: `refactor: DataService error handling and transaction safety with tests`
  - Files: `data_service.dart`, `test/services/data_service_test.dart`

- [x] 6. Riverpod Provider 体系搭建

  **What to do**:
  - 创建 `lib/providers/` 目录
  - 创建以下 Provider 文件：
    - `lib/providers/task_provider.dart`: 
      - `taskListProvider` — StateNotifierProvider 管理所有 tasks
      - `tasksForDateProvider(selectedDate)` — 根据日期过滤 tasks
    - `lib/providers/goal_provider.dart`:
      - `goalListProvider` — StateNotifierProvider 管理所有 goals
      - `rootGoalsProvider` — 过滤出顶级目标
      - `childrenOfProvider(parentId)` — 获取子目标
    - `lib/providers/journal_provider.dart`:
      - `journalListProvider` — StateNotifierProvider 管理所有 journals
      - `todayReflectionProvider` — 今日是否有反思
      - `todayReviewProvider` — 今日是否有复盘
    - `lib/providers/template_provider.dart`:
      - `customTemplateProvider` — 管理自定义模板
      - `allReflectionTemplatesProvider` — 合并内置+自定义反思模板
      - `allReviewTemplatesProvider` — 合并内置+自定义复盘模板
    - `lib/providers/settings_provider.dart`:
      - `themeModeProvider` — 主题模式
      - `seedColorProvider` — 主题色
  - 每个 StateNotifier 包含完整的 CRUD 操作
  - Provider 在初始化时从 DataService 加载数据
  - 每次 state 变更时自动持久化到 Hive
  - 为 Provider 编写单元测试

  **Must NOT do**:
  - 不修改现有页面代码（Task 7 负责）
  - 不删除 DataService（Provider 依赖它）
  - 不使用 StateProvider（用 StateNotifierProvider 更规范）

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: 核心架构变更，需要设计合理的 Provider 结构
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 2 (after Task 5)
  - **Blocks**: Task 7
  - **Blocked By**: Task 5

  **References**:
  - `lib/main.dart:85-142` — 当前 HomePage 中的状态管理逻辑（这是 Provider 要替换的）
  - `lib/services/data_service.dart` — Provider 需要调用的数据层
  - `lib/models/` — 所有模型文件
  - `lib/widgets/reflection_dialog.dart:12-53` — 内置模板列表（需要被 Provider 管理）
  - `lib/pages/schedule_page.dart:10-17` — 当前通过构造函数接收的所有数据
  - flutter_riverpod package — StateNotifierProvider, ConsumerWidget, ref.watch, ref.read

  **WHY Each Reference Matters**: executor 需要看 HomePage 的 _loadData/_saveAndRefresh 逻辑来理解当前数据流，然后将其封装到 Provider 中。reflection_dialog 的内置模板需要合并到 template provider。

  **Acceptance Criteria**:
  - [ ] `lib/providers/` 目录存在，包含 5 个 provider 文件
  - [ ] 每个 Provider 使用 StateNotifierProvider
  - [ ] Provider 初始化时从 DataService 加载数据
  - [ ] StateNotifier 的每个修改方法调用 DataService 持久化
  - [ ] `flutter test test/providers/` → ALL PASS
  - [ ] 无循环依赖

  **QA Scenarios**:

  ```
  Scenario: 验证 Provider 文件结构完整
    Tool: Bash
    Steps:
      1. `ls lib/providers/` → 应有 5 个文件
      2. `grep -l "StateNotifierProvider" lib/providers/*.dart` → 5 个匹配
      3. `grep -l "DataService" lib/providers/*.dart` → 确认 Provider 调用 DataService
    Expected Result: 5 个 Provider 文件，全部使用 StateNotifierProvider
    Evidence: .sisyphus/evidence/task-6-provider-structure.txt

  Scenario: 验证 Provider 测试通过
    Tool: Bash
    Steps:
      1. `flutter test test/providers/`
    Expected Result: ALL PASS, ≥10 test cases
    Evidence: .sisyphus/evidence/task-6-provider-tests.txt
  ```

  **Commit**: YES
  - Message: `feat: introduce Riverpod state management with providers`
  - Files: `lib/providers/*.dart`, `test/providers/*.dart`

- [x] 7. main.dart + HomePage 迁移到 Riverpod

  **What to do**:
  - 修改 `main.dart`:
    - 用 `ProviderScope` 包裹 runApp
    - `RigongyizuApp` 改为 `ConsumerWidget`（使用 ref 读取 themeModeProvider/seedColorProvider）
    - `HomePage` 改为 `ConsumerWidget`（使用 ref 读取所有 Provider）
    - 删除 HomePage 中的 `_tasks`, `_goals`, `_journals`, `_customTemplates` 状态变量
    - 删除 `_loadData()`, `_seedDemoData()`, `_saveAndRefresh()` 方法
    - 示例数据初始化逻辑移到 Provider 层
  - 修改所有 4 个子页面（SchedulePage, GoalsPage, ReviewPage, ProfilePage）：
    - 改为 `ConsumerWidget` 或 `ConsumerStatefulWidget`
    - 移除构造函数中的数据参数和回调参数
    - 使用 `ref.watch()` 读取 Provider
    - 使用 `ref.read()` 调用 StateNotifier 方法
  - 更新 `reflection_dialog.dart`：
    - 不再需要传入 journals 和 customTemplates 参数
    - 从 Provider 获取数据
  - 确保所有功能不回归：运行全量测试 + flutter analyze

  **Must NOT do**:
  - 不改变任何用户可见的功能行为
  - 不改变 UI 布局或样式
  - 不引入新的 Provider（只使用 Task 6 创建的）

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 涉及所有文件的联动修改，需要仔细确保不回归
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 2 (after Task 6)
  - **Blocks**: Tasks 8-12 (所有 Wave 3 任务)
  - **Blocked By**: Task 6

  **References**:
  - `lib/main.dart` — 175行，包含 App 配置和 HomePage 状态管理
  - `lib/main.dart:85-142` — `_HomePageState` 全部需要改写
  - `lib/pages/schedule_page.dart:10-17` — 构造函数参数要删除
  - `lib/pages/goals_page.dart:6-11` — 构造函数参数要删除
  - `lib/pages/review_page.dart:6-11` — 构造函数参数要删除
  - `lib/pages/profile_page.dart:17-30` — 构造函数参数要删除
  - `lib/widgets/reflection_dialog.dart:56-65` — 静态方法签名需要调整
  - `lib/pages/journal_list_page.dart:8-12` — 构造函数参数要删除
  - `lib/pages/template_manage_page.dart:5-9` — 构造函数参数要删除

  **Acceptance Criteria**:
  - [ ] `main.dart` 中 `ProviderScope` 包裹 runApp
  - [ ] HomePage 不再持有任何数据状态变量
  - [ ] 所有子页面通过 ref.watch/read 访问数据
  - [ ] 无构造函数传递 tasks/goals/journals/templates 数据
  - [ ] `flutter analyze` 无错误
  - [ ] `flutter test` 全部通过
  - [ ] 示例数据首次启动仍正常初始化

  **QA Scenarios**:

  ```
  Scenario: 验证无 prop drilling
    Tool: Bash
    Steps:
      1. `grep -n "required this.tasks" lib/pages/*.dart` → 应无输出
      2. `grep -n "required this.goals" lib/pages/*.dart` → 应无输出
      3. `grep -n "onTasksChanged" lib/pages/*.dart` → 应无输出
      4. `grep -n "ref.watch" lib/pages/*.dart` → 应有多处匹配
    Expected Result: 无 prop drilling，全部使用 ref
    Evidence: .sisyphus/evidence/task-7-no-prop-drilling.txt

  Scenario: 验证 ProviderScope 设置
    Tool: Bash
    Steps:
      1. `grep -n "ProviderScope" lib/main.dart` → 有匹配
      2. `grep -n "_tasks" lib/main.dart` → 应无 HomePage 内部状态
    Expected Result: ProviderScope 存在，HomePage 无数据状态
    Evidence: .sisyphus/evidence/task-7-provider-scope.txt
  ```

  **Commit**: YES
  - Message: `refactor: migrate HomePage and all pages to Riverpod`
  - Files: `main.dart`, all page files, `reflection_dialog.dart`

- [x] 8. schedule_page 拆分 — 日视图组件

  **What to do**:
  - 从 `schedule_page.dart` 提取日视图相关代码到独立文件：
    - `lib/pages/schedule/widgets/day_view.dart` — 日视图主体（时间网格 + 任务块 + 空闲时段）
    - `lib/pages/schedule/widgets/task_block.dart` — 任务色块组件（含拖拽、完成、resize handle）
    - `lib/pages/schedule/widgets/now_line.dart` — 当前时间指示线
  - `schedule_page.dart` 缩减为调度器：管理视图切换、日期选择、组织子组件
  - 使用 ref.watch/read 获取数据（已在 Task 7 迁移到 Riverpod）
  - 保持所有日视图功能：缩放、滑动切日期、拖拽调时间、resize 调时长、点击添加任务

  **Must NOT do**:
  - 不改变日视图的功能行为
  - 不删除任何交互（拖拽、点击、缩放）
  - 不改变视觉样式

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 大文件拆分，需要保持功能完整性
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 9, 10, 11, 12)
  - **Blocks**: Task 14
  - **Blocked By**: Tasks 2, 7

  **References**:
  - `lib/pages/schedule_page.dart:686-929` — `_buildTimeGrid()` + `_buildTaskBlocks()` + `_buildNowLine()` 核心渲染逻辑
  - `lib/pages/schedule_page.dart:733-882` — `_buildTaskBlocks()` 含拖拽、resize handle、完成 checkbox
  - `lib/pages/schedule_page.dart:884-893` — `_buildNowLine()` 当前时间线
  - `lib/pages/schedule_page.dart:307-324` — 空闲时间计算逻辑
  - `lib/pages/schedule_page.dart:234-249` — `_groupByOverlap()` 重叠分组算法

  **Acceptance Criteria**:
  - [ ] `lib/pages/schedule/widgets/` 目录存在
  - [ ] `schedule_page.dart` 行数 < 300
  - [ ] 日视图功能完整：拖拽、resize、缩放、滑动、添加任务
  - [ ] `flutter analyze` 无错误

  **QA Scenarios**:

  ```
  Scenario: 验证文件拆分结构
    Tool: Bash
    Steps:
      1. `wc -l lib/pages/schedule_page.dart` → 应 < 300
      2. `ls lib/pages/schedule/widgets/` → 应有 day_view.dart, task_block.dart, now_line.dart
    Expected Result: schedule_page < 300行，3个新组件文件存在
    Evidence: .sisyphus/evidence/task-8-file-split.txt
  ```

  **Commit**: YES (groups with Task 9, 10)
  - Message: `refactor: split schedule_page into day_view, task_block, now_line components`
  - Files: `schedule_page.dart`, `schedule/widgets/*.dart`

- [x] 9. schedule_page 拆分 — 周视图 + 月视图组件

  **What to do**:
  - 从 `schedule_page.dart` 提取周视图和月视图到独立文件：
    - `lib/pages/schedule/widgets/week_view.dart` — 周视图（7天横排 + 任务缩略）
    - `lib/pages/schedule/widgets/month_view.dart` — 月视图（日历网格 + 任务计数）
  - 修复周视图只显示12小时的问题：扩展到18小时(6:00-24:00)
  - 月视图保持现有功能

  **Must NOT do**:
  - 不改变周视图和月视图的布局风格

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 两个视图组件提取，加上周视图bug修复
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 8, 10, 11, 12)
  - **Blocks**: Task 16
  - **Blocked By**: Task 7

  **References**:
  - `lib/pages/schedule_page.dart:465-553` — `_buildMonthView()` 月视图
  - `lib/pages/schedule_page.dart:555-684` — `_buildWeekView()` 周视图
  - `lib/pages/schedule_page.dart:616` — `itemCount: 18 - 6` 只显示12小时，应改为 `_endHour - _startHour` = 18

  **Acceptance Criteria**:
  - [ ] `week_view.dart` 和 `month_view.dart` 存在
  - [ ] 周视图显示完整 18 小时（6:00-24:00）
  - [ ] `flutter analyze` 无错误

  **QA Scenarios**:

  ```
  Scenario: 验证周视图18小时
    Tool: Bash
    Steps:
      1. `grep -n "itemCount" lib/pages/schedule/widgets/week_view.dart`
      2. 确认 itemCount 为 18 或 _endHour - _startHour
    Expected Result: itemCount 反映18小时而非12小时
    Evidence: .sisyphus/evidence/task-9-week-view-18h.txt
  ```

  **Commit**: YES (groups with Task 8, 10)
  - Message: `refactor: extract week_view and month_view, fix week view to show 18h`
  - Files: `schedule/widgets/week_view.dart`, `schedule/widgets/month_view.dart`

- [x] 10. schedule_page 拆分 — 任务弹窗组件

  **What to do**:
  - 从 `schedule_page.dart` 提取任务相关弹窗到独立文件：
    - `lib/pages/schedule/widgets/task_dialog.dart` — 添加/编辑任务弹窗
    - `lib/pages/schedule/widgets/overlap_sheet.dart` — 重叠任务 bottom sheet
  - 弹窗使用 ref.read 调用 Provider 的添加/编辑/删除方法

  **Must NOT do**:
  - 不改变弹窗的 UI 和功能

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 代码提取，逻辑不变
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 8, 9, 11, 12)
  - **Blocks**: Task 14
  - **Blocked By**: Task 7

  **References**:
  - `lib/pages/schedule_page.dart:97-232` — `_showTaskDialog()` 添加/编辑任务弹窗
  - `lib/pages/schedule_page.dart:252-305` — `_showOverlapSheet()` + `_overlapTaskItem()` 重叠任务

  **Acceptance Criteria**:
  - [ ] `task_dialog.dart` 和 `overlap_sheet.dart` 存在
  - [ ] `flutter analyze` 无错误

  **QA Scenarios**:

  ```
  Scenario: 验证弹窗组件独立
    Tool: Bash
    Steps:
      1. `ls lib/pages/schedule/widgets/task_dialog.dart` → 存在
      2. `ls lib/pages/schedule/widgets/overlap_sheet.dart` → 存在
    Expected Result: 两个文件存在
    Evidence: .sisyphus/evidence/task-10-dialog-extracted.txt
  ```

  **Commit**: YES (groups with Task 8, 9)
  - Message: `refactor: extract task_dialog and overlap_sheet from schedule_page`
  - Files: `schedule/widgets/task_dialog.dart`, `schedule/widgets/overlap_sheet.dart`

- [x] 11. goals_page 拆分 — 目标树 + 甘特图组件

  **What to do**:
  - 从 `goals_page.dart` 提取核心视图到独立文件：
    - `lib/pages/goals/widgets/goal_tree.dart` — 目标列表 + 树状展开 + 进度条
    - `lib/pages/goals/widgets/gantt_chart.dart` — 顶部甘特图总览
  - 目标树支持无限层级嵌套展开/折叠
  - 使用 ref.watch/read 获取数据

  **Must NOT do**:
  - 不改变目标树和甘特图的功能和视觉

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 大文件拆分，需要保持功能完整
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 8, 9, 10, 12)
  - **Blocks**: Task 18
  - **Blocked By**: Tasks 2, 7

  **References**:
  - `lib/pages/goals_page.dart:1-718` — 全文件，需要识别甘特图和目标树的代码边界
  - 当前 `goals_page.dart` 包含：甘特图渲染、目标列表、树状展开、添加目标弹窗、添加子目标弹窗、添加到日程弹窗

  **Acceptance Criteria**:
  - [ ] `goal_tree.dart` 和 `gantt_chart.dart` 存在
  - [ ] `goals_page.dart` 行数 < 300（弹窗还在里面，下一步提取）
  - [ ] `flutter analyze` 无错误

  **QA Scenarios**:

  ```
  Scenario: 验证目标页拆分
    Tool: Bash
    Steps:
      1. `wc -l lib/pages/goals_page.dart` → 应 < 300
      2. `ls lib/pages/goals/widgets/goal_tree.dart` → 存在
      3. `ls lib/pages/goals/widgets/gantt_chart.dart` → 存在
    Expected Result: goals_page < 300行，组件文件存在
    Evidence: .sisyphus/evidence/task-11-goals-split.txt
  ```

  **Commit**: YES (groups with Task 12)
  - Message: `refactor: extract goal_tree and gantt_chart from goals_page`
  - Files: `goals_page.dart`, `goals/widgets/goal_tree.dart`, `goals/widgets/gantt_chart.dart`

- [x] 12. goals_page 拆分 — 目标弹窗组件

  **What to do**:
  - 从 `goals_page.dart` 提取弹窗到独立文件：
    - `lib/pages/goals/widgets/add_goal_dialog.dart` — 新建目标弹窗
    - `lib/pages/goals/widgets/add_subgoal_dialog.dart` — 添加子目标弹窗
    - `lib/pages/goals/widgets/add_to_schedule_dialog.dart` — 添加到日程弹窗
  - `goals_page.dart` 缩减为调度器 + FAB 按钮

  **Must NOT do**:
  - 不改变弹窗功能

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 纯代码提取
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 8, 9, 10, 11)
  - **Blocks**: Task 13, 19
  - **Blocked By**: Task 7

  **References**:
  - `lib/pages/goals_page.dart` — 弹窗代码分散在 State 类中

  **Acceptance Criteria**:
  - [ ] 3 个弹窗组件文件存在
  - [ ] `goals_page.dart` 行数 < 150
  - [ ] `flutter analyze` 无错误

  **QA Scenarios**:

  ```
  Scenario: 验证弹窗组件提取
    Tool: Bash
    Steps:
      1. `ls lib/pages/goals/widgets/` → 应有 5 个文件（含 Task 11 的2个）
      2. `wc -l lib/pages/goals_page.dart` → 应 < 150
    Expected Result: goals_page 极简，弹窗独立
    Evidence: .sisyphus/evidence/task-12-goals-dialogs.txt
  ```

  **Commit**: YES (groups with Task 11)
  - Message: `refactor: extract goal dialogs from goals_page`
  - Files: `goals/widgets/add_goal_dialog.dart`, `goals/widgets/add_subgoal_dialog.dart`, `goals/widgets/add_to_schedule_dialog.dart`

- [x] 13. 目标进度自动计算 + 目标编辑功能

  **What to do**:
  - 实现目标进度自动计算逻辑：
    - 如果目标有关联的子目标：progressPct = (已完成子目标数 / 总子目标数) * 100
    - 如果目标有关联的任务：progressPct = (已完成任务数 / 总任务数) * 100
    - 如果都没有：保持手动设置
    - 在 GoalProvider 中添加计算方法，每次 tasks/goals 变更时重新计算
  - 添加目标编辑功能：
    - 修改 `add_goal_dialog.dart` 支持编辑模式（传入 Goal 参数时为编辑）
    - 可编辑字段：标题、截止日期、优先级、描述
    - 长按或点击编辑图标触发编辑弹窗
    - 在目标展开区域添加编辑按钮
  - 为进度计算编写单元测试

  **Must NOT do**:
  - 不改变目标列表的 UI 布局
  - 不引入新的目标属性

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: 需要设计进度计算算法 + 编辑功能联动
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 14, 15, 16)
  - **Blocks**: None
  - **Blocked By**: Task 12

  **References**:
  - `lib/models/goal.dart:22` — `progressPct` 字段（当前从未被自动更新）
  - `lib/models/goal.dart:10` — `progressPct` 初始化为 0.0
  - `lib/providers/goal_provider.dart` — 需要在这里添加进度计算
  - `lib/providers/task_provider.dart` — 需要读取 tasks 来计算关联进度
  - `lib/pages/goals/widgets/add_goal_dialog.dart` — 需要改为支持编辑模式

  **Acceptance Criteria**:
  - [ ] 目标进度根据子目标/任务自动计算
  - [ ] 目标列表中显示的计算进度与实际一致
  - [ ] 编辑弹窗可修改标题、截止日期、优先级
  - [ ] `flutter test` 包含进度计算测试

  **QA Scenarios**:

  ```
  Scenario: 验证目标进度自动计算
    Tool: Bash
    Steps:
      1. `grep -n "progressPct" lib/providers/goal_provider.dart` → 有计算逻辑
      2. 运行进度计算相关测试
    Expected Result: progressPct 根据 children/tasks 自动更新
    Evidence: .sisyphus/evidence/task-13-auto-progress.txt

  Scenario: 验证目标编辑弹窗
    Tool: Bash
    Steps:
      1. `grep -n "isEdit" lib/pages/goals/widgets/add_goal_dialog.dart` → 有编辑模式
      2. `grep -n "编辑目标" lib/pages/goals/widgets/add_goal_dialog.dart` → 标题支持编辑模式
    Expected Result: 弹窗支持创建和编辑两种模式
    Evidence: .sisyphus/evidence/task-13-goal-edit.txt
  ```

  **Commit**: YES
  - Message: `feat: goal auto-progress calculation and editing`
  - Files: `goal_provider.dart`, `add_goal_dialog.dart`, `goal_tree.dart`, tests

- [x] 14. 任务多状态(推迟/取消) + 任务备注 UI

  **What to do**:
  - 在任务编辑弹窗（task_dialog.dart）中添加状态切换选项：
    - 当前只有「完成」按钮
    - 新增：推迟 → TaskStatus.postponed、取消 → TaskStatus.cancelled
    - 不同状态有不同的视觉标记（推迟=黄色、取消=灰色+删除线）
  - 在任务色块上显示不同状态的视觉样式：
    - done: 当前已有（半透明+删除线）
    - postponed: 黄色背景+⏭️标记
    - cancelled: 灰色背景+删除线+❌标记
  - 在任务编辑弹窗中添加备注输入：
    - TextField（多行，maxLines: 3）
    - 绑定到 task.notes 字段
    - 已有任务编辑时回显现有备注

  **Must NOT do**:
  - 不改变任务色块的基本布局

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 涉及 UI 交互和状态管理联动
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 13, 15, 16)
  - **Blocks**: None
  - **Blocked By**: Tasks 8, 10

  **References**:
  - `lib/models/task.dart:53-58` — TaskStatus enum (pending/done/postponed/cancelled)
  - `lib/pages/schedule/widgets/task_block.dart` — 任务色块（需要添加 postponed/cancelled 样式）
  - `lib/pages/schedule/widgets/task_dialog.dart` — 任务弹窗（需要添加状态按钮和备注输入）
  - `lib/models/task.dart:10` — `String notes` 字段（当前无 UI）

  **Acceptance Criteria**:
  - [ ] 任务弹窗有推迟和取消按钮
  - [ ] 任务色块显示不同状态样式
  - [ ] 任务弹窗有备注输入框
  - [ ] 备注正确持久化到 Hive

  **QA Scenarios**:

  ```
  Scenario: 验证多状态UI
    Tool: Bash
    Steps:
      1. `grep -n "postponed" lib/pages/schedule/widgets/task_block.dart` → 有视觉处理
      2. `grep -n "cancelled" lib/pages/schedule/widgets/task_block.dart` → 有视觉处理
      3. `grep -n "notes" lib/pages/schedule/widgets/task_dialog.dart` → 有备注输入
    Expected Result: postponed/cancelled 有视觉区分，notes 有输入
    Evidence: .sisyphus/evidence/task-14-multi-status.txt
  ```

  **Commit**: YES
  - Message: `feat: task postpone/cancel status + notes UI`
  - Files: `task_block.dart`, `task_dialog.dart`

- [x] 15. fl_chart 替换复盘页手绘图表

  **What to do**:
  - 用 fl_chart 替换 review_page.dart 中的手绘周统计柱状图：
    - 使用 `BarChart` widget 替换 Row+Container 手绘
    - 显示每日反思+复盘记录数量
    - 支持 fl_chart 内置的触摸交互（显示具体数值）
  - 用 fl_chart 添加完成率趋势折线图（规格中有但未实现）：
    - 近 7 天的完成率趋势
    - 使用 `LineChart` widget
  - 保持热力图用手绘方式（fl_chart 不直接支持热力图，当前实现可用）

  **Must NOT do**:
  - 不改变复盘页的整体布局
  - 不删除热力图

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: 图表是视觉组件，需要正确使用 fl_chart API
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 13, 14, 16)
  - **Blocks**: None
  - **Blocked By**: Task 7

  **References**:
  - `lib/pages/review_page.dart:83-128` — 手绘周统计柱状图（Row + Container）
  - `lib/pages/review_page.dart:218-239` — 热力图（保持不变）
  - `pubspec.yaml` — `fl_chart: ^0.70.2` 已引入
  - fl_chart 文档：BarChart, LineChart widget

  **Acceptance Criteria**:
  - [ ] 复盘页使用 fl_chart BarChart 显示周统计
  - [ ] 新增完成率趋势折线图（LineChart）
  - [ ] 热力图保持不变
  - [ ] 图表支持触摸查看数值
  - [ ] `flutter analyze` 无错误

  **QA Scenarios**:

  ```
  Scenario: 验证 fl_chart 使用
    Tool: Bash
    Steps:
      1. `grep -n "BarChart" lib/pages/review_page.dart` → 有匹配
      2. `grep -n "LineChart" lib/pages/review_page.dart` → 有匹配
      3. `grep -n "import.*fl_chart" lib/pages/review_page.dart` → 有 fl_chart 导入
    Expected Result: 使用了 fl_chart 的 BarChart 和 LineChart
    Evidence: .sisyphus/evidence/task-15-fl-chart.txt
  ```

  **Commit**: YES
  - Message: `feat: replace hand-drawn charts with fl_chart`
  - Files: `review_page.dart`

- [x] 16. 周视图扩展18小时 + 导入数据后自动刷新

  **What to do**:
  - 确认周视图（week_view.dart）已显示18小时（Task 9 应已完成）
  - 修复数据导入后的自动刷新问题：
    - 当前 `profile_page.dart` 导入后显示 "请重启应用"
    - 应改为：导入成功后触发 Provider 重新从 DataService 加载数据
    - 在 ProfilePage 中使用 ref.invalidate() 或调用 Provider 的 reload 方法
    - 导入后自动刷新所有页面数据

  **Must NOT do**:
  - 不改变导入/导出的文件格式

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 两个小修复
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 13, 14, 15)
  - **Blocks**: None
  - **Blocked By**: Task 9

  **References**:
  - `lib/pages/profile_page.dart:129-145` — 导入数据逻辑，目前只 `DataService.saveTask` 等但没刷新 Provider
  - `lib/providers/task_provider.dart` — 需要 invalidate 或添加 reload 方法

  **Acceptance Criteria**:
  - [ ] 导入数据后页面自动更新，无需重启
  - [ ] 周视图显示完整18小时

  **QA Scenarios**:

  ```
  Scenario: 验证导入后刷新
    Tool: Bash
    Steps:
      1. `grep -n "invalidate\|reload\|refresh" lib/pages/profile_page.dart` → 有 Provider 刷新调用
      2. `grep -n "请重启应用" lib/pages/profile_page.dart` → 应无此文本
    Expected Result: 导入后刷新 Provider 而非要求重启
    Evidence: .sisyphus/evidence/task-16-import-refresh.txt
  ```

  **Commit**: YES
  - Message: `fix: auto-refresh after data import`
  - Files: `profile_page.dart`, `task_provider.dart`, `goal_provider.dart`, `journal_provider.dart`

- [x] 17. 深色模式全面修复

  **What to do**:
  - 审查所有页面和组件，确保深色模式下：
    - 文字颜色可读（深色背景上浅色文字）
    - 卡片背景适配（使用 AppColors.cardBackground）
    - 输入框背景适配
    - 弹窗背景适配
    - 图表颜色适配
  - 重点检查文件（之前使用硬编码颜色的）：
    - `template_manage_page.dart` — 之前用硬编码 `bg = Color(0xFFF8F9FA)`
    - `goals_page.dart` — 检查甘特图颜色
    - `journal_list_page.dart` — 检查卡片颜色
    - `reflection_dialog.dart` — 检查弹窗颜色
  - 确保 fl_chart 图表在深色模式下颜色正确

  **Must NOT do**:
  - 不改变浅色模式的任何颜色

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: 需要仔细审查和调整视觉样式
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 18, 19, 20)
  - **Blocks**: None
  - **Blocked By**: Tasks 2, 7

  **References**:
  - `lib/utils/app_colors.dart` — 深色模式颜色工具
  - `lib/main.dart:54-64` — light/dark ThemeData 定义
  - `lib/pages/template_manage_page.dart` — 已在 Task 2 中修复 bg 硬编码，需验证

  **Acceptance Criteria**:
  - [ ] 所有页面使用 AppColors 动态颜色
  - [ ] 无硬编码浅色背景（`Color(0xFFF...)` 之类）
  - [ ] `grep -rn "Color(0xFFF8F9FA)" lib/` 无输出

  **QA Scenarios**:

  ```
  Scenario: 验证无硬编码浅色
    Tool: Bash
    Steps:
      1. `grep -rn "Color(0xFFF" lib/` → 检查是否有未适配深色模式的硬编码
    Expected Result: 无硬编码浅色背景
    Evidence: .sisyphus/evidence/task-17-dark-mode.txt
  ```

  **Commit**: YES
  - Message: `fix: dark mode support across all pages`
  - Files: 多个页面和组件文件

- [x] 18. 日视图滑动优化 + 目标优先级显示

  **What to do**:
  - 改善日视图左右滑动切换日期的体验：
    - 当前只在时间网格区域响应水平滑动
    - 考虑使用 `PageView` 替代当前日期切换逻辑
    - 或使用 `GestureDetector` 包裹整个页面（包括头部和反思/复盘卡片）
  - 在目标列表中显示优先级标识：
    - 高优先级：🔴 红色标记
    - 中优先级：🟡 黄色标记
    - 低优先级：🟢 绿色标记
    - 在目标行的进度条旁边显示

  **Must NOT do**:
  - 不改变日期切换的方向（左=前一天，右=后一天）

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 两个小功能优化
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 17, 19, 20)
  - **Blocks**: None
  - **Blocked By**: Tasks 8, 11

  **References**:
  - `lib/pages/schedule_page.dart:694-698` — 当前水平滑动检测只在时间网格
  - `lib/pages/goals/widgets/goal_tree.dart` — 目标列表，需要添加优先级标识
  - `lib/models/goal.dart:6` — `int priority` 字段（0=低, 1=中, 2=高，看创建弹窗的 priority 变量）

  **Acceptance Criteria**:
  - [ ] 日视图可以在整个页面区域滑动切换日期
  - [ ] 目标列表显示优先级标识
  - [ ] `flutter analyze` 无错误

  **QA Scenarios**:

  ```
  Scenario: 验证滑动和优先级
    Tool: Bash
    Steps:
      1. `grep -n "PageView\|onHorizontalDrag" lib/pages/schedule_page.dart` → 有更广范围的滑动处理
      2. `grep -n "priority\|优先" lib/pages/goals/widgets/goal_tree.dart` → 有优先级显示
    Expected Result: 滑动范围扩大，优先级可见
    Evidence: .sisyphus/evidence/task-18-swipe-priority.txt
  ```

  **Commit**: YES
  - Message: `feat: improve date swipe UX + show goal priority`
  - Files: `schedule_page.dart`, `goal_tree.dart`

- [x] 19. 删除确认弹窗 + 关于页面 + 清理空操作

  **What to do**:
  - 为目标删除添加确认弹窗：
    - 在目标展开区域的删除按钮点击后弹出确认
    - 格式：`确定要删除目标「{title}」吗？子目标也会被删除。`
  - 实现简单的关于页面：
    - App名称、版本号（从 pubspec.yaml 读取）
    - 一句话口号
    - "Made with ❤️"
  - 清理空操作 UI 元素：
    - "给个好评" — 暂改为跳转 GitHub 或隐藏
    - "关于" — 跳转到新的关于页面

  **Must NOT do**:
  - 不引入应用商店评价功能

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 小功能补充
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 17, 18, 20)
  - **Blocks**: None
  - **Blocked By**: Tasks 11, 12

  **References**:
  - `lib/pages/profile_page.dart:165-168` — "给个好评"和"关于"占位
  - `lib/pages/goals/widgets/goal_tree.dart` — 目标删除操作

  **Acceptance Criteria**:
  - [ ] 删除目标有确认弹窗
  - [ ] 关于页面显示版本信息
  - [ ] "给个好评"有合理行为（非空操作）

  **QA Scenarios**:

  ```
  Scenario: 验证确认弹窗和关于页面
    Tool: Bash
    Steps:
      1. `grep -n "确定要删除" lib/pages/goals/` → 有确认弹窗
      2. `grep -rn "about\|关于" lib/pages/profile_page.dart` → 有导航到关于页面
    Expected Result: 删除有确认，关于有内容
    Evidence: .sisyphus/evidence/task-19-confirm-about.txt
  ```

  **Commit**: YES
  - Message: `feat: goal delete confirmation + about page + fix empty actions`
  - Files: `goal_tree.dart`, `profile_page.dart`, new about page

- [x] 20. 日记编辑持久化修复

  **What to do**:
  - 修复 journal_list_page 中编辑日记后的持久化问题：
    - 确认 `_showEditDialog` 中的 `widget.onSave?.call(entry)` 正确调用
    - 确认 onSave 回调在 ProfilePage 中正确传递
    - 确认 DataService.saveJournal() 被调用
    - 如果改为 Riverpod，确保通过 Provider 保存
  - 修复 ReviewPage 中传入 JournalListPage 的回调链

  **Must NOT do**:
  - 不改变日记编辑的 UI

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Bug 修复
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 17, 18, 19)
  - **Blocks**: None
  - **Blocked By**: Task 7

  **References**:
  - `lib/pages/journal_list_page.dart:287-325` — `_showEditDialog` 编辑弹窗
  - `lib/pages/profile_page.dart:104-107` — JournalListPage 的 onSave 回调
  - `lib/pages/review_page.dart:60-63` — ReviewPage 中 JournalListPage 的回调

  **Acceptance Criteria**:
  - [ ] 编辑日记后数据正确保存到 Hive
  - [ ] 重新打开日记内容正确
  - [ ] `flutter analyze` 无错误

  **QA Scenarios**:

  ```
  Scenario: 验证编辑持久化
    Tool: Bash
    Steps:
      1. 确认 `DataService.saveJournal` 在编辑保存流程中被调用
      2. `grep -n "saveJournal\|onSave" lib/pages/journal_list_page.dart` → 有持久化调用
    Expected Result: 编辑保存调用 DataService 或 Provider 的 save
    Evidence: .sisyphus/evidence/task-20-journal-persist.txt
  ```

  **Commit**: YES
  - Message: `fix: journal edit persistence`
  - Files: `journal_list_page.dart`, `profile_page.dart`, `review_page.dart`

---

## Final Verification Wave

- [x] F1. **Plan Compliance Audit** — `oracle`
  Read the plan end-to-end. For each "Must Have": verify implementation exists. For each "Must NOT Have": search codebase for forbidden patterns. Check evidence files. Compare deliverables against plan.
  Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT: APPROVE/REJECT`

- [x] F2. **Code Quality Review** — `unspecified-high`
  Run `flutter analyze` + `flutter test`. Review all changed files for: hardcoded colors (should use AppColors), any remaining prop drilling (should use Riverpod), files > 300 lines (should be split), missing error handling.
  Output: `Analyze [PASS/FAIL] | Tests [N pass/N fail] | Files [N clean/N issues] | VERDICT`

- [x] F3. **Real Manual QA** — `unspecified-high` (+ `playwright` skill if web)
  Run `flutter test`. Verify: all models serialize/deserialize correctly, DataService CRUD works, notification scheduling works, Riverpod providers return correct data. Test edge cases: empty data, corrupted Hive data, missing fields.
  Output: `Scenarios [N/N pass] | Integration [N/N] | Edge Cases [N tested] | VERDICT`

- [x] F4. **Scope Fidelity Check** — `deep`
  For each task: read "What to do", read actual diff. Verify 1:1 — everything in spec was built, nothing beyond spec was built. Check "Must NOT do" compliance. Flag unaccounted changes.
  Output: `Tasks [N/N compliant] | Contamination [CLEAN/N issues] | Unaccounted [CLEAN/N files] | VERDICT`

---

## Commit Strategy

- **Wave 1**: `chore: clean up .bak files and dead code` | `refactor: unify color constants to AppColors` | `test: add test infrastructure and model tests` | `fix: add timezone for notification scheduling`
- **Wave 2**: `refactor: DataService error handling and transaction safety` | `feat: introduce Riverpod state management` | `refactor: migrate HomePage to Riverpod`
- **Wave 3**: `refactor: split schedule_page into components` | `refactor: split goals_page into components`
- **Wave 4**: `feat: goal auto-progress + editing` | `feat: task postpone/cancel + notes UI` | `feat: replace hand-drawn charts with fl_chart` | `fix: week view 18h + import auto-refresh`
- **Wave 5**: `fix: dark mode support across all pages` | `fix: UX polish — swipe, priority, confirm dialogs` | `fix: journal edit persistence`
- **Final**: `chore: verification and cleanup`

---

## Success Criteria

### Verification Commands
```bash
flutter analyze          # Expected: No issues found
flutter test             # Expected: All tests pass (≥20)
grep -r "static const Color primary" lib/  # Expected: 0 matches (all in AppColors)
find lib -name "*.bak"   # Expected: no output (no .bak files)
wc -l lib/pages/schedule_page.dart  # Expected: < 200 lines
wc -l lib/pages/goals_page.dart    # Expected: < 200 lines
```

### Final Checklist
- [ ] All "Must Have" present
- [ ] All "Must NOT Have" absent
- [ ] All tests pass
- [ ] No file exceeds 300 lines
- [ ] No hardcoded color constants outside AppColors
- [ ] Riverpod used for all state (no prop drilling)
- [ ] Notification scheduling works (not just immediate)
- [ ] Goal progress auto-calculates
- [ ] All pages support dark mode
