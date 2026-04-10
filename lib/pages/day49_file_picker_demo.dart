import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// ============================================================
/// Day 49: 文件选择——file_picker
///
/// 技术要点：
///   1. file_picker 核心用法 — 选择任意类型文件（PDF / Word / Excel / ZIP）
///   2. 文件类型过滤 — allowedExtensions 限制可选格式
///   3. 单文件 vs 多文件 — allowMultiple 批量上传
///   4. 获取文件信息 — 文件名、大小、路径、字节流
///   5. 权限处理 — 存储权限申请（Android）
///   6. 实战场景 — 上传附件、导入数据、选择头像
/// ============================================================

class Day49FilePickerDemo extends StatefulWidget {
  const Day49FilePickerDemo({super.key});

  @override
  State<Day49FilePickerDemo> createState() => _Day49FilePickerDemoState();
}

class _Day49FilePickerDemoState extends State<Day49FilePickerDemo> {
  List<PlatformFile> _pickedFiles = [];
  bool _isLoading = false;

  void _pickSingleFile() async {
    _startLoading();
    try {
      FilePickerResult? result = await FilePicker.pickFiles();
      if (result != null) {
        setState(() => _pickedFiles = result.files);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      _stopLoading();
    }
  }

  void _pickMultipleFiles() async {
    _startLoading();
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
      );
      if (result != null) {
        setState(() => _pickedFiles = result.files);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      _stopLoading();
    }
  }

  void _pickFilteredFiles() async {
    _startLoading();
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
      );
      if (result != null) {
        setState(() => _pickedFiles = result.files);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      _stopLoading();
    }
  }

  void _pickMediaOnly() async {
    // 自动请求权限的过程通常由 file_picker 内部或前置完成
    // iOS 不需要显式请求读，但 Android 可根据版本补充申请 storage
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }
    
    _startLoading();
    try {
      FilePickerResult? result = await FilePicker.pickFiles(type: FileType.media);
      if (result != null) {
        setState(() => _pickedFiles = result.files);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      _stopLoading();
    }
  }

  void _startLoading() => setState(() => _isLoading = true);
  void _stopLoading() => setState(() => _isLoading = false);

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg')));
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 49: 选择提取文件'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SectionCard(
              title: '1. 文件选择动作面板',
              icon: Icons.upload_file,
              color: const Color(0xFF7C4DFF),
              child: Column(
                children: [
                   _ActionButton(icon: Icons.insert_drive_file, label: '单选任意文件', onTap: _pickSingleFile, color: const Color(0xFF7C4DFF)),
                   const SizedBox(height: 10),
                   _ActionButton(icon: Icons.file_copy, label: '多文件批量选择', onTap: _pickMultipleFiles, color: const Color(0xFF2196F3)),
                   const SizedBox(height: 10),
                   _ActionButton(icon: Icons.filter_alt, label: '过滤格式 (PDF/Word/ZIP)', onTap: _pickFilteredFiles, color: const Color(0xFFFF9800)),
                   const SizedBox(height: 10),
                   _ActionButton(icon: Icons.image, label: '纯媒体文件 (相册/视频)', onTap: _pickMediaOnly, color: const Color(0xFFE91E63)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            _SectionCard(
              title: '2. 获取到的文件信息',
              icon: Icons.info_outline,
              color: const Color(0xFF4CAF50),
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
                  : _pickedFiles.isEmpty
                      ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('尚未选择文件', style: TextStyle(color: Color(0xFF9E9E9E)))))
                      : Column(
                          children: _pickedFiles.map((file) => _FileItemCard(
                            name: file.name,
                            size: _formatSize(file.size),
                            ext: file.extension ?? '未知',
                            path: file.path ?? '路径不可用',
                          )).toList(),
                        )
            ),
            const SizedBox(height: 16),
            const _SectionCard(
               title: '3. 实战场景',
               icon: Icons.cases_outlined,
               color: Color(0xFF00BCD4),
               child: Column(
                 children: [
                   _PracticeCard(title: '📤 OA系统发公告附件', desc: '利用 allowMultiple 配合 allowedExtensions，精准让员工一次性选中多篇 Word 或 PDF 报告一键上传，并在发请求前获取 file.size 拦截超大文件。'),
                   SizedBox(height: 10),
                   _PracticeCard(title: '📁 本地备份还原', desc: '如果你的笔记 App 支持离线导出成 .zip 备份，那通过 file_picker 取到导入的文件路径后解压，是极其常规的离线闭环打法。'),
                 ],
               )
            )
          ],
        ),
      ),
    );
  }
}

// ==================== Shared / Sub Widgets ====================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.15),
          foregroundColor: color,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _FileItemCard extends StatelessWidget {
  final String name;
  final String size;
  final String ext;
  final String path;

  const _FileItemCard({required this.name, required this.size, required this.ext, required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: const Color(0xFF4CAF50), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('$size  •  .$ext', style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 8),
          Text(path, style: const TextStyle(color: Color(0xFF6C7B95), fontSize: 10, fontFamily: 'monospace'), maxLines: 2, overflow: TextOverflow.ellipsis)
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

class _PracticeCard extends StatelessWidget {
  final String title;
  final String desc;

  const _PracticeCard({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}
