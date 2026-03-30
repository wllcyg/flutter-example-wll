import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:badges/badges.dart' as badges;

/// Day 41: Toast 与 Badge 示例
/// 
/// 功能：
/// 1. fluttertoast - 轻量级 Toast（Android 原生风格）
/// 2. 位置配置 - 顶部/中间/底部显示
/// 3. 对比 SnackBar - 何时用 Toast / SnackBar / Dialog
/// 4. badges 包 - 角标提示（购物车数量、未读消息红点）
/// 5. 角标位置 - 右上角、自定义偏移
/// 6. 动态更新角标 - Riverpod 管理未读数量

// ==================== State Management ====================

/// 购物车数量状态
final cartCountProvider = StateProvider<int>((ref) => 0);

/// 未读消息数量状态
final unreadMessagesProvider = StateProvider<int>((ref) => 5);

/// 通知数量状态
final notificationCountProvider = StateProvider<int>((ref) => 3);

// ==================== Main Page ====================

class Day41ToastBadgeDemo extends HookConsumerWidget {
  const Day41ToastBadgeDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final unreadMessages = ref.watch(unreadMessagesProvider);
    final notificationCount = ref.watch(notificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 41: Toast & Badge'),
        actions: [
          // 通知图标带角标
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: badges.Badge(
              badgeContent: Text(
                '$notificationCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              showBadge: notificationCount > 0,
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              badgeAnimation: const badges.BadgeAnimation.scale(),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ref.read(notificationCountProvider.notifier).state = 0;
                  _showToast('已清空通知', ToastGravity.TOP);
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================== Toast 示例 ====================
            _buildSectionTitle('1. Toast 位置配置'),
            const SizedBox(height: 12),
            _buildToastButtons(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('2. Toast 样式配置'),
            const SizedBox(height: 12),
            _buildToastStyleButtons(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('3. 对比：Toast vs SnackBar vs Dialog'),
            const SizedBox(height: 12),
            _buildComparisonButtons(context),
            
            const SizedBox(height: 24),
            _buildSectionTitle('4. Badge 角标示例'),
            const SizedBox(height: 12),
            _buildBadgeExamples(ref, cartCount, unreadMessages),
            
            const SizedBox(height: 24),
            _buildSectionTitle('5. Badge 位置与样式'),
            const SizedBox(height: 12),
            _buildBadgePositions(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('6. 动态更新角标'),
            const SizedBox(height: 12),
            _buildDynamicBadges(ref, cartCount, unreadMessages),
          ],
        ),
      ),
    );
  }

  // ==================== Toast 按钮组 ====================

  Widget _buildToastButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showToast('顶部提示', ToastGravity.TOP),
          icon: const Icon(Icons.arrow_upward),
          label: const Text('顶部 Toast'),
        ),
        ElevatedButton.icon(
          onPressed: () => _showToast('中间提示', ToastGravity.CENTER),
          icon: const Icon(Icons.remove),
          label: const Text('中间 Toast'),
        ),
        ElevatedButton.icon(
          onPressed: () => _showToast('底部提示', ToastGravity.BOTTOM),
          icon: const Icon(Icons.arrow_downward),
          label: const Text('底部 Toast'),
        ),
      ],
    );
  }

  Widget _buildToastStyleButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showSuccessToast('操作成功'),
          icon: const Icon(Icons.check_circle),
          label: const Text('成功提示'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        ElevatedButton.icon(
          onPressed: () => _showErrorToast('操作失败'),
          icon: const Icon(Icons.error),
          label: const Text('错误提示'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
        ElevatedButton.icon(
          onPressed: () => _showWarningToast('警告信息'),
          icon: const Icon(Icons.warning),
          label: const Text('警告提示'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        ElevatedButton.icon(
          onPressed: () => _showLongToast('这是一条较长时间显示的提示消息'),
          icon: const Icon(Icons.timer),
          label: const Text('长时间显示'),
        ),
      ],
    );
  }

  Widget _buildComparisonButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showToast('Toast: 轻量级，不阻塞交互', ToastGravity.BOTTOM),
          icon: const Icon(Icons.message),
          label: const Text('Toast - 轻量提示'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _showSnackBar(context),
          icon: const Icon(Icons.info),
          label: const Text('SnackBar - 可操作提示'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _showDialog(context),
          icon: const Icon(Icons.warning_amber),
          label: const Text('Dialog - 需要确认'),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('使用场景对比：', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Toast: 简单提示，不需要用户操作（保存成功、复制成功）'),
                Text('• SnackBar: 需要撤销操作或查看详情（删除后可撤销）'),
                Text('• Dialog: 需要用户确认或输入（删除确认、表单提交）'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== Badge 示例 ====================

  Widget _buildBadgeExamples(WidgetRef ref, int cartCount, int unreadMessages) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        // 购物车角标
        Column(
          children: [
            badges.Badge(
              badgeContent: Text(
                '$cartCount',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              showBadge: cartCount > 0,
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
                padding: EdgeInsets.all(6),
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart, size: 32),
                onPressed: () {
                  ref.read(cartCountProvider.notifier).state++;
                  _showToast('已添加到购物车', ToastGravity.BOTTOM);
                },
              ),
            ),
            const SizedBox(height: 4),
            const Text('购物车', style: TextStyle(fontSize: 12)),
          ],
        ),
        
        // 消息角标
        Column(
          children: [
            badges.Badge(
              badgeContent: Text(
                '$unreadMessages',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              showBadge: unreadMessages > 0,
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.orange,
                padding: EdgeInsets.all(6),
              ),
              child: IconButton(
                icon: const Icon(Icons.message, size: 32),
                onPressed: () {
                  ref.read(unreadMessagesProvider.notifier).state = 0;
                  _showToast('已读所有消息', ToastGravity.BOTTOM);
                },
              ),
            ),
            const SizedBox(height: 4),
            const Text('消息', style: TextStyle(fontSize: 12)),
          ],
        ),
        
        // 红点提示（无数字）
        Column(
          children: [
            badges.Badge(
              showBadge: true,
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
                padding: EdgeInsets.all(4),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications, size: 32),
                onPressed: () => _showToast('有新通知', ToastGravity.BOTTOM),
              ),
            ),
            const SizedBox(height: 4),
            const Text('通知红点', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgePositions() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        // 右上角（默认）
        _buildBadgeDemo(
          '右上角',
          badges.BadgePosition.topEnd(top: -5, end: -5),
        ),
        
        // 右下角
        _buildBadgeDemo(
          '右下角',
          badges.BadgePosition.bottomEnd(bottom: -5, end: -5),
        ),
        
        // 左上角
        _buildBadgeDemo(
          '左上角',
          badges.BadgePosition.topStart(top: -5, start: -5),
        ),
        
        // 左下角
        _buildBadgeDemo(
          '左下角',
          badges.BadgePosition.bottomStart(bottom: -5, start: -5),
        ),
      ],
    );
  }

  Widget _buildBadgeDemo(String label, badges.BadgePosition position) {
    return Column(
      children: [
        badges.Badge(
          badgeContent: const Text(
            '9',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          position: position,
          badgeStyle: const badges.BadgeStyle(
            badgeColor: Colors.red,
            padding: EdgeInsets.all(5),
          ),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inbox, size: 28),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDynamicBadges(WidgetRef ref, int cartCount, int unreadMessages) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                badges.Badge(
                  badgeContent: Text(
                    '$cartCount',
                    style: const TextStyle(color: Colors.white),
                  ),
                  showBadge: cartCount > 0,
                  badgeAnimation: const badges.BadgeAnimation.scale(
                    animationDuration: Duration(milliseconds: 300),
                  ),
                  child: const Icon(Icons.shopping_cart, size: 40),
                ),
                badges.Badge(
                  badgeContent: Text(
                    '$unreadMessages',
                    style: const TextStyle(color: Colors.white),
                  ),
                  showBadge: unreadMessages > 0,
                  badgeAnimation: const badges.BadgeAnimation.slide(),
                  child: const Icon(Icons.mail, size: 40),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('购物车', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (cartCount > 0) {
                              ref.read(cartCountProvider.notifier).state--;
                            }
                          },
                          icon: const Icon(Icons.remove_circle),
                          color: Colors.red,
                        ),
                        Text('$cartCount', style: const TextStyle(fontSize: 18)),
                        IconButton(
                          onPressed: () {
                            ref.read(cartCountProvider.notifier).state++;
                          },
                          icon: const Icon(Icons.add_circle),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('消息', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (unreadMessages > 0) {
                              ref.read(unreadMessagesProvider.notifier).state--;
                            }
                          },
                          icon: const Icon(Icons.remove_circle),
                          color: Colors.red,
                        ),
                        Text('$unreadMessages', style: const TextStyle(fontSize: 18)),
                        IconButton(
                          onPressed: () {
                            ref.read(unreadMessagesProvider.notifier).state++;
                          },
                          icon: const Icon(Icons.add_circle),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Helper Widgets ====================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  // ==================== Toast 方法 ====================

  void _showToast(String message, ToastGravity gravity) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showWarningToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showLongToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // ==================== SnackBar & Dialog ====================

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已删除项目'),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            _showToast('已撤销删除', ToastGravity.BOTTOM);
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个项目吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('已删除', ToastGravity.BOTTOM);
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
