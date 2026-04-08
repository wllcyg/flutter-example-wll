import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// ============================================================
/// Day 44: 腾讯云 COS 上传服务
///
/// 核心流程：
///   1. 从你的后端获取 STS 临时密钥
///   2. 使用临时密钥生成 COS 的 Authorization
///   3. 通过 COS XML API (PUT Object) 上传文件，并监听进度
/// ============================================================

// ──────────────────── Data Models ────────────────────

/// STS 临时凭证
class CosCredentials {
  final String tmpSecretId;
  final String tmpSecretKey;
  final String sessionToken;
  final int startTime;
  final int expiredTime;

  CosCredentials({
    required this.tmpSecretId,
    required this.tmpSecretKey,
    required this.sessionToken,
    required this.startTime,
    required this.expiredTime,
  });

  factory CosCredentials.fromJson(Map<String, dynamic> json) {
    // 兼容两种格式：
    // 格式 A（带 Response 包装）: { Response: { Credentials: {...}, ExpiredTime: ... } }
    // 格式 B（扁平结构）:          { credentials: {...}, expiredTime: ... }
    final response = json['Response'] ?? json;
    final credentials = response['Credentials'] ?? response['credentials'] ?? response;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return CosCredentials(
      tmpSecretId: credentials['TmpSecretId'] ?? credentials['tmpSecretId'] ?? '',
      tmpSecretKey: credentials['TmpSecretKey'] ?? credentials['tmpSecretKey'] ?? '',
      sessionToken: credentials['Token'] ?? credentials['sessionToken'] ?? '',
      startTime: response['StartTime'] ?? response['startTime'] ?? now,
      expiredTime: response['ExpiredTime'] ?? response['expiredTime'] ?? 0,
    );
  }

  bool get isValid =>
      tmpSecretId.isNotEmpty &&
      tmpSecretKey.isNotEmpty &&
      DateTime.now().millisecondsSinceEpoch ~/ 1000 < expiredTime;
}

/// 上传结果
class CosUploadResult {
  final bool success;
  final String? url;
  final String? cosPath;
  final String? errorMessage;

  CosUploadResult({
    required this.success,
    this.url,
    this.cosPath,
    this.errorMessage,
  });
}

/// 上传进度回调
typedef CosProgressCallback = void Function(int sent, int total);

// ──────────────────── COS Service ────────────────────

class CosService {
  final Dio _dio;

  /// 你的后端 STS 签发地址
  final String stsUrl;

  /// COS 存储桶名称，例如：my-bucket-1250000000
  final String bucket;

  /// COS 地域，例如：ap-guangzhou
  final String region;

  /// 缓存的凭证
  CosCredentials? _cachedCredentials;

