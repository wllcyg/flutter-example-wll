import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/models/diary_entry.dart';
import 'package:my_flutter_app/res/colors.dart';

class DiaryCard extends StatelessWidget {
  final DiaryEntry entry;

  const DiaryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final hasCover = entry.coverUrl != null && entry.coverUrl!.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasCover)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: entry.coverUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  debugPrint('Loading Image: $url');
                  return Container(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.background,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorWidget: (context, url, error) {
                  debugPrint('Image Load Error: $url, error: $error');
                  return Container(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.background,
                    child: Icon(Icons.broken_image,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                  );
                },
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(entry.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF60778A),
                      ),
                    ),
                    if (entry.moodEmoji != null)
                      Text(
                        entry.moodEmoji!,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                if (entry.title != null && entry.title!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text(
                      entry.title!,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : const Color(0xFF111518),
                        height: 1.25,
                        letterSpacing: -0.015 * 18.sp,
                      ),
                    ),
                  ),
                if (entry.content != null && entry.content!.isNotEmpty)
                  Text(
                    entry.content!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF60778A),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // context.push('/detail', extra: entry); // Use pushNamed for clearer passing of extra if preferred, or standard push
                        // GoRouter needs context.push with extra kwarg if using path, or pushNamed with extra.
                        context.pushNamed(
                          'detail',
                          pathParameters: {'id': entry.id},
                          extra: entry,
                        );
                      },
                      child: Container(
                        height: 36.h,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '查看详情',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
