class JournalEntry {
  final String id;
  final JournalType type;
  final String templateId;
  final String templateName;
  final DateTime date;
  final DateTime time;
  final String content;

  JournalEntry({
    required this.id,
    required this.type,
    required this.templateId,
    required this.templateName,
    required this.date,
    required this.time,
    required this.content,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.index,
        'templateId': templateId,
        'templateName': templateName,
        'date': date.toIso8601String(),
        'time': time.toIso8601String(),
        'content': content,
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
        id: map['id'] as String,
        type: JournalType.values[map['type'] as int? ?? 0],
        templateId: map['templateId'] as String,
        templateName: map['templateName'] as String,
        date: DateTime.parse(map['date'] as String),
        time: DateTime.parse(map['time'] as String),
        content: map['content'] as String,
      );
}

enum JournalType {
  reflection,
  review,
}
