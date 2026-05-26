import 'package:flutter/material.dart';

import '../../../models/goal.dart';
import '../../../models/task.dart';
import '../../../utils/app_colors.dart';
import 'task_dialog_constants.dart';

String formatTaskDuration(int duration) {
  final hours = duration ~/ 60;
  final mins = duration % 60;
  if (hours == 0) return '${mins}m';
  if (mins == 0) return '${hours}h';
  return '${hours}h${mins}m';
}
class TaskTimeField extends StatelessWidget {
  const TaskTimeField({
    super.key,
    required this.startHour,
    required this.startMinute,
    required this.onTap,
  });

  final int startHour;
  final int startMinute;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('⏰ '),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class TaskDurationEditor extends StatelessWidget {
  const TaskDurationEditor({
    super.key,
    required this.duration,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int duration;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('时长: '),
        IconButton(
          onPressed: onDecrease,
          icon: const Icon(Icons.remove_circle_outline, size: 28),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            formatTaskDuration(duration),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        IconButton(
          onPressed: onIncrease,
          icon: const Icon(Icons.add_circle_outline, size: 28),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
class TaskDurationPresetChips extends StatelessWidget {
  const TaskDurationPresetChips({
    super.key,
    required this.duration,
    required this.onSelected,
  });

  final int duration;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: presetTaskDurations
          .map(
            (minutes) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _TaskDurationChip(
                minutes: minutes,
                isSelected: duration == minutes,
                onTap: () => onSelected(minutes),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
class TaskStatusSelector extends StatelessWidget {
  const TaskStatusSelector({
    super.key,
    required this.selectedStatus,
    required this.onSelected,
  });

  final TaskStatus selectedStatus;
  final ValueChanged<TaskStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TaskStatus.values
          .map(
            (status) => _TaskStatusChip(
              status: status,
              isSelected: selectedStatus == status,
              onSelected: () => onSelected(status),
            ),
          )
          .toList(growable: false),
    );
  }
}
class TaskColorPicker extends StatelessWidget {
  const TaskColorPicker({
    super.key,
    required this.selectedColor,
    required this.onSelected,
  });

  final int selectedColor;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          ...taskDialogColors.map(
            (color) => GestureDetector(
              onTap: () => onSelected(color),
              child: Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Color(color),
                  shape: BoxShape.circle,
                ),
                child: selectedColor == color
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class TaskGoalDropdown extends StatelessWidget {
  const TaskGoalDropdown({
    super.key,
    required this.goals,
    required this.selectedGoalId,
    required this.onChanged,
  });

  final List<Goal> goals;
  final String? selectedGoalId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String?>(
        value: selectedGoalId,
        hint: const Text('不关联'),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        menuMaxHeight: 240,
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('不关联', maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          ...goals.map(
            (goal) => DropdownMenuItem<String?>(
              value: goal.id,
              child: Text(
                goal.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (value) => onChanged(value),
      ),
    );
  }
}

class _TaskDurationChip extends StatelessWidget {
  const _TaskDurationChip({
    required this.minutes,
    required this.isSelected,
    required this.onTap,
  });

  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.inactiveBg(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          formatTaskDuration(minutes),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.text2,
          ),
        ),
      ),
    );
  }
}

class _TaskStatusChip extends StatelessWidget {
  const _TaskStatusChip({
    required this.status,
    required this.isSelected,
    required this.onSelected,
  });

  final TaskStatus status;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final statusColor = taskStatusColor(status);
    final bgColor = isSelected ? statusColor : AppColors.inactiveBg(context);
    final fgColor = isSelected ? Colors.white : statusColor;

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? null : Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(taskStatusIcon(status), size: 14, color: fgColor),
            const SizedBox(width: 4),
            Text(
              taskStatusLabel(status),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
