import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

/// ============================================================
/// Day 47: 加密基础——crypto 包
///
/// 技术要点：
///   1. crypto 包核心功能 — MD5 / SHA-1 / SHA-256 哈希计算
///   2. 密码加密 — 登录密码加盐哈希（不要明文传输）
///   3. 文件校验 — 下载文件完整性验证（简易字符串模拟 MD5 校验）
///   4. HMAC 签名 — API 请求签名验证
///   5. 实战场景 — 密码加密、文件上传校验、Token 签名
/// ============================================================

class Day47CryptoDemo extends StatefulWidget {
  const Day47CryptoDemo({super.key});

  @override
  State<Day47CryptoDemo> createState() => _Day47CryptoDemoState();
}

class _Day47CryptoDemoState extends State<Day47CryptoDemo> {
  final TextEditingController _inputController = TextEditingController(text: 'flutter2024');

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Day 47: 基础哈希 (crypto)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 输入面板
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
              ),
              child: TextField(
                controller: _inputController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  icon: Icon(Icons.password, color: Color(0xFF7C4DFF)),
                  labelText: '输入数据/密码，试试看实时的散列结果 👇',
                  labelStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 24),

            _SectionCard(
              title: '1. 常见散列哈希 (不可逆)',
              icon: Icons.fingerprint,
              color: const Color(0xFF7C4DFF),
              child: _HashSection(input: _inputController.text),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: '2. 密码加盐 (Salted Hash)',
              icon: Icons.security,
              color: const Color(0xFF4CAF50),
              child: _PasswordSaltSection(input: _inputController.text),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: '3. API HMAC 签名认证',
              icon: Icons.vpn_key,
              color: const Color(0xFFFF9800),
              child: _HmacSection(input: _inputController.text),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: '4. 实战场景',
              icon: Icons.lightbulb_outline,
              color: const Color(0xFFE91E63),
              child: const _PracticalCryptoSection(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ==================== Section 1: Hash ====================
class _HashSection extends StatelessWidget {
  final String input;
  const _HashSection({required this.input});

  @override
  Widget build(BuildContext context) {
    final bytes = utf8.encode(input);
    final md5Str = md5.convert(bytes).toString();
    final sha1Str = sha1.convert(bytes).toString();
    final sha256Str = sha256.convert(bytes).toString();

    return Column(
      children: [
        _ResultRow(label: 'MD5 (不推荐做密码)', value: md5Str, color: const Color(0xFF7C4DFF)),
        _ResultRow(label: 'SHA-1', value: sha1Str, color: const Color(0xFF7C4DFF)),
        _ResultRow(label: 'SHA-256 (推荐)', value: sha256Str, color: const Color(0xFF7C4DFF)),
      ],
    );
  }
}

// ==================== Section 2: Password + Salt ====================
class _PasswordSaltSection extends StatelessWidget {
  final String input;
  const _PasswordSaltSection({required this.input});

  @override
  Widget build(BuildContext context) {
    // 模拟服务端下发的动态随机盐值
    const salt = 'random_salt_a1b2c3';
    // 拼接盐值与密码
    final saltedBytes = utf8.encode('$salt+$input');
    final hashStr = sha256.convert(saltedBytes).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('为何需要加盐？', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
        const Text('纯 MD5 容易被“彩虹表”反查碰撞，必须通过加盐破坏通用性。', style: TextStyle(color: Colors.white, fontSize: 13)),
        const SizedBox(height: 12),
        _ResultRow(label: 'Salt 盐值', value: salt, color: const Color(0xFF4CAF50)),
        _ResultRow(label: '加盐散列结果', value: hashStr, color: const Color(0xFF4CAF50)),
      ],
    );
  }
}

// ==================== Section 3: HMAC ====================
class _HmacSection extends StatelessWidget {
  final String input;
  const _HmacSection({required this.input});

  @override
  Widget build(BuildContext context) {
    const apiSecret = 'super_secret_key_123';
    final hmac = Hmac(sha256, utf8.encode(apiSecret));
    final digest = hmac.convert(utf8.encode(input)).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('场景：给后端发送带签名的请求，防止篡改。', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
        const SizedBox(height: 12),
        _ResultRow(label: 'Secret', value: apiSecret, color: const Color(0xFFFF9800)),
        _ResultRow(label: 'HMAC-SHA256', value: digest, color: const Color(0xFFFF9800)),
      ],
    );
  }
}

// ==================== Section 4: 业务实战 ====================
class _PracticalCryptoSection extends StatelessWidget {
  const _PracticalCryptoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PracticeCard(
          title: '🔐 登录拦截',
          desc: 'App端将用户密码使用 SHA256 哈希后再发送给接口，绝对禁止网络抓包明文密码。',
        ),
        const SizedBox(height: 10),
        _PracticeCard(
          title: '📄 文件下载/上传完整性验证',
          desc: '客户端计算切片大文件的 MD5 后台校验。如果不一致提示“文件损坏，请重新下载”。',
        ),
        const SizedBox(height: 10),
        _PracticeCard(
          title: '🛡️ 开放 API 签名',
          desc: '使用当前时间戳 timestamp + body 字符串作为数据，配对客户端固定的 AppSecret 进行 HMAC(SHA256) 摘要附在 Header 中鉴权。',
        ),
      ],
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
        border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.2)),
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
