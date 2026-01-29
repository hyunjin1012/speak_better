import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/topic.dart';
import '../../state/topics_provider.dart';
import '../../utils/constants.dart';
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
    final filteredTopics =
        topics.where((t) => t.language == widget.language).toList();

    return filteredTopics.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.topic,
                  size: 64,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
                AppSpacing.heightMd,
                Text(
                  widget.language == 'ko' ? '주제가 없습니다' : 'No topics available',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: AppPadding.allMd,
            itemCount: filteredTopics.length,
            itemBuilder: (context, index) {
              final topic = filteredTopics[index];
              final colorScheme = Theme.of(context).colorScheme;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.circularLg,
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
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
                  borderRadius: AppBorderRadius.circularLg,
                  child: Padding(
                    padding: AppPadding.allMd,
                    child: Row(
                      children: [
                        Container(
                          padding: AppPadding.allMd,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: AppBorderRadius.circularMd,
                          ),
                          child: Icon(
                            topic.isBuiltIn ? Icons.star : Icons.edit,
                            color: colorScheme.primary,
                          ),
                        ),
                        AppSpacing.widthMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topic.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (topic.prompt.isNotEmpty) ...[
                                AppSpacing.heightXs,
                                Text(
                                  topic.prompt,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!topic.isBuiltIn)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                color: colorScheme.primary,
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  _showEditTopicDialog(context, topic);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  _deleteTopic(context, topic.id);
                                },
                              ),
                            ],
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
            AppSpacing.heightMd,
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
              if (titleController.text.isNotEmpty &&
                  promptController.text.isNotEmpty) {
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

  void _showEditTopicDialog(BuildContext context, Topic topic) {
    final titleController = TextEditingController(text: topic.title);
    final promptController = TextEditingController(text: topic.prompt);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.language == 'ko' ? '주제 편집' : 'Edit Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: widget.language == 'ko' ? '제목' : 'Title',
              ),
            ),
            AppSpacing.heightMd,
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
              if (titleController.text.isNotEmpty &&
                  promptController.text.isNotEmpty) {
                ref.read(topicsProvider.notifier).updateTopic(
                      Topic(
                        id: topic.id,
                        title: titleController.text,
                        prompt: promptController.text,
                        language: topic.language,
                        isBuiltIn: topic.isBuiltIn,
                        createdAt: topic.createdAt,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: Text(widget.language == 'ko' ? '저장' : 'Save'),
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
