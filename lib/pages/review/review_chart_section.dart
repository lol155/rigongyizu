import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/journal_entry.dart';
import '../../utils/app_colors.dart';
import 'review_page_metrics.dart';

class ReviewChartSection extends StatelessWidget {
  const ReviewChartSection({
    super.key,
    required this.journals,
    required this.today,
    required this.thisWeekStart,
  });

  final List<JournalEntry> journals;
  final DateTime today;
  final DateTime thisWeekStart;

  @override
  Widget build(BuildContext context) {
    final weeklyCounts = buildWeeklyCounts(journals, thisWeekStart);
    final last7DayCounts = buildLast7DayCounts(journals, today);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('本周记录', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: weeklyCounts.fold<int>(0, (maxValue, value) => value > maxValue ? value : maxValue).toDouble() + 1,
                barTouchData: BarTouchData(enabled: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const labels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        final day = thisWeekStart.add(Duration(days: index));
                        final isToday = isSameCalendarDay(day, today);
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            labels[index],
                            style: TextStyle(fontSize: 10, color: isToday ? AppColors.primary : AppColors.text3),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: weeklyCounts.asMap().entries.map((entry) {
                  final day = thisWeekStart.add(Duration(days: entry.key));
                  final isToday = isSameCalendarDay(day, today);
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                        color: isToday ? AppColors.primary : AppColors.chartBarSecondary,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('近7日趋势', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: last7DayCounts.fold<int>(0, (maxValue, value) => value > maxValue ? value : maxValue).toDouble() + 1,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(enabled: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= 7) {
                          return const SizedBox.shrink();
                        }
                        final day = today.subtract(Duration(days: 6 - index));
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '${day.month}/${day.day}',
                            style: const TextStyle(fontSize: 9, color: AppColors.text3),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: last7DayCounts.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                    }).toList(),
                    isCurved: true,
                    barWidth: 3,
                    color: AppColors.primary,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.12),
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
