import 'package:hive_flutter/hive_flutter.dart';
import '../models/topic.dart';
import '../models/session.dart';

class LocalStore {
  static const String topicsBoxName = 'topics';
  static const String sessionsBoxName = 'sessions';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(topicsBoxName);
    await Hive.openBox(sessionsBoxName);
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
    return topicsBox.values
        .map((v) => Topic.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList();
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
    return sessionsBox.values
        .map((v) => PracticeSession.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}

