import '../../models/journal_entry.dart';

class ReviewPageMetrics {
  const ReviewPageMetrics({
    required this.today,
    required this.thisWeekStart,
    required this.reflectionCount,
    required this.reviewCount,
    required this.weekCount,
    required this.streak,
    required this.recent,
  });

  final DateTime today;
  final DateTime thisWeekStart;
  final int reflectionCount;
  final int reviewCount;
  final int weekCount;
  final int streak;
  final List<JournalEntry> recent;

  factory ReviewPageMetrics.fromJournals(List<JournalEntry> journals) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final recent = List<JournalEntry>.from(journals)..sort((a, b) => b.date.compareTo(a.date));

    return ReviewPageMetrics(
      today: today,
      thisWeekStart: thisWeekStart,
      reflectionCount: journals.where((journal) => journal.type == JournalType.reflection).length,
      reviewCount: journals.where((journal) => journal.type == JournalType.review).length,
      weekCount: journals.where((journal) => !journal.date.isBefore(thisWeekStart)).length,
      streak: buildStreak(journals, today),
      recent: recent,
    );
  }
}

int buildStreak(List<JournalEntry> journals, DateTime today) {
  var streak = 0;
  for (var i = 0; i < 365; i++) {
    final day = today.subtract(Duration(days: i));
    if (journals.any((journal) => isSameCalendarDay(journal.date, day))) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

List<int> buildWeeklyCounts(List<JournalEntry> journals, DateTime thisWeekStart) {
  return List<int>.generate(7, (index) {
    final day = thisWeekStart.add(Duration(days: index));
    return journalCountOnDay(journals, day);
  });
}

List<int> buildLast7DayCounts(List<JournalEntry> journals, DateTime today) {
  return List<int>.generate(7, (index) {
    final day = today.subtract(Duration(days: 6 - index));
    return journalCountOnDay(journals, day);
  });
}

int journalCountOnDay(List<JournalEntry> journals, DateTime day) {
  return journals.where((journal) => isSameCalendarDay(journal.date, day)).length;
}

bool isSameCalendarDay(DateTime left, DateTime right) {
  return left.year == right.year && left.month == right.month && left.day == right.day;
}
