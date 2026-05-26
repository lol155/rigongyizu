import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class ProfilePageHeader extends StatelessWidget {
  const ProfilePageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                '卒',
                style: TextStyle(
                  fontSize: 36,
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('日拱一卒', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('日拱一卒，功不唐捐', style: TextStyle(fontSize: 13, color: AppColors.text2)),
        ],
      ),
    );
  }
}

class ProfilePageStatsSection extends StatelessWidget {
  const ProfilePageStatsSection({
    super.key,
    required this.journalCount,
    required this.reflectionCount,
    required this.reviewCount,
    this.onJournalTap,
    this.onReflectionTap,
    this.onReviewTap,
  });

  final int journalCount;
  final int reflectionCount;
  final int reviewCount;
  final VoidCallback? onJournalTap;
  final VoidCallback? onReflectionTap;
  final VoidCallback? onReviewTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _ProfileStat(value: '$journalCount', label: '日记总数', onTap: onJournalTap),
          _ProfileStat(value: '$reflectionCount', label: '反思', onTap: onReflectionTap),
          _ProfileStat(value: '$reviewCount', label: '复盘', onTap: onReviewTap),
        ],
      ),
    );
  }
}

class ProfileAppearanceSection extends StatelessWidget {
  const ProfileAppearanceSection({super.key, required this.themeModeLabel, required this.onThemeColorTap, required this.onThemeModeTap, required this.onNotificationTap});

  final String themeModeLabel;
  final VoidCallback onThemeColorTap;
  final VoidCallback onThemeModeTap;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      children: [
        ProfileSettingItem(
          icon: Icons.palette,
          title: '主题色',
          subtitle: '选择颜色',
          onTap: onThemeColorTap,
        ),
        ProfileSettingItem(
          icon: Icons.dark_mode,
          title: '深色模式',
          subtitle: themeModeLabel,
          onTap: onThemeModeTap,
        ),
      ],
    );
  }
}

class ProfileContentSection extends StatelessWidget {
  const ProfileContentSection({super.key, required this.customTemplateCount, required this.journalCount, required this.onTemplateManageTap, required this.onJournalListTap});

  final int customTemplateCount;
  final int journalCount;
  final VoidCallback onTemplateManageTap;
  final VoidCallback onJournalListTap;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      children: [
        ProfileSettingItem(
          icon: Icons.edit_note,
          title: '模板管理',
          subtitle: '$customTemplateCount个自定义',
          onTap: onTemplateManageTap,
        ),
        ProfileSettingItem(
          icon: Icons.menu_book,
          title: '日记列表',
          subtitle: '$journalCount篇',
          onTap: onJournalListTap,
        ),
      ],
    );
  }
}

class ProfileDataActionsSection extends StatelessWidget {
  const ProfileDataActionsSection({super.key, required this.onExportTap, required this.onImportTap, required this.onClearTap});

  final VoidCallback onExportTap;
  final VoidCallback onImportTap;
  final VoidCallback onClearTap;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      children: [
        ProfileSettingItem(
          icon: Icons.cloud_upload,
          title: '导出数据',
          subtitle: 'JSON',
          onTap: onExportTap,
        ),
        ProfileSettingItem(
          icon: Icons.cloud_download,
          title: '导入数据',
          subtitle: '粘贴JSON',
          onTap: onImportTap,
        ),
        ProfileSettingItem(
          icon: Icons.delete_outline,
          title: '清除数据',
          subtitle: '',
          danger: true,
          onTap: onClearTap,
        ),
      ],
    );
  }
}

class ProfileAboutSection extends StatelessWidget {
  const ProfileAboutSection({super.key, required this.onShareTap, required this.onAboutTap});

  final VoidCallback onShareTap;
  final VoidCallback onAboutTap;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      children: [
        ProfileSettingItem(icon: Icons.star, title: '给个好评', subtitle: '', onTap: onShareTap),
        ProfileSettingItem(
          icon: Icons.info_outline,
          title: '关于',
          subtitle: 'v1.0.0',
          onTap: onAboutTap,
        ),
      ],
    );
  }
}

class ProfilePageFooter extends StatelessWidget {
  const ProfilePageFooter({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text('日拱一卒 v1.0.0 · Made with ❤️', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.text3)),
      );
}

class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class ProfileSettingItem extends StatelessWidget {
  const ProfileSettingItem({super.key, required this.icon, required this.title, required this.subtitle, this.danger = false, this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: danger ? AppColors.danger : AppColors.text2),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 15, color: danger ? AppColors.danger : Colors.black),
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.text3)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.text3),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label, this.onTap});

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          ],
        ),
      ),
    );
  }
}
