import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// ============================================================
/// Day 50: 路径管理——path_provider
///
/// 技术要点：
///   1. path_provider 核心功能 — 获取系统目录路径
///   2. 目录类型详解 — 临时目录 / 文档目录 / 外部存储 等
///   3. 平台差异 — iOS / Android 目录结构对比含义
///   4. 文件操作 — 结合 dart:io 读写文件
///   5. 实战：文件缓存管理 — 计算总缓存大小 + 一键清理
///   6. 实战场景 — 下载文件保存、日志文件、离线数据
/// ============================================================

class Day50PathProviderDemo extends StatefulWidget {
  const Day50PathProviderDemo({super.key});

  @override
  State<Day50PathProviderDemo> createState() => _Day50PathProviderDemoState();
}

class _Day50PathProviderDemoState extends State<Day50PathProviderDemo> {
  String _tempPath = 'Loading...';
  String _docPath = 'Loading...';
  String _supportPath = 'Loading...';
  String _cacheSizeStr = '0 B';

  String _demoFileContent = '';
  late File _demoFile;

  @override
  void initState() {
    super.initState();
    _initPaths();
  }

  Future<void> _initPaths() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final docDir = await getApplicationDocumentsDirectory();
      final supportDir = await getApplicationSupportDirectory();

      setState(() {
        _tempPath = tempDir.path;
        _docPath = docDir.path;
        _supportPath = supportDir.path;
      });

      // 初始化一个供读写测试的文件
      _demoFile = File('${docDir.path}/day50_demo.txt');
      if (await _demoFile.exists()) {
        _demoFileContent = await _demoFile.readAsString();
      }

      await _calculateCacheSize(tempDir);

    } catch (e) {
       _showMsg('获取路径失败: $e');
    }
  }

  Future<void> _writeToDemoFile() async {
    final now = DateTime.now().toString().split('.')[0];
    await _demoFile.writeAsString('最后保存于: $now\n', mode: FileMode.append);
    setState(() {
      _demoFileContent = _demoFile.readAsStringSync();
    });
    _showMsg('已成功写入 Document 目录');
  }

  Future<void> _clearDemoFile() async {
    if (await _demoFile.exists()) {
      await _demoFile.delete();
      setState(() {
         _demoFileContent = '';
      });
      _showMsg('文件已删除');
    }
  }

  Future<void> _calculateCacheSize(Directory tempDir) async {
    int totalBytes = 0;
    try {
      if (tempDir.existsSync()) {
        tempDir.listSync(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
          if (entity is File) {
            totalBytes += entity.lengthSync();
          }
        });
      }
    } catch (_) {}
    
    setState(() {
       _cacheSizeStr = _formatSize(totalBytes);
    });
  }

  Future<void> _clearCache() async {
    final tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      tempDir.listSync().forEach((entity) {
        try {
          entity.deleteSync(recursive: true);
        } catch (_) {}
      });
    }
    await _calculateCacheSize(tempDir);
    _showMsg('缓存已清理完毕');
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 50: 路径与文件系统'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SectionCard(
               title: '1. 核心系统目录映射',
               icon: Icons.folder,
               color: const Color(0xFF2196F3),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    _PathRow(name: 'Temporary 目录', desc: '可随时被系统清理，适合放下载的临时文件 (iOS: NSTemporaryDirectory)', path: _tempPath),
                    _PathRow(name: 'Documents 目录', desc: '用户数据，不会被清理，会被系统备份 (iOS: NSDocumentDirectory)', path: _docPath),
                    _PathRow(name: 'Support 目录', desc: 'App 隐蔽数据文件，不应对用户公开 (iOS: Application Support)', path: _supportPath),
                 ],
               )
            ),
            const SizedBox(height: 16),
            
            _SectionCard(
              title: '2. dart:io 本地文件读写',
              icon: Icons.edit_document,
              color: const Color(0xFF4CAF50),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.drive_file_rename_outline),
                        label: const Text('写入数据'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2), foregroundColor: const Color(0xFF4CAF50)),
                        onPressed: _writeToDemoFile,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('删除文件'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.2), foregroundColor: Colors.red),
                        onPressed: _clearDemoFile,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      _demoFileContent.isEmpty ? '<暂无内容>' : _demoFileContent,
                      style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, fontFamily: 'monospace'),
                    ),
                  )
                ],
              )
            ),
            const SizedBox(height: 16),
            
            _SectionCard(
              title: '3. 缓存管理实战',
              icon: Icons.cleaning_services,
              color: const Color(0xFFFF9800),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         const Text('当前临时缓存占用:', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
                         const SizedBox(height: 4),
                         Text(_cacheSizeStr, style: const TextStyle(color: Color(0xFFFF9800), fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _clearCache,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800).withOpacity(0.2), 
                      foregroundColor: const Color(0xFFFF9800),
                      elevation: 0,
                    ),
                    child: const Text('一键清扫'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Sub Widgets ====================

class _PathRow extends StatelessWidget {
  final String name;
  final String desc;
  final String path;

  const _PathRow({required this.name, required this.desc, required this.path});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11, height: 1.3)),
          const SizedBox(height: 6),
          Container(
             width: double.infinity,
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
             child: Text(path, style: const TextStyle(color: Color(0xFF2196F3), fontSize: 11, fontFamily: 'monospace')),
          )
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}
