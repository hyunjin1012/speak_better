enum AchievementType {
  firstRecording,
  weekWarrior, // 7-day streak
  monthMaster, // 30-day streak
  grammarMaster, // 10 grammar fixes
  vocabularyBuilder, // 50 new words
  practiceEnthusiast, // 100 sessions
  perfectWeek, // 7 sessions in 7 days
}

class Achievement {
  final AchievementType type;
  final String id;
  final String title;
  final String description;
  final String emoji;
  final DateTime? unlockedAt;
  final int progress;
  final int target;

  Achievement({
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.unlockedAt,
    required this.progress,
    required this.target,
  });

  bool get isUnlocked => unlockedAt != null;
  double get progressPercent => (progress / target).clamp(0.0, 1.0);

  Achievement copyWith({
    AchievementType? type,
    String? id,
    String? title,
    String? description,
    String? emoji,
    DateTime? unlockedAt,
    int? progress,
    int? target,
  }) {
    return Achievement(
      type: type ?? this.type,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'id': id,
        'title': title,
        'description': description,
        'emoji': emoji,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'progress': progress,
        'target': target,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        type: AchievementType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => AchievementType.firstRecording,
        ),
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        emoji: json['emoji'] as String,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'] as String)
            : null,
        progress: json['progress'] as int? ?? 0,
        target: json['target'] as int? ?? 1,
      );
}
