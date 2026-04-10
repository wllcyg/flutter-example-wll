import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// ============================================================
/// Day 54: 图片保存与分享
///
/// 技术要点：
///   1. image_gallery_saver — 纯 Uint8List 保存到系统原相册
///   2. 权限处理 — 相册读写权限动态申请
///   3. share_plus — 系统分享面板（多平台统一调用）
///   4. 资源落地 — 分享图片前必须先存入沙盒
///   5. 实战流程 — (联合Day 53) 截图 → 申请权限 → 存本地存相册 → 调起微信朋友圈
/// ============================================================

class Day54ShareSaveDemo extends StatefulWidget {
  const Day54ShareSaveDemo({super.key});

  @override
  State<Day54ShareSaveDemo> createState() => _Day54ShareSaveDemoState();
}

class _Day54ShareSaveDemoState extends State<Day54ShareSaveDemo> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isProcessing = false;

  Future<void> _handleSaveToGallery() async {
    setState(() => _isProcessing = true);
    try {
      // 1. 申请系统相册写入权限
      if (Platform.isAndroid || Platform.isIOS) {
        var status = await Permission.storage.request();
        // 在新版 Android 13+ 中可能是 photos 权限
        if (Platform.isAndroid) {
           await Permission.photos.request();
        }
      }

      // 2. 将 Widget 捕获为图片数据流
      final Uint8List? imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes == null) {
        _showMsg('截图失败无法保存');
        return;
      }

      // 3. 直接调用 ImageGallerySaver 保存到外层公共相册
      final result = await ImageGallerySaver.saveImage(
        imageBytes, 
        quality: 100, 
        name: "flutter_poster_${DateTime.now().millisecondsSinceEpoch}"
      );
      
      if (result['isSuccess'] == true) {
        _showMsg('✅ 已成功保存到系统相册！');
      } else {
        _showMsg('保存失败，请检查相册权限');
      }

    } catch (e) {
      _showMsg('错误: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleSystemShare() async {
    setState(() => _isProcessing = true);
    try {
      // 1. 截图获取流
      final Uint8List? imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes == null) return;

      // 2. SharePlus 不支持直接传流，必须先把它存到沙盒临时目录里 (复习 Day 50)
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share_poster.png');
      await file.writeAsBytes(imageBytes);

      // 3. 调起操作系统分享面板 (将以九宫格形式出现 微信/QQ/AirDrop/邮件等)
      // 注意：新版 share_plus 的 shareXFiles API 取代了 shareFiles
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: '这是我的炫酷 Flutter 名片！', 
        subject: '来自 Flutter 训练营的邀请'
      );
      
    } catch (e) {
      _showMsg('分享失败: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleShareTextOnly() async {
    // 分享存文本不需要截图，直接调起
    await Share.share('我推荐大家学习 Antigravity 写的 Flutter 简明全栈实战课！\nhttps://github.com/flutter');
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 54: 相册保存与系统分享'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 海报展示区，套在 Screenshot 里
            Screenshot(
              controller: _screenshotController,
              child: _buildSharePoster(),
            ),
            const SizedBox(height: 24),

            _SectionCard(
              title: '操作台 (自动截图联动)',
              icon: Icons.dashboard_customize,
              color: const Color(0xFF00E676),
              child: Column(
                children: [
                   _ActionButton(
                     icon: Icons.save_alt, 
                     label: _isProcessing ? '处理中...' : '截图并保存到手机相册', 
                     color: const Color(0xFF00E676), 
                     onTap: _isProcessing ? null : _handleSaveToGallery
                   ),
                   const SizedBox(height: 12),
                   _ActionButton(
                     icon: Icons.ios_share, 
                     label: _isProcessing ? '处理中...' : '截图并调起微信/AirDrop发送', 
                     color: const Color(0xFF2196F3), 
                     onTap: _isProcessing ? null : _handleSystemShare
                   ),
                   const SizedBox(height: 12),
                   _ActionButton(
                     icon: Icons.text_snippet, 
                     label: '发送纯文本链接', 
                     color: const Color(0xFFFF9800), 
                     onTap: _isProcessing ? null : _handleShareTextOnly
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildSharePoster() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFFE91E63)]),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
           Icon(Icons.diamond_outlined, size: 60, color: Colors.white),
           SizedBox(height: 16),
           Text('闭环操作', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
           SizedBox(height: 12),
           Text('Widget 👉 Screenshot引擎 👉\nUint8List流 👉 path临时沙盒写入 👉\n系统相册写入 or 桥接三方社交分享', 
             style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6), textAlign: TextAlign.center,
           ),
           SizedBox(height: 24),
           Icon(Icons.qr_code, size: 80, color: Colors.white),
           SizedBox(height: 8),
           Text('扫一扫查看源码', style: TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}

// ==================== Shared Widgets ====================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
        ),
        onPressed: onTap,
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
