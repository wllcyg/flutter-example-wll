import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/view_models/auth_view_model.dart';
import 'package:my_flutter_app/routers/app_router.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/pages/mine/widgets/profile_header.dart';
import 'package:my_flutter_app/pages/mine/widgets/settings_section.dart';

class MinePage extends ConsumerWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar (Matches HTML design: Title with back arrow)
          SliverAppBar(
            backgroundColor:
                isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            elevation: 0,
            pinned: true,
            title: Text(
              '个人中心',
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),

          const SliverToBoxAdapter(child: ProfileHeader()),

          const SliverToBoxAdapter(child: SettingsSection()),

          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          SmartDialog.showLoading(msg: "正在退出...");
                          await ref
                              .read(authViewModelProvider.notifier)
                              .signOut();
                          SmartDialog.dismiss();
                          ref.read(goRouterProvider).go('/login');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                        child: const Text(
                          '退出登录',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Version 0.0.1',
                        style: TextStyle(
                            color: const Color(0xFF60778A), fontSize: 12.sp),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 50.h),
              ],
            ),
          )
        ],
      ),
    );
  }
}
