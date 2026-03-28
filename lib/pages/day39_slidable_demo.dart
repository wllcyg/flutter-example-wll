import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Day39SlidableDemo extends StatefulWidget {
  const Day39SlidableDemo({super.key});

  @override
  State<Day39SlidableDemo> createState() => _Day39SlidableDemoState();
}

class _Day39SlidableDemoState extends State<Day39SlidableDemo> {
  // 待办事项列表
  List<TodoItem> _todos = [
    TodoItem(id: 1, title: '完成 Flutter 项目', isPinned: false),
    TodoItem(id: 2, title: '学习 flutter_slidable', isPinned: true),
    TodoItem(id: 3, title: '编写技术文档', isPinned: false),
    TodoItem(id: 4, title: '代码 Review', isPinned: false),
    TodoItem(id: 5, title: '团队会议', isPinned: false),
  ];

  void _deleteTodo(int id) {
    setState(() {
      _todos.removeWhere((item) => item.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已删除'), duration: Duration(seconds: 1)),
    );
  }

  void _editTodo(TodoItem item) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: item.title);
        return AlertDialog(
          title: const Text('编辑待办'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '输入新标题'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  item.title = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _togglePin(TodoItem item) {
    setState(() {
      item.isPinned = !item.isPinned;
      // 重新排序：置顶的在前
      _todos.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });
    });
  }

  void _shareTodo(TodoItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('分享: ${item.title}'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 39: 列表侧滑操作'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildTodoList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'flutter_slidable 核心功能',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• 左滑显示删除/编辑操作'),
          const Text('• 右滑显示置顶/分享操作'),
          const Text('• 三种动画模式：Slide / Drawer / Behind'),
          const SizedBox(height: 8),
          Text(
            '提示：向左或向右滑动列表项查看操作',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todos.length + 3, // 额外添加 3 个示例展示不同动画
      itemBuilder: (context, index) {
        if (index < _todos.length) {
          return _buildSlidableItem(_todos[index], ActionPaneType.slide);
        } else {
          // 展示不同动画效果的示例
          final demoIndex = index - _todos.length;
          final demoItem = TodoItem(
            id: 100 + demoIndex,
            title: _getDemoTitle(demoIndex),
            isPinned: false,
          );
          return _buildSlidableItem(
            demoItem,
            _getDemoType(demoIndex),
            isDemo: true,
          );
        }
      },
    );
  }

  String _getDemoTitle(int index) {
    switch (index) {
      case 0:
        return '【演示】Slide 动画模式';
      case 1:
        return '【演示】Drawer 动画模式';
      case 2:
        return '【演示】Behind 动画模式';
      default:
        return '演示项';
    }
  }

  ActionPaneType _getDemoType(int index) {
    switch (index) {
      case 0:
        return ActionPaneType.slide;
      case 1:
        return ActionPaneType.drawer;
      case 2:
        return ActionPaneType.behind;
      default:
        return ActionPaneType.slide;
    }
  }

  Widget _buildSlidableItem(TodoItem item, ActionPaneType type, {bool isDemo = false}) {
    return Slidable(
      key: ValueKey(item.id),
      
      // 左侧滑动操作（从右向左滑）
      endActionPane: ActionPane(
        motion: _getMotion(type),
        children: [
          SlidableAction(
            onPressed: (context) => _editTodo(item),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: '编辑',
          ),
          SlidableAction(
            onPressed: (context) => _deleteTodo(item.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),
      
      // 右侧滑动操作（从左向右滑）
      startActionPane: ActionPane(
        motion: _getMotion(type),
        children: [
          SlidableAction(
            onPressed: (context) => _togglePin(item),
            backgroundColor: item.isPinned ? Colors.grey : Colors.orange,
            foregroundColor: Colors.white,
            icon: item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: item.isPinned ? '取消置顶' : '置顶',
          ),
          SlidableAction(
            onPressed: (context) => _shareTodo(item),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: '分享',
          ),
        ],
      ),
      
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: ListTile(
          leading: item.isPinned
              ? const Icon(Icons.push_pin, color: Colors.orange, size: 20)
              : const Icon(Icons.circle_outlined, size: 20),
          title: Text(
            item.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: item.isPinned ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: isDemo
              ? Text(
                  _getMotionDescription(type),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                )
              : null,
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _getMotion(ActionPaneType type) {
    switch (type) {
      case ActionPaneType.slide:
        return const ScrollMotion(); // Slide 效果
      case ActionPaneType.drawer:
        return const DrawerMotion(); // Drawer 效果
      case ActionPaneType.behind:
        return const BehindMotion(); // Behind 效果
    }
  }

  String _getMotionDescription(ActionPaneType type) {
    switch (type) {
      case ActionPaneType.slide:
        return '操作按钮跟随滑动';
      case ActionPaneType.drawer:
        return '抽屉式展开效果';
      case ActionPaneType.behind:
        return '按钮在列表项后方';
    }
  }
}

// 待办事项模型
class TodoItem {
  final int id;
  String title;
  bool isPinned;

  TodoItem({
    required this.id,
    required this.title,
    required this.isPinned,
  });
}

// 动画类型枚举
enum ActionPaneType {
  slide,
  drawer,
  behind,
}
