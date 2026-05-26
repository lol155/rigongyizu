import '../../../models/task.dart';

int calculateFreeHours(List<ScheduleTask> tasks, {required int totalHours}) {
  var busyMinutes = 0;
  for (final task in tasks) {
    if (task.status != TaskStatus.done) {
      busyMinutes += task.durationMinutes;
    }
  }

  return (((totalHours * 60) - busyMinutes) / 60)
      .round()
      .clamp(0, totalHours);
}

String buildFreeTimeText(
  List<ScheduleTask> tasks, {
  required int startHour,
  required int endHour,
}) {
  final sortedTasks = tasks.toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  final slots = <String>[];
  var currentMinute = startHour * 60;

  for (final task in sortedTasks) {
    final startMinute = task.startTime.hour * 60 + task.startTime.minute;
    if (startMinute > currentMinute) {
      slots.add(_formatSlot(currentMinute, startMinute));
    }

    final endMinute = startMinute + task.durationMinutes;
    if (endMinute > currentMinute) {
      currentMinute = endMinute;
    }
  }

  if (currentMinute < endHour * 60) {
    slots.add('${_formatMinute(currentMinute)}-24:00');
  }

  return slots.isEmpty ? '无空闲' : slots.join(' · ');
}

String _formatSlot(int startMinute, int endMinute) {
  return '${_formatMinute(startMinute)}-${_formatMinute(endMinute)}';
}

String _formatMinute(int minute) {
  return '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';
}
