import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard.dart';
import '../models/session.dart';
import '../models/improve_result.dart';
import '../data/local_store.dart';
import '../services/spaced_repetition_service.dart';

final flashcardsProvider = StateNotifierProvider<FlashcardsNotifier, List<Flashcard>>((ref) {
  return FlashcardsNotifier();
});

class FlashcardsNotifier extends StateNotifier<List<Flashcard>> {
  final SpacedRepetitionService _spacedRepetition = SpacedRepetitionService();

  FlashcardsNotifier() : super([]) {
    _loadFlashcards();
  }

  void _loadFlashcards() {
    state = LocalStore.getAllFlashcards();
  }

  /// Extract vocabulary from a session and create flashcards
  Future<void> extractVocabularyFromSession(PracticeSession session) async {
    try {
      final improveData = session.improveData;
      final result = ImproveResult.fromJson(improveData);
      
      final existingFlashcards = LocalStore.getAllFlashcards();
      final existingFronts = existingFlashcards.map((f) => f.front.toLowerCase()).toSet();

      // Create flashcards from vocabulary upgrades
      for (final vocab in result.feedback.vocabularyUpgrades) {
        final front = vocab.from.trim();
        final back = vocab.to.trim();
        final explanation = vocab.why.trim();
        
        final frontLower = front.toLowerCase();
        final backLower = back.toLowerCase();
        final explanationLower = explanation.toLowerCase();
        
        // Skip if front or back is empty
        if (front.isEmpty || back.isEmpty) {
          continue;
        }
        
        // Skip if front and back are the same (no actual upgrade)
        if (frontLower == backLower) {
          continue;
        }
        
        // Skip if we already have this flashcard
        if (existingFronts.contains(frontLower)) {
          continue;
        }
        
        // Skip if explanation is empty or too generic
        if (explanation.isEmpty) {
          continue;
        }
        
        // Skip if explanation indicates no actual vocabulary change
        if (explanationLower.contains('remains the same') ||
            explanationLower.contains('same while') ||
            explanationLower.contains('same as') ||
            explanationLower.contains('no change') ||
            explanationLower.contains('unchanged')) {
          continue;
        }
        
        // Skip if explanation is about sentence flow rather than vocabulary
        if (explanationLower.contains('sentence flows') ||
            explanationLower.contains('whole sentence') ||
            explanationLower.contains('sentence structure') ||
            explanationLower.contains('better flow')) {
          // Only skip if front and back are very similar (likely not a vocab upgrade)
          if (frontLower.length == backLower.length && 
              frontLower.split(' ').length == backLower.split(' ').length) {
            continue;
          }
        }

        final flashcard = Flashcard(
          front: front,
          back: back,
          explanation: explanation,
          language: session.language,
        );

        await LocalStore.saveFlashcard(flashcard);
      }

      _loadFlashcards();
    } catch (e) {
      print('Error extracting vocabulary from session: $e');
    }
  }

  /// Extract vocabulary from all sessions
  Future<void> extractVocabularyFromAllSessions() async {
    final sessions = LocalStore.getAllSessions();
    for (final session in sessions) {
      if (session.improveJson.isNotEmpty) {
        await extractVocabularyFromSession(session);
      }
    }
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    await LocalStore.saveFlashcard(flashcard);
    _loadFlashcards();
  }

  Future<void> deleteFlashcard(String flashcardId) async {
    await LocalStore.deleteFlashcard(flashcardId);
    _loadFlashcards();
  }

  // Cache filtered cards by language to avoid repeated filtering
  List<Flashcard> _getLanguageCards(String language) {
    return state.where((f) => f.language == language).toList();
  }

  List<Flashcard> getDueCards(String language) {
    return _spacedRepetition.getDueCards(_getLanguageCards(language));
  }

  List<Flashcard> getNewCards(String language) {
    return _spacedRepetition.getNewCards(_getLanguageCards(language));
  }

  List<Flashcard> getMasteredCards(String language) {
    return _spacedRepetition.getMasteredCards(_getLanguageCards(language));
  }
}
