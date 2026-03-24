/// 简单的 Result 类型 (成功或失败)
/// 使用 Dart 3 的 sealed class 特性，支持模式匹配
sealed class Result<T> {
  const Result();

  /// 便捷方法：判断是否成功
  bool get isSuccess => this is Success<T>;

  /// 便捷方法：判断是否失败
  bool get isFailure => this is Failure<T>;

  /// 获取数据 (失败时返回 null)
  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Failure() => null,
      };

  /// 获取错误信息 (成功时返回 null)
  String? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final message) => message,
      };

  /// 模式匹配处理
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? code) failure,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      Failure(:final message, :final code) => failure(message, code),
    };
  }
}

/// 成功结果
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  String toString() => 'Success($data)';
}

/// 失败结果
class Failure<T> extends Result<T> {
  final String message;
  final int? code;
  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}
