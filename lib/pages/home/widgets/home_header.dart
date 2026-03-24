import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/res/colors.dart';

class HomeHeader extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.8),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          alignment: Alignment.center,
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '首页',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF111518),
                    letterSpacing: -0.015 * 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent =>
      60.h +
      MediaQueryData.fromView(PlatformDispatcher.instance.views.first)
          .padding
          .top;

  @override
  double get minExtent =>
      60.h +
      MediaQueryData.fromView(PlatformDispatcher.instance.views.first)
          .padding
          .top;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true; // Rebuild on theme changes
  }
}
