import 'package:uuid/uuid.dart';

class Topic {
  Topic({
    String? id,
    required this.title,
    required this.prompt,
    required this.language, // 'ko' or 'en'
    this.isBuiltIn = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String prompt;
  final String language;
  final bool isBuiltIn;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'prompt': prompt,
        'language': language,
        'isBuiltIn': isBuiltIn,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json['id'] as String,
        title: json['title'] as String,
        prompt: json['prompt'] as String,
        language: json['language'] as String,
        isBuiltIn: json['isBuiltIn'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

