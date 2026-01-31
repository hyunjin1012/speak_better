import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';

/// Provider to track newly unlocked achievements for celebration
final newlyUnlockedAchievementProvider =
    StateProvider<Achievement?>((ref) => null);

/// Provider to track streak milestones for celebration
final streakMilestoneProvider = StateProvider<int?>((ref) => null);
