import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketDemoPage extends StatefulWidget {
  const WebsocketDemoPage({super.key});

  @override
  State<WebsocketDemoPage> createState() => _WebsocketDemoPageState();
}

class _WebsocketDemoPageState extends State<WebsocketDemoPage> {
  // 定义 Channel 引用
  WebSocketChannel? _channel;

  // 记录聊天和系统日志
  final List<String> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 当前连接状态
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  // 建立连接的核心方法
  void _connectWebSocket() {
    if (_isConnected) return;

    try {
      // 官方提供的回显服务器，发什么它回什么，适合调试
      final wsUrl = Uri.parse('wss://echo.websocket.events');
      _channel = WebSocketChannel.connect(wsUrl);

      setState(() {
        _isConnected = true;
        _addMessage('🔗 系统: 正在连接到 echo.websocket.events ...');
      });

      // 监听消息流 (Stream)
      _channel!.stream.listen(
        (message) {
          _addMessage('⬅️ 收到: $message');
        },
        onError: (error) {
          _addMessage('❌ 错误: 网络中断 ($error)');
          setState(() => _isConnected = false);
        },
        onDone: () {
          _addMessage('⚠️ 系统: 连接已断开 (onDone被触发) ');
          setState(() => _isConnected = false);
        },
      );
    } catch (e) {
      _addMessage('❌ 系统: 连接建立抛出异常 $e');
    }
  }

  // 主动断开
  void _disconnect() {
    if (_channel != null) {
      // 传入关闭代码以告知服务端（1000 意味着正常退出）
      _channel!.sink.close(1000, "用户主动离开");
      setState(() {
        _isConnected = false;
        _addMessage('💔 系统: 已主动切断连接');
      });
    }
  }

  // 发送消息到长连接
  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (_isConnected && _channel != null) {
      // 通过 sink 添加数据推送给服务器
      _channel!.sink.add(text);
      _addMessage('➡️ 发送: $text');
      _textController.clear();
    } else {
      _addMessage('❌ 系统: 当前未建立连接，不能发消息！');
    }
  }

  // 追加日志与让聊天界面自动滚到底部
  void _addMessage(String msg) {
    setState(() {
      _messages.add(msg);
    });
    // 让最新的日志永远显示在最下方（加微小延时是因为 build 需要哪怕 1 帧的绘制时间）
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // 【极其重要】千万别忘了释放 sink 的系统内存与套接字端口！
    _channel?.sink.close();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket 闲聊测试室'),
        actions: [
          // 右上方的状态红绿灯
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 6,
              backgroundColor: _isConnected ? Colors.greenAccent : Colors.red,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // 面板按钮区域
          Container(
            color: Colors.blueGrey.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _isConnected ? _disconnect : _connectWebSocket,
                  icon: Icon(_isConnected ? Icons.flash_off : Icons.flash_on),
                  label: Text(_isConnected ? '主动断开' : '重新连接'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isConnected ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // 聊天框区域
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  // 判断一下颜色来区分收发和警告
                  Color textColor = Colors.black87;
                  if (msg.startsWith('➡️')) textColor = Colors.blue.shade700;
                  if (msg.startsWith('⬅️')) textColor = Colors.green.shade700;
                  if (msg.startsWith('❌') || msg.startsWith('💔'))
                    textColor = Colors.red;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      msg,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 底部输入框区域
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 8,
              top: 8,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: _isConnected ? '输入你想和回显服务器说的话...' : '已断开连接...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    enabled: _isConnected,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isConnected ? _sendMessage : null,
                  elevation: 0,
                  backgroundColor: _isConnected ? Colors.blue : Colors.grey,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
