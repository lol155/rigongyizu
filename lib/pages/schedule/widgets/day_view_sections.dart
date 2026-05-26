import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/reflection_dialog.dart';
import 'day_view_zoom_level_button.dart';

class DayReflectionCard extends StatelessWidget {
  const DayReflectionCard({super.key, required this.hasTodayReflection});

  final bool hasTodayReflection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GestureDetector(
        onTap: () => ReflectionDialog.showReflection(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasTodayReflection ? '✅ 已完成晨间反思' : '☀️ 晨间反思',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cardBackground(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasTodayReflection ? '今天已记录，点击查看或重新填写' : '点击开始 · 每日反思 · 每周回顾',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DayScheduleSummary extends StatelessWidget {
  const DayScheduleSummary({
    super.key,
    required this.doneCount,
    required this.totalCount,
  });

  final int doneCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '📋 日程安排',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          Text(
            '完成 $doneCount/$totalCount',
            style: const TextStyle(fontSize: 13, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class DayViewControls extends StatelessWidget {
  const DayViewControls({
    super.key,
    required this.zoomLevel,
    required this.isFullscreen,
    required this.onZoomLevelChanged,
    required this.onToggleFullscreen,
  });

  final double zoomLevel;
  final bool isFullscreen;
  final ValueChanged<double> onZoomLevelChanged;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Text('缩放:', style: TextStyle(fontSize: 12, color: AppColors.text3)),
          const SizedBox(width: 6),
          DayViewZoomLevelButton(
            label: '紧凑',
            level: 0.6,
            zoomLevel: zoomLevel,
            onTap: onZoomLevelChanged,
          ),
          const SizedBox(width: 4),
          DayViewZoomLevelButton(
            label: '标准',
            level: 1.0,
            zoomLevel: zoomLevel,
            onTap: onZoomLevelChanged,
          ),
          const SizedBox(width: 4),
          DayViewZoomLevelButton(
            label: '详细',
            level: 1.5,
            zoomLevel: zoomLevel,
            onTap: onZoomLevelChanged,
          ),
          const Spacer(),
          GestureDetector(
            onTap: onToggleFullscreen,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isFullscreen
                    ? AppColors.primary
                    : AppColors.inactiveBg(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    size: 16,
                    color: isFullscreen ? Colors.white : AppColors.text2,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isFullscreen ? '退出' : '全屏',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isFullscreen ? Colors.white : AppColors.text2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DayFreeTimeCard extends StatelessWidget {
  const DayFreeTimeCard({
    super.key,
    required this.freeTimeText,
    required this.freeHours,
  });

  final String freeTimeText;
  final int freeHours;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🕐', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '空闲时段',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    freeTimeText,
                    style: const TextStyle(fontSize: 11, color: AppColors.text2),
                  ),
                ],
              ),
            ),
            Text(
              '${freeHours}h',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DayReviewCard extends StatelessWidget {
  const DayReviewCard({super.key, required this.hasTodayReview});

  final bool hasTodayReview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GestureDetector(
        onTap: () => ReflectionDialog.showReview(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.reviewCardGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasTodayReview ? '✅ 已完成晚间复盘' : '🌙 晚间复盘',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cardBackground(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasTodayReview ? '今天已复盘，点击查看或重新填写' : '花3分钟回顾今天',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '→',
                style: TextStyle(
                  fontSize: 22,
                  color: AppColors.cardBackground(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
