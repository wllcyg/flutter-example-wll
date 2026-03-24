import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/res/colors.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    this.text = '',
    this.onPressed,
    this.width = double.infinity, // 默认宽度占满父容器
    this.height = 48, // 默认高度 48 (方便手指点击)
    this.fontSize = 18,
    this.radius = 24,
    this.backgroundColor,
    this.disabled = false, // 新增：可手动强制禁用
  });

  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double fontSize;
  final double radius;
  final Color? backgroundColor;
  final bool disabled; // 新增字段

  @override
  Widget build(BuildContext context) {
    // 使用 Theme 里配置好的样式，但也允许临时覆盖
    final themeStyle = Theme.of(context).elevatedButtonTheme.style;

    return SizedBox(
      width: width == double.infinity ? double.infinity : width.w,
      height: height.h,
      child: ElevatedButton(
        // 只有当 onPressed 本身就是 null 时，才真的让它不可点
        onPressed: (disabled || onPressed == null) ? null : onPressed,
        style: themeStyle?.copyWith(
          // 背景色处理：如果是 disabled 状态，我们不能让 onPressed 为 null (否则会被强制变灰)
          // 但这里我们用了一个可以在 disabled 状态下也生效的技巧：使用 MaterialStateProperty.resolveWith
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (disabled) return AppColors.buttonDisabledBg;
            if (backgroundColor != null) return backgroundColor;
            // 回退到 Theme 的默认配置
            return AppColors.primary;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius.r)),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize.sp,
            color: disabled ? AppColors.buttonDisabledText : Colors.white,
          ),
        ),
      ),
    );
  }
}
