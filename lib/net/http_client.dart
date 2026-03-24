import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Dio HTTP 客户端封装
/// 单例模式，统一配置拦截器、超时、BaseUrl
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;

  late final Dio dio;

  HttpClient._internal() {
    dio = Dio(BaseOptions(
      // TODO: 替换为你的实际 API 地址
      baseUrl: 'https://your-api.com/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    // 添加日志拦截器 (仅在 Debug 模式)
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ));
    }

    // 添加 Token 拦截器
    dio.interceptors.add(_AuthInterceptor());
  }

  /// 更新 BaseUrl (用于切换环境)
  void updateBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }
}

/// Token 拦截器：自动添加 Authorization Header
class _AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 从安全存储读取 Token
    final token = await _storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token 过期处理
      debugPrint('HttpClient: Token expired (401), should redirect to login');
      // TODO: 可以在这里触发全局登出逻辑
    }
    handler.next(err);
  }
}
