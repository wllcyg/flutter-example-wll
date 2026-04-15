import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// 全局日志单例，提供统一的日志输出管理能力。
/// 在实际项目中，建议将其独立抽离到 `utils/log_util.dart` 或类似文件中。
class Log {
  // 单例模式定义全局 Logger
  static final Logger _logger = Logger(
    // 过滤器：用来决定哪些级别的日志会被打印
    // DevelopmentFilter 表示开发模式打印所有，Release 模式结合配置可自动关停
    filter: DevelopmentFilter(), 
    printer: PrettyPrinter(
      methodCount: 2,           // 打印方法调用堆栈层数，方便溯源
      errorMethodCount: 8,      // 异常情况下打印更深的堆栈层数
      lineLength: 100,          // 分割线长度
      colors: true,             // 终端输出彩色文字
      printEmojis: true,        // 日志级别打印前缀 Emoji 方便快速辨识
      printTime: true,          // 是否打印每条日志的时间戳
    ),
  );

  /// Trace: 最详细的追踪级别（在一些低级别的诊断才开启）
  static void t(dynamic message) => _logger.t(message);
  
  /// Debug: 开发调试日志级别（推荐在排查过程或开发过程中使用）
  static void d(dynamic message) => _logger.d(message);
  
  /// Info: 通常的信息打印（例如初始化成功、关键业务节点响应等）
  static void i(dynamic message) => _logger.i(message);
  
  /// Warning: 警告级别（代表存在潜在问题、参数缺失使用默认值等情况）
  static void w(dynamic message) => _logger.w(message);
  
  /// Error: 错误级别（抛出异常、崩溃边缘的行为、重要网络请求错误）
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
      
  /// Fatal: 致命错误级别（导致系统直接崩溃的致命行为）
  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}

class Day60LoggerDemo extends StatelessWidget {
  const Day60LoggerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 60: Logger 日志美化'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Text(
                  '💡 点击下方按钮\n查看您的 IDE 控制台中的彩色日志输出效果',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              _buildLogBtn(
                'Trace 日志 (t)', 
                Colors.grey.shade600, 
                () => Log.t('这是一条 Trace 级别的微小日志信息')
              ),
              _buildLogBtn(
                'Debug 日志 (d)', 
                Colors.blue, 
                () => Log.d('这是一条 Debug 日志：即将发起发起 GET 请求 -> /api/user')
              ),
              _buildLogBtn(
                'Info 日志 (i)', 
                Colors.green, 
                () => Log.i('这是一条 Info 日志：应用已准备就绪，用户数据加载完毕')
              ),
              _buildLogBtn(
                'Warning 日志 (w)', 
                Colors.orange, 
                () => Log.w('这是一条 Warning 日志：Token 即将过期，请留意')
              ),
              _buildLogBtn(
                'Error 日志 (e)', 
                Colors.red, 
                () {
                  try {
                    // 故意抛出异常来演示带有 StackTrace 的日志
                    throw FormatException('无法解析的 JSON 数据结构');
                  } catch (e, stack) {
                    Log.e('这是一条 Error 日志：发生了不可预期的错误', e, stack);
                  }
                }
              ),
              _buildLogBtn(
                'Fatal 日志 (f)', 
                Colors.purple, 
                () => Log.f('这是一条 Fatal 日志：数据库连接完全失效，App 面临崩溃！')
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogBtn(String text, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          )
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
