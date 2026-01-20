class Flashcard {
  Flashcard({
    String? id,
    required this.front, // Original word/phrase
    required this.back, // Improved word/phrase
    required this.explanation, // Why it's better
    required this.language, // 'ko' or 'en'
    this.easeFactor = 2.5, // SM-2 ease factor
    this.interval = 1, // Days until next review
    this.repetitions = 0, // Number of successful reviews
    DateTime? lastReview,
    DateTime? nextReview,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        lastReview = lastReview,
        nextReview = nextReview ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String front;
  final String back;
  final String explanation;
  final String language;
  double easeFactor; // SM-2 ease factor (default 2.5)
  int interval; // Days until next review
  int repetitions; // Number of successful reviews
  DateTime? lastReview;
  DateTime? nextReview;
  final DateTime createdAt;

  bool get isDue => nextReview == null || DateTime.now().isAfter(nextReview!);
  bool get isNew => repetitions == 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'front': front,
        'back': back,
        'explanation': explanation,
        'language': language,
        'easeFactor': easeFactor,
        'interval': interval,
        'repetitions': repetitions,
        'lastReview': lastReview?.toIso8601String(),
        'nextReview': nextReview?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'] as String,
        front: json['front'] as String,
        back: json['back'] as String,
        explanation: json['explanation'] as String,
        language: json['language'] as String,
        easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
        interval: json['interval'] as int? ?? 1,
        repetitions: json['repetitions'] as int? ?? 0,
        lastReview: json['lastReview'] != null
            ? DateTime.parse(json['lastReview'] as String)
            : null,
        nextReview: json['nextReview'] != null
            ? DateTime.parse(json['nextReview'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Flashcard copyWith({
    String? id,
    String? front,
    String? back,
    String? explanation,
    String? language,
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? lastReview,
    DateTime? nextReview,
    DateTime? createdAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      explanation: explanation ?? this.explanation,
      language: language ?? this.language,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      lastReview: lastReview ?? this.lastReview,
      nextReview: nextReview ?? this.nextReview,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
