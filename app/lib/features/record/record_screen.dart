import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import '../../api/speakbetter_api.dart';
import '../../models/session.dart';
import 'dart:convert';
import '../results/result_screen.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({
    super.key,
    required this.language, // 'ko' or 'en'
    required this.learnerMode, // 'korean_learner' or 'english_learner'
    this.topicTitle,
    this.topicPrompt,
    this.topicId,
  });

  final String language;
  final String learnerMode;
  final String? topicTitle;
  final String? topicPrompt;
  final String? topicId;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _recorder = AudioRecorder();
  final _api = SpeakBetterApi();

  bool _isRecording = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Request permission when screen loads to ensure app appears in Settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissionOnLoad();
    });
  }

  Future<void> _requestPermissionOnLoad() async {
    // Check and request permission silently when screen loads
    // This ensures the app appears in Settings even if user hasn't tapped record yet
    try {
      final micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted && !micStatus.isPermanentlyDenied) {
        // Request permission - this will make the app appear in Settings
        await Permission.microphone.request();
        // Also try to check if recorder can access microphone
        // This helps register the app in iOS Settings
        final hasPermission = await _recorder.hasPermission();
        if (!hasPermission) {
          // Permission not granted, but app should now appear in Settings
        }
      }
    } catch (e) {
      // Ignore errors during initialization
    }
  }

  Future<void> _start() async {
    // Check permission using recorder's method first (more reliable)
    final recorderHasPermission = await _recorder.hasPermission();

    // Also check using permission_handler
    var micStatus = await Permission.microphone.status;

    // If recorder says we have permission, proceed (even if permission_handler disagrees)
    if (recorderHasPermission) {
      // Permission is granted, proceed with recording
    } else if (micStatus.isGranted) {
      // permission_handler says granted, proceed
    } else {
      // Request permission if not granted
      micStatus = await Permission.microphone.request();

      // Wait a moment for the system to update
      await Future.delayed(const Duration(milliseconds: 500));

      // Re-check both methods
      micStatus = await Permission.microphone.status;
      final recorderHasPermissionAfterRequest = await _recorder.hasPermission();

      // If recorder says we have permission now, proceed
      if (recorderHasPermissionAfterRequest) {
        // Permission granted, will proceed below
      } else if (!micStatus.isGranted) {
        // Still not granted, will show dialog below
      }
    }

    // Final check: if still not granted, show dialog
    final finalRecorderCheck = await _recorder.hasPermission();
    final finalStatusCheck = await Permission.microphone.status;

    // If either method says we have permission, proceed with recording
    if (finalRecorderCheck || finalStatusCheck.isGranted) {
      // Permission is granted, proceed with recording below
    } else {
      // Permission not granted - show dialog
      if (finalStatusCheck.isPermanentlyDenied) {
        if (mounted) {
          final shouldOpen = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(widget.language == 'ko'
                  ? '마이크 권한 필요'
                  : 'Microphone Permission Required'),
              content: Text(widget.language == 'ko'
                  ? '마이크 권한이 거부되었습니다.\n\n설정 앱을 열면 "Speak Better" 앱이 마이크 목록에 나타납니다.\n\n경로: 개인정보 보호 및 보안 > 마이크 > Speak Better'
                  : 'Microphone permission was denied.\n\nWhen you open Settings, "Speak Better" will appear in the Microphone list.\n\nPath: Privacy & Security > Microphone > Speak Better'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(widget.language == 'ko' ? '취소' : 'Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child:
                      Text(widget.language == 'ko' ? '설정 열기' : 'Open Settings'),
                ),
              ],
            ),
          );

          if (shouldOpen == true) {
            await openAppSettings();
          }
        }
        return;
      } else {
        // Not permanently denied, but still not granted
        if (mounted) {
          final shouldOpen = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(widget.language == 'ko'
                  ? '마이크 권한 필요'
                  : 'Microphone Permission Required'),
              content: Text(widget.language == 'ko'
                  ? '마이크 권한이 필요합니다.\n\n설정 앱을 열면 "Speak Better" 앱이 마이크 목록에 나타납니다.\n\n경로: 개인정보 보호 및 보안 > 마이크 > Speak Better'
                  : 'Microphone permission is required.\n\nWhen you open Settings, "Speak Better" will appear in the Microphone list.\n\nPath: Privacy & Security > Microphone > Speak Better'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(widget.language == 'ko' ? '취소' : 'Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child:
                      Text(widget.language == 'ko' ? '설정 열기' : 'Open Settings'),
                ),
              ],
            ),
          );

          if (shouldOpen == true) {
            await openAppSettings();
          }
        }
        return;
      }
    }

    // Permission is granted - proceed with recording
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final audioPath = path.join(tempDir.path, 'recording_$timestamp.m4a');

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: audioPath,
      );

      setState(() => _isRecording = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _stopAndProcess() async {
    try {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);

      if (path == null) return;
      final file = File(path);

      // Debug: log the file path and extension
      print('Recording file path: $path');
      print('File extension: ${path.split('.').last}');
      print('File exists: ${await file.exists()}');

      setState(() {
        _isProcessing = true;
      });

      // Transcribe
      Map<String, dynamic> t;
      try {
        t = await _api.transcribe(
          audioFile: file,
          language: widget.language,
        );
      } catch (e) {
        // Log error to console
        print('=== TRANSCRIPTION ERROR ===');
        print('Error: $e');
        if (e is DioException) {
          print('Status Code: ${e.response?.statusCode}');
          print('Response Data: ${e.response?.data}');
          print('Request Path: ${e.requestOptions.path}');
        }
        print('==========================');

        setState(() => _isProcessing = false);
        if (mounted) {
          final errorMessage = e is DioException && e.response?.data != null
              ? '${e.response?.statusCode}: ${e.response?.data}'
              : e.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.language == 'ko'
                  ? '전사 실패: $errorMessage'
                  : 'Transcription failed: $errorMessage'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      final transcript = (t['transcript'] ?? '') as String;

      // Improve
      Map<String, dynamic> improved;
      try {
        improved = await _api.improve(
          language: widget.language,
          learnerMode: widget.learnerMode,
          transcript: transcript,
          topic: widget.topicTitle != null || widget.topicPrompt != null
              ? {
                  'title': widget.topicTitle,
                  'prompt': widget.topicPrompt,
                }
              : null,
          preferences: {
            'tone': 'neutral',
            'length': 'similar',
          },
        );
      } catch (e) {
        // Log error to console
        print('=== IMPROVEMENT ERROR ===');
        print('Error: $e');
        if (e is DioException) {
          print('Status Code: ${e.response?.statusCode}');
          print('Response Data: ${e.response?.data}');
          print('Request Path: ${e.requestOptions.path}');
        }
        print('========================');

        setState(() => _isProcessing = false);
        if (mounted) {
          final errorMessage = e is DioException && e.response?.data != null
              ? '${e.response?.statusCode}: ${e.response?.data}'
              : e.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.language == 'ko'
                  ? '개선 실패: $errorMessage'
                  : 'Improvement failed: $errorMessage'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      // Save session
      final session = PracticeSession(
        language: widget.language,
        learnerMode: widget.learnerMode,
        topicId: widget.topicId,
        audioPath: file.path,
        transcript: transcript,
        improveJson: jsonEncode(improved),
      );

      // Save to local store (you'll need to access the provider)
      // For now, we'll pass it to the result screen

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            session: session,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == 'ko' ? '녹음하기' : 'Record'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.topicTitle != null) ...[
              Text(
                widget.topicTitle!,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  widget.topicPrompt ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
            ],
            if (_isProcessing)
              const CircularProgressIndicator()
            else
              Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                size: 64,
                color: _isRecording ? Colors.red : Colors.grey,
              ),
            const SizedBox(height: 16),
            Text(
              _isRecording
                  ? (widget.language == 'ko' ? '녹음 중...' : 'Recording...')
                  : (widget.language == 'ko' ? '준비됨' : 'Ready'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : (_isRecording ? _stopAndProcess : _start),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: _isRecording ? Colors.red : Colors.blue,
              ),
              child: Text(
                _isRecording
                    ? (widget.language == 'ko' ? '중지' : 'Stop')
                    : (widget.language == 'ko' ? '녹음 시작' : 'Start Recording'),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
