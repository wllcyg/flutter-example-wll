import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/res/colors.dart';

class TimelineHeader extends SliverPersistentHeaderDelegate {
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
                Container(
                  width: 40.w,
                  height: 40.w,
                  alignment: Alignment.center,
                  child: Icon(Icons.calendar_today,
                      color: AppColors.primary, size: 24.w),
                ),
                Text(
                  '时间轴',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF111518),
                  ),
                ),
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Icon(Icons.search,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : const Color(0xFF111518),
                      size: 24.w),
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
