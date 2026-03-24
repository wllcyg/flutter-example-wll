// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_item_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostItemFreezed {
  int get id;
  String get title;
  String get subtitle;
  String get avatar;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  int get likes;

  /// Create a copy of PostItemFreezed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PostItemFreezedCopyWith<PostItemFreezed> get copyWith =>
      _$PostItemFreezedCopyWithImpl<PostItemFreezed>(
          this as PostItemFreezed, _$identity);

  /// Serializes this PostItemFreezed to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PostItemFreezed &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.likes, likes) || other.likes == likes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, subtitle, avatar, createdAt, likes);

  @override
  String toString() {
    return 'PostItemFreezed(id: $id, title: $title, subtitle: $subtitle, avatar: $avatar, createdAt: $createdAt, likes: $likes)';
  }
}

/// @nodoc
abstract mixin class $PostItemFreezedCopyWith<$Res> {
  factory $PostItemFreezedCopyWith(
          PostItemFreezed value, $Res Function(PostItemFreezed) _then) =
      _$PostItemFreezedCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String title,
      String subtitle,
      String avatar,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      int likes});
}

/// @nodoc
class _$PostItemFreezedCopyWithImpl<$Res>
    implements $PostItemFreezedCopyWith<$Res> {
  _$PostItemFreezedCopyWithImpl(this._self, this._then);

  final PostItemFreezed _self;
  final $Res Function(PostItemFreezed) _then;

  /// Create a copy of PostItemFreezed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? avatar = null,
    Object? createdAt = freezed,
    Object? likes = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: null == subtitle
          ? _self.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _self.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      likes: null == likes
          ? _self.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [PostItemFreezed].
extension PostItemFreezedPatterns on PostItemFreezed {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PostItemFreezed value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostItemFreezed() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PostItemFreezed value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostItemFreezed():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PostItemFreezed value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostItemFreezed() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int id, String title, String subtitle, String avatar,
            @JsonKey(name: 'created_at') DateTime? createdAt, int likes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostItemFreezed() when $default != null:
        return $default(_that.id, _that.title, _that.subtitle, _that.avatar,
            _that.createdAt, _that.likes);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int id, String title, String subtitle, String avatar,
            @JsonKey(name: 'created_at') DateTime? createdAt, int likes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostItemFreezed():
        return $default(_that.id, _that.title, _that.subtitle, _that.avatar,
            _that.createdAt, _that.likes);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int id, String title, String subtitle, String avatar,
            @JsonKey(name: 'created_at') DateTime? createdAt, int likes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostItemFreezed() when $default != null:
        return $default(_that.id, _that.title, _that.subtitle, _that.avatar,
            _that.createdAt, _that.likes);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PostItemFreezed implements PostItemFreezed {
  const _PostItemFreezed(
      {required this.id,
      required this.title,
      this.subtitle = '',
      this.avatar = '',
      @JsonKey(name: 'created_at') this.createdAt,
      this.likes = 0});
  factory _PostItemFreezed.fromJson(Map<String, dynamic> json) =>
      _$PostItemFreezedFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  @JsonKey()
  final String subtitle;
  @override
  @JsonKey()
  final String avatar;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey()
  final int likes;

  /// Create a copy of PostItemFreezed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PostItemFreezedCopyWith<_PostItemFreezed> get copyWith =>
      __$PostItemFreezedCopyWithImpl<_PostItemFreezed>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PostItemFreezedToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PostItemFreezed &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.likes, likes) || other.likes == likes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, subtitle, avatar, createdAt, likes);

  @override
  String toString() {
    return 'PostItemFreezed(id: $id, title: $title, subtitle: $subtitle, avatar: $avatar, createdAt: $createdAt, likes: $likes)';
  }
}

/// @nodoc
abstract mixin class _$PostItemFreezedCopyWith<$Res>
    implements $PostItemFreezedCopyWith<$Res> {
  factory _$PostItemFreezedCopyWith(
          _PostItemFreezed value, $Res Function(_PostItemFreezed) _then) =
      __$PostItemFreezedCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String subtitle,
      String avatar,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      int likes});
}

