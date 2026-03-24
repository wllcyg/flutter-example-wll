import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CicdDemoPage extends StatelessWidget {
  const CicdDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 核心代码演示：从环境变量读取配置
    // 如果没有使用 --dart-define=ENV=xxx 指定，默认为 '未配置'
    const String envName = String.fromEnvironment('ENV', defaultValue: '-');
    const String apiUrl = String.fromEnvironment('API_URL', defaultValue: '-');
    const bool isDebugToolEnabled =
        bool.fromEnvironment('DEBUG_TOOLS', defaultValue: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('多环境部署演示 (CI/CD)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '当前运行环境变量读取',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow('当前环境 (ENV)', envName),
                    const Divider(),
                    _buildInfoRow('对应 API 接口', apiUrl),
                    const Divider(),
                    _buildInfoRow('是否开启调试看板', isDebugToolEnabled ? '开启' : '关闭'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '测试操作提示',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '如果不添加任何命令行参数，上方的各项内容都会显示为横杠 (-) 或是它的 fallback 默认值。\n\n'
              '你可以结束当前的执行，然后在终端使用如下语句重新启动它以测试不同环境的打包切分：',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                r'flutter run --dart-define=ENV=staging --dart-define=API_URL=https://staging.abc.com --dart-define=DEBUG_TOOLS=true',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('复制命令'),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(
                      text:
                          r'flutter run --dart-define=ENV=staging --dart-define=API_URL=https://staging.abc.com --dart-define=DEBUG_TOOLS=true'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('启动命令已复制')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
