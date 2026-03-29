import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Day39SlidableDemoHooks extends HookWidget {
  const Day39SlidableDemoHooks({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 useState 替代 StatefulWidget 的 state
    final todos = useState<List<TodoItem>>([
      TodoItem(id: 1, title: '完成 Flutter 项目', isPinned: false),
      TodoItem(id: 2, title: '学习 flutter_slidable', isPinned: true),
      TodoItem(id: 3, title: '编写技术文档', isPinned: false),
      TodoItem(id: 4, title: '代码 Review', isPinned: false),
      TodoItem(id: 5, title: '团队会议', isPinned: false),
    ]);

    // 使用 useCallback 缓存回调函数
    final deleteTodo = useCallback((int id) {
      todos.value = todos.value.where((item) => item.id != id).toList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已删除'), duration: Duration(seconds: 1)),
      );
    }, [todos.value]);

    final editTodo = useCallback((TodoItem item) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return _EditDialog(
            item: item,
            onSave: (newTitle) {
              final index = todos.value.indexWhere((t) => t.id == item.id);
              if (index != -1) {
                final updated = List<TodoItem>.from(todos.value);
                updated[index] = TodoItem(
                  id: item.id,
                  title: newTitle,
                  isPinned: item.isPinned,
                );
                todos.value = updated;
              }
            },
          );
        },
      );
    }, [todos.value]);

    final togglePin = useCallback((TodoItem item) {
      final updated = todos.value.map((t) {
        if (t.id == item.id) {
          return TodoItem(id: t.id, title: t.title, isPinned: !t.isPinned);
        }
        return t;
      }).toList();
      
      // 重新排序：置顶的在前
      updated.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });
      
      todos.value = updated;
    }, [todos.value]);

    final shareTodo = useCallback((TodoItem item) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('分享: ${item.title}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 39: 列表侧滑操作 (Hooks)'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildTodoList(
              todos.value,
              deleteTodo,
              editTodo,
              togglePin,
              shareTodo,
            ),
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
            'flutter_slidable 核心功能 (Hooks 版本)',
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

  Widget _buildTodoList(
    List<TodoItem> todos,
    Function(int) deleteTodo,
    Function(TodoItem) editTodo,
    Function(TodoItem) togglePin,
    Function(TodoItem) shareTodo,
  ) {
    return ListView.builder(
      itemCount: todos.length + 3,
      itemBuilder: (context, index) {
        if (index < todos.length) {
          return _buildSlidableItem(
            todos[index],
            ActionPaneType.slide,
            deleteTodo,
            editTodo,
            togglePin,
            shareTodo,
          );
        } else {
          final demoIndex = index - todos.length;
          final demoItem = TodoItem(
            id: 100 + demoIndex,
            title: _getDemoTitle(demoIndex),
            isPinned: false,
          );
          return _buildSlidableItem(
            demoItem,
            _getDemoType(demoIndex),
            deleteTodo,
            editTodo,
            togglePin,
            shareTodo,
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

  Widget _buildSlidableItem(
    TodoItem item,
    ActionPaneType type,
    Function(int) deleteTodo,
    Function(TodoItem) editTodo,
    Function(TodoItem) togglePin,
    Function(TodoItem) shareTodo, {
    bool isDemo = false,
  }) {
    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: _getMotion(type),
        children: [
          SlidableAction(
            onPressed: (context) => editTodo(item),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: '编辑',
          ),
          SlidableAction(
            onPressed: (context) => deleteTodo(item.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: _getMotion(type),
        children: [
          SlidableAction(
            onPressed: (context) => togglePin(item),
            backgroundColor: item.isPinned ? Colors.grey : Colors.orange,
            foregroundColor: Colors.white,
            icon: item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: item.isPinned ? '取消置顶' : '置顶',
          ),
          SlidableAction(
            onPressed: (context) => shareTodo(item),
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
        return const ScrollMotion();
      case ActionPaneType.drawer:
        return const DrawerMotion();
      case ActionPaneType.behind:
        return const BehindMotion();
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

// 编辑对话框组件（使用 HookWidget）
class _EditDialog extends HookWidget {
  final TodoItem item;
  final Function(String) onSave;

  const _EditDialog({required this.item, required this.onSave});

  @override
  Widget build(BuildContext context) {
    // 使用 useTextEditingController 自动管理生命周期
    final controller = useTextEditingController(text: item.title);

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
            onSave(controller.text);
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}

// 待办事项模型（不可变）
class TodoItem {
  final int id;
  final String title;
  final bool isPinned;

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