/// @nodoc
class __$PostItemFreezedCopyWithImpl<$Res>
    implements _$PostItemFreezedCopyWith<$Res> {
  __$PostItemFreezedCopyWithImpl(this._self, this._then);

  final _PostItemFreezed _self;
  final $Res Function(_PostItemFreezed) _then;

  /// Create a copy of PostItemFreezed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? avatar = null,
    Object? createdAt = freezed,
    Object? likes = null,
  }) {
    return _then(_PostItemFreezed(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: null == subtitle
          ? _self.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _self.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      likes: null == likes
          ? _self.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$DataResult<T> {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is DataResult<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'DataResult<$T>()';
  }
}

/// @nodoc
class $DataResultCopyWith<T, $Res> {
  $DataResultCopyWith(DataResult<T> _, $Res Function(DataResult<T>) __);
}

/// Adds pattern-matching-related methods to [DataResult].
extension DataResultPatterns<T> on DataResult<T> {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataLoading<T> value)? loading,
    TResult Function(DataSuccess<T> value)? success,
    TResult Function(DataError<T> value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case DataLoading() when loading != null:
        return loading(_that);
      case DataSuccess() when success != null:
        return success(_that);
      case DataError() when error != null:
        return error(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataLoading<T> value) loading,
    required TResult Function(DataSuccess<T> value) success,
    required TResult Function(DataError<T> value) error,
  }) {
    final _that = this;
    switch (_that) {
      case DataLoading():
        return loading(_that);
      case DataSuccess():
        return success(_that);
      case DataError():
        return error(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataLoading<T> value)? loading,
    TResult? Function(DataSuccess<T> value)? success,
    TResult? Function(DataError<T> value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case DataLoading() when loading != null:
        return loading(_that);
      case DataSuccess() when success != null:
        return success(_that);
      case DataError() when error != null:
        return error(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(T data)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case DataLoading() when loading != null:
        return loading();
      case DataSuccess() when success != null:
        return success(_that.data);
      case DataError() when error != null:
        return error(_that.message);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(T data) success,
    required TResult Function(String message) error,
  }) {
    final _that = this;
    switch (_that) {
      case DataLoading():
        return loading();
      case DataSuccess():
        return success(_that.data);
      case DataError():
        return error(_that.message);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(T data)? success,
    TResult? Function(String message)? error,
  }) {
    final _that = this;
    switch (_that) {
      case DataLoading() when loading != null:
        return loading();
      case DataSuccess() when success != null:
        return success(_that.data);
      case DataError() when error != null:
        return error(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class DataLoading<T> implements DataResult<T> {
  const DataLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is DataLoading<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'DataResult<$T>.loading()';
  }
}

/// @nodoc

class DataSuccess<T> implements DataResult<T> {
  const DataSuccess(this.data);

  final T data;

  /// Create a copy of DataResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DataSuccessCopyWith<T, DataSuccess<T>> get copyWith =>
      _$DataSuccessCopyWithImpl<T, DataSuccess<T>>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DataSuccess<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'DataResult<$T>.success(data: $data)';
  }
}

/// @nodoc
abstract mixin class $DataSuccessCopyWith<T, $Res>
    implements $DataResultCopyWith<T, $Res> {
  factory $DataSuccessCopyWith(
          DataSuccess<T> value, $Res Function(DataSuccess<T>) _then) =
      _$DataSuccessCopyWithImpl;
  @useResult
  $Res call({T data});
}

/// @nodoc
class _$DataSuccessCopyWithImpl<T, $Res>
    implements $DataSuccessCopyWith<T, $Res> {
  _$DataSuccessCopyWithImpl(this._self, this._then);

  final DataSuccess<T> _self;
  final $Res Function(DataSuccess<T>) _then;

  /// Create a copy of DataResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = freezed,
  }) {
    return _then(DataSuccess<T>(
      freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class DataError<T> implements DataResult<T> {
  const DataError(this.message);

  final String message;

  /// Create a copy of DataResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DataErrorCopyWith<T, DataError<T>> get copyWith =>
      _$DataErrorCopyWithImpl<T, DataError<T>>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DataError<T> &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'DataResult<$T>.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class $DataErrorCopyWith<T, $Res>
    implements $DataResultCopyWith<T, $Res> {
  factory $DataErrorCopyWith(
          DataError<T> value, $Res Function(DataError<T>) _then) =
      _$DataErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$DataErrorCopyWithImpl<T, $Res> implements $DataErrorCopyWith<T, $Res> {
  _$DataErrorCopyWithImpl(this._self, this._then);

  final DataError<T> _self;
  final $Res Function(DataError<T>) _then;

  /// Create a copy of DataResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(DataError<T>(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
