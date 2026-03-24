import 'dart:math';
import 'package:flutter/material.dart';

class PerformanceDemoPage extends StatefulWidget {
  const PerformanceDemoPage({super.key});

  @override
  State<PerformanceDemoPage> createState() => _PerformanceDemoPageState();
}

class _PerformanceDemoPageState extends State<PerformanceDemoPage> {
  bool _isOptimized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('性能重绘与优化测试'),
        actions: [
          Row(
            children: [
              const Text('优化开关: '),
              Switch(
                value: _isOptimized,
                activeColor: Colors.greenAccent,
                onChanged: (val) {
                  setState(() => _isOptimized = val);
                },
              ),
              const SizedBox(width: 8),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Text(
              '提示：请在 IDE 打开 Flutter Inspector 并勾选 "Highlight Repaints" (高亮重绘)。\n\n'
              '然后观察下方旋转方块时周边 UI 区域是否有持续刷新的颜色块。未优化时，转动的方块可能引发整个列表/周边的渲染刷新。',
              style: TextStyle(fontSize: 14, color: Colors.blueGrey),
            ),
          ),
          const SizedBox(height: 16),
          // 顶部的持续高频重绘动画
          _isOptimized
              // 优化：使用 RepaintBoundary 隔离独立图层，旋转不再影响其他兄弟节点
              ? const RepaintBoundary(child: _RotatingBox())
              // 未优化：旋转会使得当前引擎绘制脏区扩散
              : const _RotatingBox(),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
                '下面的长列表是一个静态数据列表，但在未优化的情况下，当顶部处于持续动画时，如果一起塞在同一个复杂层里，极易造成 GPU 负担。',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                // 如果 _isOptimized 为 true，通过将一些确定的静态 UI 前置使用 const，可大幅减少 build 压力 (虽然这里只是展示差异，实际 ListView item 仍按需加载)
                return _isOptimized
                    ? const _OptimizedListItem()
                    : _UnoptimizedListItem(index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 一个一直在不停旋转导致极高频渲染重绘的组件
class _RotatingBox extends StatefulWidget {
  const _RotatingBox();

  @override
  State<_RotatingBox> createState() => _RotatingBoxState();
}

class _RotatingBoxState extends State<_RotatingBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [Colors.purple, Colors.orange]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'High\nGPU',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 伪造一个由于层级堆砌、复杂无优化约束的子项
class _UnoptimizedListItem extends StatelessWidget {
  final int index;
  const _UnoptimizedListItem({required this.index});

  @override
  Widget build(BuildContext context) {
    // 每次滑动都会重新创建该对象
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '未经过 Const 与层级优化的极耗费内存单元。重绘隔离未开启。 (Index: $index)',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// 使用了 const 的静态复用项
class _OptimizedListItem extends StatelessWidget {
  const _OptimizedListItem();

  @override
  Widget build(BuildContext context) {
    // 整个框架都可以被引擎当作单例内存复用
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              '我是高度优化的静态常驻 Const 单元。不会被无辜重绘，内存也只需申请一份！',
              style: TextStyle(fontSize: 14, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
