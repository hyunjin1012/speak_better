import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/stats.dart';

class StreakIndicator extends StatelessWidget {
  final UserStats stats;
  final String language;
  final VoidCallback? onTap;

  const StreakIndicator({
    super.key,
    required this.stats,
    required this.language,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isKorean = language == 'ko';

    if (stats.currentStreak == 0) {
      return const SizedBox.shrink();
    }

    // Determine if it's a milestone
    final isMilestone = stats.currentStreak == 7 ||
        stats.currentStreak == 30 ||
        stats.currentStreak == 50 ||
        stats.currentStreak == 100;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isMilestone
                ? [
                    Colors.orange.shade400,
                    Colors.red.shade400,
                  ]
                : [
                    Colors.orange.shade300,
                    Colors.orange.shade200,
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isMilestone
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fire emoji with animation hint
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 1.2),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: const Text(
                    '🔥',
                    style: TextStyle(fontSize: 28),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            // Streak count
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isKorean ? '연속 연습' : 'Day Streak',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${stats.currentStreak}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Milestone indicator
            if (isMilestone)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getMilestoneText(stats.currentStreak, isKorean),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getMilestoneText(int streak, bool isKorean) {
    if (streak == 7) {
      return isKorean ? '1주' : '1W';
    } else if (streak == 30) {
      return isKorean ? '1개월' : '1M';
    } else if (streak == 50) {
      return isKorean ? '50일' : '50';
    } else if (streak == 100) {
      return isKorean ? '100일' : '100';
    }
    return '';
  }
}

/// Widget to show streak celebration dialog
class StreakCelebrationDialog extends StatelessWidget {
  final int streak;
  final String language;

  const StreakCelebrationDialog({
    super.key,
    required this.streak,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final isKorean = language == 'ko';

    String title;
    String message;
    if (streak == 7) {
      title = isKorean ? '🔥 1주 연속 연습! 🔥' : '🔥 Week Warrior! 🔥';
      message = isKorean
          ? '7일 연속으로 연습하셨네요! 정말 대단해요!'
          : 'You\'ve practiced 7 days in a row! Amazing!';
    } else if (streak == 30) {
      title = isKorean ? '👑 1개월 연속 연습! 👑' : '👑 Month Master! 👑';
      message = isKorean
          ? '30일 연속으로 연습하셨네요! 정말 멋져요!'
          : 'You\'ve practiced 30 days in a row! Incredible!';
    } else if (streak == 50) {
      title = isKorean ? '🌟 50일 연속 연습! 🌟' : '🌟 50 Day Streak! 🌟';
      message = isKorean
          ? '50일 연속으로 연습하셨네요! 놀라운 성취예요!'
          : 'You\'ve practiced 50 days in a row! Outstanding achievement!';
    } else if (streak == 100) {
      title = isKorean ? '💎 100일 연속 연습! 💎' : '💎 100 Day Streak! 💎';
      message = isKorean
          ? '100일 연속으로 연습하셨네요! 전설적인 성취예요!'
          : 'You\'ve practiced 100 days in a row! Legendary achievement!';
    } else {
      title = isKorean ? '🔥 연속 연습! 🔥' : '🔥 Streak! 🔥';
      message = isKorean
          ? '$streak일 연속으로 연습하고 계시네요! 계속 화이팅!'
          : 'You\'re on a $streak day streak! Keep it up!';
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade400,
              Colors.red.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔥',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isKorean ? '계속 연습하기' : 'Keep Practicing!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
