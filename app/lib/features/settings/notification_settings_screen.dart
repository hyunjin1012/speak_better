import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  final String language; // 'ko' or 'en'

  const NotificationSettingsScreen({
    super.key,
    required this.language,
  });

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  bool _loading = false;

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
    setState(() {
      _notificationsEnabled = hasPermission;
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
        await _notificationService.scheduleDailyNotifications(
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
          language: widget.language,
        );
        setState(() {
          _notificationsEnabled = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.language == 'ko'
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
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(widget.language == 'ko'
                    ? '알림 권한 필요'
                    : 'Notification Permission Required'),
                content: Text(widget.language == 'ko'
                    ? '알림을 받으려면 설정에서 알림 권한을 허용해주세요.'
                    : 'Please enable notification permission in Settings to receive reminders.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(widget.language == 'ko' ? '취소' : 'Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      openAppSettings();
                    },
                    child: Text(widget.language == 'ko' ? '설정 열기' : 'Open Settings'),
                  ),
                ],
              ),
            );
          }
        } else {
          // Permission denied (but not permanently)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.language == 'ko'
                    ? '알림 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.'
                    : 'Notification permission denied. Please enable it in Settings.'),
                action: SnackBarAction(
                  label: widget.language == 'ko' ? '설정' : 'Settings',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.language == 'ko'
                ? '알림이 비활성화되었습니다'
                : 'Notifications disabled'),
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
        await _notificationService.scheduleDailyNotifications(
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
          language: widget.language,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.language == 'ko'
                  ? '알림 시간이 업데이트되었습니다'
                  : 'Notification time updated'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKorean = widget.language == 'ko';

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
                  child: SwitchListTile(
                    title: Text(isKorean ? '일일 연습 알림' : 'Daily Practice Reminders'),
                    subtitle: Text(isKorean
                        ? '매일 연습하도록 알림을 받으세요'
                        : 'Get reminded to practice every day'),
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    secondary: const Icon(Icons.notifications),
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
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              isKorean ? '알림 정보' : 'About Notifications',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
