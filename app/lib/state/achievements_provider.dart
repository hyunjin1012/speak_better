import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../data/local_store.dart';
import 'stats_provider.dart';
import 'achievement_celebration_provider.dart';
import 'dart:convert';

final achievementsProvider =
    StateNotifierProvider<AchievementsNotifier, List<Achievement>>((ref) {
  return AchievementsNotifier(ref);
});

class AchievementsNotifier extends StateNotifier<List<Achievement>> {
  final Ref _ref;

  AchievementsNotifier(this._ref) : super([]) {
    _initializeAchievements();
    _checkAchievements();
  }

  void _initializeAchievements() {
    // Create all achievements with default values
    state = [
      Achievement(
        type: AchievementType.firstRecording,
        id: 'first_recording',
        title: 'First Steps',
        description: 'Complete your first recording',
        emoji: '🎤',
        progress: 0,
        target: 1,
      ),
      Achievement(
        type: AchievementType.weekWarrior,
        id: 'week_warrior',
        title: 'Week Warrior',
        description: 'Practice 7 days in a row',
        emoji: '🔥',
        progress: 0,
        target: 7,
      ),
      Achievement(
        type: AchievementType.monthMaster,
        id: 'month_master',
        title: 'Month Master',
        description: 'Practice 30 days in a row',
        emoji: '👑',
        progress: 0,
        target: 30,
      ),
      Achievement(
        type: AchievementType.grammarMaster,
        id: 'grammar_master',
        title: 'Grammar Master',
        description: 'Get 10 grammar fixes',
        emoji: '📚',
        progress: 0,
        target: 10,
      ),
      Achievement(
        type: AchievementType.vocabularyBuilder,
        id: 'vocabulary_builder',
        title: 'Vocabulary Builder',
        description: 'Learn 50 new words',
        emoji: '📖',
        progress: 0,
        target: 50,
      ),
      Achievement(
        type: AchievementType.practiceEnthusiast,
        id: 'practice_enthusiast',
        title: 'Practice Enthusiast',
        description: 'Complete 100 practice sessions',
        emoji: '⭐',
        progress: 0,
        target: 100,
      ),
      Achievement(
        type: AchievementType.perfectWeek,
        id: 'perfect_week',
        title: 'Perfect Week',
        description: 'Practice every day for a week',
        emoji: '💯',
        progress: 0,
        target: 7,
      ),
    ];
  }

  void _checkAchievements() {
    final sessions = LocalStore.getAllSessions();
    final stats = _ref.read(statsProvider);

    // Load saved achievements
    final savedAchievements = _loadSavedAchievements();
    final achievementsMap = <String, Achievement>{};

    for (final achievement in savedAchievements) {
      achievementsMap[achievement.id] = achievement;
    }

    // Update achievements based on current progress
    final updatedAchievements = state.map((achievement) {
      // Get saved version if exists
      final saved = achievementsMap[achievement.id] ?? achievement;

      int progress = 0;
      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.firstRecording:
          progress = sessions.isEmpty ? 0 : 1;
          shouldUnlock = sessions.isNotEmpty && saved.unlockedAt == null;
          break;

        case AchievementType.weekWarrior:
          progress = stats.currentStreak >= 7 ? 7 : stats.currentStreak;
          shouldUnlock = stats.currentStreak >= 7 && saved.unlockedAt == null;
          break;

        case AchievementType.monthMaster:
          progress = stats.currentStreak >= 30 ? 30 : stats.currentStreak;
          shouldUnlock = stats.currentStreak >= 30 && saved.unlockedAt == null;
          break;

        case AchievementType.grammarMaster:
          int grammarCount = 0;
          for (final session in sessions) {
            try {
              final improveData = session.improveData;
              final feedback = improveData['feedback'] as Map<String, dynamic>?;
              final grammarFixes = feedback?['grammar_fixes'] as List? ?? [];
              grammarCount += grammarFixes.length;
            } catch (e) {
              // Ignore parsing errors
            }
          }
          progress = grammarCount;
          shouldUnlock = grammarCount >= 10 && saved.unlockedAt == null;
          break;

        case AchievementType.vocabularyBuilder:
          int vocabCount = 0;
          for (final session in sessions) {
            try {
              final improveData = session.improveData;
              final feedback = improveData['feedback'] as Map<String, dynamic>?;
              final vocabUpgrades =
                  feedback?['vocabulary_upgrades'] as List? ?? [];
              vocabCount += vocabUpgrades.length;
            } catch (e) {
              // Ignore parsing errors
            }
          }
          progress = vocabCount;
          shouldUnlock = vocabCount >= 50 && saved.unlockedAt == null;
          break;

        case AchievementType.practiceEnthusiast:
          progress = sessions.length;
          shouldUnlock = sessions.length >= 100 && saved.unlockedAt == null;
          break;

        case AchievementType.perfectWeek:
          // Check if practiced every day for the last 7 days
          final now = DateTime.now();
          int daysPracticed = 0;
          final practiceDates = <String>{};

          for (final session in sessions) {
            final dateKey =
                '${session.createdAt.year}-${session.createdAt.month.toString().padLeft(2, '0')}-${session.createdAt.day.toString().padLeft(2, '0')}';
            practiceDates.add(dateKey);
          }

          for (int i = 0; i < 7; i++) {
            final checkDate = now.subtract(Duration(days: i));
            final dateKey =
                '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
            if (practiceDates.contains(dateKey)) {
              daysPracticed++;
            }
          }

          progress = daysPracticed;
          shouldUnlock = daysPracticed >= 7 && saved.unlockedAt == null;
          break;
      }

      final updatedAchievement = saved.copyWith(
        progress: progress,
        unlockedAt: shouldUnlock ? DateTime.now() : saved.unlockedAt,
      );

      // If this achievement was just unlocked, trigger celebration
      // Defer this to avoid modifying providers during initialization
      if (shouldUnlock && saved.unlockedAt == null) {
        Future.microtask(() {
          _ref.read(newlyUnlockedAchievementProvider.notifier).state =
              updatedAchievement;
        });
      }

      return updatedAchievement;
    }).toList();

    state = updatedAchievements;
    _saveAchievements(updatedAchievements);
  }

  List<Achievement> _loadSavedAchievements() {
    try {
      final box = LocalStore.sessionsBox; // Reuse sessions box for now
      final savedJson = box.get('achievements');
      if (savedJson != null) {
        final List<dynamic> achievementsList = jsonDecode(savedJson as String);
        return achievementsList
            .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Ignore errors
    }
    return [];
  }

  void _saveAchievements(List<Achievement> achievements) {
    try {
      final box = LocalStore.sessionsBox;
      final json = jsonEncode(achievements.map((a) => a.toJson()).toList());
      box.put('achievements', json);
    } catch (e) {
      // Ignore errors
    }
  }

  void refresh() {
    _checkAchievements();
  }
}
