import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// ============================================================
/// Day 55: 应用信息与链接跳转
///
/// 技术要点：
///   1. package_info_plus — 获取应用名称、版本号、包名等元数据
///   2. url_launcher — 外部链接跳转（Web、拨号、短信、邮件）
///   3. 实战场景 — About 页面版本展示、检查更新跳转、联系客服
/// ============================================================

class Day55AppInfoDemo extends StatefulWidget {
  const Day55AppInfoDemo({super.key});

  @override
  State<Day55AppInfoDemo> createState() => _Day55AppInfoDemoState();
}

class _Day55AppInfoDemoState extends State<Day55AppInfoDemo> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      _showError('无法打开链接: $urlString');
    }
  }

  Future<void> _makeCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '10086',
    );
    await launchUrl(launchUri);
  }

  Future<void> _sendSms() async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: '10086',
      queryParameters: <String, String>{
        'body': '你好，这是来自 Flutter 的短信测试',
      },
    );
    await launchUrl(launchUri);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 55: 应用信息与跳转'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SectionCard(
              title: '1. App 基础信息 (package_info)',
              icon: Icons.info_outline,
              color: const Color(0xFF2196F3),
              child: Column(
                children: [
                  _InfoRow(label: '应用名称', value: _packageInfo.appName),
                  _InfoRow(label: '包名', value: _packageInfo.packageName),
                  _InfoRow(label: '版本号', value: _packageInfo.version),
                  _InfoRow(label: '构建版本', value: _packageInfo.buildNumber),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            _SectionCard(
              title: '2. 外部调起 (url_launcher)',
              icon: Icons.launch,
              color: const Color(0xFF4CAF50),
              child: Column(
                children: [
                  _ActionButton(
                    icon: Icons.public,
                    label: '打开官方网站',
                    color: const Color(0xFF4CAF50),
                    onTap: () => _launchUrl('https://flutter.dev'),
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.phone,
                    label: '拨打客服电话 (10086)',
                    color: const Color(0xFF2196F3),
                    onTap: _makeCall,
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.sms,
                    label: '发送短信测试',
                    color: const Color(0xFFFF9800),
                    onTap: _sendSms,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            _SectionCard(
              title: '3. 实战建议',
              icon: Icons.tips_and_updates,
              color: const Color(0xFFE91E63),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PointItem(text: '• 在“关于”页面展示版本号时，直接从 package_info 读，不要硬编码。'),
                  _PointItem(text: '• 检查更新逻辑：对比 API 返回的版本号与本地版本号，老旧则弹窗并用 url_launcher 跳转 App Store。'),
                  _PointItem(text: '• 注意：iOS 拨号/短信等 Scheme 需要在 Info.plist 的 LSApplicationQueriesSchemes 中配置，Android 11+ 需要在 AndroidManifest.xml 的 queries 节点配置。'),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.15),
          foregroundColor: color,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _PointItem extends StatelessWidget {
  final String text;
  const _PointItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, height: 1.5)),
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
