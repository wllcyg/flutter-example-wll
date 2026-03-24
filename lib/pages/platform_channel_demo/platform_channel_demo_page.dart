import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformChannelDemoPage extends StatefulWidget {
  const PlatformChannelDemoPage({super.key});

  @override
  State<PlatformChannelDemoPage> createState() =>
      _PlatformChannelDemoPageState();
}

class _PlatformChannelDemoPageState extends State<PlatformChannelDemoPage> {
  // 定义通道：必须和我们在 Android 和 iOS 原生端定义的名字完全一致
  static const MethodChannel _shareChannel =
      MethodChannel('com.example.my_flutter_app/share');

  // 这是给输入框绑定的控制器，方便获取输入内容
  final TextEditingController _textController = TextEditingController(
    text: 'Hello from Flutter Day 24! 看我用原生分享通道功能！🚀',
  );

  bool _isSharing = false;

  Future<void> _shareText(String text) async {
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('不能分享空文本哦')),
      );
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      // 核心跨端调用：将 'shareText' 方法请求和参数派发给底层系统
      final bool? result = await _shareChannel.invokeMethod<bool>(
        'shareText',
        {'text': text},
      );

      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('调用系统分享成功')),
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("调用系统分享失败: '${e.message}'.")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('平台通道 (Platform Channel)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'MethodChannel 演示',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '我们在底层配置了iOS的 UIActivityViewController 和 Android的 Intent.ACTION_SEND，点击下方按钮体验系统原生的文本分发功能。',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: '想要分享的文本',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
                  _isSharing ? null : () => _shareText(_textController.text),
              icon: _isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share),
              label: Text(_isSharing ? '调用中...' : '使用系统原生分享'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
