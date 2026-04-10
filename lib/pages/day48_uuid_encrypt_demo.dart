import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// ============================================================
/// Day 48: UUID 与对称加密
///
/// 技术要点：
///   1. uuid 包 — 生成唯一标识符（UUID v1/v4/v5）
///   2. 使用场景 — 本地数据临时 ID、请求追踪 ID、文件命名
///   3. encrypt 包 — AES 对称加密（敏感数据本地存储）
///   4. 加密流程 — 密钥生成 → 加密 → 解密
///   5. 实战场景 — 本地敏感信息加密、离线数据保护
/// ============================================================

class Day48UuidEncryptDemo extends StatefulWidget {
  const Day48UuidEncryptDemo({super.key});

  @override
  State<Day48UuidEncryptDemo> createState() => _Day48UuidEncryptDemoState();
}

class _Day48UuidEncryptDemoState extends State<Day48UuidEncryptDemo> {
  // UUID 生成器
  final Uuid _uuid = const Uuid();
  String _currentV1 = '';
  String _currentV4 = '';

  // AES 加密器 (全局保留实例)
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;
  final TextEditingController _textController = TextEditingController(text: 'Hello Flutter!');
  String _encryptedText = '';
  String _decryptedText = '';

  @override
  void initState() {
    super.initState();
    _generateUuids();
    _setupEncryption();
  }

  void _generateUuids() {
    setState(() {
      _currentV1 = _uuid.v1(); // 基于时间的 UUID
      _currentV4 = _uuid.v4(); // 基于随机数的 UUID (最常用)
    });
  }

  void _setupEncryption() {
    // 1. 生成 32 字节的 Key (AES-256)
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
    // 2. 生成 16 字节的 IV (初始化向量)
    _iv = encrypt.IV.fromLength(16);
    // 3. 构建 Encrypter
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  void _performEncryption() {
    if (_textController.text.isEmpty) return;
    setState(() {
      // 加密 (得到 Base64 字符串)
      final encrypted = _encrypter.encrypt(_textController.text, iv: _iv);
      _encryptedText = encrypted.base64;
      
      // 解密 (从 Base64 字符串解出原文)
      _decryptedText = _encrypter.decrypt64(_encryptedText, iv: _iv);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 48: UUID 与对称加密'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SectionCard(
              title: '1. 生成唯一标识 (UUID)',
              icon: Icons.fingerprint,
              color: const Color(0xFF2196F3),
              child: Column(
                children: [
                  _ResultRow(label: 'UUID v1 (基于时间MAC)', value: _currentV1, color: const Color(0xFF2196F3)),
                  _ResultRow(label: 'UUID v4 (完全随机 - 推荐)', value: _currentV4, color: const Color(0xFF2196F3)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('重新生成'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3).withOpacity(0.2),
                        foregroundColor: const Color(0xFF2196F3),
                      ),
                      onPressed: _generateUuids,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            _SectionCard(
              title: '2. 敏感数据对称加密 (AES)',
              icon: Icons.lock_outline,
              color: const Color(0xFF7C4DFF),
              child: Column(
                children: [
                  TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: '待加密的敏感文本',
                      labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0xFF7C4DFF).withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF7C4DFF))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.enhanced_encryption),
                      label: const Text('执行 AES 加密 & 解密'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.2),
                        foregroundColor: const Color(0xFF7C4DFF),
                      ),
                      onPressed: _performEncryption,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_encryptedText.isNotEmpty) ...[
                    _ResultRow(label: '加锁后 (保存本地数据库的Base64形态)', value: _encryptedText, color: const Color(0xFFE91E63)),
                    _ResultRow(label: '解锁后 (读取时还原的数据)', value: _decryptedText, color: const Color(0xFF4CAF50)),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: '3. 实战场景',
              icon: Icons.lightbulb_outline,
              color: const Color(0xFFFF9800),
              child: Column(
                children: [
                  _PracticeCard(
                    title: '🆔 UUID - 离线数据同步',
                    desc: '在断网环境下新建了笔记/日记，无法获取自增主键，直接客户端生成 UUID v4 作为主键保存，联网后推送到服务端不会重复冲突。',
                  ),
                  const SizedBox(height: 10),
                  _PracticeCard(
                    title: '📸 UUID - 图片文件命名',
                    desc: '上传头像到 COS 或 OSS 前，将文件重命名为 UUID.png，防止名字含中文或特殊字符导致路径加载失败。',
                  ),
                  const SizedBox(height: 10),
                  _PracticeCard(
                    title: '🔑 AES 加密 - 本地信息脱敏',
                    desc: '使用 shared_preferences 时如果不想明文存用户名、隐私 token，可以使用固定的内部密钥，通过 AES 加密成 Base64 再存放。',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Shared Widgets ====================
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

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 12),
            ),
          ),
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
        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.2)),
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
