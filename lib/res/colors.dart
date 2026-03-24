import 'package:flutter/material.dart';

class AppColors {
  // 主色调 (品牌色)
  static const Color primary = Color(0xFF689EFD);

  // 背景色
  static const Color background = Color(0xFFF5F5F7); // 类似 iOS 的浅灰背景
  static const Color surface = Colors.white; // 卡片背景

  // 文字颜色
  static const Color textPrimary = Color(0xFF333333); // 主要文字
  static const Color textSecondary = Color(0xFF666666); // 次要文字
  static const Color textHint = Color(0xFFCCCCCC); // 提示文字

  // 功能色
  static const Color success = Color(0xFF52C41A);
  static const Color error = Color(0xFFFF4D4F);
  static const Color warning = Color(0xFFFAAD14);

  // 按钮禁用状态 (浅蓝系)
  static const Color buttonDisabledBg = Color(0xFF96BBFA);
  static const Color buttonDisabledText = Color(0xFFD4E2FA);

  // 输入框背景
  static const Color inputBackground = Color(0xFFF2F4F7);
  // 占位符文字颜色 (比 hint 更深一点)
  static const Color textPlaceholder = Color(0xFF999999);
  // 附件按钮背景
  static const Color attachmentBg = Color(0xFFEBF5FF);

  // ============ 深色模式颜色 ============
  // 背景色 (深色模式)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // 文字颜色 (深色模式)
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color textHintDark = Color(0xFF666666);
  static const Color textPlaceholderDark = Color(0xFF888888);

  // 输入框背景 (深色模式)
  static const Color inputBackgroundDark = Color(0xFF2C2C2C);
  // 附件按钮背景 (深色模式)
  static const Color attachmentBgDark = Color(0xFF1A3050);

  // 定义字体大小
  static const double font12 = 12;
  static const double font14 = 14;
  static const double font16 = 16;
  static const double font18 = 18;
  static const double font20 = 20;
}
