import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// ============================================================
/// Day 51: 视频播放基础——video_player
///
/// 技术要点：
///   1. video_player 官方包 — Flutter 官方底层的视频播放器引擎
///   2. 基础播放控制 — 播放/暂停/进度条定制
///   3. VideoPlayerController — 生命周期：初始化、监听、释放
///   4. 资源配置支持 — network(网络) / asset(本地) / file(沙盒)
///   5. 实战场景 — 原生UI无依赖的视频详情页、动态短视频缩略播放
/// ============================================================

class Day51VideoPlayerDemo extends StatefulWidget {
  const Day51VideoPlayerDemo({super.key});

  @override
  State<Day51VideoPlayerDemo> createState() => _Day51VideoPlayerDemoState();
}

class _Day51VideoPlayerDemoState extends State<Day51VideoPlayerDemo> {
  late VideoPlayerController _controller;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    // 这里使用开源免费的一个测试 mp4 链接
    final uri = Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');
    _controller = VideoPlayerController.networkUrl(uri)
      ..initialize().then((_) {
        // 初始化成功后确保第一帧渲染
        setState(() {
          _isInit = true;
        });
      });
      
    // 监听播放状态改变(比如进度条更新)
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 51: 官方 video_player'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 播放器主视口
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF7C4DFF).withOpacity(0.2), blurRadius: 15, spreadRadius: 2)
                ]
              ),
              clipBehavior: Clip.antiAlias,
              child: _isInit
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          VideoPlayer(_controller),
                          _buildCustomControls(), // 自定义控制器叠加在上面
                        ],
                      ),
                    )
                  : const AspectRatio(
                      aspectRatio: 16 / 9, 
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                    ),
            ),
            const SizedBox(height: 24),

            _SectionCard(
              title: '1. 控制器底层状态机',
              icon: Icons.memory,
              color: const Color(0xFF4CAF50),
              child: Column(
                children: [
                  _StatusRow(label: '是否初始化完毕', value: _controller.value.isInitialized ? '是' : '否'),
                  _StatusRow(label: '是否正在播放', value: _controller.value.isPlaying ? '播放中' : '已暂停'),
                  _StatusRow(label: '是否处于缓冲', value: _controller.value.isBuffering ? '缓冲中...' : '流畅'),
                  _StatusRow(label: '当前播放进度', value: _formatDuration(_controller.value.position)),
                  _StatusRow(label: '视频总时长', value: _formatDuration(_controller.value.duration)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            _SectionCard(
              title: '2. 技术解析与局限性',
              icon: Icons.build_circle,
              color: const Color(0xFFFF9800),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• video_player 仅仅提供了解码引擎和渲染图层平台通道。', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13, height: 1.5)),
                  Text('• 它的巨大优势是干净、没有任何包袱，适合用在列表项的超小无声自动播放。', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13, height: 1.5)),
                  Text('• 缺点非常明显：进度条、全屏切换、音量、亮度、拖拽这些 UI 需要自己从 0 纯手写，非常折磨。这也就引出了 Day 52 的 Chewie！', style: TextStyle(color: Color(0xFFFF9800), fontSize: 13, height: 1.5, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 纯手写的轻量级自定义控制栏
  Widget _buildCustomControls() {
    return AnimatedOpacity(
      opacity: _controller.value.isPlaying ? 0.0 : 1.0, // 播放时隐去控制器
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          )
        ),
        child: Row(
          children: [
            InkWell(
              onTap: _togglePlay,
              child: Icon(
                 _controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                 color: Colors.white,
                 size: 36,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              // Flutter 官方自带的轻量级进度条组件 VideoProgressIndicator
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF7C4DFF),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.black45,
                ),
              ),
            ),
             const SizedBox(width: 12),
             Text(
               '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
               style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
             )
          ],
        ),
      ),
    );
  }
}

// ==================== Shared Widgets ====================

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatusRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
