/// 统一 API 响应包装
/// 适用于后端返回 { "code": 0, "msg": "success", "data": {...} } 格式
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  /// 判断请求是否成功 (code == 0)
  bool get isSuccess => code == 0;

  /// 从 JSON 解析
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      code: json['code'] as int? ?? -1,
      message: json['msg'] as String? ?? 'Unknown error',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  /// 无数据类型的简化解析
  factory ApiResponse.fromJsonSimple(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'] as int? ?? -1,
      message: json['msg'] as String? ?? 'Unknown error',
      data: json['data'] as T?,
    );
  }

  @override
  String toString() =>
      'ApiResponse(code: $code, message: $message, data: $data)';
}
