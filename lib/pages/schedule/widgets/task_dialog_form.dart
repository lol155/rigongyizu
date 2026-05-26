import 'package:flutter/material.dart';

import '../../../models/goal.dart';
import '../../../models/task.dart';
import '../../../utils/app_colors.dart';
import 'task_dialog.dart';
import 'task_dialog_form_sections.dart';

class TaskDialogForm extends StatefulWidget {
  const TaskDialogForm({
    super.key,
    required this.selectedDate,
    required this.goals,
    required this.initialHour,
    required this.initialMinute,
    this.task,
  });

  final DateTime selectedDate;
  final List<Goal> goals;
  final int initialHour;
  final int initialMinute;
  final ScheduleTask? task;

  @override
  State<TaskDialogForm> createState() => _TaskDialogFormState();
}

class _TaskDialogFormState extends State<TaskDialogForm> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _selectedDate;
  late int _startHour;
  late int _startMinute;
  late int _duration;
  late String? _selectedGoalId;
  late TaskStatus _selectedStatus;
  late int _selectedColor;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _notesCtrl = TextEditingController(text: widget.task?.notes ?? '');
    _selectedDate = widget.task?.date ?? widget.selectedDate;
    _startHour = widget.task?.startTime.hour ?? widget.initialHour;
    _startMinute = widget.task?.startTime.minute ?? widget.initialMinute;
    _duration = widget.task?.durationMinutes ?? 60;
    _selectedGoalId = widget.task?.goalId;
    _selectedStatus = widget.task?.status ?? TaskStatus.pending;
    _selectedColor = widget.task?.color ?? AppColors.primaryValue;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _startHour, minute: _startMinute),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _startHour = picked.hour;
      _startMinute = picked.minute;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = picked;
    });
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      return;
    }

    Navigator.pop(
      context,
      TaskDialogResult.save(
        TaskDialogData(
          title: title,
          startTime: DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _startHour,
            _startMinute,
          ),
          durationMinutes: _duration,
          goalId: _selectedGoalId,
          status: _selectedStatus,
          color: _selectedColor,
          notes: _notesCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              _isEdit ? '编辑任务' : '添加任务',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleCtrl,
                    autofocus: !_isEdit,
                    decoration: InputDecoration(
                      labelText: '任务名称',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                    const SizedBox(height: 14),
                    // Date picker
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderSubtle),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: AppColors.text2),
                            const SizedBox(width: 10),
                            Text(
                              '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right, size: 18, color: AppColors.text3),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TaskTimeField(
                      startHour: _startHour,
                      startMinute: _startMinute,
                      onTap: _pickTime,
                    ),
                    const SizedBox(height: 12),
                    TaskDurationEditor(
                      duration: _duration,
                      onDecrease: () => setState(
                        () => _duration = (_duration - 15).clamp(15, 240),
                      ),
                      onIncrease: () => setState(
                        () => _duration = (_duration + 15).clamp(15, 240),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TaskDurationPresetChips(
                      duration: _duration,
                      onSelected: (minutes) => setState(() => _duration = minutes),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '状态:',
                      style: TextStyle(fontSize: 13, color: AppColors.text2),
                    ),
                    const SizedBox(height: 6),
                    TaskStatusSelector(
                      selectedStatus: _selectedStatus,
                      onSelected: (status) => setState(() => _selectedStatus = status),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '颜色:',
                      style: TextStyle(fontSize: 13, color: AppColors.text2),
                    ),
                    const SizedBox(height: 4),
                    TaskColorPicker(
                      selectedColor: _selectedColor,
                      onSelected: (color) => setState(() => _selectedColor = color),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '关联目标:',
                      style: TextStyle(fontSize: 13, color: AppColors.text2),
                    ),
                    const SizedBox(height: 4),
                    TaskGoalDropdown(
                      goals: widget.goals,
                      selectedGoalId: _selectedGoalId,
                      onChanged: (value) => setState(() => _selectedGoalId = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesCtrl,
                      minLines: 3,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: '备注',
                        hintText: '补充上下文、提醒或延期原因',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_isEdit)
                    TextButton(
                      onPressed: () => Navigator.pop(
                        context,
                        const TaskDialogResult.delete(),
                      ),
                      style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                      child: const Text('删除'),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _save,
                    child: Text(_isEdit ? '保存' : '添加'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}