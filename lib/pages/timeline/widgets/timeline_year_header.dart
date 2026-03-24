import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/res/colors.dart';

class TimelineYearHeader extends SliverPersistentHeaderDelegate {
  final String year;

  TimelineYearHeader({required this.year});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.backgroundDark : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      alignment: Alignment.centerLeft,
      child: Text(
        '$year年',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textSecondaryDark : const Color(0xFFA0A0A0),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 50.h;

  @override
  double get minExtent => 50.h;

  @override
  bool shouldRebuild(covariant TimelineYearHeader oldDelegate) {
    return true; // Rebuild on theme changes
  }
}
