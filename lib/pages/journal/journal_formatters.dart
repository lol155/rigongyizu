String formatJournalDate(DateTime date) => '${date.month}月${date.day}日';

String formatJournalDateTime(DateTime date, DateTime time) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
