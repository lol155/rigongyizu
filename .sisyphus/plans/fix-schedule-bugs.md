# 日拱一卒 - 修复日程视图三个 Bug

## TL;DR

> **Quick Summary**: 修复日视图圆圈按钮溢出、多任务重叠排版错误、周视图内容为空三个 Bug。
> 
> **Deliverables**:
> - 圆圈按钮和拖拽手柄跟随列偏移正确定位
> - 重叠任务正确并排显示
> - 周视图正确显示任务内容
> 
> **Estimated Effort**: Quick
> **Parallel Execution**: YES - 3 independent fixes
> **Critical Path**: All tasks independent → Verify

---

## Context

### Bug Reports (from user)

1. 日视图紧凑排版时，完成的圆圈按钮会多出任务块（溢出到块外面）
2. 同一时间有多个任务块排版有问题
3. 周视图中没有内容，是空的

### Root Cause Analysis

**Bug 1 — 圆圈按钮溢出**：
`task_block.dart` 第 69-71 行计算了 `blockLeft`（含列偏移），任务块 Container 使用 `blockLeft` 定位。但第 210 行圆圈按钮和第 229 行拖拽手柄仍然用 `widget.leftPos + N`（固定值），不跟随列偏移。当 `columnCount > 1` 时圆圈脱离任务块。

**Bug 2 — 重叠排版错误**：
`day_timeline.dart` 第 82-110 行 `_groupByOverlap()` 算法只检查新任务是否与**组内最后一个**任务重叠，不检查与组内所有任务。当 A(9:00-10:00)、B(9:30-10:30)、C(10:00-11:00) 时，C 与 B 重叠但被放到 A 的组里（因为只比较 B 的 endTime），导致位置计算错误。

**Bug 3 — 周视图为空**：
`week_view.dart` 第 143-148 行过滤条件 `task.date.year == date.year && task.date.month == date.month && task.date.day == date.day` 本身没问题。真正的问题是 `week_view.dart` 使用 `Colors.white` 硬编码背景（第 164 行），而任务色块颜色可能与白色背景接近导致不可见。另外需要检查 `_rowHeight = 52.0` 是否太小导致内容被裁切。更深层的可能是：`ListView.builder` 在 `Column` + `Expanded` 内的布局冲突导致 `ListView` 高度为 0。

---

## TODOs

- [x] 1. 修复 Bug 1：圆圈按钮和拖拽手柄跟随列偏移

  **What to do**:
  - 文件：`lib/pages/schedule/widgets/task_block.dart`
  - 第 210-228 行：圆圈按钮 `Positioned` 的 `left` 从 `widget.leftPos + 6` 改为 `blockLeft + 6`
  - 第 229-256 行：拖拽手柄 `Positioned` 的 `left` 从 `widget.leftPos + 20` 改为 `blockLeft + 20`
  - 注意：`blockLeft` 在 `build()` 方法第 69-71 行已经计算好，在同一 build 方法内可直接引用

  **References**:
  - `lib/pages/schedule/widgets/task_block.dart:69-71` — `blockLeft` 的计算逻辑
  - `lib/pages/schedule/widgets/task_block.dart:210` — 圆圈按钮 `left: widget.leftPos + 6` → 改为 `blockLeft + 6`
  - `lib/pages/schedule/widgets/task_block.dart:229` — 拖拽手柄 `left: widget.leftPos + 20` → 改为 `blockLeft + 20`

  **QA Scenarios**:
  ```
  Scenario: 创建两个同时间段的任务，检查圆圈按钮位置
    Tool: Playwright (运行 Web 版) 或 Bash (flutter run)
    Steps:
      1. 打开日视图
      2. 创建两个 9:00-10:00 的任务
      3. 检查两个任务块的圆圈按钮是否都在各自色块内
    Expected Result: 圆圈按钮不溢出色块边界
    Evidence: .sisyphus/evidence/task-1-circle-position.png
  ```

