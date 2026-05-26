import '../utils/app_colors.dart';

class ScheduleTask {
  final String id;
  String title;
  final DateTime date;
  DateTime startTime;
  int durationMinutes;
  String? goalId;
  TaskStatus status;
  int color;
  String notes;

  ScheduleTask({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    this.durationMinutes = 60,
    this.goalId,
    this.status = TaskStatus.pending,
    this.color = AppColors.primaryValue,
    this.notes = '',
  });

  DateTime get endTime =>
      startTime.add(Duration(minutes: durationMinutes));

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'startTime': startTime.toIso8601String(),
        'durationMinutes': durationMinutes,
        'goalId': goalId,
        'status': status.index,
        'color': color,
        'notes': notes,
      };

  factory ScheduleTask.fromMap(Map<String, dynamic> map) => ScheduleTask(
        id: map['id'] as String,
        title: map['title'] as String,
        date: DateTime.parse(map['date'] as String),
        startTime: DateTime.parse(map['startTime'] as String),
        durationMinutes: map['durationMinutes'] as int? ?? 60,
        goalId: map['goalId'] as String?,
        status: TaskStatus.values[map['status'] as int? ?? 0],
        color: map['color'] as int? ?? AppColors.primaryValue,
        notes: map['notes'] as String? ?? '',
      );
}

enum TaskStatus {
  pending,
  done,
  postponed,
  cancelled,
}
