import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class Day62PrettyDioLoggerDemo extends StatefulWidget {
  const Day62PrettyDioLoggerDemo({super.key});

  @override
  State<Day62PrettyDioLoggerDemo> createState() => _Day62PrettyDioLoggerDemoState();
}

class _Day62PrettyDioLoggerDemoState extends State<Day62PrettyDioLoggerDemo> {
  late Dio _dio;
  bool _isLoading = false;
  String _responseLog = '点击按钮发起网络请求...\n(具体彩色打印请前往 IDE 控制台查看)';

  @override
  void initState() {
    super.initState();
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 5),
    ));

    // 使用 const bool.fromEnvironment('dart.vm.product') 判断是否是生产环境
    // 通常只在开发环境 (Debug) 下挂载 pretty_dio_logger
    const isProd = bool.fromEnvironment('dart.vm.product');
    
    if (!isProd) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,      // 打印请求头
          requestBody: true,        // 打印请求参数 (Body)
          responseBody: true,       // 打印服务器返回的数据
          responseHeader: false,    // 不打印繁杂的返回头
          error: true,              // 打印错误堆栈
          compact: true,            // 压缩日志（避免占用过多的输出行）
          maxWidth: 90,             // 终端打印的最长线宽
        ),
      );
    }
  }

  Future<void> _fetchData(String endpoint) async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get(endpoint);
      setState(() {
        _responseLog = "请求成功: ${response.statusCode}\n\n请求地址: $endpoint\n\n返回数据预览:\n${response.data.toString().substring(0, 100)}...";
      });
    } on DioException catch (e) {
      setState(() {
        _responseLog = "请求发生错误: ${e.type}\n错误信息: ${e.message}";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 62: 网络日志美化'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pretty Dio Logger 拦截器演示',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '请打开 IDE 的控制台/Run 窗口，点击下方按钮发起请求，您将看到排版精美的 HTTP 请求与响应日志，而不仅仅是下面 UI 里的简陋内容。',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('发起成功的请求 (GET /users)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isLoading ? null : () => _fetchData('/users/1'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.error_outline),
              label: const Text('发起报错的请求 (GET /404)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isLoading ? null : () => _fetchData('/not-found-endpoint'),
            ),
            const SizedBox(height: 32),
            const Text(
              'UI 数据回显 (用于对比)：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _responseLog,
                    style: const TextStyle(fontFamily: 'monospace', height: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
