import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/achievements_provider.dart';
import '../../models/achievement.dart';

class AchievementsScreen extends ConsumerWidget {
  final String language;

  const AchievementsScreen({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider);
    final unlockedAchievements = achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements = achievements.where((a) => !a.isUnlocked).toList();
    final isKorean = language == 'ko';

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '업적' : 'Achievements'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, size: 48, color: Colors.orange),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isKorean ? '업적 달성' : 'Achievements Unlocked',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${unlockedAchievements.length} / ${achievements.length}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Unlocked achievements
            if (unlockedAchievements.isNotEmpty) ...[
              Text(
                isKorean ? '달성한 업적' : 'Unlocked',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ...unlockedAchievements.map((achievement) => _buildAchievementCard(
                    context,
                    achievement,
                    isKorean,
                    isUnlocked: true,
                  )),
              const SizedBox(height: 24),
            ],
            // Locked achievements
            if (lockedAchievements.isNotEmpty) ...[
              Text(
                isKorean ? '진행 중인 업적' : 'In Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ...lockedAchievements.map((achievement) => _buildAchievementCard(
                    context,
                    achievement,
                    isKorean,
                    isUnlocked: false,
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    Achievement achievement,
    bool isKorean,
    {required bool isUnlocked}
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Emoji/Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.orange.shade100 : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  achievement.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isUnlocked ? null : Colors.grey,
                              ),
                        ),
                      ),
                      if (isUnlocked)
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isUnlocked ? null : Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  LinearProgressIndicator(
                    value: achievement.progressPercent,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUnlocked ? Colors.green : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.progress} / ${achievement.target}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  if (isUnlocked && achievement.unlockedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      isKorean
                          ? '달성일: ${_formatDate(achievement.unlockedAt!)}'
                          : 'Unlocked: ${_formatDate(achievement.unlockedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
