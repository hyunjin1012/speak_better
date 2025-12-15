import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/topic.dart';
import '../../state/topics_provider.dart';
import '../record/record_screen.dart';

class TopicListScreen extends ConsumerStatefulWidget {
  final String language; // 'ko' or 'en'
  final String learnerMode; // 'korean_learner' or 'english_learner'

  const TopicListScreen({
    super.key,
    required this.language,
    required this.learnerMode,
  });

  @override
  ConsumerState<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends ConsumerState<TopicListScreen> {
  @override
  Widget build(BuildContext context) {
    final topics = ref.watch(topicsProvider);
    final filteredTopics = topics.where((t) => t.language == widget.language).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == 'ko' ? '주제 선택' : 'Select Topic'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTopicDialog(context),
          ),
        ],
      ),
      body: filteredTopics.isEmpty
          ? Center(
              child: Text(widget.language == 'ko' ? '주제가 없습니다' : 'No topics available'),
            )
          : ListView.builder(
              itemCount: filteredTopics.length,
              itemBuilder: (context, index) {
                final topic = filteredTopics[index];
                return ListTile(
                  title: Text(topic.title),
                  subtitle: Text(topic.prompt),
                  trailing: topic.isBuiltIn
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTopic(context, topic.id),
                        ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecordScreen(
                          language: widget.language,
                          learnerMode: widget.learnerMode,
                          topicId: topic.id,
                          topicTitle: topic.title,
                          topicPrompt: topic.prompt,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showAddTopicDialog(BuildContext context) {
    final titleController = TextEditingController();
    final promptController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.language == 'ko' ? '새 주제 추가' : 'Add New Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: widget.language == 'ko' ? '제목' : 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: promptController,
              decoration: InputDecoration(
                labelText: widget.language == 'ko' ? '프롬프트' : 'Prompt',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.language == 'ko' ? '취소' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && promptController.text.isNotEmpty) {
                ref.read(topicsProvider.notifier).addTopic(
                      Topic(
                        title: titleController.text,
                        prompt: promptController.text,
                        language: widget.language,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: Text(widget.language == 'ko' ? '추가' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _deleteTopic(BuildContext context, String topicId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.language == 'ko' ? '주제 삭제' : 'Delete Topic'),
        content: Text(widget.language == 'ko'
            ? '이 주제를 삭제하시겠습니까?'
            : 'Are you sure you want to delete this topic?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.language == 'ko' ? '취소' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(topicsProvider.notifier).deleteTopic(topicId);
              Navigator.pop(context);
            },
            child: Text(widget.language == 'ko' ? '삭제' : 'Delete'),
          ),
        ],
      ),
    );
  }
}

