import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// ============================================================
/// Day 56: 设备详情与网络状态
///
/// 技术要点：
///   1. device_info_plus — 获取硬件详细规格（型号、厂商、系统版本、唯一标识）
///   2. connectivity_plus — 实时监听网络连接状态变化
///   3. 平台适配 — Android/iOS/Web 差异化字段提取
///   4. 实战场景 — 登录设备指纹、断网提示全局组件
/// ============================================================

class Day56DeviceConnectivityDemo extends StatefulWidget {
  const Day56DeviceConnectivityDemo({super.key});

  @override
  State<Day56DeviceConnectivityDemo> createState() => _Day56DeviceConnectivityDemoState();
}

class _Day56DeviceConnectivityDemoState extends State<Day56DeviceConnectivityDemo> {
  // 设备信息存储
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  
  // 网络状态存储
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initData();
    // 监听网络变化
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initData() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData = {
          'OS': 'Android',
          'Version': androidInfo.version.release,
          'Model': androidInfo.model,
          'Manufacturer': androidInfo.manufacturer,
          'Hardware': androidInfo.hardware,
          'Fingerprint': androidInfo.fingerprint,
          'AndroidID': androidInfo.id, // 常用于设备指纹
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData = {
          'OS': 'iOS',
          'Version': iosInfo.systemVersion,
          'Model': iosInfo.model,
          'Name': iosInfo.name,
          'SystemName': iosInfo.systemName,
          'Identifier': iosInfo.identifierForVendor, // IDFV
        };
      }
    } catch (e) {
      deviceData = {'Error': 'Failed to get info: $e'};
    }

    // 获取初始网络状态
    List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      result = [ConnectivityResult.none];
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
      _connectionStatus = result;
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _connectionStatus = result;
    });
    
    // 如果断网了弹个轻提醒
    if (result.contains(ConnectivityResult.none)) {
       _showMsg('⚠️ 网络已断开，请检查设置');
    } else {
       _showMsg('✅ 网络已回复: ${result.first.name}');
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 56: 设备与网络监测'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 实时网络状态面板
            _SectionCard(
              title: '1. 实时网络监测 (connectivity)',
              icon: Icons.wifi,
              color: _connectionStatus.contains(ConnectivityResult.none) ? Colors.red : const Color(0xFF4CAF50),
              child: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: (_connectionStatus.contains(ConnectivityResult.none) ? Colors.red : const Color(0xFF4CAF50)).withOpacity(0.2),
                       shape: BoxShape.circle,
                     ),
                     child: Icon(
                       _connectionStatus.contains(ConnectivityResult.none) ? Icons.wifi_off : Icons.wifi,
                       color: _connectionStatus.contains(ConnectivityResult.none) ? Colors.red : const Color(0xFF4CAF50),
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          const Text('当前连接类型:', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            _connectionStatus.map((e) => e.name.toUpperCase()).join(' & '), 
                            style: TextStyle(
                              color: _connectionStatus.contains(ConnectivityResult.none) ? Colors.red : const Color(0xFF4CAF50), 
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                       ],
                     ),
                   )
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // 设备详情面板
            _SectionCard(
              title: '2. 硬件设备指纹 (device_info)',
              icon: Icons.developer_board,
              color: const Color(0xFF7C4DFF),
              child: Column(
                children: _deviceData.entries.map((e) => _InfoRow(label: e.key, value: e.value.toString())).toList(),
              ),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: '3. 核心实战场景',
              icon: Icons.business_center,
              color: const Color(0xFFFF9800),
              child: const Column(
                children: [
                   _PracticeItem(title: '🛡️ 安全：设备锁定', desc: '在用户更换新手机登录时，通过 IdentifierForVendor 或 AndroidID 识别出异常设备，强制要求二次短信验证。'),
                   SizedBox(height: 12),
                   _PracticeItem(title: '📡 体验：离线兜底', desc: '利用 connectivity 监听。当检测到 none 时，自动在列表页顶部显示“当前处于离线模式，部分功能不可用”，而不是让用户看着转圈圈。'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _PracticeItem extends StatelessWidget {
  final String title;
  final String desc;
  const _PracticeItem({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 11, height: 1.4)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}
