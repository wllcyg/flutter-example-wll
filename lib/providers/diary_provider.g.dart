// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diaryDetailHash() => r'18b68803771dfde73de6c959a07f8eca885107f3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 单条日记详情 Provider
///
/// Copied from [diaryDetail].
@ProviderFor(diaryDetail)
const diaryDetailProvider = DiaryDetailFamily();

/// 单条日记详情 Provider
///
/// Copied from [diaryDetail].
class DiaryDetailFamily extends Family<AsyncValue<DiaryEntry?>> {
  /// 单条日记详情 Provider
  ///
  /// Copied from [diaryDetail].
  const DiaryDetailFamily();

  /// 单条日记详情 Provider
  ///
  /// Copied from [diaryDetail].
  DiaryDetailProvider call(
    String id,
  ) {
    return DiaryDetailProvider(
      id,
    );
  }

  @override
  DiaryDetailProvider getProviderOverride(
    covariant DiaryDetailProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'diaryDetailProvider';
}

/// 单条日记详情 Provider
///
/// Copied from [diaryDetail].
class DiaryDetailProvider extends AutoDisposeFutureProvider<DiaryEntry?> {
  /// 单条日记详情 Provider
  ///
  /// Copied from [diaryDetail].
  DiaryDetailProvider(
    String id,
  ) : this._internal(
          (ref) => diaryDetail(
            ref as DiaryDetailRef,
            id,
          ),
          from: diaryDetailProvider,
          name: r'diaryDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$diaryDetailHash,
          dependencies: DiaryDetailFamily._dependencies,
          allTransitiveDependencies:
              DiaryDetailFamily._allTransitiveDependencies,
          id: id,
        );

  DiaryDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<DiaryEntry?> Function(DiaryDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DiaryDetailProvider._internal(
        (ref) => create(ref as DiaryDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DiaryEntry?> createElement() {
    return _DiaryDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DiaryDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DiaryDetailRef on AutoDisposeFutureProviderRef<DiaryEntry?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _DiaryDetailProviderElement
    extends AutoDisposeFutureProviderElement<DiaryEntry?> with DiaryDetailRef {
  _DiaryDetailProviderElement(super.provider);

  @override
  String get id => (origin as DiaryDetailProvider).id;
}

String _$diaryListHash() => r'ab482decfd15c6e76423061e1ed690abc8ed6b7f';

/// 日记列表 Provider (重构后)
/// 现在通过 Repository 获取数据，不再直接依赖 Supabase
///
/// Copied from [DiaryList].
@ProviderFor(DiaryList)
final diaryListProvider =
    AutoDisposeAsyncNotifierProvider<DiaryList, List<DiaryEntry>>.internal(
  DiaryList.new,
  name: r'diaryListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$diaryListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DiaryList = AutoDisposeAsyncNotifier<List<DiaryEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
