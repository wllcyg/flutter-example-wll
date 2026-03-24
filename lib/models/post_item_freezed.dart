import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_item_freezed.freezed.dart';
part 'post_item_freezed.g.dart';

/// Day 31 示例：用 freezed 改写 PostItem
///
/// 对比原始版本 `post_item.dart`（手写 class），
/// freezed 版本自动获得 copyWith / toJson / fromJson / == / hashCode。
@freezed
abstract class PostItemFreezed with _$PostItemFreezed {
  const factory PostItemFreezed({
    required int id,
    required String title,
    @Default('') String subtitle,
    @Default('') String avatar,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @Default(0) int likes,
  }) = _PostItemFreezed;

  factory PostItemFreezed.fromJson(Map<String, dynamic> json) =>
      _$PostItemFreezedFromJson(json);
}

/// Day 31 示例：freezed 的联合类型 (Union Types / Sealed Class)
///
/// 对标前端 TypeScript 的 discriminated union：
/// type Result = { type: 'loading' } | { type: 'success', data: T } | { type: 'error', message: string }
@freezed
sealed class DataResult<T> with _$DataResult<T> {
  const factory DataResult.loading() = DataLoading;
  const factory DataResult.success(T data) = DataSuccess;
  const factory DataResult.error(String message) = DataError;
}
