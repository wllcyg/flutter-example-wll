// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_item_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostItemFreezed _$PostItemFreezedFromJson(Map<String, dynamic> json) =>
    _PostItemFreezed(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PostItemFreezedToJson(_PostItemFreezed instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'avatar': instance.avatar,
      'created_at': instance.createdAt?.toIso8601String(),
      'likes': instance.likes,
    };
