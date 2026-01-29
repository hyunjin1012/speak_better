import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../api/speakbetter_api.dart';
import '../../models/session.dart';
import '../../utils/error_messages.dart';
import '../../utils/constants.dart';
import '../../widgets/offline_banner.dart' show connectivityProvider;
import 'dart:convert';
import '../results/result_screen.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({
    super.key,
    required this.language, // 'ko' or 'en'
    required this.learnerMode, // 'korean_learner' or 'english_learner'
    this.topicTitle,
    this.topicPrompt,
    this.topicId,
    this.initialImagePath,
  });

  final String language;
  final String learnerMode;
  final String? topicTitle;
  final String? topicPrompt;
  final String? topicId;
  final String? initialImagePath;

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  final _recorder = AudioRecorder();
  final _api = SpeakBetterApi();
  final _imagePicker = ImagePicker();

  bool _isRecording = false;
  bool _isProcessing = false;
  DateTime? _recordingStartTime;
  String? _currentAudioPath;
  File? _selectedImage;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Load initial image if provided
    if (widget.initialImagePath != null) {
      _selectedImage = File(widget.initialImagePath!);
    }
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
      // Use documents directory for permanent storage
      final appDocDir = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory(path.join(appDocDir.path, 'recordings'));
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final audioPath =
          path.join(recordingsDir.path, 'recording_$timestamp.m4a');

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: audioPath,
      );

      setState(() {
        _isRecording = true;
        _recordingStartTime = DateTime.now();
        _recordingDuration = Duration.zero;
        _currentAudioPath = audioPath;
      });

      // Start timer for recording duration
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && _recordingStartTime != null) {
          setState(() {
            _recordingDuration =
                DateTime.now().difference(_recordingStartTime!);
          });
        }
      });

      // Haptic feedback for recording start
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorMessages.getApiErrorMessage(
          e,
          isKorean: widget.language == 'ko',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _cancelRecording() async {
    try {
      _recordingTimer?.cancel();
      await _recorder.stop();
      _cleanupAudioFile(_currentAudioPath);
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _recordingDuration = Duration.zero;
        _currentAudioPath = null;
      });

      // Haptic feedback for cancellation
      HapticFeedback.lightImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.language == 'ko'
                ? '녹음이 취소되었습니다'
                : 'Recording cancelled'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Ignore errors when cancelling
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _currentAudioPath = null;
      });
    }
  }

  Future<void> _stopAndProcess() async {
    String? audioPath;
    String? transcript;
    PracticeSession? session;
    try {
      _recordingTimer?.cancel();
      audioPath = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _recordingDuration = Duration.zero;
      });

      // Haptic feedback for stop
      HapticFeedback.mediumImpact();

      if (audioPath == null) {
        _cleanupAudioFile(_currentAudioPath);
        return;
      }
      final file = File(audioPath);

      // Debug: log the file path and extension
      print('Recording file path: $audioPath');
      print('File extension: ${audioPath.split('.').last}');
      print('File exists: ${await file.exists()}');

      setState(() {
        _isProcessing = true;
      });

      // Determine the language being spoken (not UI language)
      // If learning English, they're speaking English. If learning Korean, they're speaking Korean.
      final spokenLanguage =
          widget.learnerMode == 'english_learner' ? 'en' : 'ko';

      // Transcribe
      Map<String, dynamic> t;
      try {
        t = await _api.transcribe(
          audioFile: file,
          language: spokenLanguage,
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
          final errorMessage = ErrorMessages.getApiErrorMessage(
            e,
            isKorean: widget.language == 'ko',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.language == 'ko'
                  ? '전사 실패: $errorMessage'
                  : 'Transcription failed: $errorMessage'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red,
            ),
          );
        }
        _cleanupAudioFile(audioPath);
        return;
      }

      transcript = (t['transcript'] ?? '') as String;

      // Ensure audio file exists and is accessible
      if (!await file.exists()) {
        throw Exception('Audio file was deleted before saving session');
      }

      // Save session immediately with transcript (even if improvement fails)
      // Use absolute path to ensure file can be found later
      final absoluteAudioPath = file.absolute.path;

      // Save image to permanent storage if present
      String? absoluteImagePath;
      if (_selectedImage != null) {
        try {
          final appDocDir = await getApplicationDocumentsDirectory();
          final imagesDir = Directory(path.join(appDocDir.path, 'images'));
          if (!await imagesDir.exists()) {
            await imagesDir.create(recursive: true);
          }
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageExtension =
              _selectedImage!.path.split('.').last.toLowerCase();
          final savedImagePath = path.join(
            imagesDir.path,
            'image_$timestamp.$imageExtension',
          );

          // Copy image to permanent location
          await _selectedImage!.copy(savedImagePath);
          absoluteImagePath = File(savedImagePath).absolute.path;
        } catch (e) {
          print('Failed to save image: $e');
          // Continue without image if save fails
        }
      }

      session = PracticeSession(
        language: spokenLanguage, // Use practiced language, not UI language
        learnerMode: widget.learnerMode,
        topicId: widget.topicId,
        audioPath: absoluteAudioPath,
        imagePath: absoluteImagePath,
        transcript: transcript,
        improveJson: '', // Will be updated after improvement
      );

      // Improve
      Map<String, dynamic> improved;
      try {
        improved = await _api.improve(
          language: spokenLanguage,
          learnerMode: widget.learnerMode,
          transcript: transcript,
          imageFile: _selectedImage,
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
          print('Request Data: ${e.requestOptions.data}');
          print('Request Headers: ${e.requestOptions.headers}');
        }
        print('========================');

        setState(() => _isProcessing = false);
        if (mounted) {
          final errorMessage = ErrorMessages.getApiErrorMessage(
            e,
            isKorean: widget.language == 'ko',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.language == 'ko'
                  ? '개선 실패: $errorMessage'
                  : 'Improvement failed: $errorMessage'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.orange,
            ),
          );
          // Still show results with transcript even if improvement failed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(session: session!),
            ),
          );
        } else {
          _cleanupAudioFile(audioPath);
        }
        return;
      }

      // Update session with improvement data
      // Preserve the absolute audio and image paths
      final updatedSession = PracticeSession(
        id: session.id,
        language: session.language,
        learnerMode: session.learnerMode,
        topicId: session.topicId,
        audioPath: session.audioPath, // Already absolute path
        imagePath: session.imagePath, // Already absolute path
        transcript: session.transcript,
        improveJson: jsonEncode(improved),
        createdAt: session.createdAt,
      );

      setState(() {
        _isProcessing = false;
      });

      if (!mounted) {
        // Don't cleanup audio file - it's saved in the session
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            session: updatedSession,
            imageFile: _selectedImage,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        // If we have a session with transcript, still navigate to results
        if (session != null && transcript != null && transcript.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(session: session!),
            ),
          );
        } else {
          _cleanupAudioFile(audioPath);
        }
      } else {
        _cleanupAudioFile(audioPath);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.getApiErrorMessage(
              e,
              isKorean: widget.language == 'ko',
            )),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cleanupAudioFile(String? path) {
    if (path != null) {
      try {
        final file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        // Ignore cleanup errors
        print('Failed to cleanup audio file: $e');
      }
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isKorean = widget.language == 'ko';
    final connectivityAsync = ref.watch(connectivityProvider);
    final isOffline =
        connectivityAsync.valueOrNull?.contains(ConnectivityResult.none) ??
            false;

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '녹음하기' : 'Record'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: _isRecording && _selectedImage != null
              ? Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: AppPadding.allLg,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Display image if selected (always visible, even during recording)
                            if (_selectedImage != null) ...[
                              Container(
                                height: AppSizes.imageMedium,
                                width: double.infinity,
                                margin: AppPadding.horizontalSm,
                                decoration: BoxDecoration(
                                  borderRadius: AppBorderRadius.circularLg,
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.2),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: AppBorderRadius.circularLg,
                                  child: Stack(
                                    children: [
                                      Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.md,
                                              vertical: AppSpacing.sm),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.9),
                                            borderRadius:
                                                AppBorderRadius.circularXl,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.mic,
                                                  color: Colors.white,
                                                  size: 18),
                                              AppSpacing.widthSm,
                                              Text(
                                                isKorean
                                                    ? '이 사진에 대해 말해주세요'
                                                    : 'Describe this image',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              AppSpacing.heightLg,
                            ],
                            if (widget.topicTitle != null) ...[
                              Card(
                                elevation: 4,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppBorderRadius.circularLg,
                                ),
                                child: Padding(
                                  padding: AppPadding.allMd,
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.topicTitle!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (widget.topicPrompt != null &&
                                          widget.topicPrompt!.isNotEmpty) ...[
                                        AppSpacing.heightMd,
                                        Text(
                                          widget.topicPrompt!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: colorScheme.onSurface
                                                    .withOpacity(0.7),
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              AppSpacing.heightLg,
                            ],
                            Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: AppPadding.allMd,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.mic,
                                    size: 80,
                                    color: Colors.red,
                                  ),
                                ),
                                AppSpacing.heightLg,
                                Text(
                                  isKorean ? '녹음 중...' : 'Recording...',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (_isRecording &&
                                    _recordingDuration.inSeconds > 0) ...[
                                  AppSpacing.heightMd,
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.lg,
                                        vertical: AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: AppBorderRadius.circularXl,
                                    ),
                                    child: Text(
                                      '${_recordingDuration.inMinutes.toString().padLeft(2, '0')}:${(_recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Fixed buttons at bottom when recording
                    Container(
                      padding: AppPadding.allLg,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    _isProcessing ? null : _cancelRecording,
                                icon: const Icon(Icons.close),
                                label: Text(
                                  isKorean ? '취소' : 'Cancel',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 18),
                                  side: BorderSide(color: colorScheme.outline),
                                ),
                              ),
                            ),
                            AppSpacing.widthMd,
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isProcessing ? null : _stopAndProcess,
                                icon: const Icon(Icons.stop, size: 24),
                                label: Text(
                                  isKorean ? '중지' : 'Stop',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 20),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  padding: AppPadding.allLg,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Display image if selected (always visible, even during recording)
                      if (_selectedImage != null) ...[
                        Container(
                          height: _isRecording ? 250 : 200,
                          width: double.infinity,
                          margin: AppPadding.horizontalSm,
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.35,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: AppBorderRadius.circularLg,
                            border: Border.all(
                              color: _isRecording
                                  ? Colors.red.withOpacity(0.5)
                                  : colorScheme.outline,
                              width: _isRecording ? 2 : 1,
                            ),
                            boxShadow: _isRecording
                                ? [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.2),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                          ),
                          child: ClipRRect(
                            borderRadius: AppBorderRadius.circularLg,
                            child: Stack(
                              children: [
                                Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                if (!_isRecording && !_isProcessing)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        setState(() {
                                          _selectedImage = null;
                                        });
                                      },
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.black54,
                                      ),
                                      tooltip:
                                          isKorean ? '이미지 제거' : 'Remove Image',
                                    ),
                                  ),
                                if (_isRecording)
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.sm),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.9),
                                        borderRadius:
                                            AppBorderRadius.circularXl,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.mic,
                                              color: Colors.white, size: 18),
                                          AppSpacing.widthSm,
                                          Text(
                                            isKorean
                                                ? '이 사진에 대해 말해주세요'
                                                : 'Describe this image',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (widget.topicTitle != null) ...[
                        Card(
                          elevation: 4,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppBorderRadius.circularLg,
                          ),
                          child: Padding(
                            padding: AppPadding.allMd,
                            child: Column(
                              children: [
                                Text(
                                  widget.topicTitle!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                if (widget.topicPrompt != null &&
                                    widget.topicPrompt!.isNotEmpty) ...[
                                  AppSpacing.heightMd,
                                  Text(
                                    widget.topicPrompt!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.7),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.heightXxl,
                      ],
                      // Image selection button (only when not recording and no image selected)
                      if (!_isRecording &&
                          !_isProcessing &&
                          _selectedImage == null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                _pickImage(ImageSource.gallery);
                              },
                              icon: const Icon(Icons.image),
                              label: Text(
                                isKorean ? '갤러리' : 'Gallery',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.md),
                              ),
                            ),
                            AppSpacing.widthMd,
                            OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                _pickImage(ImageSource.camera);
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: Text(
                                isKorean ? '카메라' : 'Camera',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.md),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (_isProcessing)
                        Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 24),
                            Text(
                              isKorean ? '처리 중...' : 'Processing...',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            AnimatedContainer(
                              duration: AppDurations.animationNormal,
                              padding: EdgeInsets.all(
                                  _isRecording ? AppSpacing.md : AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: _isRecording
                                    ? Colors.red.withOpacity(0.1)
                                    : colorScheme.primaryContainer
                                        .withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isRecording ? Icons.mic : Icons.mic_none,
                                size: _isRecording ? 80 : 64,
                                color: _isRecording
                                    ? Colors.red
                                    : colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _isRecording
                                  ? (isKorean ? '녹음 중...' : 'Recording...')
                                  : (isKorean ? '준비됨' : 'Ready'),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (_isRecording &&
                                _recordingDuration.inSeconds > 0) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: AppBorderRadius.circularXl,
                                ),
                                child: Text(
                                  '${_recordingDuration.inMinutes.toString().padLeft(2, '0')}:${(_recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      AppSpacing.heightXxl,
                      if (_isRecording)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    _isProcessing ? null : _cancelRecording,
                                icon: const Icon(Icons.close),
                                label: Text(
                                  isKorean ? '취소' : 'Cancel',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 18),
                                  side: BorderSide(color: colorScheme.outline),
                                ),
                              ),
                            ),
                            AppSpacing.widthMd,
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isProcessing ? null : _stopAndProcess,
                                icon: const Icon(Icons.stop, size: 24),
                                label: Text(
                                  isKorean ? '중지' : 'Stop',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 20),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: (_isProcessing || isOffline)
                              ? null
                              : () {
                                  HapticFeedback.mediumImpact();
                                  _start();
                                },
                          icon: Icon(
                            isOffline ? Icons.wifi_off : Icons.mic,
                            size: 24,
                          ),
                          label: Text(
                            isOffline
                                ? (isKorean ? '오프라인 모드' : 'Offline Mode')
                                : (isKorean ? '녹음 시작' : 'Start Recording'),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 20),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 4,
                          ),
                        ),
                      // Add bottom padding to ensure button is visible
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
