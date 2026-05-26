import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class DayViewZoomLevelButton extends StatelessWidget {
  const DayViewZoomLevelButton({
    super.key,
    required this.label,
    required this.level,
    required this.zoomLevel,
    required this.onTap,
  });

  final String label;
  final double level;
  final double zoomLevel;
  final ValueChanged<double> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = (zoomLevel - level).abs() < 0.1;

    return GestureDetector(
      onTap: () => onTap(level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.inactiveBg(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.text2,
          ),
        ),
      ),
    );
  }
}
