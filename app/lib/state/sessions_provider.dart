import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import '../data/local_store.dart';

final sessionsProvider = StateNotifierProvider<SessionsNotifier, List<PracticeSession>>((ref) {
  return SessionsNotifier();
});

class SessionsNotifier extends StateNotifier<List<PracticeSession>> {
  SessionsNotifier() : super([]) {
    _loadSessions();
  }

  void _loadSessions() {
    state = LocalStore.getAllSessions();
  }

  Future<void> addSession(PracticeSession session) async {
    await LocalStore.saveSession(session);
    _loadSessions();
  }

  Future<void> deleteSession(String sessionId) async {
    await LocalStore.deleteSession(sessionId);
    _loadSessions();
  }
}

