import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Day 33 Demo：推送通知演示
///
/// 演示要点：
/// 1. 本地通知 (flutter_local_notifications) 的完整用法
/// 2. 远程推送的工作原理讲解 (FCM / JPush)
/// 3. 通知点击跳转逻辑
///
/// 注意：远程推送需要 Firebase/极光 后台配置，
/// 本 Demo 以本地通知模拟远程推送的完整流程。
class PushDemoPage extends StatefulWidget {
  const PushDemoPage({super.key});

  @override
  State<PushDemoPage> createState() => _PushDemoPageState();
}

class _PushDemoPageState extends State<PushDemoPage> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> _logs = [];
  int _notificationId = 0;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  /// 初始化本地通知
  Future<void> _initNotifications() async {
    // Android 初始化设置
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 初始化设置
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 用户点击了通知
        _appendLog('👆 用户点击了通知 [ID: ${response.id}]');
        _appendLog('   payload: ${response.payload ?? "无"}');
        // 这里可以根据 payload 跳转到指定页面
        // context.push('/detail/${response.payload}');
      },
    );

    _appendLog('✅ 通知插件初始化完成');
  }

  /// 发送简单文本通知
  Future<void> _sendSimpleNotification() async {
    _notificationId++;

    const androidDetails = AndroidNotificationDetails(
      'demo_channel',
      '演示通知',
      channelDescription: 'Day 33 推送通知演示频道',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: _notificationId,
      title: '📬 你有一条新消息',
      body: '这是第 $_notificationId 条推送通知 — Day 33 Demo',
      notificationDetails: details,
      payload: 'notification_$_notificationId',
    );

    _appendLog('📤 发送通知 #$_notificationId (简单文本)');
  }

  /// 发送带进度条的通知 (模拟下载)
  Future<void> _sendProgressNotification() async {
    _notificationId++;
    final id = _notificationId;
    _appendLog('📤 发送进度通知 #$id (模拟下载)');

    for (int i = 0; i <= 100; i += 20) {
      await Future.delayed(const Duration(milliseconds: 500));

      final androidDetails = AndroidNotificationDetails(
        'progress_channel',
        '下载进度',
        channelDescription: '下载进度通知频道',
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        maxProgress: 100,
        progress: i,
        ongoing: i < 100,
      );

      await _notificationsPlugin.show(
        id: id,
        title: '正在下载...',
        body: '$i%',
        notificationDetails: NotificationDetails(android: androidDetails),
      );
    }

    _appendLog('✅ 下载完毕! 通知 #$id');
  }

  /// 发送定时通知 (5 秒后)
  Future<void> _sendScheduledNotification() async {
    _notificationId++;
    final myId = _notificationId;
    _appendLog('⏰ 已预约 5 秒后发送通知 #$myId');

    Future.delayed(const Duration(seconds: 5), () async {
      if (!mounted) return;

      const androidDetails = AndroidNotificationDetails(
        'scheduled_channel',
        '定时通知',
        channelDescription: '定时推送频道',
        importance: Importance.high,
        priority: Priority.high,
      );

      const details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: myId,
        title: '⏰ 定时通知到了！',
        body: '这条通知在 5 秒前被预约发送',
        notificationDetails: details,
      );

      if (mounted) {
        _appendLog('📤 定时通知 #$myId 已发送');
      }
    });
  }

  /// 取消所有通知
  Future<void> _cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    _appendLog('🗑️ 已取消所有通知');
  }

  void _appendLog(String msg) {
    if (mounted) {
      setState(() {
        _logs.add('${DateTime.now().toString().substring(11, 19)} $msg');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Day 33: 推送通知')),
      body: Column(
        children: [
          // 推送原理说明卡片
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(12.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📲 推送通知架构',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '远程推送: 后端 → FCM/APNs → 系统通知栏\n'
                  '本地推送: App → flutter_local_notifications → 系统通知栏\n'
                  '\n'
                  '本 Demo 使用本地推送模拟完整推送流程：\n'
                  '发送 → 展示 → 点击 → 跳转',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13.sp,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          // 操作按钮区域
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                _buildActionRow(
                  '📬 简单文本通知',
                  '发送标题+内容的基础通知',
                  _sendSimpleNotification,
                  isDark,
                ),
                _buildActionRow(
                  '📊 进度条通知',
                  '模拟下载进度（仅 Android）',
                  _sendProgressNotification,
                  isDark,
                ),
                _buildActionRow(
                  '⏰ 延迟 5s 通知',
                  '预约 5 秒后弹出通知',
                  _sendScheduledNotification,
                  isDark,
                ),
                _buildActionRow(
                  '🗑️ 取消全部通知',
                  '清除所有未读通知',
                  _cancelAllNotifications,
                  isDark,
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // 远程推送说明
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.orange.shade900.withOpacity(0.3) : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 远程推送接入建议',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '• 海外项目 → firebase_messaging (FCM)\n'
                  '• 国内项目 → jpush_flutter (极光推送)\n'
                  '• 两者都需搭配 flutter_local_notifications 处理前台展示',
                  style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.grey.shade300 : Colors.black54),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // 日志面板
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 12.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.black87 : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📋 通知日志',
                        style: TextStyle(
                          color: Colors.green.shade300,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _logs.clear()),
                        child: Text(
                          '清空',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (_, index) => Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Text(
                          _logs[index],
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.grey.shade300,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    String title,
    String subtitle,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_outline,
                  color: Colors.blue, size: 24.w),
            ],
          ),
        ),
      ),
    );
  }
}
