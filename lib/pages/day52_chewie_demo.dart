import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

/// ============================================================
/// Day 52: 增强视频播放器——chewie
///
/// 技术要点：
///   1. chewie 包 — 增强版视频播放器（基于 video_player）
///   2. Material/Cupertino 风格 — 自动适配各平台高颜值控制栏
///   3. 全屏支持 — 自动横屏全屏播放
///   4. 播放配置项 — 各种颜色控制、是否自动播放、倍速调节
///   5. 实战场景 — 在线课程详情、视频教程大屏播放
/// ============================================================

class Day52ChewieDemo extends StatefulWidget {
  const Day52ChewieDemo({super.key});

  @override
  State<Day52ChewieDemo> createState() => _Day52ChewieDemoState();
}

class _Day52ChewieDemoState extends State<Day52ChewieDemo> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 依然需要先初始化 video_player 这个引擎内核
    final uri = Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');
    _videoPlayerController = VideoPlayerController.networkUrl(uri);
    
    await _videoPlayerController.initialize();

    // 内核就绪后，初始化强大的 Chewie 外衣
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: 16 / 9,
      // 主题定制，配合当前深色模式
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFE91E63),
        handleColor: const Color(0xFFE91E63),
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white60,
      ),
      // 占位图
      placeholder: Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63))),
      ),
      autoInitialize: true,
      // 是否显示错误
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(errorMessage, style: const TextStyle(color: Colors.white)),
        );
      },
    );

    // 触发刷新
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 52: 增强播放器 (chewie)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Chewie 黑盒视图区
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFE91E63).withOpacity(0.2), blurRadius: 15, spreadRadius: 2)
                ]
              ),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _chewieController != null && _videoPlayerController.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63))),
              ),
            ),
            const SizedBox(height: 24),

            _SectionCard(
              title: '1. Chewie 的革命性提升',
              icon: Icons.rocket_launch,
              color: const Color(0xFFE91E63),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _FeatureRow(icon: Icons.fullscreen, text: '自带一键进入横屏全屏'),
                   _FeatureRow(icon: Icons.speed, text: '右下角内置完备的倍速播放面板 (0.5x - 2.0x)'),
                   _FeatureRow(icon: Icons.auto_awesome_motion, text: '支持 Material / Cupertino 风格切换'),
                   _FeatureRow(icon: Icons.subtitles, text: '扩展支持 SRT/VTT 字幕嵌入'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            _SectionCard(
              title: '2. 什么时候用 Chewie？',
              icon: Icons.movie_filter,
              color: const Color(0xFF00BCD4),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('在教育类、影视类等需要 "核心视频观看体验" 且不需要超级花哨的抖音交互的场景，Chewie 是首选。', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13, height: 1.5)),
                  SizedBox(height: 8),
                  Text('它内部完全桥接了刚才写的 video_player 引擎，省去了你手搓长达千行的进度条、音量控制和横竖屏旋转监听代码！', style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Shared Widgets ====================

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
           Icon(icon, color: const Color(0xFFE91E63), size: 20),
           const SizedBox(width: 12),
           Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13))),
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
