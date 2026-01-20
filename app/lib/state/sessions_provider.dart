import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import '../data/local_store.dart';
import '../services/notification_service.dart';
import 'stats_provider.dart';
import 'achievements_provider.dart';
import 'flashcards_provider.dart';

final sessionsProvider =
    StateNotifierProvider<SessionsNotifier, List<PracticeSession>>((ref) {
  return SessionsNotifier(ref);
});

class SessionsNotifier extends StateNotifier<List<PracticeSession>> {
  final Ref _ref;

  SessionsNotifier(this._ref) : super([]) {
    _loadSessions();
  }

  void _loadSessions() {
    state = LocalStore.getAllSessions();
    // Refresh stats and achievements when sessions change
    // Defer refresh to avoid modifying providers during initialization
    Future.microtask(() {
      _ref.read(statsProvider.notifier).refresh();
      _ref.read(achievementsProvider.notifier).refresh();
    });
  }

  Future<void> addSession(PracticeSession session) async {
    await LocalStore.saveSession(session);
    _loadSessions();

    // Extract vocabulary from session for flashcards
    Future.microtask(() {
      _ref
          .read(flashcardsProvider.notifier)
          .extractVocabularyFromSession(session);
    });

    // Update notification messages based on new session
    // This will update tomorrow's notification with updated streak info
    Future.microtask(() {
      NotificationService().updateNotificationMessage(session.language);
    });
  }

  Future<void> deleteSession(String sessionId) async {
    await LocalStore.deleteSession(sessionId);
    _loadSessions();
  }
}
