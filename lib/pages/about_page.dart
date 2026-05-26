import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _version = 'v1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                  ),
                  child: const Icon(Icons.flag, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 16),
                const Text(
                  '日拱一卒',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  '目标驱动 + 日程管理 + 复盘闭环',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.text2),
                ),
                const SizedBox(height: 12),
                const Text('版本 $_version', style: TextStyle(color: AppColors.text3)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: '它能做什么',
            items: const [
              '管理目标与子目标进度',
              '把目标快速关联到日程任务',
              '记录日记、反思和复盘',
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: '数据说明',
            items: const [
              '所有数据都保存在本地设备',
              '支持导出与导入备份',
              '清除数据后可恢复默认演示内容',
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await SharePlus.instance.share(
                ShareParams(text: '推荐你试试「日拱一卒」：目标、日程、复盘一体化管理。'),
              );
            },
            icon: const Icon(Icons.star_border),
            label: const Text('分享给朋友 / 给个好评'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: AppColors.primary)),
                  Expanded(child: Text(item, style: const TextStyle(height: 1.4))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
