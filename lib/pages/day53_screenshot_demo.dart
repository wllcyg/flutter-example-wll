import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';

/// ============================================================
/// Day 53: 截图生成——screenshot
///
/// 技术要点：
///   1. screenshot 包核心原理 — 将隐式或显式的 Widget 转化为 Uint8List图片流
///   2. ScreenshotController — 核心控制器，随时触发截图截取
///   3. 截图区域 — 通过 Screenshot 挂载件包裹要截图的组件区域
///   4. 样式隔离 — 被截图的 Widget 不必非要在屏幕上可见
///   5. 实战场景 — 生成分享海报 (带用户头像资料+二维码)
/// ============================================================

class Day53ScreenshotDemo extends StatefulWidget {
  const Day53ScreenshotDemo({super.key});

  @override
  State<Day53ScreenshotDemo> createState() => _Day53ScreenshotDemoState();
}

class _Day53ScreenshotDemoState extends State<Day53ScreenshotDemo> {
  // 核心入口：截图控制器
  final ScreenshotController _screenshotController = ScreenshotController();
  
  // 保存截取的二进制图片数据以供日后显示/存储
  Uint8List? _capturedImage;
  bool _isCapturing = false;

  void _capturePoster() async {
    setState(() => _isCapturing = true);
    try {
      // 捕获被包裹区域，可以通过 pixelRatio 提高清晰度 (2.0 或 3.0 更清晰)
      final Uint8List? image = await _screenshotController.capture(pixelRatio: 3.0);
      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
        _showMsg('截图生成成功！');
      }
    } catch (e) {
      _showMsg('截图失败: $e');
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 53: 截图框架 (screenshot)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SectionCard(
              title: '1. UI 渲染成图目标区域',
              icon: Icons.crop_free,
              color: const Color(0xFF2196F3),
              child: Column(
                children: [
                  const Text('下面的卡片被 Screenshot() 包裹，通过 controller.capture() 可无缝转为图片对象。', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
                  const SizedBox(height: 16),
                  
                  // ====== 核心挂载层 ======
                  Screenshot(
                    controller: _screenshotController,
                    child: _buildSharePoster(),
                  ),
                  
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isCapturing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.camera_alt),
                      label: Text(_isCapturing ? '生成中...' : '一键生成高清图片'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3).withOpacity(0.2),
                        foregroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isCapturing ? null : _capturePoster,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            if (_capturedImage != null)
              _SectionCard(
                title: '2. 内存中的截图流 (待保存)',
                icon: Icons.image,
                color: const Color(0xFFE91E63),
                child: Column(
                  children: [
                     const Text('这已经是 Image.memory(..) 渲染出来的实体图片了！你可以将它塞给 Day 54 的保存接口转存为本地文件。', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
                     const SizedBox(height: 16),
                     Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: const Color(0xFFE91E63), width: 2),
                         boxShadow: [BoxShadow(color: const Color(0xFFE91E63).withOpacity(0.3), blurRadius: 10)]
                       ),
                       child: Image.memory(
                         _capturedImage!,
                         // 缩小显示
                         height: 250,
                         fit: BoxFit.contain,
                       ),
                     )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  // 这是一个模拟被截图的业务层海报
  Widget _buildSharePoster() {
    return Container(
      width: double.infinity,
      color: Colors.white, // 注意：截图最好包裹带固定背景色的 Container，否则会变成透明图黑块
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF7C4DFF),
                  child: Icon(Icons.flutter_dash, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Flutter 大神', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('正在邀请你加入俱乐部', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                )
             ],
           ),
           const SizedBox(height: 20),
           Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: const Color(0xFFF5F5F5),
               borderRadius: BorderRadius.circular(12),
             ),
             child: const Text(
               '我已经在这个极客应用里完成了 53 天的实战集训，快来和我一起解锁全新的技术视野！',
               style: TextStyle(color: Colors.black87, height: 1.5),
             ),
           ),
           const SizedBox(height: 20),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               const Text('长按识别二维码加入', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
               // 模拟一个假二维码使用占位图
               Container(
                 width: 60,
                 height: 60,
                 color: Colors.black12,
                 child: const Icon(Icons.qr_code_2, size: 40, color: Colors.black87),
               )
             ],
           )
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
