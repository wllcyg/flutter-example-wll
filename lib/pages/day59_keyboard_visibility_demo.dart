import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class Day59KeyboardVisibilityDemo extends StatefulWidget {
  const Day59KeyboardVisibilityDemo({super.key});

  @override
  State<Day59KeyboardVisibilityDemo> createState() => _Day59KeyboardVisibilityDemoState();
}

class _Day59KeyboardVisibilityDemoState extends State<Day59KeyboardVisibilityDemo> {
  // 定义焦点节点，用于控制输入框
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    // 必须释放对应的 FocusNode 以防止内存泄漏
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 KeyboardVisibilityProvider 在整个树中共享键盘显隐状态
    return KeyboardVisibilityProvider(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Day 59: 键盘体验与输入优化'),
        ),
        // 关键配置：当键盘弹起时，自动重新计算页面高度并向上推，防止遮挡底部的输入框
        resizeToAvoidBottomInset: true,
        body: KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return Column(
              children: [
                // ==================== 顶部键盘状态监测 ====================
                Container(
                  width: double.infinity,
                  color: isKeyboardVisible ? Colors.green.shade100 : Colors.grey.shade200,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    isKeyboardVisible ? '🔑 键盘已弹起 (布局自动避让)' : '🔽 键盘已收起',
                    style: TextStyle(
                      color: isKeyboardVisible ? Colors.green.shade800 : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // ==================== 主体内容区域 ====================
                Expanded(
                  child: GestureDetector(
                    // 空白处点击收起键盘
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          '场景一：多输入框表单（焦点切换）', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        // 1. 用户名输入框
                        TextField(
                          focusNode: _emailFocus,
                          decoration: const InputDecoration(
                            labelText: '用户名',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          // TextInputAction.next：将键盘右下角的回车键变为“下一步”
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) {
                            // 当点击“下一步”时，控制焦点转移到密码框
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                        ),
                        const SizedBox(height: 16),
                        // 2. 密码输入框
                        TextField(
                          focusNode: _passwordFocus,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: '密码',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          // TextInputAction.done：将键盘右下角的回车键变为“完成”，不填默认也会根据上下文变化
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            // 提交操作，并收起键盘
                            _passwordFocus.unfocus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('登录表单已提交！')),
                            );
                          },
                        ),
                        
                        const Divider(height: 48),

                        const Text(
                          '场景二：搜索框优化', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: InputDecoration(
                            hintText: '输入要搜索的内容...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          // TextInputAction.search：将键盘右下角的回车键变为“搜索”图标或文字
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {
                            FocusScope.of(context).unfocus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('开始搜索：$value')),
                            );
                          },
                        ),

                        // 为了让 ListView 能够滚动，添加一些占位区块
                        const SizedBox(height: 200),
                        const Center(child: Text('向下滚动查看聊天输入框演示', style: TextStyle(color: Colors.grey))),
                        const SizedBox(height: 200),
                      ],
                    ),
                  ),
                ),

                // ==================== 底部吸附聊天输入框 ====================
                // 该组件放置在 Column 底部，由于 `resizeToAvoidBottomInset: true`，
                // 当键盘弹起时，它会被自动推到键盘的上方
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle_outline, color: Colors.blue, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          // TextInputAction.send：配置发送键
                          textInputAction: TextInputAction.send,
                          // 修改键盘为多行文本输入（根据情况决定是否需要“换行”还是“发送”）
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: '发送消息...',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () {
                          if (_chatController.text.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('发送: ${_chatController.text}')),
                            );
                            _chatController.clear();
                            // 发送后收起键盘
                            FocusScope.of(context).unfocus();
                          }
                        },
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
