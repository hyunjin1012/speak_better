import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/sessions_provider.dart';
import '../../state/topics_provider.dart';
import '../../models/topic.dart';
import '../results/result_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final String language; // 'ko' or 'en'

  const HistoryScreen({
    super.key,
    required this.language,
  });

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsProvider);
    final topics = ref.watch(topicsProvider);
    final filteredSessions =
        sessions.where((s) => s.language == widget.language).toList();

    // Helper function to get topic by ID
    Topic? getTopicById(String? topicId) {
      if (topicId == null) return null;
      try {
        return topics.firstWhere((t) => t.id == topicId);
      } catch (e) {
        return null;
      }
    }

    // Apply search filter
    final searchResults = _searchQuery.isEmpty
        ? filteredSessions
        : filteredSessions.where((session) {
            return session.transcript
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == 'ko' ? '기록' : 'History'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.language == 'ko' ? '검색...' : 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          // Results count
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.language == 'ko'
                      ? '${searchResults.length}개 결과'
                      : '${searchResults.length} results',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          // Sessions list
          Expanded(
            child: searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off
                              : Icons.history,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? (widget.language == 'ko'
                                  ? '검색 결과가 없습니다'
                                  : 'No results found')
                              : (widget.language == 'ko'
                                  ? '기록이 없습니다'
                                  : 'No history available'),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final session = searchResults[index];
                      final colorScheme = Theme.of(context).colorScheme;
                      final topic = getTopicById(session.topicId);
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ResultScreen(session: session),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    topic?.isBuiltIn == true
                                        ? Icons.star
                                        : Icons.mic,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (topic != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                colorScheme.secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            topic.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onSecondaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                      Text(
                                        session.transcript.length > 50
                                            ? '${session.transcript.substring(0, 50)}...'
                                            : session.transcript,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${session.createdAt.year}-${session.createdAt.month.toString().padLeft(2, '0')}-${session.createdAt.day.toString().padLeft(2, '0')} ${session.createdAt.hour.toString().padLeft(2, '0')}:${session.createdAt.minute.toString().padLeft(2, '0')}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                  onPressed: () =>
                                      _deleteSession(context, ref, session.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _deleteSession(BuildContext context, WidgetRef ref, String sessionId) {
    final isKorean = widget.language == 'ko';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isKorean ? '기록 삭제' : 'Delete Session'),
        content: Text(isKorean
            ? '이 기록을 삭제하시겠습니까?'
            : 'Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isKorean ? '취소' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(sessionsProvider.notifier).deleteSession(sessionId);
              Navigator.pop(context);
            },
            child: Text(isKorean ? '삭제' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
