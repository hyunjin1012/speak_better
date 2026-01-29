import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/flashcards_provider.dart';
import '../../utils/constants.dart';
import 'flashcard_review_screen.dart';

class FlashcardsScreen extends ConsumerWidget {
  final String language; // 'ko' or 'en'

  const FlashcardsScreen({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcards = ref.watch(flashcardsProvider);
    final isKorean = language == 'ko';

    // Filter once and reuse
    final languageCards =
        flashcards.where((f) => f.language == language).toList();
    final notifier = ref.read(flashcardsProvider.notifier);
    final dueCards = notifier.getDueCards(language);
    final newCards = notifier.getNewCards(language);
    final masteredCards = notifier.getMasteredCards(language);

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '단어 카드' : 'Flashcards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isKorean ? '단어 추출' : 'Extract Words',
            onPressed: () async {
              // Extract vocabulary from all sessions
              await ref
                  .read(flashcardsProvider.notifier)
                  .extractVocabularyFromAllSessions();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isKorean
                        ? '세션에서 단어를 추출했습니다'
                        : 'Extracted words from sessions'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    isKorean ? '전체' : 'Total',
                    '${languageCards.length}',
                    Colors.blue,
                    Icons.auto_stories,
                  ),
                ),
                AppSpacing.widthMd,
                Expanded(
                  child: _buildStatCard(
                    context,
                    isKorean ? '복습 필요' : 'Due',
                    '${dueCards.length}',
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
                AppSpacing.widthMd,
                Expanded(
                  child: _buildStatCard(
                    context,
                    isKorean ? '장기 기억' : 'Long-term',
                    '${masteredCards.length}',
                    Colors.green,
                    Icons.star,
                  ),
                ),
              ],
            ),
          ),

          // Start review button or completion message
          if (dueCards.isNotEmpty || newCards.isNotEmpty)
            Padding(
              padding: AppPadding.horizontalMd,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FlashcardReviewScreen(language: language),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(isKorean ? '복습 시작' : 'Start Review'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            )
          else if (languageCards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      AppSpacing.widthMd,
                      Expanded(
                        child: Text(
                          isKorean
                              ? '모든 카드를 복습했습니다! 다음 복습 날짜를 확인하세요.'
                              : 'All cards reviewed! Check next review dates.',
                          style: TextStyle(color: Colors.green.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Flashcards list
          Expanded(
            child: languageCards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.auto_stories,
                          size: 64,
                          color: Colors.grey,
                        ),
                        AppSpacing.heightMd,
                        Text(
                          isKorean ? '아직 단어 카드가 없습니다' : 'No flashcards yet',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        AppSpacing.heightSm,
                        Text(
                          isKorean
                              ? '연습 세션에서 단어를 추출하세요'
                              : 'Extract words from practice sessions',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: languageCards.length,
                    itemBuilder: (context, index) {
                      final card = languageCards[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: ListTile(
                          title: Text(
                            card.front,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(card.back),
                              const SizedBox(height: 4),
                              Text(
                                card.explanation,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (card.nextReview != null) ...[
                                AppSpacing.heightXs,
                                Text(
                                  isKorean
                                      ? '다음 복습: ${_formatDate(card.nextReview!, isKorean: isKorean)}'
                                      : 'Next review: ${_formatDate(card.nextReview!, isKorean: isKorean)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        card.isDue ? Colors.red : Colors.grey,
                                    fontWeight: card.isDue
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title:
                                      Text(isKorean ? '카드 삭제' : 'Delete Card'),
                                  content: Text(isKorean
                                      ? '이 카드를 삭제하시겠습니까?'
                                      : 'Are you sure you want to delete this card?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(isKorean ? '취소' : 'Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref
                                            .read(flashcardsProvider.notifier)
                                            .deleteFlashcard(card.id);
                                        Navigator.pop(context);
                                      },
                                      child: Text(isKorean ? '삭제' : 'Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
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

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date, {required bool isKorean}) {
    final now = DateTime.now();
    // Compare dates only (ignore time)
    final today = DateTime(now.year, now.month, now.day);
    final reviewDate = DateTime(date.year, date.month, date.day);
    final difference = reviewDate.difference(today).inDays;

    if (difference < 0) {
      return isKorean ? '지연됨' : 'Overdue';
    } else if (difference == 0) {
      return isKorean ? '오늘' : 'Today';
    } else if (difference == 1) {
      return isKorean ? '내일' : 'Tomorrow';
    } else {
      return isKorean ? '$difference일 후' : 'In $difference days';
    }
  }
}
