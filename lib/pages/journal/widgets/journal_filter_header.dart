import 'package:flutter/material.dart';

import '../../../models/journal_entry.dart';
import '../../../utils/app_colors.dart';

class JournalFilterHeader extends StatelessWidget {
  const JournalFilterHeader({
    super.key,
    required this.totalCount,
    required this.filterType,
    required this.onSearchChanged,
    required this.onFilterTap,
  });

  final int totalCount;
  final JournalType? filterType;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<JournalType> onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground(context),
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📔 日记记录',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '共 $totalCount 篇',
            style: const TextStyle(fontSize: 13, color: AppColors.text2),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: '搜索...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: AppColors.text3),
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _JournalFilterButton(
                label: '反思',
                isActive: filterType == JournalType.reflection,
                onTap: () => onFilterTap(JournalType.reflection),
              ),
              const SizedBox(width: 4),
              _JournalFilterButton(
                label: '复盘',
                isActive: filterType == JournalType.review,
                onTap: () => onFilterTap(JournalType.review),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JournalFilterButton extends StatelessWidget {
  const _JournalFilterButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.inactiveBg(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.text2,
          ),
        ),
      ),
    );
  }
}
