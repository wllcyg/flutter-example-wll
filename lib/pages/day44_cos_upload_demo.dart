import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../services/cos_service.dart';

/// ============================================================
/// Day 44: 腾讯云 COS 图片上传实战
///
/// 完整流程：选图 → 压缩 → STS 临时授权 → 上传 COS → 进度监听
///
/// 技术要点：
///   1. STS 临时密钥：服务端签发，避免客户端暴露永久密钥
///   2. COS XML API：HMAC-SHA1 签名 + PUT Object
///   3. 上传进度：Dio onSendProgress 实现实时进度条
///   4. 图片压缩：复用 Day 21 的 flutter_image_compress
/// ============================================================

// ==================== Constants ====================

/// ⚠️ 请确认你的存储桶名称（格式如 my-bucket-1258475753）
const _kStsUrl =
    'https://1258475753-fq2a4nc48v.ap-guangzhou.tencentscf.com/token';
const _kBucket = 'wll-1258475753'; // 实际存储桶名称
const _kRegion = 'ap-guangzhou';
const _kPrefix = 'editor-images'; // 上传目录前缀

// ==================== State ====================

/// 上传状态
enum UploadStatus { idle, picking, compressing, uploading, success, error }

class UploadState {
  final UploadStatus status;
  final File? localFile;
  final double progress; // 0.0 ~ 1.0
  final String? remoteUrl;
  final String? errorMessage;
  final int? originalSize; // 原始文件大小 (bytes)
  final int? compressedSize; // 压缩后大小 (bytes)

  const UploadState({
    this.status = UploadStatus.idle,
    this.localFile,
    this.progress = 0.0,
    this.remoteUrl,
    this.errorMessage,
    this.originalSize,
    this.compressedSize,
  });

  UploadState copyWith({
    UploadStatus? status,
    File? localFile,
    double? progress,
    String? remoteUrl,
    String? errorMessage,
    int? originalSize,
    int? compressedSize,
  }) {
    return UploadState(
      status: status ?? this.status,
      localFile: localFile ?? this.localFile,
      progress: progress ?? this.progress,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      originalSize: originalSize ?? this.originalSize,
      compressedSize: compressedSize ?? this.compressedSize,
    );
  }

  String get statusText {
    switch (status) {
      case UploadStatus.idle:
        return '等待选择图片';
      case UploadStatus.picking:
        return '正在选择图片...';
      case UploadStatus.compressing:
        return '正在压缩图片...';
      case UploadStatus.uploading:
        return '正在上传 ${(progress * 100).toStringAsFixed(0)}%';
      case UploadStatus.success:
        return '上传成功 ✅';
      case UploadStatus.error:
        return '上传失败 ❌';
    }
  }
}

// ==================== Provider ====================

class UploadNotifier extends StateNotifier<UploadState> {
  final CosService _cosService;
  final ImagePicker _picker = ImagePicker();

  UploadNotifier(this._cosService) : super(const UploadState());

