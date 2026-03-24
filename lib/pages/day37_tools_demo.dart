import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'dart:async';
import '../../gen/assets.gen.dart';

class Day37ToolsDemo extends ConsumerStatefulWidget {
  const Day37ToolsDemo({super.key});

  @override
  ConsumerState<Day37ToolsDemo> createState() => _Day37ToolsDemoState();
}

class _Day37ToolsDemoState extends ConsumerState<Day37ToolsDemo> {
  // Connectivity
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();

  // Device Info
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _initDeviceInfo();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      result = [ConnectivityResult.none];
    }
    if (!mounted) {
      return;
    }
    return _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _connectionStatus = result;
    });
  }

  Future<void> _initDeviceInfo() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await _deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await _deviceInfoPlugin.iosInfo);
      }
    } catch (e) {
      deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'OS Version': build.version.release,
      'SDK Int': build.version.sdkInt,
      'Brand': build.brand,
      'Device': build.device,
      'Model': build.model,
      'Product': build.product,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'OS Name': data.systemName,
      'OS Version': data.systemVersion,
      'Model': data.model,
      'Name': data.name,
      'Identifier': data.identifierForVendor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 37: 普通工具包 (一)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. SVG
            _buildSection(
              title: "1. SVG 矢量图",
              child: Column(
                children: [
                  const Text('使用 flutter_svg 加载矢量图不会失真：', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          SvgPicture.asset(
                            Assets.svgs.sampleIcon.path,
                            width: 64,
                            height: 64,
                            colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                          ),
                          const SizedBox(height: 8),
                          const Text('主题色'),
                        ],
                      ),
                      Column(
                        children: [
                          SvgPicture.asset(
                            Assets.svgs.sampleIcon.path,
                            width: 64,
                            height: 64,
                            colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                          ),
                          const SizedBox(height: 8),
                          const Text('红色'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Connectivity
            _buildSection(
              title: "2. 网络连接状态",
              child: Column(
                children: [
                  const Text('实时监听设备的网络连接类型：', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Text(
                    '当前状态: ${_connectionStatus.map((e) => e.name).join(', ')}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    _getNetworkIcon(),
                    size: 48,
                    color: _connectionStatus.contains(ConnectivityResult.none) ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Device Info
            _buildSection(
              title: "3. 设备信息",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('获取当前设备的型号、系统版本等信息：', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ..._deviceData.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(e.value.toString()),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNetworkIcon() {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) return Icons.wifi;
    if (_connectionStatus.contains(ConnectivityResult.mobile)) return Icons.signal_cellular_4_bar;
    if (_connectionStatus.contains(ConnectivityResult.ethernet)) return Icons.settings_ethernet;
    if (_connectionStatus.contains(ConnectivityResult.none)) return Icons.signal_wifi_off;
    return Icons.device_unknown;
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
