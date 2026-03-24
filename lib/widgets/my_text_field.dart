import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/res/colors.dart';
import 'package:my_flutter_app/res/styles.dart';

class MyTextField extends HookWidget {
  const MyTextField({
    super.key,
    required this.controller,
    this.hintText = '',
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.keyboardAction = TextInputAction.next,
    this.onChanged,
    this.suffix, // 新增插槽
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction keyboardAction;
  final ValueChanged<String>? onChanged;
  final Widget? suffix; // 插槽定义

  @override
  Widget build(BuildContext context) {
    // 1. 监听 controller 变化，以便实时显示/隐藏 清除按钮
    // useListenable 会在 controller 发出通知时重建 Widget
    useListenable(controller);

    // 2. 密码显隐状态 (仅当 obscureText=true 时使用)
    final isObscure = useState(obscureText);

    return TextField(
      controller: controller,
      obscureText: isObscure.value, // 使用 Hook 状态
      keyboardType: keyboardType,
      textInputAction: keyboardAction,
      onChanged: onChanged,
      style: AppStyles.text14,

      // 覆盖默认样式，使用简洁的下划线风格
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppStyles.text14.copyWith(color: AppColors.textHint),
        filled: false,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        isDense: true,

        // --- 后缀图标逻辑 (Suffix Icon) ---
        // 优先级：如果传了 suffix (插槽)，直接显示插槽内容
        suffixIcon: suffix ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // A. 清除按钮 (有字且有焦点时才显示？通常只要有字就显示比较直观)
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.cancel,
                        color: Color(0xFFCCCCCC), size: 20),
                    onPressed: () {
                      controller.clear();
                      onChanged?.call(''); // 手动触发回调
                    },
                  ),

                // B. 眼睛按钮 (仅在密码模式下显示)
                if (obscureText)
                  IconButton(
                    icon: Icon(
                      isObscure.value ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFFCCCCCC),
                      size: 20,
                    ),
                    onPressed: () {
                      isObscure.value = !isObscure.value;
                    },
                  ),
              ],
            ),

        // 默认边框 (浅灰下划线)
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE6E6E6), width: 0.5),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE6E6E6), width: 0.5),
        ),
        // 聚焦边框 (主色下划线)
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }
}
