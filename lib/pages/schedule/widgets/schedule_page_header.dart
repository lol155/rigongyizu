import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class SchedulePageHeader extends StatelessWidget {
  const SchedulePageHeader({
    super.key,
    required this.formattedDate,
    required this.totalCount,
    required this.currentView,
    required this.onChangeDate,
    required this.onViewChanged,
  });

  final String formattedDate;
  final int totalCount;
  final int currentView;
  final ValueChanged<int> onChangeDate;
  final ValueChanged<int> onViewChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground(context),
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      totalCount > 0 ? '$totalCount项任务' : '今日无任务',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.text2,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _SchedulePageNavButton('‹', () => onChangeDate(-1)),
                  const SizedBox(width: 6),
                  _SchedulePageNavButton('今', () => onChangeDate(0), small: true),
                  const SizedBox(width: 6),
                  _SchedulePageNavButton('›', () => onChangeDate(1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.inactiveBg(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _SchedulePageViewSwitchButton(
                  label: '日',
                  index: 0,
                  currentView: currentView,
                  onTap: onViewChanged,
                ),
                _SchedulePageViewSwitchButton(
                  label: '周',
                  index: 1,
                  currentView: currentView,
                  onTap: onViewChanged,
                ),
                _SchedulePageViewSwitchButton(
                  label: '月',
                  index: 2,
                  currentView: currentView,
                  onTap: onViewChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SchedulePageNavButton extends StatelessWidget {
  const _SchedulePageNavButton(this.text, this.onTap, {this.small = false});

  final String text;
  final VoidCallback onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: small ? null : 40,
        height: 40,
        padding: small ? const EdgeInsets.symmetric(horizontal: 12) : null,
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: small ? 14 : 18,
              fontWeight: small ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _SchedulePageViewSwitchButton extends StatelessWidget {
  const _SchedulePageViewSwitchButton({
    required this.label,
    required this.index,
    required this.currentView,
    required this.onTap,
  });

  final String label;
  final int index;
  final int currentView;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = currentView == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : const [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.white : AppColors.text2,
            ),
          ),
        ),
      ),
    );
  }
}
