import '../models/flashcard.dart';

/// SM-2 Algorithm implementation for spaced repetition
/// Based on SuperMemo 2 algorithm
class SpacedRepetitionService {
  /// Update flashcard after review
  /// quality: 0-5 (0=blackout, 1=incorrect, 2=incorrect but remembered, 3=correct with difficulty, 4=correct, 5=perfect)
  Flashcard updateAfterReview(Flashcard card, int quality) {
    if (quality < 0 || quality > 5) {
      throw ArgumentError('Quality must be between 0 and 5');
    }

    final now = DateTime.now();
    double newEaseFactor = card.easeFactor;
    int newInterval = card.interval;
    int newRepetitions = card.repetitions;

    if (quality < 3) {
      // Incorrect answer - reset
      newRepetitions = 0;
      newInterval = 1;
      // Don't change ease factor on first failure
      if (card.repetitions > 0) {
        newEaseFactor = card.easeFactor - 0.2;
        if (newEaseFactor < 1.3) {
          newEaseFactor = 1.3; // Minimum ease factor
        }
      }
    } else {
      // Correct answer
      if (card.repetitions == 0) {
        newInterval = 1;
      } else if (card.repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (card.interval * card.easeFactor).round();
      }

      newRepetitions = card.repetitions + 1;

      // Update ease factor based on quality
      newEaseFactor = card.easeFactor +
          (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (newEaseFactor < 1.3) {
        newEaseFactor = 1.3;
      }
    }

    // Set nextReview to start of day (midnight) to avoid time-of-day issues
    final nextReviewDate = now.add(Duration(days: newInterval));
    final nextReview = DateTime(nextReviewDate.year, nextReviewDate.month, nextReviewDate.day);

    return card.copyWith(
      easeFactor: newEaseFactor,
      interval: newInterval,
      repetitions: newRepetitions,
      lastReview: now,
      nextReview: nextReview,
    );
  }

  /// Get cards that are due for review
  List<Flashcard> getDueCards(List<Flashcard> allCards) {
    final now = DateTime.now();
    return allCards
        .where((card) =>
            card.nextReview == null || card.nextReview!.isBefore(now) || card.nextReview!.isAtSameMomentAs(now))
        .toList()
      ..sort((a, b) {
        // Sort by nextReview date (earliest first)
        if (a.nextReview == null && b.nextReview == null) return 0;
        if (a.nextReview == null) return 1;
        if (b.nextReview == null) return -1;
        return a.nextReview!.compareTo(b.nextReview!);
      });
  }

  /// Get new cards (not yet reviewed)
  List<Flashcard> getNewCards(List<Flashcard> allCards) {
    return allCards.where((card) => card.repetitions == 0).toList();
  }

  /// Get mastered cards (interval > 30 days)
  List<Flashcard> getMasteredCards(List<Flashcard> allCards) {
    return allCards.where((card) => card.interval > 30).toList();
  }
}
