import 'package:flutter/material.dart';

/// Helper to get theme-aware colors
class AppColors {
  static const int primaryValue = 0xFFFF6B35;
  static const int successValue = 0xFF10B981;
  static const int purpleValue = 0xFF8B5CF6;
  static const int blueValue = 0xFF3B82F6;
  static const int warningValue = 0xFFF59E0B;
  static const int dangerValue = 0xFFEF4444;
  static const int text2Value = 0xFF6B7280;

  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFFA07A);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color pink = Color(0xFFEC4899);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color text2 = Color(0xFF6B7280);
  static const Color text3 = Color(0xFF9CA3AF);
  static const Color borderSubtle = Color(0xFFD1D5DB);
  static const Color borderMuted = Color(0xFFE5E7EB);
  static const Color journalReflectionBg = Color(0xFFFEF3C7);
  static const Color journalReflectionFg = Color(0xFF92400E);
  static const Color journalReviewBg = Color(0xFFDBEAFE);
  static const Color journalReviewFg = Color(0xFF1D4ED8);
  static const Color chartBarSecondary = Color(0xFFFDBA74);
  static const Color heatmapLow = Color(0xFFFED7AA);
  static const Color heatmapMedium = Color(0xFFFDBA74);
  static const Color heatmapHigh = Color(0xFFFB923C);
  static const Color goalPriorityHighBg = Color(0xFFFEE2E2);
  static const Color goalPriorityHighFg = Color(0xFFB91C1C);
  static const Color goalPriorityMediumBg = Color(0xFFFFF7CC);
  static const Color goalPriorityMediumFg = Color(0xFFB45309);
  static const Color goalPriorityLowBg = Color(0xFFE0F2FE);
  static const Color goalPriorityLowFg = Color(0xFF0369A1);
  static const Color taskBlockOrangeBg = Color(0xFFFFF3ED);
  static const Color taskBlockBlueBg = Color(0xFFEFF6FF);
  static const Color taskBlockGreenBg = Color(0xFFF0FDF4);
  static const Color taskBlockPurpleBg = Color(0xFFFAF5FF);
  static const Color taskBlockWarningBg = Color(0xFFFFFBEB);
  static const Color taskBlockFallbackBg = Color(0xFFF9FAFB);
  static const Color taskBlockCancelledBg = Color(0xFFF3F4F6);
  static const Color taskBlockOrangeText = Color(0xFFC2410C);
  static const Color taskBlockBlueText = Color(0xFF1D4ED8);
  static const Color taskBlockGreenText = Color(0xFF166534);
  static const Color taskBlockPurpleText = Color(0xFF6D28D9);
  static const Color taskBlockWarningText = Color(0xFF92400E);
  static const Color taskBlockFallbackText = Color(0xFF4B5563);
  static const List<Color> reviewCardGradient = [Color(0xFF667EEA), Color(0xFF764BA2)];

  static const List<Color> themeColors = [
    primary,
    blue,
    success,
    purple,
    danger,
    warning,
    pink,
    cyan,
  ];

  static const List<int> goalColorValues = [
    0xFFFF6B35,
    0xFF3B82F6,
    0xFF10B981,
    0xFF8B5CF6,
    0xFFF59E0B,
  ];

  static const List<int> taskDialogColorValues = [
    0xFFFF6B35,
    0xFF3B82F6,
    0xFF10B981,
    0xFF8B5CF6,
    0xFFF59E0B,
    0xFFEF4444,
    0xFF6B7280,
  ];

  static List<Color> reviewHeatmapScale(BuildContext context) => [
    inactiveBg(context),
    heatmapLow,
    heatmapMedium,
    heatmapHigh,
    primary,
  ];

  static const Map<int, int> taskBlockBackgroundValues = {
    primaryValue: 0xFFFDDCC4,
    blueValue: 0xFFDBEAFE,
    successValue: 0xFFDCFCE7,
    purpleValue: 0xFFF3E8FF,
    warningValue: 0xFFFEF3C7,
  };

  static const Map<int, int> taskBlockTextValues = {
    primaryValue: 0xFFC2410C,
    blueValue: 0xFF1D4ED8,
    successValue: 0xFF166534,
    purpleValue: 0xFF6D28D9,
    warningValue: 0xFF92400E,
  };

  static Color surface(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color background(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A3E) : const Color(0xFFF0F0F0);
  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFE2E8F0) : Colors.black;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
  static Color cardBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E293B) : Colors.white;
  static Color inactiveBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF334155) : const Color(0xFFF0F0F0);
  static Color todayHighlight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D1B0E) : const Color(0xFFFFF8F4);
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
