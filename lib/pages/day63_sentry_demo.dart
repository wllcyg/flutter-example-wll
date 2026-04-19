import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class Day63SentryDemo extends StatefulWidget {
  const Day63SentryDemo({super.key});

  @override
  State<Day63SentryDemo> createState() => _Day63SentryDemoState();
}

class _Day63SentryDemoState extends State<Day63SentryDemo> {
  bool _isProfiling = false;

  @override
  void initState() {
    super.initState();
    // 绑定用户信息 - Day 63
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: 'user_12345',
        username: 'flutter_worker',
        email: 'demo@example.com',
      ));
      scope.setTag('module', 'developer_tools');
    });
  }

  // 手动上报异常 - Day 63
  Future<void> _captureManualException() async {
    try {
      throw Exception('这是一个业务逻辑手动抛出的异常');
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('priority', 'high');
          scope.setContexts('logic_info', {'action': 'manual_report'});
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('手动上报成功 (查看 Sentry 控制台)')),
        );
      }
    }
  }

  // 性能监控追踪 - Day 64
  Future<void> _runPerformanceTrace() async {
    setState(() => _isProfiling = true);

    // 1. 开始事务
    final transaction = Sentry.startTransaction(
      'process-data-transaction',
      'task.execution',
      bindToScope: true,
    );

    // 2. 添加面包屑记录路径
    Sentry.addBreadcrumb(Breadcrumb(
      message: '用户开始了性能耗时操作测试',
      category: 'action',
      level: SentryLevel.info,
    ));

    try {
      // 模拟耗时步骤 A
      final spanA = transaction.startChild('step_fetch_local_db', description: '从本地加载缓存');
      await Future.delayed(const Duration(milliseconds: 800));
      spanA.status = const SpanStatus.ok();
      await spanA.finish();

      // 模拟耗时步骤 B
      final spanB = transaction.startChild('step_api_sync', description: '与服务器同步数据');
      await Future.delayed(const Duration(seconds: 1));
      spanB.status = const SpanStatus.ok();
      await spanB.finish();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('性能追踪事务完成 (查看 Sentry Performance)')),
        );
      }
    } catch (e) {
      transaction.status = const SpanStatus.internalError();
    } finally {
      // 3. 结束事务上报
      await transaction.finish();
      setState(() => _isProfiling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 63/64: Sentry 实战'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader('崩溃日志收集 (Day 63)', Icons.bug_report),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
              onPressed: () {
                // 模拟自动捕获：未处理异常
                throw Exception('🔥 模拟一个触发自动上报的未捕获错误');
              },
              child: const Text('触发模拟崩溃 (自动上报)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.send),
              onPressed: _captureManualException,
              label: const Text('手动上报业务异常'),
            ),
            const SizedBox(height: 32),
            _buildHeader('性能监测与追踪 (Day 64)', Icons.speed),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Colors.blue.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('性能追踪会监控事务中的子时间轴(Spans)，帮助定位具体哪个步骤耗时过长。', style: TextStyle(fontSize: 13, color: Colors.blueGrey)),
                    const SizedBox(height: 16),
                    _isProfiling
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: _runPerformanceTrace,
                            label: const Text('开始一段模拟事务追踪'),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildHeader('面包屑与标签', Icons.label_outline),
            const Text(
              '在 Sentry 控制台的事件详情中，你可以看到上面按钮点击记录的面包屑轨迹，以及全局配置的用户 ID 标签。',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
