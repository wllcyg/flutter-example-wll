import 'package:freezed_annotation/freezed_annotation.dart';

// 必须引入这两个 part 文件，build_runner 会自动生成它们
part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Day 31 示例：使用 freezed 定义不可变数据类
///
/// 对标前端：TypeScript 的 interface + 自动序列化
/// freezed 会自动生成：
///   - copyWith() 不可变更新
///   - toString() 可读输出
///   - == / hashCode 值相等比较
///   - toJson() / fromJson() JSON 序列化
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String nickname,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @Default('') String bio,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
