import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/session.dart';
import '../../models/improve_result.dart';
import '../../state/sessions_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final PracticeSession session;

  const ResultScreen({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late ImproveResult _result;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _result = ImproveResult.fromJson(widget.session.improveData);
    // Save session to local store
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionsProvider.notifier).addSession(widget.session);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKorean = widget.session.language == 'ko';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isKorean ? '결과' : 'Results'),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
          bottom: TabBar(
            onTap: (index) => setState(() => _selectedTab = index),
            tabs: [
              Tab(text: isKorean ? '개선된 텍스트' : 'Improved'),
              Tab(text: isKorean ? '대안' : 'Alternatives'),
              Tab(text: isKorean ? '피드백' : 'Feedback'),
            ],
          ),
        ),
        body: IndexedStack(
          index: _selectedTab,
          children: [
            _buildImprovedTab(),
            _buildAlternativesTab(),
            _buildFeedbackTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.session.language == 'ko' ? '원본' : 'Original',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(widget.session.transcript),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.session.language == 'ko' ? '개선된 텍스트' : 'Improved',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_result.improved),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlternativeCard(
            widget.session.language == 'ko' ? '격식체' : 'Formal',
            _result.alternatives.formal,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildAlternativeCard(
            widget.session.language == 'ko' ? '구어체' : 'Casual',
            _result.alternatives.casual,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildAlternativeCard(
            widget.session.language == 'ko' ? '간결한 버전' : 'Concise',
            _result.alternatives.concise,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeCard(
      String title, String content, MaterialColor color) {
    return Card(
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color.shade700,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_result.feedback.summary.isNotEmpty) ...[
            Text(
              widget.session.language == 'ko' ? '요약' : 'Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ..._result.feedback.summary.map((s) => Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(s),
                  ),
                )),
            const SizedBox(height: 24),
          ],
          if (_result.feedback.grammarFixes.isNotEmpty) ...[
            Text(
              widget.session.language == 'ko' ? '문법 수정' : 'Grammar Fixes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ..._result.feedback.grammarFixes.map((fix) => Card(
                  child: ExpansionTile(
                    title: Text('${fix.from} → ${fix.to}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(fix.why),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
          ],
          if (_result.feedback.vocabularyUpgrades.isNotEmpty) ...[
            Text(
              widget.session.language == 'ko' ? '어휘 개선' : 'Vocabulary Upgrades',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ..._result.feedback.vocabularyUpgrades.map((upgrade) => Card(
                  child: ExpansionTile(
                    title: Text('${upgrade.from} → ${upgrade.to}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(upgrade.why),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
          ],
          if (_result.feedback.fillerWords.count > 0) ...[
            Text(
              widget.session.language == 'ko' ? '채움말' : 'Filler Words',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.session.language == 'ko'
                          ? '총 ${_result.feedback.fillerWords.count}개 발견'
                          : 'Found ${_result.feedback.fillerWords.count} filler words',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_result.feedback.fillerWords.examples.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _result.feedback.fillerWords.examples
                            .map((e) => Chip(label: Text(e)))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
