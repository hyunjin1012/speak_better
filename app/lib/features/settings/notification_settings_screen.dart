import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification_service.dart';
import '../../features/tutorial/tutorial_overlay.dart';
import '../../state/preferences_provider.dart';
import '../../utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  final String language; // 'ko' or 'en'

  const NotificationSettingsScreen({
    super.key,
    required this.language,
  });

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  bool _loading = false;
  String? _currentUILanguage;
  String? _currentLearnerMode;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);

    // Initialize notification service first
    await _notificationService.initialize();

    // Check if notifications are enabled using the service's method (more reliable)
    final hasPermission = await _notificationService.checkPermissions();

    // Load preferences
    final uiLanguage = ref.read(uiLanguageProvider);
    final learnerMode = ref.read(learnerModeProvider);

    setState(() {
      _notificationsEnabled = hasPermission;
      _currentUILanguage = uiLanguage ?? widget.language;
      _currentLearnerMode = learnerMode;
    });

    setState(() => _loading = false);
  }

  Future<void> _toggleNotifications(bool enabled) async {
    setState(() => _loading = true);

    if (enabled) {
      // Ensure notification service is initialized
      await _notificationService.initialize();

      // Check current permission status using the service's method
      var hasPermission = await _notificationService.checkPermissions();

      if (!hasPermission) {
        // Request permission
        hasPermission = await _notificationService.requestPermissions();
        // Wait a bit for the permission to be processed
        await Future.delayed(const Duration(milliseconds: 500));
        // Check status again
        hasPermission = await _notificationService.checkPermissions();
      }

      if (hasPermission) {
        // Get current language from provider
        final currentLang = ref.read(uiLanguageProvider) ?? widget.language;
        await _notificationService.scheduleDailyNotifications(
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
          language: currentLang,
        );
        setState(() {
          _notificationsEnabled = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(currentLang == 'ko'
                  ? '알림이 활성화되었습니다'
                  : 'Notifications enabled'),
            ),
          );
        }
      } else {
        // Permission denied - check if permanently denied
        final permissionStatus = await Permission.notification.status;
        if (permissionStatus.isPermanentlyDenied) {
          // Show dialog to open settings
          if (mounted) {
            final currentLang = ref.read(uiLanguageProvider) ?? widget.language;
            final isKorean = currentLang == 'ko';
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                    isKorean ? '알림 권한 필요' : 'Notification Permission Required'),
                content: Text(isKorean
                    ? '알림을 받으려면 설정에서 알림 권한을 허용해주세요.'
                    : 'Please enable notification permission in Settings to receive reminders.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(isKorean ? '취소' : 'Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      openAppSettings();
                    },
                    child: Text(isKorean ? '설정 열기' : 'Open Settings'),
                  ),
                ],
              ),
            );
          }
        } else {
          // Permission denied (but not permanently)
          if (mounted) {
            final currentLang = ref.read(uiLanguageProvider) ?? widget.language;
            final isKorean = currentLang == 'ko';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isKorean
                    ? '알림 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.'
                    : 'Notification permission denied. Please enable it in Settings.'),
                action: SnackBarAction(
                  label: isKorean ? '설정' : 'Settings',
                  onPressed: () => openAppSettings(),
                ),
              ),
            );
          }
        }
      }
    } else {
      await _notificationService.cancelAllNotifications();
      setState(() {
        _notificationsEnabled = false;
      });

      if (mounted) {
        final currentLang = ref.read(uiLanguageProvider) ?? widget.language;
        final isKorean = currentLang == 'ko';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(isKorean ? '알림이 비활성화되었습니다' : 'Notifications disabled'),
          ),
        );
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });

      // Update notifications if enabled
      if (_notificationsEnabled) {
        // Get current language from provider
        final currentLang = ref.read(uiLanguageProvider) ?? widget.language;
        await _notificationService.scheduleDailyNotifications(
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
          language: currentLang,
        );

        if (mounted) {
          final currentLang = ref.read(uiLanguageProvider) ?? widget.language;
          final isKorean = currentLang == 'ko';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  isKorean ? '알림 시간이 업데이트되었습니다' : 'Notification time updated'),
            ),
          );
        }
      }
    }
  }

  void _showTutorial(BuildContext context) {
    // Get current language from provider
    final currentLang = ref.read(uiLanguageProvider) ?? widget.language;
    final isKorean = currentLang == 'ko';

    showTutorialOverlay(
      context,
      steps: [
        TutorialStep(
          title: isKorean ? '환영합니다!' : 'Welcome!',
          description: isKorean
              ? 'Speak Better에 오신 것을 환영합니다. 이 튜토리얼을 통해 앱의 주요 기능을 알아보세요.'
              : 'Welcome to Speak Better! This tutorial will help you learn about the app\'s main features.',
        ),
        TutorialStep(
          title: isKorean ? '주제 선택' : 'Select a Topic',
          description: isKorean
              ? '주제 탭에서 연습할 주제를 선택하거나 새 주제를 추가할 수 있습니다.'
              : 'In the Topics tab, you can select a topic to practice or add a new custom topic.',
        ),
        TutorialStep(
          title: isKorean ? '녹음하기' : 'Record Your Speech',
          description: isKorean
              ? '주제를 선택한 후 녹음 버튼을 눌러 연습을 시작하세요. AI가 당신의 발음을 분석하고 피드백을 제공합니다.'
              : 'After selecting a topic, tap the record button to start practicing. AI will analyze your speech and provide feedback.',
        ),
        TutorialStep(
          title: isKorean ? '이미지 연습' : 'Image Practice',
          description: isKorean
              ? '이미지 아이콘을 눌러 사진을 선택하고, 그 사진에 대해 설명하면 AI가 이미지를 참고하여 더 정확한 피드백을 제공합니다.'
              : 'Tap the image icon to select a photo. Describe the image and AI will provide feedback considering the image context.',
        ),
        TutorialStep(
          title: isKorean ? '기록 보기' : 'View History',
          description: isKorean
              ? '기록 탭에서 모든 연습 세션을 확인하고, 검색 기능을 사용하여 특정 세션을 찾을 수 있습니다.'
              : 'In the History tab, you can view all your practice sessions and use the search feature to find specific sessions.',
        ),
        TutorialStep(
          title: isKorean ? '알림 설정' : 'Notification Settings',
          description: isKorean
              ? '설정에서 일일 연습 알림을 활성화하여 매일 연습하는 습관을 만들 수 있습니다.'
              : 'Enable daily practice reminders in Settings to build a daily practice habit.',
        ),
        TutorialStep(
          title: isKorean ? '완료!' : 'All Set!',
          description: isKorean
              ? '이제 앱을 사용할 준비가 되었습니다. 즐거운 연습 되세요!'
              : 'You\'re all set! Start practicing and improve your language skills.',
        ),
      ],
      language: currentLang,
      onComplete: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isKorean ? '튜토리얼을 완료했습니다!' : 'Tutorial completed!'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch UI language provider to react to changes immediately
    final savedLanguage = ref.watch(uiLanguageProvider);
    final currentLanguage = savedLanguage ?? widget.language;
    final isKorean = currentLanguage == 'ko';

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '알림 설정' : 'Notification Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Enable/Disable switch
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.circularLg,
                    side: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.circularLg,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text(
                          isKorean ? '일일 연습 알림' : 'Daily Practice Reminders'),
                      subtitle: Text(isKorean
                          ? '매일 연습하도록 알림을 받으세요'
                          : 'Get reminded to practice every day'),
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time picker
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(isKorean ? '알림 시간' : 'Notification Time'),
                    subtitle: Text(
                      _selectedTime.format(context),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _notificationsEnabled ? _selectTime : null,
                    enabled: _notificationsEnabled,
                  ),
                ),
                const SizedBox(height: 24),

                // UI Language selector
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title:
                            Text(isKorean ? '인터페이스 언어' : 'Interface Language'),
                        subtitle: Text(
                            _currentUILanguage == 'ko' ? '한국어' : 'English'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(uiLanguageProvider.notifier)
                                      .setLanguage('ko');
                                  setState(() {
                                    _currentUILanguage = 'ko';
                                  });
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('언어가 변경되었습니다. 앱을 재시작해주세요.'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: _currentUILanguage == 'ko'
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                    width: _currentUILanguage == 'ko' ? 2 : 1,
                                  ),
                                  backgroundColor: _currentUILanguage == 'ko'
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : null,
                                ),
                                child: const Text('한국어'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(uiLanguageProvider.notifier)
                                      .setLanguage('en');
                                  setState(() {
                                    _currentUILanguage = 'en';
                                  });
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Language changed. Please restart the app.'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: _currentUILanguage == 'en'
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                    width: _currentUILanguage == 'en' ? 2 : 1,
                                  ),
                                  backgroundColor: _currentUILanguage == 'en'
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : null,
                                ),
                                child: const Text('English'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Learning Language selector
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.school),
                        title: Text(isKorean ? '학습 언어' : 'Learning Language'),
                        subtitle: Text(_currentLearnerMode == 'korean_learner'
                            ? (isKorean ? '한국어 학습자' : 'Korean Learner')
                            : (isKorean ? '영어 학습자' : 'English Learner')),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(learnerModeProvider.notifier)
                                      .setLearnerMode('korean_learner');
                                  setState(() {
                                    _currentLearnerMode = 'korean_learner';
                                  });
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isKorean
                                            ? '학습 언어가 변경되었습니다'
                                            : 'Learning language changed'),
                                      ),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: _currentLearnerMode ==
                                            'korean_learner'
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                    width:
                                        _currentLearnerMode == 'korean_learner'
                                            ? 2
                                            : 1,
                                  ),
                                  backgroundColor:
                                      _currentLearnerMode == 'korean_learner'
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                          : null,
                                ),
                                child: Text(
                                    isKorean ? '한국어 학습자' : 'Korean Learner'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(learnerModeProvider.notifier)
                                      .setLearnerMode('english_learner');
                                  setState(() {
                                    _currentLearnerMode = 'english_learner';
                                  });
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isKorean
                                            ? '학습 언어가 변경되었습니다'
                                            : 'Learning language changed'),
                                      ),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: _currentLearnerMode ==
                                            'english_learner'
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                    width:
                                        _currentLearnerMode == 'english_learner'
                                            ? 2
                                            : 1,
                                  ),
                                  backgroundColor:
                                      _currentLearnerMode == 'english_learner'
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                          : null,
                                ),
                                child: Text(
                                    isKorean ? '영어 학습자' : 'English Learner'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tutorial button
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.school),
                    title: Text(isKorean ? '앱 사용법 보기' : 'View Tutorial'),
                    subtitle: Text(isKorean
                        ? '앱의 주요 기능을 알아보세요'
                        : 'Learn about the app\'s main features'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showTutorial(context);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Info card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              isKorean ? '알림 정보' : 'About Notifications',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isKorean
                              ? '• 매일 선택한 시간에 연습 알림을 받습니다\n• 연속 연습 기록에 따라 동기부여 메시지가 표시됩니다\n• 알림을 탭하면 앱이 열립니다'
                              : '• Receive practice reminders at your selected time each day\n• Motivational messages based on your streak\n• Tap notification to open the app',
                          style: TextStyle(color: Colors.blue.shade900),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
