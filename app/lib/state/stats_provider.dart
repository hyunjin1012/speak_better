import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stats.dart';
import '../models/session.dart';
import '../data/local_store.dart';
import 'package:intl/intl.dart';

final statsProvider = StateNotifierProvider<StatsNotifier, UserStats>((ref) {
  return StatsNotifier();
});

class StatsNotifier extends StateNotifier<UserStats> {
  StatsNotifier() : super(UserStats(
    currentStreak: 0,
    longestStreak: 0,
    totalSessions: 0,
    totalPracticeDays: 0,
  )) {
    _calculateStats();
  }

  void _calculateStats() {
    final sessions = LocalStore.getAllSessions();
    
    if (sessions.isEmpty) {
      state = UserStats(
        currentStreak: 0,
        longestStreak: 0,
        totalSessions: 0,
        totalPracticeDays: 0,
      );
      return;
    }

    // Group sessions by date (ignore time)
    final sessionsByDate = <String, List<PracticeSession>>{};
    for (final session in sessions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(session.createdAt);
      sessionsByDate.putIfAbsent(dateKey, () => []).add(session);
    }

    // Get unique practice dates sorted
    final practiceDates = sessionsByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    // Calculate current streak
    int currentStreak = 0;
    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayKey = DateFormat('yyyy-MM-dd').format(yesterday);

    // Check if practiced today or yesterday
    if (practiceDates.contains(todayKey)) {
      // Practiced today, start counting from today
      currentStreak = 1;
      DateTime checkDate = yesterday;
      String checkKey = yesterdayKey;

      while (practiceDates.contains(checkKey)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
        checkKey = DateFormat('yyyy-MM-dd').format(checkDate);
      }
    } else if (practiceDates.contains(yesterdayKey)) {
      // Practiced yesterday but not today
      currentStreak = 1;
      DateTime checkDate = yesterday.subtract(const Duration(days: 1));
      String checkKey = DateFormat('yyyy-MM-dd').format(checkDate);

      while (practiceDates.contains(checkKey)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
        checkKey = DateFormat('yyyy-MM-dd').format(checkDate);
      }
    } else {
      // No practice today or yesterday, streak is broken
      currentStreak = 0;
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastDate;

    for (final dateKey in practiceDates.reversed) {
      final date = DateTime.parse(dateKey);
      
      if (lastDate == null) {
        tempStreak = 1;
      } else {
        final daysDiff = date.difference(lastDate).inDays;
        if (daysDiff == 1) {
          // Consecutive day
          tempStreak++;
        } else {
          // Streak broken
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
          }
          tempStreak = 1;
        }
      }
      lastDate = date;
    }

    // Check final streak
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }

    // Get last practice date
    final lastSession = sessions.first; // Already sorted by date desc
    final lastPracticeDate = lastSession.createdAt;

    state = UserStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastPracticeDate: lastPracticeDate,
      totalSessions: sessions.length,
      totalPracticeDays: practiceDates.length,
    );
  }

  void refresh() {
    _calculateStats();
  }
}
