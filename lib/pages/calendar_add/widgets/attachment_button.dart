import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/res/colors.dart';

class AttachmentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Widget? customIcon;
  final VoidCallback? onClear;

  const AttachmentButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.customIcon,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80.w,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: customIcon ?? Icon(icon, color: color, size: 24.w),
                ),
                if (onClear != null)
                  Positioned(
                    right: -4.w,
                    top: -4.w,
                    child: GestureDetector(
                      onTap: onClear,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 12.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(label,
                style:
                    TextStyle(fontSize: 12.sp, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
