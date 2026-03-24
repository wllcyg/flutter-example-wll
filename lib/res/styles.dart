import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

class AppStyles {
  // 文字样式规范
  static TextStyle get text12 =>
      TextStyle(fontSize: 12.sp, color: AppColors.textPrimary);
  static TextStyle get text14 =>
      TextStyle(fontSize: 14.sp, color: AppColors.textPrimary);
  static TextStyle get text16 =>
      TextStyle(fontSize: 16.sp, color: AppColors.textPrimary);
  static TextStyle get text18 => TextStyle(
      fontSize: 18.sp,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold);
  static TextStyle get text24 => TextStyle(
      fontSize: 24.sp,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold);

  // 变体 (灰色文字)
  static TextStyle get textGray12 =>
      text12.copyWith(color: AppColors.textSecondary);
  static TextStyle get textGray14 =>
      text14.copyWith(color: AppColors.textSecondary);

  // 阴影样式
  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
}
