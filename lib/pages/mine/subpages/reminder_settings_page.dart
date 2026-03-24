import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/res/colors.dart';
import 'package:my_flutter_app/services/notification_service.dart';

class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  bool _isReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // 1. Load from SharedPreferences (Fastest)
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isReminderEnabled = prefs.getBool('reminder_enabled') ?? false;
        final hour = prefs.getInt('reminder_hour') ?? 20;
        final minute = prefs.getInt('reminder_minute') ?? 0;
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
        _isLoading = false;
      });

      // 2. Load from Supabase (Sync) - update if different
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final metadata = user.userMetadata;
        if (metadata != null && metadata.containsKey('reminder_enabled')) {
          final remoteEnabled = metadata['reminder_enabled'] as bool;
          final remoteHour = metadata['reminder_hour'] as int;
          final remoteMinute = metadata['reminder_minute'] as int;

          if (remoteEnabled != _isReminderEnabled ||
              remoteHour != _reminderTime.hour ||
              remoteMinute != _reminderTime.minute) {
            setState(() {
              _isReminderEnabled = remoteEnabled;
              _reminderTime = TimeOfDay(hour: remoteHour, minute: remoteMinute);
            });
            // Update local storage to match remote
            await _saveToLocal(_isReminderEnabled, _reminderTime);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveToLocal(bool enabled, TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', enabled);
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
  }

  Future<void> _saveSettings(bool enabled, TimeOfDay time) async {
    setState(() {
      _isReminderEnabled = enabled;
      _reminderTime = time;
    });

    try {
      // 1. Save Local
      await _saveToLocal(enabled, time);

      // 2. Schedule/Cancel Notification (Isolate error)
      try {
        final service = NotificationService();
        if (enabled) {
          // Request permissions first
          final hasPermission = await service.requestPermissions();
          if (hasPermission) {
            await service.scheduleDailyNotification(
              id: 1,
              title: '写日记提醒',
              body: '今天发生了什么值得记录的事吗？来写篇日记吧！',
              hour: time.hour,
              minute: time.minute,
            );
            if (mounted) {
              SmartDialog.showToast('已设置每日 ${time.format(context)} 提醒');
            }
          } else {
            if (mounted) SmartDialog.showToast('请开启通知权限以接收提醒');
          }
        } else {
          await service.cancelid(1);
          if (mounted) SmartDialog.showToast('已关闭提醒');
        }
      } catch (e) {
        debugPrint('Notification Error: $e');
        // Don't fail the whole save process just because notification failed
        if (mounted) SmartDialog.showToast('提醒设置失败，但已保存偏好');
      }

      // 3. Save Remote (Supabase)
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'reminder_enabled': enabled,
              'reminder_hour': time.hour,
              'reminder_minute': time.minute,
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
      if (mounted) SmartDialog.showToast('设置保存失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("提醒设置"), centerTitle: true),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("每日提醒"),
            subtitle: const Text("开启后，每天将在指定时间提醒您写日记"),
            value: _isReminderEnabled,
            onChanged: (value) => _saveSettings(value, _reminderTime),
            activeTrackColor: AppColors.primary,
          ),
          if (_isReminderEnabled)
            ListTile(
              title: const Text("提醒时间"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _reminderTime.format(context),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                ],
              ),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                );
                if (picked != null && picked != _reminderTime) {
                  _saveSettings(_isReminderEnabled, picked);
                }
              },
            ),
        ],
      ),
    );
  }
}
