import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:my_flutter_app/res/colors.dart';
import 'package:my_flutter_app/res/dimens.dart';
import 'package:my_flutter_app/widgets/my_button.dart';
import 'package:my_flutter_app/widgets/my_text_field.dart';
import 'package:my_flutter_app/view_models/auth_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/gen/assets.gen.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 使用 Hooks 创建控制器
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    // 监听 ViewModel 状态
    final authState = ref.watch(authViewModelProvider);

    // 监听 AuthState 中的 user 变化，如果已登录则跳转
    useEffect(() {
      if (authState.user != null) {
        // 使用 Future.microtask 避免在 build 过程中跳转
        Future.microtask(() {
          if (context.mounted) {
            // 3. 跳转主页前，显式强制关闭所有加载框，防止跳转后残留在新页面上
            SmartDialog.dismiss(status: SmartStatus.loading);
            context.go('/home');
          }
        });
      }
      return null;
    }, [authState.user]);

    // 监听加载状态，显示 Loading
    useEffect(() {
      if (authState.isLoading) {
        SmartDialog.showLoading(msg: "登录中...");
      } else {
        SmartDialog.dismiss(status: SmartStatus.loading);
      }
      // 2. 添加副作用清理函数：如果组件在 isLoading 还是 true 时被卸载（如页面跳转），强制关闭加载框
      return () => SmartDialog.dismiss(status: SmartStatus.loading);
    }, [authState.isLoading]);

    // 监听错误信息并弹出 Toast
    useEffect(() {
      if (authState.errorMessage != null) {
        SmartDialog.showToast(authState.errorMessage!);
        // 清除错误，避免重复弹
        Future.microtask(() {
          ref.read(authViewModelProvider.notifier).clearError();
        });
      }
      return null;
    }, [authState.errorMessage]);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // 防止键盘遮挡
          padding: EdgeInsets.symmetric(horizontal: AppDimens.pagePaddingLarge),
          child: Column(
            children: [
              SizedBox(height: AppDimens.gap32 * 2), // 顶部留白更多一点

              // Logo Area
              Center(
                child: Hero(
                  tag: 'app_logo',
                  child: Assets.images.splash.logo.image(
                    width: 100.w,
                    height: 100.w,
                  ),
                ),
              ),
              SizedBox(height: AppDimens.gap32),

              // 标题
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '欢迎登录',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: AppDimens.gap32),

              // --- 1. 邮箱输入框 ---
              MyTextField(
                controller: emailController,
                hintText: '请输入邮箱',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: AppDimens.gap16),

              // --- 2. 密码输入框 ---
              MyTextField(
                controller: passwordController,
                hintText: '请输入密码',
                obscureText: true,
              ),
              SizedBox(height: AppDimens.gap32),

              // --- 3. 登录按钮 ---
              MyButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        final password = passwordController.text;

                        if (email.isEmpty || password.isEmpty) {
                          SmartDialog.showToast('请输入邮箱和密码');
                          return;
                        }

                        await ref
                            .read(authViewModelProvider.notifier)
                            .signInWithPassword(
                                email: email, password: password);
                      },
                text: '登 录',
                radius: 4,
                // 根据 Loading 状态改变样式 (可选)
              ),

              SizedBox(height: AppDimens.gap16),

              // --- 4. 底部链接 ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '还没有账号？',
                    style: TextStyle(
                      fontSize: AppDimens.font14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Text(
                      '立即注册',
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
