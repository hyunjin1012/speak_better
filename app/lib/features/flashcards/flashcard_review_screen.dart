import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard.dart';
import '../../state/flashcards_provider.dart';
import '../../services/spaced_repetition_service.dart';

class FlashcardReviewScreen extends ConsumerStatefulWidget {
  final String language; // 'ko' or 'en'

  const FlashcardReviewScreen({
    super.key,
    required this.language,
  });

  @override
  ConsumerState<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends ConsumerState<FlashcardReviewScreen> {
  final SpacedRepetitionService _spacedRepetition = SpacedRepetitionService();
  int _currentIndex = 0;
  bool _showBack = false;
  List<Flashcard> _reviewCards = [];

  @override
  void initState() {
    super.initState();
    _loadReviewCards();
  }

  void _loadReviewCards() {
    final dueCards = ref.read(flashcardsProvider.notifier).getDueCards(widget.language);
    final newCards = ref.read(flashcardsProvider.notifier).getNewCards(widget.language);
    
    // Combine due and new cards, prioritize due cards
    _reviewCards = [...dueCards, ...newCards];
    
    if (_reviewCards.isEmpty) {
      // No cards to review
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.language == 'ko'
                  ? '복습할 카드가 없습니다'
                  : 'No cards to review'),
            ),
          );
        }
      });
    }
  }

  void _flipCard() {
    setState(() {
      _showBack = !_showBack;
    });
  }

  void _answerCard(int quality) {
    if (_currentIndex >= _reviewCards.length) return;

    final card = _reviewCards[_currentIndex];
    final updatedCard = _spacedRepetition.updateAfterReview(card, quality);
    
    ref.read(flashcardsProvider.notifier).updateFlashcard(updatedCard);

    setState(() {
      _showBack = false;
      _currentIndex++;
    });

    if (_currentIndex >= _reviewCards.length) {
      // All cards reviewed
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.language == 'ko' ? '복습 완료!' : 'Review Complete!'),
        content: Text(widget.language == 'ko'
            ? '모든 카드를 복습했습니다. 잘하셨어요!'
            : 'You\'ve reviewed all cards. Great job!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close review screen
            },
            child: Text(widget.language == 'ko' ? '확인' : 'OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKorean = widget.language == 'ko';

    if (_reviewCards.isEmpty || _currentIndex >= _reviewCards.length) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isKorean ? '단어 카드' : 'Flashcards'),
        ),
        body: Center(
          child: Text(isKorean ? '복습할 카드가 없습니다' : 'No cards to review'),
        ),
      );
    }

    final card = _reviewCards[_currentIndex];
    final progress = (_currentIndex + 1) / _reviewCards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '단어 카드 복습' : 'Flashcard Review'),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${_currentIndex + 1} / ${_reviewCards.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          
          // Card
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _flipCard,
                child: Container(
                  margin: const EdgeInsets.all(24),
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 300),
                  decoration: BoxDecoration(
                    color: _showBack ? Colors.blue.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_showBack) ...[
                          Text(
                            isKorean ? '단어/구문' : 'Word/Phrase',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            card.front,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            isKorean ? '탭하여 뒤집기' : 'Tap to flip',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ] else ...[
                          Text(
                            isKorean ? '개선된 표현' : 'Improved Expression',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            card.back,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              card.explanation,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Answer buttons (only show when back is visible)
          if (_showBack) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    isKorean ? '어떻게 기억하셨나요?' : 'How well did you remember?',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildAnswerButton(
                        context,
                        isKorean ? '잘못' : 'Wrong',
                        0,
                        Colors.red,
                      ),
                      _buildAnswerButton(
                        context,
                        isKorean ? '어려움' : 'Hard',
                        1,
                        Colors.orange,
                      ),
                      _buildAnswerButton(
                        context,
                        isKorean ? '보통' : 'Medium',
                        2,
                        Colors.yellow.shade700,
                      ),
                      _buildAnswerButton(
                        context,
                        isKorean ? '쉬움' : 'Easy',
                        3,
                        Colors.green,
                      ),
                      _buildAnswerButton(
                        context,
                        isKorean ? '완벽' : 'Perfect',
                        4,
                        Colors.green.shade700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerButton(
    BuildContext context,
    String label,
    int quality,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: () => _answerCard(quality),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }
}
