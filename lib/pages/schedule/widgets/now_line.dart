import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class NowLine extends StatelessWidget {
  const NowLine({
    super.key,
    required this.selectedDate,
    required this.startHour,
    required this.totalHours,
    required this.hourHeight,
  });

  final DateTime selectedDate;
  final int startHour;
  final int totalHours;
  final double hourHeight;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isToday(selectedDate)) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final mins = (now.hour - startHour) * 60 + now.minute;
    if (mins < 0 || mins > totalHours * 60) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: mins / 60.0 * hourHeight,
      left: 40,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(height: 2, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}
