class UserStats {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPracticeDate;
  final int totalSessions;
  final int totalPracticeDays;

  UserStats({
    required this.currentStreak,
    required this.longestStreak,
    this.lastPracticeDate,
    required this.totalSessions,
    required this.totalPracticeDays,
  });

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastPracticeDate': lastPracticeDate?.toIso8601String(),
        'totalSessions': totalSessions,
        'totalPracticeDays': totalPracticeDays,
      };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        lastPracticeDate: json['lastPracticeDate'] != null
            ? DateTime.parse(json['lastPracticeDate'] as String)
            : null,
        totalSessions: json['totalSessions'] as int? ?? 0,
        totalPracticeDays: json['totalPracticeDays'] as int? ?? 0,
      );

  UserStats copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastPracticeDate,
    int? totalSessions,
    int? totalPracticeDays,
  }) {
    return UserStats(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      totalSessions: totalSessions ?? this.totalSessions,
      totalPracticeDays: totalPracticeDays ?? this.totalPracticeDays,
    );
  }
}
