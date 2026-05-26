import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart' show AppSettings;
import '../models/journal_entry.dart';
import '../providers/app_bootstrap_provider.dart';
import '../providers/goals_provider.dart';
import '../providers/journals_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/templates_provider.dart';
import '../providers/tasks_provider.dart';
import '../services/data_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import 'about_page.dart';
import 'journal_list_page.dart';
import 'profile_page/sections.dart';
import 'template_manage_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _refreshAppState(WidgetRef ref) async {
    await Future.wait([
      ref.read(journalsProvider.notifier).reload(),
      ref.read(templatesProvider.notifier).reload(),
      ref.read(tasksProvider.notifier).reload(),
      ref.read(goalsProvider.notifier).reload(),
    ]);
    ref.invalidate(appBootstrapProvider);
    await ref.read(appBootstrapProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalsAsync = ref.watch(journalsProvider);
    final customTemplatesAsync = ref.watch(templatesProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;

    if (journalsAsync.isLoading || customTemplatesAsync.isLoading || settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (journalsAsync.hasError) {
      return Scaffold(body: Center(child: Text('个人页数据加载失败：${journalsAsync.error}')));
    }

    if (customTemplatesAsync.hasError) {
      return Scaffold(body: Center(child: Text('个人页数据加载失败：${customTemplatesAsync.error}')));
    }

    final journals = journalsAsync.requireValue;
    final customTemplates = customTemplatesAsync.requireValue;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const ProfilePageHeader(),
          const SizedBox(height: 12),
          ProfilePageStatsSection(
            journalCount: journals.length,
            reflectionCount: journals.where((journal) => journal.type.name == 'reflection').length,
            reviewCount: journals.where((journal) => journal.type.name == 'review').length,
            onJournalTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JournalListPage()),
            ),
            onReflectionTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JournalListPage(initialFilterType: JournalType.reflection)),
            ),
            onReviewTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JournalListPage(initialFilterType: JournalType.review)),
            ),
          ),
          const SizedBox(height: 16),
          ProfileAppearanceSection(
            themeModeLabel: _themeModeLabel(settings.themeMode),
            onThemeColorTap: () => _showThemeColorDialog(context, ref, settings.seedColor),
            onThemeModeTap: () => _toggleThemeMode(context, ref, settings.themeMode),
            onNotificationTap: () => _showTestNotification(context),
          ),
          const SizedBox(height: 12),
          ProfileContentSection(
            customTemplateCount: customTemplates.length,
            journalCount: journals.length,
            onTemplateManageTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TemplateManagePage()),
            ),
            onJournalListTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JournalListPage()),
            ),
          ),
          const SizedBox(height: 12),
          ProfileDataActionsSection(
            onExportTap: () => _exportData(context),
            onImportTap: () => _showImportDialog(context, ref),
            onClearTap: () => _clearData(context, ref),
          ),
          const SizedBox(height: 12),
          ProfileAboutSection(
            onShareTap: _shareApp,
            onAboutTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutPage()),
            ),
          ),
          const SizedBox(height: 16),
          const ProfilePageFooter(),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode themeMode) {
    return themeMode == ThemeMode.dark
        ? '深色'
        : (themeMode == ThemeMode.light ? '浅色' : '跟随系统');
  }

  Future<void> _showThemeColorDialog(BuildContext context, WidgetRef ref, Color selectedSeedColor) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择主题色'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppSettings.themeColors
              .map(
                (color) => GestureDetector(
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await ref.read(settingsProvider.notifier).setSeedColor(color);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                    } catch (error) {
                      messenger.showSnackBar(SnackBar(content: Text('设置主题色失败：$error')));
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: color == selectedSeedColor
                          ? Border.all(color: AppColors.text(context), width: 3)
                          : null,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消'))],
      ),
    );
  }

  Future<void> _toggleThemeMode(BuildContext context, WidgetRef ref, ThemeMode themeMode) async {
    final modes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    final index = modes.indexOf(themeMode);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(settingsProvider.notifier).setThemeMode(modes[(index + 1) % 3]);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('切换主题模式失败：$error')));
    }
  }

  Future<void> _showTestNotification(BuildContext context) async {
    try {
      await NotificationService.showTestNotification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('测试通知已发送 ✅')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('测试通知发送失败：$error')));
      }
    }
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final data = DataService.exportAll();
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/rigongyizu_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(json);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: '日拱一卒数据备份'));
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败：$error')));
      }
    }
  }

  Future<void> _showImportDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入数据'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '粘贴之前导出的JSON数据',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () => _importData(context, ctx, ref, controller.text),
            child: const Text('导入'),
          ),
        ],
      ),
    );
  }

  Future<void> _importData(
    BuildContext context,
    BuildContext dialogContext,
    WidgetRef ref,
    String rawJson,
  ) async {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      await DataService.importAll(data);
      await _refreshAppState(ref);
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('导入成功！')));
      }
    } on FormatException catch (error) {
      if (!dialogContext.mounted) return;
      ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('格式错误: $error')));
    } catch (error) {
      if (!dialogContext.mounted) return;
      ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('导入失败：$error')));
    }
  }

  Future<void> _clearData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('将删除所有数据，此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await DataService.clearAll();
      await _refreshAppState(ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据已清除并恢复演示内容')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('清除数据失败：$error')));
      }
    }
  }

  Future<void> _shareApp() async {
    await SharePlus.instance.share(
      ShareParams(text: '我正在使用「日拱一卒」做目标、日程和复盘管理，体验很顺手，推荐试试！'),
    );
  }
}
