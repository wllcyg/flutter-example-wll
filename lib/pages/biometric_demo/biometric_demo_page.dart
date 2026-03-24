import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';

/// Day 23：原生硬件与生物识别 Demo 页面
/// 演示 local_auth 的核心 API：
/// 1. 检测设备是否支持生物识别
/// 2. 获取已注册的生物识别类型（Face ID / 指纹 / 虹膜）
/// 3. 发起生物识别认证
class BiometricDemoPage extends StatefulWidget {
  const BiometricDemoPage({super.key});

  @override
  State<BiometricDemoPage> createState() => _BiometricDemoPageState();
}

class _BiometricDemoPageState extends State<BiometricDemoPage> {
  final LocalAuthentication _auth = LocalAuthentication();

  // --- 状态字段 ---
  bool _isDeviceSupported = false;
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  String _authStatus = '尚未认证';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceCapabilities();
  }

  /// 检查设备能力：是否支持生物识别 + 已注册的生物类型
  Future<void> _checkDeviceCapabilities() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final biometrics = await _auth.getAvailableBiometrics();

      if (mounted) {
        setState(() {
          _isDeviceSupported = isSupported;
          _canCheckBiometrics = canCheck;
          _availableBiometrics = biometrics;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('检查设备能力失败: ${e.message}');
    }
  }

  /// 发起生物识别认证（Face ID / 指纹）
  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _authStatus = '认证中...';
    });

    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: '请验证身份以继续操作',
        options: const AuthenticationOptions(
          stickyAuth: true, // App 切到后台再回来时保持认证弹窗
          biometricOnly: false, // 允许回退到 PIN/密码
        ),
      );

      if (mounted) {
        setState(() {
          _authStatus = didAuthenticate ? '✅ 认证成功！' : '❌ 认证失败';
          _isAuthenticating = false;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _authStatus = '⚠️ 认证异常: ${e.message}';
          _isAuthenticating = false;
        });
      }
    }
  }

  /// 仅使用生物识别（不回退到 PIN/密码）
  Future<void> _authenticateBiometricOnly() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _authStatus = '生物识别认证中...';
    });

    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: '请使用 Face ID 或指纹验证',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true, // 仅生物识别，不回退
        ),
      );

      if (mounted) {
        setState(() {
          _authStatus = didAuthenticate ? '✅ 生物识别成功！' : '❌ 生物识别失败';
          _isAuthenticating = false;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _authStatus = '⚠️ 异常: ${e.message}';
          _isAuthenticating = false;
        });
      }
    }
  }

  /// 取消正在进行的认证
  Future<void> _cancelAuthentication() async {
    await _auth.stopAuthentication();
    if (mounted) {
      setState(() {
        _isAuthenticating = false;
        _authStatus = '已取消认证';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111518);
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF60778A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Day 23 · 生物识别'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. 设备能力信息卡片 ---
            _buildCard(
              cardColor: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardTitle('📱 设备能力检测', textColor),
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    '设备支持认证',
                    _isDeviceSupported ? '✅ 支持' : '❌ 不支持',
                    subtitleColor,
                    textColor,
                  ),
                  _buildInfoRow(
                    '支持生物识别',
                    _canCheckBiometrics ? '✅ 是' : '❌ 否',
                    subtitleColor,
                    textColor,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '已注册的生物识别类型：',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: subtitleColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (_availableBiometrics.isEmpty)
                    Text(
                      '暂无（模拟器/设备未录入指纹或面容）',
                      style: TextStyle(fontSize: 13.sp, color: subtitleColor),
                    )
                  else
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _availableBiometrics.map((type) {
                        return _buildBiometricChip(type, isDark);
                      }).toList(),
                    ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _checkDeviceCapabilities,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('重新检测'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // --- 2. 认证状态卡片 ---
            _buildCard(
              cardColor: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardTitle('🔐 认证状态', textColor),
                  SizedBox(height: 16.h),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _getStatusColor().withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isAuthenticating)
                            Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          Flexible(
                            child: Text(
                              _authStatus,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // --- 3. 操作按钮区 ---
            _buildCard(
              cardColor: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardTitle('🎯 操作测试', textColor),
                  SizedBox(height: 12.h),
                  // 按钮 1: 通用认证（可回退到 PIN）
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: _isAuthenticating ? null : _authenticate,
                      icon: const Icon(Icons.verified_user),
                      label: const Text('通用认证（含 PIN 回退）'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90D9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // 按钮 2: 仅生物识别
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isAuthenticating ? null : _authenticateBiometricOnly,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('仅生物识别（Face ID / 指纹）'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // 按钮 3: 取消认证
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton.icon(
                      onPressed:
                          _isAuthenticating ? _cancelAuthentication : null,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('取消认证'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // --- 4. Face ID 登录方案说明 ---
            _buildCard(
              cardColor: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardTitle('💡 Face ID 登录方案', textColor),
                  SizedBox(height: 12.h),
                  _buildStepItem(
                      '1',
                      '首次登录',
                      '用户使用账号密码登录成功后，弹窗询问"是否启用 Face ID 快捷登录？"',
                      subtitleColor,
                      textColor),
                  _buildStepItem(
                      '2',
                      '存储凭证',
                      '用户同意后，将 Token 加密存入 flutter_secure_storage（Keychain / Keystore）',
                      subtitleColor,
                      textColor),
                  _buildStepItem(
                      '3',
                      '再次打开App',
                      '检测到本地存在加密 Token → 调用 local_auth 发起 Face ID 认证',
                      subtitleColor,
                      textColor),
                  _buildStepItem(
                      '4',
                      '认证成功',
                      'Face ID 验证通过 → 读取加密 Token → 验证有效性 → 自动登录',
                      subtitleColor,
                      textColor),
                  _buildStepItem('5', '认证失败', '验证失败或取消 → 回退到账号密码登录页',
                      subtitleColor, textColor),
                ],
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  // --- UI 辅助方法 ---

  Widget _buildCard({required Color cardColor, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, Color labelColor, Color valueColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, color: labelColor)),
          Text(value,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildBiometricChip(BiometricType type, bool isDark) {
    final (icon, label) = switch (type) {
      BiometricType.face => (Icons.face, 'Face ID'),
      BiometricType.fingerprint => (Icons.fingerprint, '指纹'),
      BiometricType.iris => (Icons.remove_red_eye, '虹膜'),
      _ => (Icons.security, type.name),
    };

    return Chip(
      avatar: Icon(icon, size: 18.w),
      label: Text(label),
      backgroundColor:
          isDark ? const Color(0xFF2D2D3F) : const Color(0xFFF0F4FF),
      labelStyle: TextStyle(fontSize: 13.sp),
    );
  }

  Widget _buildStepItem(String step, String title, String desc,
      Color subtitleColor, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Text(
              step,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: subtitleColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_authStatus.contains('成功')) return Colors.green;
    if (_authStatus.contains('失败')) return Colors.red;
    if (_authStatus.contains('异常')) return Colors.orange;
    if (_authStatus.contains('取消')) return Colors.grey;
    if (_isAuthenticating) return Colors.blue;
    return Colors.grey;
  }
}
