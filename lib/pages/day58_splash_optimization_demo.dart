import 'package:flutter/material.dart';

class Day58SplashOptimizationDemo extends StatefulWidget {
  const Day58SplashOptimizationDemo({super.key});

  @override
  State<Day58SplashOptimizationDemo> createState() =>
      _Day58SplashOptimizationDemoState();
}

class _Day58SplashOptimizationDemoState
    extends State<Day58SplashOptimizationDemo> {
  // 模拟应用初始化状态
  bool _isInitializing = false;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 58: 启动优化与原生启动屏'),
      ),
      body: Stack(
        children: [
          // 首页实际内容
          _buildMainContent(),

          // 模拟原生启动屏过渡期间的覆盖层
          if (_isInitializing && !_isInitialized) _buildMockSplashScreen(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '启动优化步骤指南：',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: '1. flutter_native_splash',
            content: '在 pubspec.yaml 中添加该依赖插件，并创建 flutter_native_splash.yaml 配置文件，替换掉系统默认纯白启动屏，使得点击APP瞬间即呈现品牌Logo。可通过以下命令自动生成原生代码配置：\n'
                '> flutter pub run flutter_native_splash:create',
          ),
          _buildInfoCard(
            title: '2. 延迟初始化 (main.dart)',
            content:
                '在 main() 函数中，保留启动屏直至应用首屏渲染准备完毕：\n\n'
                'WidgetsBinding binding = \n WidgetsFlutterBinding.ensureInitialized();\n'
                'FlutterNativeSplash.preserve(widgetsBinding: binding);',
          ),
          _buildInfoCard(
            title: '3. 启动时间优化 — 异步加载',
            content: '在 App 启动生命周期阶段，发起异步并发请求以加载依赖和关键数据（例如：解析本地 Token、初始化 Sqlite 数据库、拉取基础配置字典等）。不要让同步任务阻塞 UI 线程。',
          ),
          _buildInfoCard(
            title: '4. 启动页平滑衔接',
            content: '在全部初始化任务（或首个核心界面帧渲染）完成后，再手动移除原生启动屏：\n\n'
                'FlutterNativeSplash.remove();\n\n'
                '此时 Flutter 首页 UI 已绘制完毕，能够从原生屏无缝、平滑衔接到应用首页，避免中间闪烁。',
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                _simulateAppStartup();
              },
              icon: const Icon(Icons.rocket_launch),
              label: const Text('模拟体验：应用完整启动流'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(height: 1.5, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // 模拟从原生启动屏过渡到 Flutter 渲染层的过程
  Widget _buildMockSplashScreen() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 模拟 App Icon
          const Icon(Icons.flutter_dash, size: 100, color: Colors.blueAccent),
          const SizedBox(height: 40),
          // 模拟后台初始化数据时的 Loading
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text(
            '伪造的原生启动屏...',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            '执行初始化：延迟屏展示、异步加载核心数据',
            style: TextStyle(color: Colors.black38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateAppStartup() async {
    setState(() {
      _isInitializing = true;
      _isInitialized = false;
    });

    // 模拟耗时的并发初始化任务（如：网络请求、读取本地 DB、极光推送初始化等）
    await Future.wait([
      Future.delayed(const Duration(seconds: 1)),
      Future.delayed(const Duration(seconds: 2)),
      Future.delayed(const Duration(seconds: 3)),
    ]);

    // 模拟调用 FlutterNativeSplash.remove(); 进行平滑过渡
    setState(() {
      _isInitialized = true;
      _isInitializing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 核心组件初始化完成！已平滑移除启动屏 (FlutterNativeSplash.remove())'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
