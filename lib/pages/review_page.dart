import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_entry.dart';
import '../providers/journals_provider.dart';
import '../utils/app_colors.dart';
import 'journal_list_page.dart';
import 'review/review_chart_section.dart';
import 'review/review_heatmap_section.dart';
import 'review/review_page_metrics.dart';
import 'review/review_recent_list_section.dart';
import 'review/review_stats_section.dart';

class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalsAsync = ref.watch(journalsProvider);

    return journalsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('复盘数据加载失败：$error'))),
      data: (journals) {
        final metrics = ReviewPageMetrics.fromJournals(journals);

        return Scaffold(
          backgroundColor: AppColors.background(context),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              const _ReviewPageHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ReviewStatsSection(
                  reflectionCount: metrics.reflectionCount,
                  reviewCount: metrics.reviewCount,
                  weekCount: metrics.weekCount,
                  streak: metrics.streak,
                  onReflectionTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JournalListPage(initialFilterType: JournalType.reflection)),
                  ),
                  onReviewTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JournalListPage(initialFilterType: JournalType.review)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ReviewChartSection(
                  journals: journals,
                  today: metrics.today,
                  thisWeekStart: metrics.thisWeekStart,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ReviewHeatmapSection(
                  today: metrics.today,
                  journals: journals,
                ),
              ),
              ReviewRecentListSection(recent: metrics.recent),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewPageHeader extends StatelessWidget {
  const _ReviewPageHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📊 复盘中心', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('数据驱动成长', style: TextStyle(fontSize: 13, color: AppColors.text2)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JournalListPage()),
            ),
          ),
        ],
      ),
    );
  }
}
