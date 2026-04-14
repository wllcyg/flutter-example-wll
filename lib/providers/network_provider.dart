import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_provider.g.dart';

/// 1. 监听全局网络连接状态的 Stream
@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> networkStatus(NetworkStatusRef ref) {
  return Connectivity().onConnectivityChanged;
}

/// 2. 衍生的状态：判断当前是否离线
@Riverpod(keepAlive: true)
bool isOffline(IsOfflineRef ref) {
  final statusAsyncValue = ref.watch(networkStatusProvider);
  return statusAsyncValue.when(
    data: (results) => results.contains(ConnectivityResult.none),
    loading: () => false,
    error: (_, __) => false,
  );
}
