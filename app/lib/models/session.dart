import 'package:uuid/uuid.dart';
import 'dart:convert';

class PracticeSession {
  PracticeSession({
    String? id,
    required this.language, // 'ko' or 'en'
    required this.learnerMode, // 'korean_learner' or 'english_learner'
    this.topicId,
    this.audioPath,
    required this.transcript,
    required this.improveJson, // store raw JSON map as string
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String language;
  final String learnerMode;
  final String? topicId;
  final String? audioPath;
  final String transcript;
  final String improveJson;
  final DateTime createdAt;

  Map<String, dynamic> get improveData => jsonDecode(improveJson) as Map<String, dynamic>;

  Map<String, dynamic> toJson() => {
        'id': id,
        'language': language,
        'learnerMode': learnerMode,
        'topicId': topicId,
        'audioPath': audioPath,
        'transcript': transcript,
        'improveJson': improveJson,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PracticeSession.fromJson(Map<String, dynamic> json) => PracticeSession(
        id: json['id'] as String,
        language: json['language'] as String,
        learnerMode: json['learnerMode'] as String,
        topicId: json['topicId'] as String?,
        audioPath: json['audioPath'] as String?,
        transcript: json['transcript'] as String,
        improveJson: json['improveJson'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

