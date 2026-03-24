import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/res/colors.dart';
import 'package:my_flutter_app/view_models/auth_view_model.dart';
import 'package:my_flutter_app/providers/diary_provider.dart';
import 'package:my_flutter_app/pages/mine/widgets/wavy_header_painter.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;
    final diaryListAsync = ref.watch(diaryListProvider);
    final diaryCount = diaryListAsync.maybeWhen(
      data: (entries) => entries.length,
      orElse: () => 0,
    );

    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;
    final email = user?.email ?? '用户';
    final username = email.split('@').first;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      child: Stack(
        children: [
          // Day 30: CustomPainter Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180.h,
            child: CustomPaint(
              painter: WavyHeaderPainter(
                color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.primary, width: 2.w),
                          ),
                          child: CircleAvatar(
                            radius: 56.w,
                            backgroundImage: avatarUrl != null
                                ? NetworkImage(avatarUrl)
                                : const NetworkImage(
                                    "https://lh3.googleusercontent.com/aida-public/AB6AXuAZw-bsfuU6gHSXKFzt1NQryxT54T9dIZoD-MIBKRW5cQlFWGLs4bWGc5gtDHzRBDO7pRYvhGEnyCccUhsSYUHoc8jR4AFdU9C2FOUplPXB9mCPzRPpnbKtiIgKYC8QXUPEKAX-62hBwRXvWpmnm6MSjM93-mDvuvIfufY5xWIvhiYSNkexUXV4M6t2QXKvQyZLmbSAJXBKNO670ekw0568gHKfkdX8iSZdmzHgZx2K_lOXgq4UcS2dORJO49Jc4axYkhfZHizbsQE"),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : const Color(0xFF111518),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '共 $diaryCount 篇日记',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/mine/profile');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '编辑资料',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
