import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic.dart';
import '../data/built_in_topics.dart';
import '../data/local_store.dart';

final topicsProvider = StateNotifierProvider<TopicsNotifier, List<Topic>>((ref) {
  return TopicsNotifier();
});

class TopicsNotifier extends StateNotifier<List<Topic>> {
  TopicsNotifier() : super([]) {
    _loadTopics();
  }

  void _loadTopics() {
    final customTopics = LocalStore.getAllTopics();
    state = [...builtInTopics, ...customTopics];
  }

  Future<void> addTopic(Topic topic) async {
    await LocalStore.saveTopic(topic);
    _loadTopics();
  }

  Future<void> deleteTopic(String topicId) async {
    await LocalStore.deleteTopic(topicId);
    _loadTopics();
  }

  List<Topic> getTopicsByLanguage(String language) {
    return state.where((t) => t.language == language).toList();
  }
}

