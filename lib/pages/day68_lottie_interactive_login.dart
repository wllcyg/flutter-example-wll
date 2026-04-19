import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/res/colors.dart';

class Day68LottieInteractiveLogin extends StatefulWidget {
  const Day68LottieInteractiveLogin({super.key});

  @override
  State<Day68LottieInteractiveLogin> createState() =>
      _Day68LottieInteractiveLoginState();
}

class _Day68LottieInteractiveLoginState
    extends State<Day68LottieInteractiveLogin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _passwordFocusNode = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isCoveringEyes = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 监听密码框焦点变化
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        // 获得焦点：猫头鹰转头（根据 JSON 分析，第 6 帧左右完成转头，6/150 ≈ 0.04）
        _controller.animateTo(0.04);
        setState(() => _isCoveringEyes = true);
      } else {
        // 失去焦点：猫头鹰转回正脸
        _controller.animateBack(0);
        setState(() => _isCoveringEyes = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('趣味交互：猫头鹰登录'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 40.h),
            // Lottie 动画展示区
            Container(
              width: 220.w,
              height: 220.w,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipOval(
                child: Lottie.asset(
                  // 切换为本地资源，确保加载稳定
                  'assets/lottie/owl_login.json',
                  controller: _controller,
                  fit: BoxFit.contain, // 改为 contain 确保比例正确
                  alignment: Alignment.center, // 强制内容居中
                  onLoaded: (composition) {
                    // 初始化时长
                    _controller.duration = composition.duration;
                  },
                ),
              ),
            ),
            SizedBox(height: 40.h),
            // 登录表单卡片
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                children: [
                  Text(
                    '欢迎回来',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '请输入您的账户信息进行登录',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  _buildTextField(
                    controller: _emailController,
                    label: '邮箱地址',
                    icon: Icons.email_outlined,
                    isDark: isDark,
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _passwordController,
                    label: '登录密码',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    focusNode: _passwordFocusNode,
                    isDark: isDark,
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // 登录逻辑
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('立 即 登 录',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            TextButton(
              onPressed: () {},
              child: const Text('忘记密码？', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    FocusNode? focusNode,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      focusNode: focusNode,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22.w),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
