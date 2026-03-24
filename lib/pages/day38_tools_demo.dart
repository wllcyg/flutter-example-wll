import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class Day38ToolsDemo extends StatefulWidget {
  const Day38ToolsDemo({super.key});

  @override
  State<Day38ToolsDemo> createState() => _Day38ToolsDemoState();
}

class _Day38ToolsDemoState extends State<Day38ToolsDemo> {
  final TextEditingController _qrTextController = TextEditingController(text: 'https://flutter.dev');
  String _scanResult = '暂无扫描结果';
  bool _isScannerActive = false;
  
  String _downloadTaskId = '';

  @override
  void dispose() {
    _qrTextController.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _isScannerActive = true;
    });
  }

  void _shareContent() {
    Share.share('Hello from Flutter Day 38 Demo! Check out this awesome toolkit.', subject: 'Flutter Share Plus');
  }

  Future<void> _startDummyDownload() async {
    try {
      // 演示下载一个图片文件，注意真正的 flutter_downloader 需要在 main.dart 中初始化
      // await FlutterDownloader.initialize(); 
      // 这里为了演示，我们只调用 API，如果没有初始化会抛出异常
      final dir = await getApplicationDocumentsDirectory();
      final taskId = await FlutterDownloader.enqueue(
        url: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
        savedDir: dir.path,
        showNotification: true,
        openFileFromNotification: true,
      );
      setState(() {
        _downloadTaskId = taskId ?? '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('下载已加入队列！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('下载失败 (需要在 main.dart 配置 Initialize) : $e')),
        );
      }
    }
  }

  Widget _buildQRCodeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. 生成二维码 (qr_flutter)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _qrTextController,
              decoration: const InputDecoration(
                labelText: '输入内容生成二维码',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Center(
              child: QrImageView(
                data: _qrTextController.text.isNotEmpty ? _qrTextController.text : ' ',
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('2. 扫描二维码 (mobile_scanner)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_isScannerActive)
              SizedBox(
                height: 300,
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                      setState(() {
                        _scanResult = barcodes.first.rawValue!;
                        _isScannerActive = false; // 扫到后停止
                      });
                    }
                  },
                ),
              )
            else
              Center(
                child: ElevatedButton.icon(
                  onPressed: _startScan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('启动扫描仪'),
                ),
              ),
            const SizedBox(height: 10),
            Text('扫描结果: $_scanResult', style: const TextStyle(color: Colors.blue)),
            const Text('注: 需要真机或支持摄像头的模拟器测试', style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('3. 文件下载 (flutter_downloader)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              '说明：flutter_downloader 会调用原生下载器，并自带状态栏通知。完整的集成需要在 iOS/Android 工程和 main.dart 做初始化配置。',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: _startDummyDownload,
                icon: const Icon(Icons.download),
                label: const Text('下载示例图片'),
              ),
            ),
            if (_downloadTaskId.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Task ID: $_downloadTaskId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('4. 调用系统分享 (share_plus)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: _shareContent,
                icon: const Icon(Icons.share),
                label: const Text('分享文本到微信/备忘录等'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 38: 常用工具包 (二)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQRCodeSection(),
            const SizedBox(height: 16),
            _buildScannerSection(),
            const SizedBox(height: 16),
            _buildDownloadSection(),
            const SizedBox(height: 16),
            _buildShareSection(),
          ],
        ),
      ),
    );
  }
}
