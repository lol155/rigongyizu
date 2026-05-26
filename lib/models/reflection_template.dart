class ReflectionTemplate {
  final String id;
  String name;
  TemplateType type;
  final String icon;
  final bool isBuiltIn;
  List<String> questions;

  ReflectionTemplate({
    required this.id,
    required this.name,
    required this.type,
    this.icon = '📝',
    this.isBuiltIn = false,
    this.questions = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.index,
        'icon': icon,
        'isBuiltIn': isBuiltIn,
        'questions': questions,
      };

  factory ReflectionTemplate.fromMap(Map<String, dynamic> map) =>
      ReflectionTemplate(
        id: map['id'] as String,
        name: map['name'] as String,
        type: TemplateType.values[map['type'] as int? ?? 0],
        icon: map['icon'] as String? ?? '📝',
        isBuiltIn: map['isBuiltIn'] as bool? ?? false,
        questions: List<String>.from(map['questions'] as List? ?? []),
      );
}

enum TemplateType {
  reflection,
  review,
}