  /// 选图 → 压缩 → 上传全流程
  Future<void> pickAndUpload(ImageSource source) async {
    try {
      // 1. 选择图片
      state = state.copyWith(
        status: UploadStatus.picking,
        errorMessage: null,
        remoteUrl: null,
        progress: 0.0,
      );

      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (picked == null) {
        state = state.copyWith(status: UploadStatus.idle);
        return;
      }

      final originalFile = File(picked.path);
      final originalSize = await originalFile.length();

      state = state.copyWith(
        localFile: originalFile,
        originalSize: originalSize,
        status: UploadStatus.compressing,
      );

      // 2. 压缩图片
      final compressed = await _compressImage(originalFile);
      final compressedSize = await compressed.length();

      state = state.copyWith(
        localFile: compressed,
        compressedSize: compressedSize,
        status: UploadStatus.uploading,
        progress: 0.0,
      );

      // 3. 上传到 COS
      final result = await _cosService.uploadFile(
        file: compressed,
        cosPath: _generateCosPath(picked.name),
        onProgress: (sent, total) {
          if (total > 0) {
            state = state.copyWith(progress: sent / total);
          }
        },
      );

      if (result.success) {
        state = state.copyWith(
          status: UploadStatus.success,
          remoteUrl: result.url,
          progress: 1.0,
        );
      } else {
        state = state.copyWith(
          status: UploadStatus.error,
          errorMessage: result.errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: UploadStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 重置状态
  void reset() {
    state = const UploadState();
  }

  /// 压缩图片
  Future<File> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/cos_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 80,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    return result != null ? File(result.path) : file;
  }

  /// 生成 COS 存储路径
  String _generateCosPath(String fileName) {
    final now = DateTime.now();
    final datePath =
        '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
    final uniqueName =
        '${now.millisecondsSinceEpoch}_${fileName.hashCode.abs()}.jpg';
    return '$_kPrefix/$datePath/$uniqueName';
  }
}

/// COS Service Provider
final cosServiceProvider = Provider<CosService>((ref) {
  return CosService(
    stsUrl: _kStsUrl,
    bucket: _kBucket,
    region: _kRegion,
  );
});

/// Upload Notifier Provider
final uploadProvider =
    StateNotifierProvider.autoDispose<UploadNotifier, UploadState>((ref) {
  return UploadNotifier(ref.watch(cosServiceProvider));
});

// ==================== UI ====================

class Day44CosUploadDemo extends HookConsumerWidget {
  const Day44CosUploadDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadProvider);
    final animController =
        useAnimationController(duration: const Duration(milliseconds: 800));

    // 上传成功时触发动画
    useEffect(() {
      if (uploadState.status == UploadStatus.success) {
        animController.forward(from: 0.0);
      }
      return null;
    }, [uploadState.status]);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 44: COS 图片上传'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showTechDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 状态指示卡片
            _buildStatusCard(uploadState),
            const SizedBox(height: 24),

            // 图片预览区域
            _buildImagePreview(context, uploadState, animController),
            const SizedBox(height: 24),

            // 进度条
            if (uploadState.status == UploadStatus.uploading ||
                uploadState.status == UploadStatus.compressing)
              _buildProgressSection(uploadState),
            const SizedBox(height: 16),

            // 文件信息
            if (uploadState.originalSize != null) _buildFileInfo(uploadState),
            const SizedBox(height: 24),

            // 远程 URL 展示
            if (uploadState.remoteUrl != null)
              _buildUrlCard(context, uploadState.remoteUrl!),
            const SizedBox(height: 24),

            // 操作按钮
            _buildActionButtons(context, ref, uploadState),
          ],
        ),
      ),
    );
  }

  // ─────────── 状态卡片 ───────────

  Widget _buildStatusCard(UploadState state) {
    Color statusColor;
    IconData statusIcon;

    switch (state.status) {
      case UploadStatus.idle:
        statusColor = const Color(0xFF6C7B95);
        statusIcon = Icons.cloud_upload_outlined;
        break;
      case UploadStatus.picking:
        statusColor = const Color(0xFF7C4DFF);
        statusIcon = Icons.photo_library_outlined;
        break;
      case UploadStatus.compressing:
        statusColor = const Color(0xFFFF9800);
        statusIcon = Icons.compress;
        break;
      case UploadStatus.uploading:
        statusColor = const Color(0xFF2196F3);
        statusIcon = Icons.cloud_upload;
        break;
      case UploadStatus.success:
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle;
        break;
      case UploadStatus.error:
        statusColor = const Color(0xFFF44336);
        statusIcon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.2),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    state.errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── 图片预览 ───────────

  Widget _buildImagePreview(
    BuildContext context,
    UploadState state,
    AnimationController animController,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: state.status == UploadStatus.success
              ? const Color(0xFF4CAF50).withOpacity(0.5)
              : const Color(0xFF2A2A4A),
          width: 2,
        ),
        boxShadow: state.status == UploadStatus.success
            ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _buildPreviewContent(state, animController),
      ),
    );
  }

  Widget _buildPreviewContent(
    UploadState state,
    AnimationController animController,
  ) {
    // 上传成功 → 优先展示远程图片
    if (state.status == UploadStatus.success && state.remoteUrl != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: state.remoteUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (context, url, error) {
              // 远程加载失败时回退到本地
              if (state.localFile != null) {
                return Image.file(state.localFile!, fit: BoxFit.cover);
              }
              return const Center(
                child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
              );
            },
          ),
          // 成功徽章
          Positioned(
            top: 12,
            right: 12,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animController,
                curve: Curves.elasticOut,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_done, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '已上传',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 有本地文件 → 展示本地预览
    if (state.localFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(state.localFile!, fit: BoxFit.cover),
          if (state.status == UploadStatus.uploading ||
              state.status == UploadStatus.compressing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: state.status == UploadStatus.uploading
                            ? state.progress
                            : null,
                        strokeWidth: 4,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF7C4DFF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.status == UploadStatus.compressing
                          ? '压缩中...'
                          : '${(state.progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // 空状态
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF7C4DFF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: Color(0xFF7C4DFF),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '选择一张图片开始上传',
          style: TextStyle(
            color: Color(0xFF6C7B95),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '支持 JPG / PNG / WebP',
          style: TextStyle(
            color: const Color(0xFF6C7B95).withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ─────────── 进度条 ───────────

  Widget _buildProgressSection(UploadState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.status == UploadStatus.compressing ? '压缩进度' : '上传进度',
              style: const TextStyle(color: Color(0xFF6C7B95), fontSize: 13),
            ),
            Text(
              state.status == UploadStatus.compressing
                  ? '处理中...'
                  : '${(state.progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: state.status == UploadStatus.compressing
                ? null
                : state.progress,
            minHeight: 8,
            backgroundColor: const Color(0xFF2A2A4A),
            valueColor: AlwaysStoppedAnimation<Color>(
              state.status == UploadStatus.compressing
                  ? const Color(0xFFFF9800)
                  : const Color(0xFF7C4DFF),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────── 文件信息 ───────────

  Widget _buildFileInfo(UploadState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Row(
        children: [
          _buildInfoItem(
            '原始大小',
            _formatFileSize(state.originalSize ?? 0),
            Icons.insert_drive_file_outlined,
            const Color(0xFFFF9800),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFF2A2A4A),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _buildInfoItem(
            '压缩后',
            _formatFileSize(state.compressedSize ?? 0),
            Icons.compress,
            const Color(0xFF4CAF50),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFF2A2A4A),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _buildInfoItem(
            '压缩率',
            state.originalSize != null && state.compressedSize != null
                ? '${((1 - state.compressedSize! / state.originalSize!) * 100).toStringAsFixed(0)}%'
                : '-',
            Icons.speed,
            const Color(0xFF7C4DFF),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6C7B95), fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ─────────── URL 卡片 ───────────

  Widget _buildUrlCard(BuildContext context, String url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF4CAF50).withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.link, color: Color(0xFF4CAF50), size: 18),
              SizedBox(width: 8),
              Text(
                '远程地址',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              url,
              style: const TextStyle(
                color: Color(0xFF81C784),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('复制链接'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
              ),
              onPressed: () {
                // 复制到剪贴板
                // Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('链接已复制到剪贴板')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── 操作按钮 ───────────

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    UploadState state,
  ) {
    final isUploading = state.status == UploadStatus.uploading ||
        state.status == UploadStatus.compressing ||
        state.status == UploadStatus.picking;

    return Column(
      children: [
        // 主操作按钮行
        Row(
          children: [
            Expanded(
              child: _GradientButton(
                label: '📷  拍照上传',
                colors: const [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                icon: Icons.camera_alt_rounded,
                isEnabled: !isUploading,
                onPressed: () => ref
                    .read(uploadProvider.notifier)
                    .pickAndUpload(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GradientButton(
                label: '🖼  相册选择',
                colors: const [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                icon: Icons.photo_library_rounded,
                isEnabled: !isUploading,
                onPressed: () => ref
                    .read(uploadProvider.notifier)
                    .pickAndUpload(ImageSource.gallery),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 重置按钮
        if (state.status == UploadStatus.success ||
            state.status == UploadStatus.error)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('重新选择'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6C7B95),
                side: const BorderSide(color: Color(0xFF2A2A4A)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => ref.read(uploadProvider.notifier).reset(),
            ),
          ),
      ],
    );
  }

  // ─────────── 技术说明弹窗 ───────────

  void _showTechDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🔧 技术解析',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TechItem(
              icon: '🔑',
              title: 'STS 临时密钥',
              desc: '从后端获取临时 SecretId/SecretKey/Token，避免暴露永久密钥',
            ),
            SizedBox(height: 12),
            _TechItem(
              icon: '📝',
              title: 'HMAC-SHA1 签名',
              desc: '对每次请求生成唯一 Authorization Header',
            ),
            SizedBox(height: 12),
            _TechItem(
              icon: '📤',
              title: 'PUT Object',
              desc: '通过 COS XML API 直传文件，支持大文件分片',
            ),
            SizedBox(height: 12),
            _TechItem(
              icon: '📊',
              title: '进度监听',
              desc: '利用 Dio onSendProgress 实现实时进度反馈',
            ),
            SizedBox(height: 12),
            _TechItem(
              icon: '🗜️',
              title: '图片压缩',
              desc: '上传前使用 flutter_image_compress 压缩，节省流量和存储空间',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了', style: TextStyle(color: Color(0xFF7C4DFF))),
          ),
        ],
      ),
    );
  }

  // ─────────── Utils ───────────

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ==================== Custom Widgets ====================

/// 渐变按钮
class _GradientButton extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.label,
    required this.colors,
    required this.icon,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(14),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: colors.first.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 技术项
class _TechItem extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;

  const _TechItem({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  color: Color(0xFF6C7B95),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