- [x] 2. 修复 Bug 2：重叠任务分组算法

  **What to do**:
  - 文件：`lib/pages/schedule/widgets/day_timeline.dart`
  - 重写 `_groupByOverlap()` 方法（第 82-110 行）
  - 新算法：使用区间重叠检测，对每个任务检查它是否与组内**任何一个**已有任务重叠，而不仅仅是最后一个
  - 正确算法伪代码：
    ```dart
    List<List<ScheduleTask>> _groupByOverlap(List<ScheduleTask> tasks) {
      final sorted = List<ScheduleTask>.from(tasks)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      final groups = <List<ScheduleTask>>[];

      for (final task in sorted) {
        final taskStart = task.startTime.hour * 60 + task.startTime.minute;
        final taskEnd = taskStart + task.durationMinutes;
        var placed = false;

        for (final group in groups) {
          // 检查是否与组内任何一个任务重叠
          final overlaps = group.any((existing) {
            final existStart = existing.startTime.hour * 60 + existing.startTime.minute;
            final existEnd = existStart + existing.durationMinutes;
            return taskStart < existEnd && taskEnd > existStart;
          });

          if (overlaps) {
            group.add(task);
            placed = true;
            break;
          }
        }

        if (!placed) {
          groups.add([task]);
        }
      }

      return groups;
    }
    ```

  **References**:
  - `lib/pages/schedule/widgets/day_timeline.dart:82-110` — 当前有缺陷的 `_groupByOverlap()`
  - `lib/pages/schedule/widgets/day_timeline.dart:116-187` — `_buildTaskBlocks()` 使用分组结果

  **QA Scenarios**:
  ```
  Scenario: 创建 3 个部分重叠的任务，检查排版
    Steps:
      1. 创建任务 A: 9:00-10:00
      2. 创建任务 B: 9:30-10:30
      3. 创建任务 C: 10:00-11:00
      4. 检查三者在日视图中的位置
    Expected Result: A 和 B 并排显示，C 可以独立或与 B 并排（取决于是否有真实重叠）
    Evidence: .sisyphus/evidence/task-2-overlap-layout.png
  ```

- [x] 3. 修复 Bug 3：周视图内容为空

  **What to do**:
  - 文件：`lib/pages/schedule/widgets/week_view.dart`
  - 问题排查：
    1. 第 164 行硬编码 `Colors.white` 背景在深色模式下会看不到 → 改为主题感知颜色
    2. `ListView.builder` 嵌套在 `Column` + `Expanded` 中，需要确认 `Expanded` 确实给了高度
    3. **关键**：第 143-148 行过滤 `task.startTime.hour == hour` 只匹配精确开始小时。如果任务 9:30 开始（hour=9），它只在 9:00 行显示，这是正确的。但要确认 `tasks` 列表不为空
  - 修复方案：
    1. 背景色用 `AppColors.cardBackground(context)` 替代 `Colors.white`
    2. 在 `WeekView` 的 `build` 方法开头添加调试：如果 `tasks.isEmpty`，显示一个"本周无任务"的空状态提示
    3. 确保 `schedule_page_content.dart` 第 121 行传的 `tasks: viewState.tasks` 确实是全部任务（已确认是 `_tasks`，即全部）

  **References**:
  - `lib/pages/schedule/widgets/week_view.dart:143-148` — 任务过滤逻辑
  - `lib/pages/schedule/widgets/week_view.dart:164` — 硬编码 `Colors.white`
  - `lib/pages/schedule/widgets/schedule_page_content.dart:121` — `tasks: viewState.tasks`
  - `lib/pages/schedule_page.dart:267` — `tasks: _tasks`（全部任务）

  **QA Scenarios**:
  ```
  Scenario: 切换到周视图检查任务显示
    Steps:
      1. 先在日视图创建几个不同日期的任务
      2. 切换到周视图
      3. 检查对应日期列是否显示任务色块
    Expected Result: 有任务的日期和小时行显示任务色块
    Evidence: .sisyphus/evidence/task-3-week-content.png
  ```

- [x] 4. 验证

  **What to do**:
  - 运行 `flutter analyze` 确认无错误
  - 运行 `flutter test` 确认测试通过
  - 打 debug APK 验证三个 bug 均修复

---

## Commit Strategy

- `fix: task block circle and handle position follow column offset`
- `fix: correct overlap grouping algorithm for concurrent tasks`
- `fix: week view empty content and dark mode background`
