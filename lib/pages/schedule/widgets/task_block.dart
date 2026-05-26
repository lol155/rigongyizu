import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/task.dart';
import 'task_block_colors.dart';

class TaskBlock extends StatefulWidget {
  const TaskBlock({
    super.key,
    required this.task,
    required this.top,
    required this.height,
    required this.leftPos,
    required this.columnIndex,
    required this.columnCount,
    required this.hourHeight,
    required this.startHour,
    required this.endHour,
    required this.onEditTask,
    required this.onToggleDone,
    required this.onTaskChanged,
    required this.onPersist,
  });

  final ScheduleTask task;
  final double top;
  final double height;
  final double leftPos;
  final int columnIndex;
  final int columnCount;
  final double hourHeight;
  final int startHour;
  final int endHour;
  final ValueChanged<ScheduleTask> onEditTask;
  final ValueChanged<ScheduleTask> onToggleDone;
  final VoidCallback onTaskChanged;
  final Future<void> Function() onPersist;

  @override
  State<TaskBlock> createState() => _TaskBlockState();
}

class _TaskBlockState extends State<TaskBlock> {
  DateTime? _dragOriginalStart;

  @override
  Widget build(BuildContext context) {
    final status = widget.task.status;
    final isDone = status == TaskStatus.done;
    final accentColor = TaskBlockColors.accent(widget.task.color, status);
    final textColor = TaskBlockColors.text(widget.task.color, status);
    final statusLabel = TaskBlockColors.statusLabel(status);
    final statusIcon = TaskBlockColors.statusIcon(status);

    final isMultiColumn = widget.columnCount > 1;
    final colFrac = 1.0 / widget.columnCount;
    // Calculate available width from screen: total width minus container margins (32),
    // minus time label area (44), minus right padding (4).
    final screenWidth = MediaQuery.sizeOf(context).width;
    final taskAreaWidth = screenWidth - 32 - 44 - 4;
    final colWidth = colFrac * taskAreaWidth;

    final titleText = Text(
      widget.task.title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
        decoration: TaskBlockColors.usesLineThrough(status)
            ? TextDecoration.lineThrough
            : null,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Positioned(
      top: widget.top,
      left: isMultiColumn
          ? widget.leftPos + widget.columnIndex * colWidth
          : widget.leftPos,
      width: isMultiColumn ? colWidth - 2 : null,
      right: isMultiColumn ? null : 4.0,
      height: widget.height,
      child: AnimatedOpacity(
        opacity: TaskBlockColors.opacity(status),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: TaskBlockColors.background(widget.task.color, status),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: accentColor, width: 3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Content fills full card — no separate resize zone
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onEditTask(widget.task),
                  onLongPressStart: (_) {
                    HapticFeedback.mediumImpact();
                    _dragOriginalStart = widget.task.startTime;
                  },
                  onLongPressMoveUpdate: (details) {
                    if (_dragOriginalStart != null) {
                      setState(() {
                        final offsetMinutes =
                            (details.localOffsetFromOrigin.dy / widget.hourHeight * 60)
                                .round();
                        final snappedMinutes = (offsetMinutes ~/ 15) * 15;
                        final newStart =
                            _dragOriginalStart!.add(Duration(minutes: snappedMinutes));
                        final clampedHour =
                            newStart.hour.clamp(widget.startHour, widget.endHour - 1);
                        final clampedMinute = (newStart.minute ~/ 15) * 15;
                        widget.task.startTime = DateTime(
                          widget.task.date.year,
                          widget.task.date.month,
                          widget.task.date.day,
                          clampedHour,
                          clampedMinute,
                        );
                      });
                      widget.onTaskChanged();
                    }
                  },
                  onLongPressEnd: (_) {
                    _dragOriginalStart = null;
                    widget.onPersist();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      top: 4,
                      right: 6,
                      bottom: 4,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => widget.onToggleDone(widget.task),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 16,
                              color: accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildContent(
                            titleText: titleText,
                            statusLabel: statusLabel,
                            statusIcon: statusIcon,
                            textColor: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Resize handle — always visible, overlays bottom edge
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 12,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onEditTask(widget.task),
                  onVerticalDragStart: (_) {
                    HapticFeedback.selectionClick();
                  },
                  onVerticalDragUpdate: (details) {
                    final deltaMinutes =
                        (details.delta.dy / widget.hourHeight * 60).round();
                    if (deltaMinutes != 0) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        widget.task.durationMinutes =
                            (widget.task.durationMinutes + deltaMinutes).clamp(15, 480);
                      });
                      widget.onTaskChanged();
                    }
                  },
                  onVerticalDragEnd: (_) => widget.onPersist(),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Container(
                        width: widget.height >= 40 ? 32 : 20,
                        height: widget.height >= 40 ? 3 : 2,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent({
    required Text titleText,
    required String? statusLabel,
    required IconData? statusIcon,
    required Color textColor,
  }) {
    final status = widget.task.status;
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentHeight = constraints.maxHeight;
        final showStatusBadge =
            statusLabel != null && statusIcon != null && contentHeight >= 44;
        final showTime = contentHeight >= (showStatusBadge ? 56 : 36);

        if (!showStatusBadge && !showTime) {
          return Align(alignment: Alignment.topLeft, child: titleText);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleText,
            if (showStatusBadge)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: TaskBlockColors.statusBadgeBackground(status),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 10,
                        color: TaskBlockColors.statusBadgeForeground(status),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: TaskBlockColors.statusBadgeForeground(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (showTime)
              Text(
                '${widget.task.startTime.hour.toString().padLeft(2, '0')}:${widget.task.startTime.minute.toString().padLeft(2, '0')}-${widget.task.endTime.hour.toString().padLeft(2, '0')}:${widget.task.endTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 9,
                  color: textColor.withValues(alpha: 0.6),
                ),
                maxLines: 1,
              ),
          ],
        );
      },
    );
  }
}
