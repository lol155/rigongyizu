import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import 'schedule_page_content.dart';
import 'schedule_page_header.dart';

class SchedulePageScaffold extends StatelessWidget {
  const SchedulePageScaffold({
    super.key,
    required this.viewState,
    required this.actions,
  });

  final SchedulePageViewState viewState;
  final SchedulePageActions actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Column(
        children: [
          if (!viewState.isFullscreen)
            SchedulePageHeader(
              formattedDate: viewState.formattedDate,
              totalCount: viewState.totalCount,
              currentView: viewState.currentView,
              onChangeDate: actions.onChangeDate,
              onViewChanged: actions.onViewChanged,
            ),
          Expanded(
            child: SchedulePageContent(
              viewState: viewState,
              actions: actions,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => actions.onShowTaskDialog(null, defaultHour: 9),
        backgroundColor: AppColors.primary,
        elevation: 4,
        tooltip: '添加任务',
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: AppColors.cardBackground(context)),
      ),
    );
  }
}
