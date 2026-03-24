import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';

class LifecycleDemoPage extends StatefulWidget {
  const LifecycleDemoPage({super.key});

  @override
  State<LifecycleDemoPage> createState() => _LifecycleDemoPageState();
}

// 1. 核心重点：混入 WidgetsBindingObserver
class _LifecycleDemoPageState extends State<LifecycleDemoPage>
    with WidgetsBindingObserver {
  AppLifecycleState? _lifecycleState;

  // 这是用来展示模糊遮罩层的开关
  bool _showPrivacyOverlay = false;

  // 用个列表存储生命周期记录展示在页面上
  final List<String> _logs = [];

  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    // 2. 注册观察者
    WidgetsBinding.instance.addObserver(this);
    _logs.add('initState -> Observer Registered');
  }

  @override
  void dispose() {
    // 3. 注销观察者，防止内存泄漏
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 4. 重写生命周期变化回调方法
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lifecycleState = state;
      _logs.insert(0, '📝 State changed to: ${state.name}');

      // 重点实战：如果退出到非活动页面/后台，显示隐私遮挡
      if (state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused) {
        _showPrivacyOverlay = true;
      } else if (state == AppLifecycleState.resumed) {
        _showPrivacyOverlay = false;
        // 如果这里有 WebSocket 或者需要校验 Token，就在这里搞
      }
    });
  }

  // === Isolate 计算测试 ===

  // 注意：传给 Isolate.run 的必须是可以顶层或 static 调用的纯函数，不能包含 BuildContext
  static int _heavyCalculationTask(int count) {
    int sum = 0;
    for (int i = 0; i < count; i++) {
      // 故意加一些乘除法增大 CPU 压力
      sum += (i * 2) ~/ 2;
      sum -= (i * 2) ~/ 2;
      sum += i;
    }
    return sum;
  }

  Future<void> _runOnMainThread() async {
    setState(() => _isCalculating = true);

    // 主线程卡死计算 (模拟大概耗时 1 到 2 秒)
    // 这个期间上方的圆圈动画会彻底卡住停止
    await Future.delayed(const Duration(milliseconds: 100)); // 让 UI 先转圈
    final result = _heavyCalculationTask(2000000000); // 20 亿次循环

    setState(() {
      _isCalculating = false;
      _logs.insert(0, '💥 Main Thread finished: sum = $result');
    });
  }

  Future<void> _runOnIsolate() async {
    setState(() => _isCalculating = true);

    // 丢给后台隔离栈区 (此期间上方的圆圈动画流畅)
    final result = await Isolate.run(() => _heavyCalculationTask(2000000000));

    setState(() {
      _isCalculating = false;
      _logs.insert(0, '🚀 Isolate finished: sum = $result');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('周期与计算演示'),
      ),
      // 核心技巧：用 Stack 把整个内容包住，如果在后台就把最上层罩上高斯模糊
      body: Stack(
        children: [
          _buildContent(),
          if (_showPrivacyOverlay) _buildPrivacyOverlay(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('测试切屏(回到主屏幕或开启多任务栏)'),
                  const SizedBox(height: 10),
                  Text(
                    '当前 App 状态: ${_lifecycleState?.name ?? '首次创建 (resumed 前)'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 动画检测卡顿区
          const Center(child: Text("注意看这个圈圈会不会停下：")),
          const SizedBox(height: 10),
          Center(
            child: _isCalculating
                ? const CircularProgressIndicator()
                : const Icon(Icons.check_circle, size: 40, color: Colors.green),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isCalculating ? null : _runOnMainThread,
                icon: const Icon(Icons.block, color: Colors.red),
                label: const Text('在主线程跑'),
              ),
              ElevatedButton.icon(
                onPressed: _isCalculating ? null : _runOnIsolate,
                icon: const Icon(Icons.rocket, color: Colors.green),
                label: const Text('用 Isolate 跑'),
              ),
            ],
          ),
          const Divider(height: 32),
          const Text('生命周期 & 计算日志：',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // 日志列表
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    _logs[index],
                    style:
                        const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // 构建高斯模糊蒙版
  Widget _buildPrivacyOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        // ImageFilter.blur 是做高斯模糊的组件
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          color: Colors.black.withValues(alpha: 0.1),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, size: 60, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  '为了隐私安全，切后台时遮挡',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
