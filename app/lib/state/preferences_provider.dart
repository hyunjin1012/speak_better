import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_store.dart';

/// Provider for UI language preference
final uiLanguageProvider =
    StateNotifierProvider<UILanguageNotifier, String?>((ref) {
  return UILanguageNotifier();
});

class UILanguageNotifier extends StateNotifier<String?> {
  UILanguageNotifier() : super(LocalStore.getUILanguage()) {
    _loadLanguage();
  }

  void _loadLanguage() {
    state = LocalStore.getUILanguage();
  }

  Future<void> setLanguage(String language) async {
    await LocalStore.saveUILanguage(language);
    state = language;
  }
}

/// Provider for learner mode preference
final learnerModeProvider =
    StateNotifierProvider<LearnerModeNotifier, String?>((ref) {
  return LearnerModeNotifier();
});

class LearnerModeNotifier extends StateNotifier<String?> {
  LearnerModeNotifier() : super(LocalStore.getLearnerMode()) {
    _loadLearnerMode();
  }

  void _loadLearnerMode() {
    state = LocalStore.getLearnerMode();
  }

  Future<void> setLearnerMode(String learnerMode) async {
    await LocalStore.saveLearnerMode(learnerMode);
    state = learnerMode;
  }
}