  CosService({
    required this.stsUrl,
    required this.bucket,
    required this.region,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  /// COS 请求 Host
  String get _cosHost => '$bucket.cos.$region.myqcloud.com';

  // ─────────── 1. 获取 STS 临时密钥 ───────────

  /// 从后端获取 STS 临时凭证
  Future<CosCredentials> getCredentials({bool forceRefresh = false}) async {
    // 如果缓存有效，直接返回
    if (!forceRefresh && _cachedCredentials != null && _cachedCredentials!.isValid) {
      return _cachedCredentials!;
    }

    try {
      debugPrint('🔑 COS: 正在获取 STS 临时密钥...');
      final response = await _dio.get(stsUrl);

      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        _cachedCredentials = CosCredentials.fromJson(data);
        debugPrint('✅ COS: STS 密钥获取成功，'
            '有效至 ${DateTime.fromMillisecondsSinceEpoch(_cachedCredentials!.expiredTime * 1000)}');
        return _cachedCredentials!;
      } else {
        throw Exception('STS 请求失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ COS: STS 获取失败 — $e');
      rethrow;
    }
  }

  // ─────────── 2. COS 授权签名生成 ───────────

  /// 生成 COS XML API 的 Authorization Header
  ///
  /// 签名算法文档：
  /// https://cloud.tencent.com/document/product/436/7778
  String _generateAuthorization({
    required CosCredentials cred,
    required String method,
    required String cosPath,
    Map<String, String>? headers,
    Map<String, String>? params,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final signTime = '$now;${now + 600}'; // 签名有效期 10 分钟
    final keyTime = signTime;

    // Step 1: SignKey = HMAC-SHA1(SecretKey, KeyTime)
    final signKey = _hmacSha1(cred.tmpSecretKey, keyTime);

    // Step 2: 构建 HttpString
    // 格式：method\nUriPathname\nQueryString\nHeaders\n
    final sortedHeaders = _sortAndLowerCase(headers ?? {});
    final sortedParams = _sortAndLowerCase(params ?? {});

    final headerList = sortedHeaders.keys.join(';');
    final paramList = sortedParams.keys.join(';');

    final httpString = '${method.toLowerCase()}\n'
        '/$cosPath\n'
        '${_mapToQueryString(sortedParams)}\n'
        '${_mapToQueryString(sortedHeaders)}\n';

    // Step 3: StringToSign
    final httpStringHash = sha1.convert(utf8.encode(httpString)).toString();
    final stringToSign = 'sha1\n$keyTime\n$httpStringHash\n';

    // Step 4: Signature = HMAC-SHA1(SignKey, StringToSign)
    final signature = _hmacSha1(signKey, stringToSign);

    // Step 5: 组装 Authorization
    return 'q-sign-algorithm=sha1'
        '&q-ak=${cred.tmpSecretId}'
        '&q-sign-time=$signTime'
        '&q-key-time=$keyTime'
        '&q-header-list=$headerList'
        '&q-url-param-list=$paramList'
        '&q-signature=$signature';
  }

  // ─────────── 3. 上传文件 ───────────

  /// 上传文件到 COS
  ///
  /// [file] 本地文件
  /// [cosPath] COS 上的存储路径，例如 "images/avatar/xxx.jpg"
  /// [onProgress] 进度回调
  Future<CosUploadResult> uploadFile({
    required File file,
    String? cosPath,
    CosProgressCallback? onProgress,
  }) async {
    try {
      // 1. 获取临时凭证
      final cred = await getCredentials();

      // 2. 生成 COS 上的路径
      final ext = p.extension(file.path);
      final objectKey = cosPath ??
          'uploads/${DateTime.now().millisecondsSinceEpoch}'
              '_${file.path.hashCode.abs()}$ext';

      // 3. 读取文件
      final bytes = await file.readAsBytes();
      final contentType = _getContentType(ext);

      // 4. 构建请求 Headers（参与签名的）
      final signHeaders = <String, String>{
        'host': _cosHost,
        'content-type': contentType,
      };

      // 5. 生成 Authorization
      final authorization = _generateAuthorization(
        cred: cred,
        method: 'PUT',
        cosPath: objectKey,
        headers: signHeaders,
      );

      // 6. 发起 PUT 请求
      final url = 'https://$_cosHost/$objectKey';

      debugPrint('📤 COS: 开始上传 → $url');

      final response = await _dio.put(
        url,
        data: bytes,
        options: Options(
          headers: {
            'Authorization': authorization,
            'x-cos-security-token': cred.sessionToken,
            'Content-Type': contentType,
            'Content-Length': bytes.length,
            'Host': _cosHost,
          },
        ),
        onSendProgress: (sent, total) {
          onProgress?.call(sent, total);
          if (kDebugMode && total > 0) {
            // 简单控制下打印频率：每 10% 打印一次
            final percent = sent / total;
            if (sent == total || (sent % (total ~/ 10) == 0)) {
              debugPrint('📤 COS: 上传进度 ${(percent * 100).toStringAsFixed(1)}%');
            }
          }
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final fileUrl = url;
        debugPrint('✅ COS: 上传成功 → $fileUrl');
        return CosUploadResult(
          success: true,
          url: fileUrl,
          cosPath: objectKey,
        );
      } else {
        return CosUploadResult(
          success: false,
          errorMessage: '上传失败: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? '未知网络错误';
      debugPrint('❌ COS: 上传异常 — $msg');
      return CosUploadResult(success: false, errorMessage: msg);
    } catch (e) {
      debugPrint('❌ COS: 上传异常 — $e');
      return CosUploadResult(success: false, errorMessage: e.toString());
    }
  }

  // ─────────── 辅助方法 ───────────

  /// HMAC-SHA1
  String _hmacSha1(String key, String message) {
    final hmac = Hmac(sha1, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(message));
    return digest.toString();
  }

  /// 将 Map 的 key 转小写后排序
  Map<String, String> _sortAndLowerCase(Map<String, String> map) {
    final sorted = <String, String>{};
    final keys = map.keys.map((k) => k.toLowerCase()).toList()..sort();
    for (final key in keys) {
      final originalKey =
          map.keys.firstWhere((k) => k.toLowerCase() == key);
      sorted[key] = Uri.encodeComponent(map[originalKey]!);
    }
    return sorted;
  }

  /// 将 Map 转成 key=value&key=value 格式
  String _mapToQueryString(Map<String, String> map) {
    return map.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  /// 根据扩展名获取 ContentType
  String _getContentType(String ext) {
    switch (ext.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
