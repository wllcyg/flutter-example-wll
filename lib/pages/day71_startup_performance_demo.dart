import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Day71StartupPerformanceDemo extends StatefulWidget {
  const Day71StartupPerformanceDemo({super.key});

  @override
  State<Day71StartupPerformanceDemo> createState() =>
      _Day71StartupPerformanceDemoState();
}

class _Day71StartupPerformanceDemoState
    extends State<Day71StartupPerformanceDemo> {
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 71: 启动性能深度优化'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConceptSection(),
            SizedBox(height: 24.h),
            _buildDevToolsGuide(),
            SizedBox(height: 24.h),
            _buildPracticalOptimizationSection(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildConceptSection() {
    return _buildCard(
      title: '🚀 核心理念：关键路径 (Critical Path)',
      content: '并不是所有服务都必须在 main() 中 await。我们将初始化任务分为两类：\n\n'
          '1. 🔴 关键任务：首页必须展示的数据/配置（如环境变量、DB）。这些保持阻塞。\n'
          '2. 🟢 非关键任务：统计、下载器、第三方 SDK 等。将其改为并行或延迟加载。',
      color: Colors.blueAccent,
    );
  }

  Widget _buildDevToolsGuide() {
    return _buildCard(
      title: '🛠️ 如何使用 DevTools 分析耗时',
      content: '1. 在 IDE 中运行应用（Debug 模式）。\n'
          '2. 打开 Flutter DevTools -> Performance 标签页。\n'
          '3. 点击 "Record" 按钮开始录制。\n'
          '4. 在手机/模拟器上执行 "Hot Restart" (热重启)。\n'
          '5. 停止录制，查找我们在代码中埋入的自定义标签：\n'
          '   - "App Startup"\n'
          '   - "Critical Path Init"\n'
          '   - "Init Supabase" 等。',
      color: Colors.orangeAccent,
    );
  }

  Widget _buildPracticalOptimizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '实战演练：模拟性能追踪',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        const Text(
          '点击下方按钮，将执行一段被 Timeline 包裹的模拟任务。请在 DevTools 中观察它的波形：',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 20.h),
        Center(
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _simulateTraceableTask,
                icon: const Icon(Icons.analytics),
                label: Text(_isAnalyzing ? '正在运行并记录...' : '运行模拟任务并记录 Timeline'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                ),
              ),
              if (_isAnalyzing)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(color: Colors.green),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: color),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: TextStyle(fontSize: 14.sp, height: 1.6),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateTraceableTask() async {
    setState(() => _isAnalyzing = true);

    // 1. 在 Timeline 中添加标记
    developer.Timeline.startSync('Heavy Simulation Task');

    // 模拟一段 CPU 敏感的回调处理
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 嵌套一个子标记
    developer.Timeline.startSync('Complex Calculation');
    double sum = 0;
    for (int i = 0; i < 10000000; i++) {
      sum += i;
    }
    developer.Timeline.finishSync(); // 结束 Complex Calculation

    await Future.delayed(const Duration(milliseconds: 500));

    // 结束外层标记
    developer.Timeline.finishSync(); // 结束 Heavy Simulation Task

    setState(() => _isAnalyzing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 模拟记录完成！请在 DevTools -> Performance 确认追踪波形。'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
