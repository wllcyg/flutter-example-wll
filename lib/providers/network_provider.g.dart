// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$networkStatusHash() => r'624e350889b2cc78f85dcbd5110c39b58cf9e690';

/// 1. 监听全局网络连接状态的 Stream
///
/// Copied from [networkStatus].
@ProviderFor(networkStatus)
final networkStatusProvider = StreamProvider<List<ConnectivityResult>>.internal(
  networkStatus,
  name: r'networkStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$networkStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NetworkStatusRef = StreamProviderRef<List<ConnectivityResult>>;
String _$isOfflineHash() => r'61d8a519af4aff85c93d138c510c8c7a2ff30501';

/// 2. 衍生的状态：判断当前是否离线
///
/// Copied from [isOffline].
@ProviderFor(isOffline)
final isOfflineProvider = Provider<bool>.internal(
  isOffline,
  name: r'isOfflineProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isOfflineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsOfflineRef = ProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
