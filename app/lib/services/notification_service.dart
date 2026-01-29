import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../data/local_store.dart';
import '../models/session.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz
        .getLocation('America/New_York')); // Default, can be made configurable

    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings - request permissions during initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final initialized = await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (initialized != null && initialized) {
      _initialized = true;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to recording screen
    // For now, just acknowledge
  }

  Future<bool> requestPermissions() async {
    await initialize();

    // Check permission status using notification plugin first (more reliable on iOS)
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      // On iOS, check actual permission status
      final iosSettings = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (iosSettings == true) {
        return true;
      }
    }

    // Fallback to permission_handler for Android or if iOS check fails
    final status = await Permission.notification.status;
    if (status.isGranted) {
      return true;
    }

    // Request permission
    final newStatus = await Permission.notification.request();
    return newStatus.isGranted;
  }

  Future<bool> checkPermissions() async {
    await initialize();

    // Check using notification plugin first (more reliable on iOS)
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      // On iOS, we need to check the actual authorization status
      // Since we can't directly check, we'll try to request (which returns current status if already granted)
      try {
        final iosSettings = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (iosSettings == true) {
          return true;
        }
      } catch (e) {
        // If request fails, check permission_handler
      }
    }

    // Fallback to permission_handler
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<void> scheduleDailyNotifications({
    required int hour,
    required int minute,
    required String language, // 'ko' or 'en'
  }) async {
    await initialize();

    // Cancel existing notifications
    await cancelAllNotifications();

    // Request permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      print('Notification permission not granted');
      return;
    }

    // Get stats once for all notifications (simplified calculation)
    final sessions = LocalStore.getAllSessions();
    final stats = _calculateStatsSimple(sessions);

    // Schedule notification for each day of the week
    for (int day = 1; day <= 7; day++) {
      await _scheduleNotificationForDay(
        day: day,
        hour: hour,
        minute: minute,
        language: language,
        stats: stats,
      );
    }
  }

  Future<void> _scheduleNotificationForDay({
    required int day,
    required int hour,
    required int minute,
    required String language,
    required Map<String, dynamic> stats,
  }) async {
    final message = _getMotivationalMessage(stats, language);
    final title = language == 'ko'
        ? 'Speak Better 연습 시간!'
        : 'Time to Practice Speak Better!';

    // Calculate next occurrence of this weekday
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Find next occurrence of the target weekday
    int daysUntilTarget = (day - scheduledDate.weekday) % 7;
    if (daysUntilTarget == 0 && scheduledDate.isBefore(now)) {
      daysUntilTarget = 7; // Next week
    }
    scheduledDate = scheduledDate.add(Duration(days: daysUntilTarget));

    // Schedule repeating notification (weekly)
    await _notifications.zonedSchedule(
      day, // Unique ID for each day
      title,
      message,
      _nextInstanceOfTime(hour, minute, day),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_practice',
          'Daily Practice Reminders',
          channelDescription:
              language == 'ko' ? '매일 연습 알림' : 'Daily practice reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, int dayOfWeek) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    int daysUntilTarget = (dayOfWeek - scheduledDate.weekday) % 7;
    if (daysUntilTarget == 0 && scheduledDate.isBefore(now)) {
      daysUntilTarget = 7;
    }
    scheduledDate = scheduledDate.add(Duration(days: daysUntilTarget));

    return scheduledDate;
  }

  String _getMotivationalMessage(Map<String, dynamic> stats, String language) {
    final currentStreak = stats['currentStreak'] as int;
    final totalSessions = stats['totalSessions'] as int;
    final lastPracticeDate = stats['lastPracticeDate'] as DateTime?;

    if (language == 'ko') {
      if (currentStreak > 0) {
        if (currentStreak >= 7) {
          return '🔥 $currentStreak일 연속 연습 중! 계속 화이팅하세요!';
        } else if (currentStreak >= 3) {
          return '🔥 $currentStreak일 연속 연습 중! 오늘도 연습해볼까요?';
        } else {
          return '🔥 $currentStreak일 연속 연습 중! 오늘도 연습해보세요!';
        }
      } else if (totalSessions > 0) {
        if (lastPracticeDate != null) {
          final daysSince = DateTime.now().difference(lastPracticeDate).inDays;
          if (daysSince == 1) {
            return '어제 연습하셨네요! 오늘도 연습해볼까요?';
          } else if (daysSince <= 3) {
            return '$daysSince일 전에 연습하셨네요. 오늘도 연습해보세요!';
          }
        }
        return '총 $totalSessions번 연습하셨네요! 오늘도 연습해볼까요?';
      } else {
        return '첫 연습을 시작해볼까요? 지금 바로 시작하세요!';
      }
    } else {
      // English
      if (currentStreak > 0) {
        if (currentStreak >= 7) {
          return '🔥 $currentStreak day streak! Keep it up!';
        } else if (currentStreak >= 3) {
          return '🔥 $currentStreak day streak! Ready to practice today?';
        } else {
          return '🔥 $currentStreak day streak! Let\'s practice today!';
        }
      } else if (totalSessions > 0) {
        if (lastPracticeDate != null) {
          final daysSince = DateTime.now().difference(lastPracticeDate).inDays;
          if (daysSince == 1) {
            return 'You practiced yesterday! Ready to practice today?';
          } else if (daysSince <= 3) {
            return 'You practiced $daysSince days ago. Let\'s practice today!';
          }
        }
        return 'You\'ve practiced $totalSessions times! Ready to practice today?';
      } else {
        return 'Ready to start your first practice? Let\'s begin now!';
      }
    }
  }

  Map<String, dynamic> _calculateStatsSimple(List<PracticeSession> sessions) {
    if (sessions.isEmpty) {
      return {
        'currentStreak': 0,
        'totalSessions': 0,
        'lastPracticeDate': null,
      };
    }

    // Calculate streak
    sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    int currentStreak = 0;

    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayKey = DateFormat('yyyy-MM-dd').format(yesterday);

    final sessionsByDate = <String, List<PracticeSession>>{};
    for (final session in sessions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(session.createdAt);
      sessionsByDate.putIfAbsent(dateKey, () => []).add(session);
    }

    final practiceDates = sessionsByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (practiceDates.contains(todayKey)) {
      currentStreak = 1;
      DateTime checkDate = yesterday;
      String checkKey = yesterdayKey;
      while (practiceDates.contains(checkKey)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
        checkKey = DateFormat('yyyy-MM-dd').format(checkDate);
      }
    } else if (practiceDates.contains(yesterdayKey)) {
      currentStreak = 1;
      DateTime checkDate = yesterday.subtract(const Duration(days: 1));
      String checkKey = DateFormat('yyyy-MM-dd').format(checkDate);
      while (practiceDates.contains(checkKey)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
        checkKey = DateFormat('yyyy-MM-dd').format(checkDate);
      }
    }

    return {
      'currentStreak': currentStreak,
      'totalSessions': sessions.length,
      'lastPracticeDate': sessions.isNotEmpty ? sessions.first.createdAt : null,
    };
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> updateNotificationMessage(String language) async {
    // Update scheduled notifications with new messages
    // This is called when user practices to update tomorrow's message
    // Cancel and reschedule to update messages
    // For simplicity, we'll just reschedule all
    // In a production app, you'd want to get the saved time preference
    // Note: language parameter is the practiced language (from session.language),
    // not the UI language, so notifications will be in the language being practiced
    await scheduleDailyNotifications(
      hour: 18, // Default 6 PM - TODO: Use saved user preference
      minute: 0,
      language: language, // This is now the practiced language, not UI language
    );
  }
}
