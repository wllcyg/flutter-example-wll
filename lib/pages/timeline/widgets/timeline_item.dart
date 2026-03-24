import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/models/diary_entry.dart';
import 'package:my_flutter_app/res/colors.dart';

class TimelineItem extends StatelessWidget {
  final DiaryEntry entry;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.entry,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(entry.createdAt);
    final hasCover = entry.coverUrl != null && entry.coverUrl!.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline visual column
          SizedBox(
            width: 40.w,
            child: Column(
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: CustomPaint(
                    painter: DashedLinePainter(
                      color: isDark
                          ? const Color(0xFF444444)
                          : const Color(0xFFDBE1E6),
                      isLast: isLast,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content column
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8.w, bottom: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : const Color(0xFF111518),
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                          color: isDark
                              ? const Color(0xFF333333)
                              : const Color(0xFFF3F4F6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.05),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry.content != null && entry.content!.isNotEmpty)
                          Text(
                            entry.content!,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : const Color(0xFF111518),
                              height: 1.5,
                            ),
                          ),
                        if (hasCover) ...[
                          SizedBox(height: 12.h),
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: CachedNetworkImage(
                                imageUrl: entry.coverUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: isDark
                                      ? AppColors.backgroundDark
                                      : AppColors.background,
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: isDark
                                      ? AppColors.backgroundDark
                                      : AppColors.background,
                                  child: Icon(Icons.broken_image,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary),
                                ),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                size: 14.sp,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : const Color(0xFF60778A)),
                            SizedBox(width: 4.w),
                            Text(
                              DateFormat('HH:mm').format(entry.createdAt),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : const Color(0xFF60778A),
                              ),
                            ),
                            if (entry.moodEmoji != null) ...[
                              SizedBox(width: 8.w),
                              Text(entry.moodEmoji!,
                                  style: TextStyle(fontSize: 14.sp)),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final bool isLast;

  DashedLinePainter({required this.color, this.isLast = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (isLast) {
      // Draw gradient fade out for last item
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ).createShader(
            Rect.fromLTWH(size.width / 2 - 0.75, 0, 1.5, size.height));
      canvas.drawRect(
          Rect.fromLTWH(size.width / 2 - 0.75, 0, 1.5, size.height), paint);
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    const dashHeight = 8.0;
    const dashSpace = 4.0;
    double startY = 0;

    // Draw dashed line center vertically
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isLast != isLast;
  }
}
