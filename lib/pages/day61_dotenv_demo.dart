import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Day61DotenvDemo extends StatefulWidget {
  const Day61DotenvDemo({super.key});

  @override
  State<Day61DotenvDemo> createState() => _Day61DotenvDemoState();
}

class _Day61DotenvDemoState extends State<Day61DotenvDemo> {
  String _currentEnvFile = '.env.dev';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 页面加载时默认初始化 dev 环境
    _loadEnv('.env.dev');
  }

  /// 动态加载对应的环境配置文件
  Future<void> _loadEnv(String fileName) async {
    setState(() => _isLoading = true);
    try {
      // dotenv.load 会从 pubspec.yaml 中声明的 assets 里去读取该文件
      await dotenv.load(fileName: fileName);
      setState(() {
        _currentEnvFile = fileName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载配置失败: $e\n请确保在 pubspec.yaml 的 assets 中注册了此文件')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 从环境变量中读取，若不存在则提供备选默认值
    final apiUrl = dotenv.env['API_URL'] ?? '未配置 API_URL';
    final debugMode = dotenv.env['DEBUG_MODE'] ?? '未配置';
    final appName = dotenv.env['APP_NAME'] ?? '未配置 APP_NAME';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 61: 环境变量切换'),
        backgroundColor: _getPrimaryColor(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎛 环境选择器 (仅 Debug 模式可见)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // 实战：在内部测试版本中，经常会做这样一个抓手来热切环境
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEnvButton('.env.dev', '开发环境 (Dev)'),
                      _buildEnvButton('.env.staging', '测试环境 (Staging)'),
                      _buildEnvButton('.env.prod', '生产环境 (Prod)'),
                    ],
                  ),
                  const Divider(height: 48),

                  const Text(
                    '当前读取到的全局配置参数：',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildConfigItem('🌍 API_URL', apiUrl),
                  _buildConfigItem('🐛 DEBUG_MODE', debugMode),
                  _buildConfigItem('📱 APP_NAME', appName),
                  
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '安全提醒：切记在 .gitignore 中添加 .env*！万万不可将包含云服务 Secret、密码的环境变量文件通过 Git 推送到公共仓库进行泄露。',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEnvButton(String mapFile, String title) {
    final isSelected = _currentEnvFile == mapFile;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            elevation: isSelected ? 2 : 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => _loadEnv(mapFile),
          child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildConfigItem(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(key, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Color _getPrimaryColor() {
    if (_currentEnvFile.contains('dev')) return Colors.green;
    if (_currentEnvFile.contains('staging')) return Colors.orange;
    return Colors.blue;
  }
}
