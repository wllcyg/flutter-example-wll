import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeepLinkMapDemoPage extends StatelessWidget {
  const DeepLinkMapDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地图唤起演示 (Deep Link)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.navigation, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              '点击下方按钮选择地图应用导航到天安门',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const NavigateButton(),
          ],
        ),
      ),
    );
  }
}

class MapUtils {
  static Future<bool> openAMap(double lat, double lon, String title) async {
    final url = 'iosamap://path?sourceApplication=MyApp&dlat=$lat&dlon=$lon&dname=$title&dev=0&t=0';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  static Future<bool> openBaiduMap(double lat, double lon, String title) async {
    final url = 'baidumap://map/direction?destination=name:$title|latlng:$lat,$lon&coord_type=gcj02&mode=driving&src=MyApp';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  static Future<bool> openTencentMap(double lat, double lon, String title) async {
    final url = 'qqmap://map/routeplan?type=drive&to=$title&tocoord=$lat,$lon&referer=MyApp';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  static Future<bool> openAppleMap(double lat, double lon, String title) async {
    if (!Platform.isIOS) return false;
    // 使用 maps:// scheme 可以确保唤起自带地图而不是浏览器
    final url = 'maps://?daddr=$lat,$lon&dirflg=d';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}

class NavigateButton extends StatelessWidget {
  final double latitude = 39.9042; 
  final double longitude = 116.4074; 
  final String destName = '天安门广场';

  const NavigateButton({super.key});

  void _showMapSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('选择导航方式', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.blue),
                title: const Text('高德地图'),
                onTap: () async {
                  final success = await MapUtils.openAMap(latitude, longitude, destName);
                  if (!success) _showError(context, '未安装高德地图');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.blueAccent),
                title: const Text('百度地图'),
                onTap: () async {
                  final success = await MapUtils.openBaiduMap(latitude, longitude, destName);
                  if (!success) _showError(context, '未安装百度地图');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.green),
                title: const Text('腾讯地图'),
                onTap: () async {
                  final success = await MapUtils.openTencentMap(latitude, longitude, destName);
                  if (!success) _showError(context, '未安装腾讯地图');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              if (Platform.isIOS) 
                ListTile(
                  leading: const Icon(Icons.apple, color: Colors.black),
                  title: const Text('Apple Maps'),
                  onTap: () async {
                    await MapUtils.openAppleMap(latitude, longitude, destName);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showMapSelection(context),
      icon: const Icon(Icons.navigation),
      label: const Text('导航到目的地'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
