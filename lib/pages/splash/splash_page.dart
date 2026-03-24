import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/gen/assets.gen.dart';
import 'package:my_flutter_app/view_models/auth_view_model.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialize Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Define Scale Animation with Elastic Curve (Pop effect)
    // begin: 0.0 (invisible) -> target: 1.0 (normal size)
    // elasticOut creates the "overshoot and settle" effect
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    // Start Animation
    _controller.forward();

    // 检查登录状态并跳转 (增加一点人工延迟让用户看到 Logo)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // 读取当前的 AuthState
        final user = ref.read(authViewModelProvider).user;
        debugPrint("SplashPage: Checking AuthState. User is: ${user?.email}");
        if (user != null) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 使用 ScaleTransition 包裹 Hero
              ScaleTransition(
                scale: _animation,
                child: Hero(
                  tag: 'app_logo',
                  child: Assets.images.splash.logo.image(
                    width: 150.w,
                    height: 150.w,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
