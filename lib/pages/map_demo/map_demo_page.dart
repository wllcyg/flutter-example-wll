import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapDemoPage extends StatefulWidget {
  const MapDemoPage({super.key});

  @override
  State<MapDemoPage> createState() => _MapDemoPageState();
}

class _MapDemoPageState extends State<MapDemoPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Map 示例'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(39.9042, 116.4074), // 北京
          initialZoom: 13.0,
          maxZoom: 19.0,
          minZoom: 3.0,
        ),
        children: [
          TileLayer(
            // 高德地图免费公开瓦片
            urlTemplate:
                'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
            userAgentPackageName: 'com.example.my_flutter_app',
            maxZoom: 19,
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(39.9042, 116.4074), // 北京
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('这是北京！')),
                    );
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
              Marker(
                point: const LatLng(31.2304, 121.4737), // 上海
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('这是上海！')),
                    );
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: const [
                  LatLng(39.9042, 116.4074), // 北京
                  LatLng(36.6512, 117.1201), // 济南
                  LatLng(34.2631, 117.1850), // 徐州
                  LatLng(32.0603, 118.7969), // 南京
                  LatLng(31.2304, 121.4737), // 上海
                ],
                color: Colors.blue,
                strokeWidth: 4.0,
              ),
            ],
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                '高德地图',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 移动到上海
          _mapController.move(const LatLng(31.2304, 121.4737), 13.0);
        },
        child: const Icon(Icons.location_city),
      ),
    );
  }
}
