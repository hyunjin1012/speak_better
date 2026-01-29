import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/sessions_provider.dart';
import '../../state/topics_provider.dart';
import '../../models/topic.dart';
import '../../models/session.dart';
import '../../utils/constants.dart';
import '../../widgets/session_card.dart';
import '../../widgets/skeleton_loader.dart';
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
  final Map<String, bool> _imageExistsCache = {};
  static const int _itemsPerPage = 20;
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Load more when 90% scrolled
      _loadMore();
    }
  }

  void _loadMore() {
    final sessions = ref.read(sessionsProvider);
    final filteredSessions =
        sessions.where((s) => s.language == widget.language).toList();
    final searchResults = _searchQuery.isEmpty
        ? filteredSessions
        : filteredSessions.where((session) {
            return session.transcript
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();

    final totalPages = (searchResults.length / _itemsPerPage).ceil();
    if (_currentPage < totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  List<PracticeSession> _getPaginatedSessions(List<PracticeSession> sessions) {
    const startIndex = 0;
    final endIndex = (_currentPage + 1) * _itemsPerPage;
    return sessions.sublist(
        startIndex, endIndex > sessions.length ? sessions.length : endIndex);
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

    // Get paginated results
    final paginatedResults = _getPaginatedSessions(searchResults);
    final hasMore = paginatedResults.length < searchResults.length;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: AppPadding.allMd,
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
              border: const OutlineInputBorder(
                borderRadius: AppBorderRadius.circularMd,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _currentPage = 0; // Reset pagination when search changes
              });
            },
          ),
        ),
        // Results count
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: AppPadding.horizontalMd,
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
                        size: AppSizes.iconXxl,
                        color: Colors.grey,
                      ),
                      AppSpacing.heightMd,
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
                      if (_searchQuery.isEmpty) ...[
                        AppSpacing.heightLg,
                        ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pushNamed(context, '/topics');
                          },
                          icon: const Icon(Icons.mic),
                          label: Text(widget.language == 'ko'
                              ? '첫 녹음 시작하기'
                              : 'Start Your First Recording'),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.lightImpact();
                    // Refresh sessions
                    ref.invalidate(sessionsProvider);
                    await Future.delayed(AppDurations.refreshDelay);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: AppPadding.allMd,
                    itemCount: paginatedResults.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == paginatedResults.length) {
                        // Loading indicator at the end
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final session = paginatedResults[index];
                      final topic = getTopicById(session.topicId);
                      return SessionCard(
                        session: session,
                        topic: topic,
                        imageExistsCache: _imageExistsCache,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ResultScreen(session: session),
                            ),
                          );
                        },
                        onDelete: () {
                          _deleteSession(context, ref, session.id);
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Future<bool> _checkImageExists(String imagePath) async {
    if (_imageExistsCache.containsKey(imagePath)) {
      return _imageExistsCache[imagePath]!;
    }
    try {
      final file = File(imagePath);
      final exists = await file.exists();
      _imageExistsCache[imagePath] = exists;
      return exists;
    } catch (e) {
      _imageExistsCache[imagePath] = false;
      return false;
    }
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
              HapticFeedback.mediumImpact();
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
