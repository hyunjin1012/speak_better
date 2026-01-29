import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/topic.dart';
import '../models/session.dart';
import '../models/flashcard.dart';

class LocalStore {
  static const String topicsBoxName = 'topics';
  static const String sessionsBoxName = 'sessions';
  static const String flashcardsBoxName = 'flashcards';
  static const String preferencesBoxName = 'preferences';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(topicsBoxName);
    await Hive.openBox(sessionsBoxName);
    await Hive.openBox(flashcardsBoxName);
    await Hive.openBox(preferencesBoxName);
  }

  // Preferences
  static Box get preferencesBox => Hive.box(preferencesBoxName);

  static Future<void> savePreference(String key, String value) async {
    await preferencesBox.put(key, value);
  }

  static String? getPreference(String key) {
    return preferencesBox.get(key) as String?;
  }

  // UI Language preference ('ko' or 'en')
  static Future<void> saveUILanguage(String language) async {
    await savePreference('ui_language', language);
  }

  static String? getUILanguage() {
    return getPreference('ui_language');
  }

  // Learner Mode preference ('korean_learner' or 'english_learner')
  static Future<void> saveLearnerMode(String learnerMode) async {
    await savePreference('learner_mode', learnerMode);
  }

  static String? getLearnerMode() {
    return getPreference('learner_mode');
  }

  // Topics
  static Box get topicsBox => Hive.box(topicsBoxName);

  static Future<void> saveTopic(Topic topic) async {
    await topicsBox.put(topic.id, topic.toJson());
  }

  static Future<void> deleteTopic(String topicId) async {
    await topicsBox.delete(topicId);
  }

  static List<Topic> getAllTopics() {
    final topics = <Topic>[];
    for (final v in topicsBox.values) {
      try {
        // Handle Map, String, and skip invalid types (for backward compatibility)
        Map<String, dynamic> json;
        if (v is Map) {
          json = Map<String, dynamic>.from(v);
        } else if (v is String) {
          final decoded = jsonDecode(v);
          if (decoded is Map) {
            json = Map<String, dynamic>.from(decoded);
          } else {
            // Skip invalid data (e.g., List instead of Map)
            print(
                'Warning: Skipping topic with invalid format (List instead of Map)');
            continue;
          }
        } else {
          // Skip invalid data types (e.g., List)
          print(
              'Warning: Skipping topic with unexpected type: ${v.runtimeType}');
          continue;
        }
        topics.add(Topic.fromJson(json));
      } catch (e) {
        // Skip topics that fail to parse
        print('Warning: Failed to parse topic: $e');
        continue;
      }
    }
    return topics;
  }

  // Sessions
  static Box get sessionsBox => Hive.box(sessionsBoxName);

  static Future<void> saveSession(PracticeSession session) async {
    await sessionsBox.put(session.id, session.toJson());
  }

  static Future<void> deleteSession(String sessionId) async {
    await sessionsBox.delete(sessionId);
  }

  static List<PracticeSession> getAllSessions() {
    final sessions = <PracticeSession>[];
    final keysToDelete = <dynamic>[]; // Track corrupted entries to delete

    for (final entry in sessionsBox.toMap().entries) {
      final key = entry.key;
      final v = entry.value;

      try {
        // Handle Map, String, List, and skip invalid types (for backward compatibility)
        Map<String, dynamic> json;
        if (v is Map) {
          json = Map<String, dynamic>.from(v);
        } else if (v is String) {
          final decoded = jsonDecode(v);
          if (decoded is Map) {
            json = Map<String, dynamic>.from(decoded);
          } else if (decoded is List) {
            // Try to recover sessions from List (might be old format)
            print('Warning: Found List format, attempting recovery...');
            for (final item in decoded) {
              if (item is Map) {
                try {
                  sessions.add(PracticeSession.fromJson(
                      Map<String, dynamic>.from(item)));
                } catch (e) {
                  print(
                      'Warning: Failed to recover session from List item: $e');
                }
              }
            }
            // Mark this entry for deletion after recovery
            keysToDelete.add(key);
            continue;
          } else {
            print(
                'Warning: Skipping session with invalid format (decoded as ${decoded.runtimeType})');
            keysToDelete.add(key);
            continue;
          }
        } else if (v is List) {
          // Try to recover sessions from List directly
          print('Warning: Found List format, attempting recovery...');
          for (final item in v) {
            if (item is Map) {
              try {
                sessions.add(
                    PracticeSession.fromJson(Map<String, dynamic>.from(item)));
              } catch (e) {
                print('Warning: Failed to recover session from List item: $e');
              }
            }
          }
          // Mark this entry for deletion after recovery
          keysToDelete.add(key);
          continue;
        } else {
          // Skip invalid data types
          print(
              'Warning: Skipping session with unexpected type: ${v.runtimeType}');
          keysToDelete.add(key);
          continue;
        }
        sessions.add(PracticeSession.fromJson(json));
      } catch (e) {
        // Skip sessions that fail to parse
        print('Warning: Failed to parse session: $e');
        keysToDelete.add(key);
        continue;
      }
    }

    // Clean up corrupted entries
    if (keysToDelete.isNotEmpty) {
      print('Cleaning up ${keysToDelete.length} corrupted session entries...');
      for (final key in keysToDelete) {
        sessionsBox.delete(key);
      }
    }

    sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sessions;
  }

  /// Clean up corrupted session entries (call this if you want to manually clean)
  static Future<void> cleanupCorruptedSessions() async {
    final keysToDelete = <dynamic>[];

    for (final entry in sessionsBox.toMap().entries) {
      final key = entry.key;
      final v = entry.value;

      bool isValid = false;
      if (v is Map) {
        isValid = true;
      } else if (v is String) {
        try {
          final decoded = jsonDecode(v);
          isValid = decoded is Map;
        } catch (e) {
          isValid = false;
        }
      }

      if (!isValid) {
        keysToDelete.add(key);
      }
    }

    if (keysToDelete.isNotEmpty) {
      print('Deleting ${keysToDelete.length} corrupted session entries...');
      for (final key in keysToDelete) {
        await sessionsBox.delete(key);
      }
    }
  }

  // Flashcards
  static Box get flashcardsBox => Hive.box(flashcardsBoxName);

  static Future<void> saveFlashcard(Flashcard flashcard) async {
    await flashcardsBox.put(flashcard.id, flashcard.toJson());
  }

  static Future<void> deleteFlashcard(String flashcardId) async {
    await flashcardsBox.delete(flashcardId);
  }

  static List<Flashcard> getAllFlashcards() {
    final flashcards = <Flashcard>[];
    for (final v in flashcardsBox.values) {
      try {
        Map<String, dynamic> json;
        if (v is Map) {
          json = Map<String, dynamic>.from(v);
        } else if (v is String) {
          final decoded = jsonDecode(v);
          if (decoded is Map) {
            json = Map<String, dynamic>.from(decoded);
          } else {
            continue;
          }
        } else {
          continue;
        }
        flashcards.add(Flashcard.fromJson(json));
      } catch (e) {
        print('Warning: Failed to parse flashcard: $e');
        continue;
      }
    }
    return flashcards;
  }

  static List<Flashcard> getFlashcardsByLanguage(String language) {
    return getAllFlashcards().where((f) => f.language == language).toList();
  }
}
