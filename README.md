# 日拱一卒

> 目标驱动 · 日程管理 · 复盘闭环

一款帮你把每一天都用在刀刃上的 Flutter 生产力应用。围绕"制定目标 → 安排日程 → 反思复盘"的闭环，让每天的努力看得见、可追溯。

## 功能概览

### 日程管理

- **日视图**：时间块可视化（6:00-24:00），任务以色块占据对应时段，空闲时间一目了然
- **周视图**：7 天横排总览，支持纵向缩放
- **月视图**：日历视图，标记有任务的日期
- 点击空白时段快速添加任务，拖拽调整时间和时长
- 任务状态：待办 / 已完成 / 已推迟 / 已取消

### 目标管理

- 目标无限层级拆分（目标 → 子目标 → 任务）
- 目标树可视化，甘特图进度总览
- 一键将目标下的任务添加到日程
- 截止日期、优先级、进度追踪

### 复盘中心

- 统计卡片：反思次数、复盘次数、本周记录、连续天数
- 完成趋势折线图、活跃热力图
- 最近反思/复盘记录列表

### 模板化反思 & 复盘

- 内置模板：每日反思、每周回顾
- 自定义模板：自由配置问题列表，保存后可复用
- 晨间反思提醒 / 晚间复盘提醒

### 我的

- 日记总数 / 反思 / 复盘统计，点击直达对应记录
- 主题色自定义 + 深色模式
- 数据导出 / 导入

## 技术栈

| 层 | 技术 |
|---|---|
| 框架 | Flutter 3.x (Dart) |
| 状态管理 | Riverpod (AsyncNotifier) |
| 本地存储 | Hive |
| 图表 | fl_chart |
| 平台 | Android / iOS / macOS |

## 项目结构

```
lib/
├── main.dart                  # 入口，主题配置
├── models/                    # 数据模型 (Task, Goal, JournalEntry, ReflectionTemplate)
├── providers/                 # Riverpod providers (CRUD + 数据加载)
├── services/                  # 数据持久化 (DataService, NotificationService)
├── pages/
│   ├── schedule/              # 日程页 (日/周/月视图，任务弹窗)
│   ├── goals/                 # 目标页 (目标树，甘特图，弹窗)
│   ├── review/                # 复盘页 (统计，图表，热力图)
│   ├── journal/               # 日记列表 (筛选，搜索，详情)
│   └── profile_page/          # 我的页
└── utils/                     # 颜色、工具
```

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行
flutter run

# 静态分析
flutter analyze

# 测试
flutter test

# 打包 APK
flutter build apk --split-per-abi
```

## 环境要求

- Flutter SDK >= 3.11
- Dart >= 3.11

## 许可

MIT
