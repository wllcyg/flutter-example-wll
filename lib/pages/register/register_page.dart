import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_flutter_app/res/colors.dart';
import 'package:my_flutter_app/res/dimens.dart';
import 'package:my_flutter_app/widgets/my_button.dart';
import 'package:my_flutter_app/widgets/my_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    // final codeController = useTextEditingController(); // 不再需要验证码
    final passwordController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('注册账号'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.pagePaddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppDimens.gap32),

              Text(
                '创建新账号',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '请填写以下信息完成注册',
                style: TextStyle(
                  fontSize: AppDimens.font14,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),

              // --- 1. 邮箱输入框 ---
              MyTextField(
                controller: emailController,
                hintText: '请输入邮箱地址',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: AppDimens.gap16),

              // --- 2. 密码输入框 (提前到验证码之前，因为我们改用直接注册) ---
              MyTextField(
                controller: passwordController,
                hintText: '设置登录密码',
                obscureText: true,
              ),
              SizedBox(height: AppDimens.gap16),

              SizedBox(height: 32.h),

              // --- 4. 注册按钮 ---
              MyButton(
                onPressed: () async {
                  debugPrint("开始注册...");
                  // 1. 清洗数据 (去除空格)
                  final email = emailController.text.trim();
                  final password = passwordController.text;

                  if (email.isEmpty || password.isEmpty) {
                    SmartDialog.showToast('请填写完整信息');
                    return;
                  }

                  if (password.length < 6) {
                    SmartDialog.showToast('密码长度至少为6位');
                    return;
                  }

                  try {
                    // 2. 直接使用 signUp 注册 (Email + Password)
                    final AuthResponse res =
                        await Supabase.instance.client.auth.signUp(
                      email: email,
                      password: password,
                    );

                    debugPrint(
                        "注册响应: User=${res.user?.id}, Session=${res.session}");

                    // 3. 检查是否需要确认邮箱
                    // 如果 Supabase 后台关闭了 Confirm Email，这里直接就能拿到 Session
                    if (res.session != null) {
                      if (context.mounted) {
                        SmartDialog.showToast('注册成功，已自动登录');
                        // AuthViewModel 会监听到 Session 变化自动跳转首页，这里只需要 pop
                        // 或者稍微等一下让路由反应过来
                        context.go('/home'); // 显式跳转更稳妥
                      }
                    } else {
                      // 如果没有 Session，说明 Supabase 还是开启了 Confirm Email
                      if (context.mounted) {
                        SmartDialog.showToast('注册成功，请查收邮件确认链接');
                        context.pop();
                      }
                    }
                  } catch (e) {
                    debugPrint("注册失败: $e");
                    String msg = '注册失败';
                    if (e is AuthException) {
                      msg = e.message;
                    }
                    if (context.mounted) {
                      SmartDialog.showToast(msg);
                    }
                  }
                },
                text: '注 册',
                radius: 4,
              ),

              SizedBox(height: AppDimens.gap16),

              // --- 5. 返回登录 ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '已有账号？te',
                    style: TextStyle(
                      fontSize: AppDimens.font14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.pop(); // 返回登录页
                    },
                    child: Text(
                      '直接登录',
                      style: TextStyle(
                        fontSize: AppDimens.font14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
