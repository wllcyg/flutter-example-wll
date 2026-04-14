import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/providers/network_provider.dart';

class Day57ConnectivityPlusDemo extends ConsumerWidget {
  const Day57ConnectivityPlusDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听全局离线状态
    final isOffline = ref.watch(isOfflineProvider);
    // 监听完整网络状态流数据
    final networkStatusAsyncValue = ref.watch(networkStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 57: 全局网络状态监测'),
      ),
      body: Column(
        children: [
          // ==============================
          // 4. 离线提示 UI：顶部横幅提示
          // ==============================
          if (isOffline)
            Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '网络已断开，请检查网络设置',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

          Expanded(
            child: Center(
              child: networkStatusAsyncValue.when(
                data: (results) {
                  // ==============================
                  // 1 & 2. 获取连接类型并展示
                  // ==============================
                  final connectionNames =
                      results.map((e) => e.name.toUpperCase()).join(', ');

                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isOffline ? Icons.signal_wifi_off : Icons.wifi,
                          size: 80,
                          color: isOffline ? Colors.red : Colors.green,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isOffline ? '当前处于离线状态' : '网络连接正常',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '当前连接类型: $connectionNames',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 40),
                        
                        // ==============================
                        // 6. 实战场景：离线模式切换体验
                        // ==============================
                        ElevatedButton.icon(
                          onPressed: () {
                            // 模拟如果离线时拒绝操作
                            if (isOffline) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('离线模式下无法获取最新数据！'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('正在获取云端最新数据...'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.cloud_sync),
                          label: const Text('模拟网络请求'),
                        )
                      ],
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, _) => Text('发生错误: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
