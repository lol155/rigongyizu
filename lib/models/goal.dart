import '../utils/app_colors.dart';

class Goal {
  final String id;
  String title;
  String description;
  DateTime? deadline;
  int priority;
  final int color;
  GoalStatus status;
  final String? parentId;
  double progressPct;

  Goal({
    required this.id,
    required this.title,
    this.description = '',
    this.deadline,
    this.priority = 0,
    this.color = AppColors.primaryValue,
    this.status = GoalStatus.inProgress,
    this.parentId,
    this.progressPct = 0.0,
  });

  int get remainingDays {
    if (deadline == null) return -1;
    return deadline!.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'deadline': deadline?.toIso8601String(),
        'priority': priority,
        'color': color,
        'status': status.index,
        'parentId': parentId,
        'progressPct': progressPct,
      };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        deadline: map['deadline'] != null
            ? DateTime.parse(map['deadline'] as String)
            : null,
        priority: map['priority'] as int? ?? 0,
        color: map['color'] as int? ?? AppColors.primaryValue,
        status: GoalStatus.values[map['status'] as int? ?? 0],
        parentId: map['parentId'] as String?,
        progressPct: (map['progressPct'] as num?)?.toDouble() ?? 0.0,
      );
}

enum GoalStatus {
  inProgress,
  completed,
}
