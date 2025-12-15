import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/sessions_provider.dart';
import '../results/result_screen.dart';

class HistoryScreen extends ConsumerWidget {
  final String language; // 'ko' or 'en'

  const HistoryScreen({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final filteredSessions = sessions.where((s) => s.language == language).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(language == 'ko' ? '기록' : 'History'),
      ),
      body: filteredSessions.isEmpty
          ? Center(
              child: Text(language == 'ko' ? '기록이 없습니다' : 'No history available'),
            )
          : ListView.builder(
              itemCount: filteredSessions.length,
              itemBuilder: (context, index) {
                final session = filteredSessions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      session.transcript.length > 50
                          ? '${session.transcript.substring(0, 50)}...'
                          : session.transcript,
                    ),
                    subtitle: Text(
                      '${session.createdAt.year}-${session.createdAt.month.toString().padLeft(2, '0')}-${session.createdAt.day.toString().padLeft(2, '0')} ${session.createdAt.hour.toString().padLeft(2, '0')}:${session.createdAt.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteSession(context, ref, session.id),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(session: session),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  void _deleteSession(BuildContext context, WidgetRef ref, String sessionId) {
    final isKorean = language == 'ko';
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

