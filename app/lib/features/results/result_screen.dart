import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import '../../models/session.dart';
import '../../models/improve_result.dart' hide Feedback;
import '../../models/improve_result.dart' as models show Feedback;
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

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late ImproveResult _result;
  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    try {
      _result = ImproveResult.fromJson(widget.session.improveData);
    } catch (e) {
      // If improveJson is empty or invalid, create empty result
      _result = ImproveResult(
        improved: widget.session.transcript,
        alternatives: Alternatives(
          formal: widget.session.transcript,
          casual: widget.session.transcript,
          concise: widget.session.transcript,
        ),
        feedback: models.Feedback(
          summary: [],
          grammarFixes: [],
          vocabularyUpgrades: [],
          fillerWords: FillerWords(count: 0, examples: []),
        ),
      );
    }

    // Setup audio player listeners
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Save session to local store
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionsProvider.notifier).addSession(widget.session);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (widget.session.audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.session.language == 'ko'
              ? '오디오 파일을 찾을 수 없습니다'
              : 'Audio file not found'),
        ),
      );
      return;
    }

    final file = File(widget.session.audioPath!);
    final exists = await file.exists();

    // Debug logging
    print('=== AUDIO PLAYBACK DEBUG ===');
    print('Audio path: ${widget.session.audioPath}');
    print('File exists: $exists');
    if (exists) {
      print('File size: ${await file.length()} bytes');
    }
    print('===========================');

    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.session.language == 'ko'
              ? '오디오 파일이 삭제되었습니다'
              : 'Audio file has been deleted'),
        ),
      );
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.session.audioPath!));
      }
    } catch (e) {
      print('Audio playback error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.session.language == 'ko'
              ? '오디오 재생 오류: $e'
              : 'Audio playback error: $e'),
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showExportMenu() {
    final isKorean = widget.session.language == 'ko';
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(isKorean ? 'PDF로 내보내기' : 'Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: Text(isKorean ? '텍스트로 내보내기' : 'Export as Text'),
              onTap: () {
                Navigator.pop(context);
                _exportAsText();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(isKorean ? '공유하기' : 'Share'),
              onTap: () {
                Navigator.pop(context);
                _shareSession();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    final isKorean = widget.session.language == 'ko';
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  isKorean ? '연습 결과' : 'Practice Session',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '${isKorean ? '날짜' : 'Date'}: ${dateFormat.format(widget.session.createdAt)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  isKorean ? '원본' : 'Original',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  widget.session.transcript,
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  isKorean ? '개선된 텍스트' : 'Improved',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  _result.improved,
                  style: const pw.TextStyle(fontSize: 12),
                ),
                if (_result.feedback.grammarFixes.isNotEmpty) ...[
                  pw.SizedBox(height: 30),
                  pw.Text(
                    isKorean ? '문법 수정' : 'Grammar Fixes',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  ..._result.feedback.grammarFixes.map((fix) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 10),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '${fix.from} → ${fix.to}',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              fix.why,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      )),
                ],
                if (_result.feedback.vocabularyUpgrades.isNotEmpty) ...[
                  pw.SizedBox(height: 30),
                  pw.Text(
                    isKorean ? '어휘 개선' : 'Vocabulary Upgrades',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  ..._result.feedback.vocabularyUpgrades
                      .map((upgrade) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 10),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  '${upgrade.from} → ${upgrade.to}',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  upgrade.why,
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          )),
                ],
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _exportAsText() async {
    final isKorean = widget.session.language == 'ko';
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    final buffer = StringBuffer();
    buffer.writeln(isKorean ? '연습 결과' : 'Practice Session');
    buffer.writeln(
        '${isKorean ? '날짜' : 'Date'}: ${dateFormat.format(widget.session.createdAt)}');
    buffer.writeln('');
    buffer.writeln('${isKorean ? '원본' : 'Original'}:');
    buffer.writeln(widget.session.transcript);
    buffer.writeln('');
    buffer.writeln('${isKorean ? '개선된 텍스트' : 'Improved'}:');
    buffer.writeln(_result.improved);
    buffer.writeln('');

    if (_result.feedback.grammarFixes.isNotEmpty) {
      buffer.writeln('${isKorean ? '문법 수정' : 'Grammar Fixes'}:');
      for (final fix in _result.feedback.grammarFixes) {
        buffer.writeln('${fix.from} → ${fix.to}');
        buffer.writeln('  ${fix.why}');
      }
      buffer.writeln('');
    }

    if (_result.feedback.vocabularyUpgrades.isNotEmpty) {
      buffer.writeln('${isKorean ? '어휘 개선' : 'Vocabulary Upgrades'}:');
      for (final upgrade in _result.feedback.vocabularyUpgrades) {
        buffer.writeln('${upgrade.from} → ${upgrade.to}');
        buffer.writeln('  ${upgrade.why}');
      }
    }

    // Get the RenderBox for positioning (iOS requirement)
    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? Rect.fromLTWH(
            box.localToGlobal(Offset.zero).dx,
            box.localToGlobal(Offset.zero).dy,
            box.size.width,
            box.size.height,
          )
        : null;

    await Share.share(
      buffer.toString(),
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  Future<void> _shareSession() async {
    final isKorean = widget.session.language == 'ko';
    final text = isKorean
        ? '${widget.session.transcript}\n\n개선: ${_result.improved}'
        : '${widget.session.transcript}\n\nImproved: ${_result.improved}';

    // Get the RenderBox for positioning (iOS requirement)
    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? Rect.fromLTWH(
            box.localToGlobal(Offset.zero).dx,
            box.localToGlobal(Offset.zero).dy,
            box.size.width,
            box.size.height,
          )
        : null;

    await Share.share(
      text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKorean = widget.session.language == 'ko';

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '결과' : 'Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: isKorean ? '내보내기' : 'Export',
            onPressed: _showExportMenu,
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: isKorean ? '개선된 텍스트' : 'Improved'),
            Tab(text: isKorean ? '대안' : 'Alternatives'),
            Tab(text: isKorean ? '피드백' : 'Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildImprovedTab(),
          _buildAlternativesTab(),
          _buildFeedbackTab(),
        ],
      ),
    );
  }

  Widget _buildImprovedTab() {
    final isKorean = widget.session.language == 'ko';
    final hasAudio = widget.session.audioPath != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Audio playback controls
          if (hasAudio) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon:
                              Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                          iconSize: 32,
                          onPressed: _togglePlayback,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Slider(
                                value: _duration.inMilliseconds > 0
                                    ? _position.inMilliseconds.toDouble()
                                    : 0.0,
                                max: _duration.inMilliseconds > 0
                                    ? _duration.inMilliseconds.toDouble()
                                    : 1.0,
                                onChanged: (value) async {
                                  await _audioPlayer.seek(
                                      Duration(milliseconds: value.toInt()));
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_position),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    _formatDuration(_duration),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            isKorean ? '원본' : 'Original',
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
