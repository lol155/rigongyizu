import 'package:flutter/material.dart';

import '../../../models/goal.dart';
import '../../../utils/app_colors.dart';

class GanttChart extends StatelessWidget {
  const GanttChart({super.key, required this.goals});

  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 项目进度总览',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 80),
              ...['4月', '5月', '6月'].map(
                (month) => Expanded(
                  child: Text(
                    month,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.text3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...goals.take(5).map((goal) {
            final pct = goal.progressPct.clamp(0.0, 1.0);
            final goalColor = Color(goal.color);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      goal.title.replaceAll(RegExp(r'[^\w\s]'), '').trim(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.text2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.inactiveBg(context),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        children: [
                          if (pct > 0)
                            FractionallySizedBox(
                              widthFactor: pct,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: goalColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          Positioned(
                            left: 80,
                            top: -2,
                            bottom: -2,
                            child: Container(
                              width: 1.5,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
