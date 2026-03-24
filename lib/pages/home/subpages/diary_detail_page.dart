import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/models/diary_entry.dart';
import 'package:my_flutter_app/res/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:my_flutter_app/providers/diary_provider.dart';

class DiaryDetailPage extends ConsumerWidget {
  final String id;
  final DiaryEntry? entry;

  const DiaryDetailPage({super.key, required this.id, this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get real-time updates
    final diaryListAsync = ref.watch(diaryListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Try to find the updated entry from the list
    // Priority:
    // 1. Updated item in list (if loaded)
    // 2. Passed 'entry' (extra object)
    // 3. Loading/Error state
    final asyncEntry = diaryListAsync
        .whenData((list) => list.firstWhereOrNull((e) => e.id == id));

    final DiaryEntry? displayedEntry = asyncEntry.valueOrNull ?? entry;

    // Loading State (Deep Link case: no extra, list loading)
    if (displayedEntry == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: isDark ? Colors.white : const Color(0xFF111518)),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Format Date: 2023年10月24日 星期二
    final dateStr = DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN')
        .format(displayedEntry.createdAt);
    // Format Time: 14:30
    final timeStr = DateFormat('HH:mm').format(displayedEntry.createdAt);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: isDark ? Colors.white : const Color(0xFF111518)),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          '日记详情',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : const Color(0xFF111518),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Share button removed per request
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.primary),
            onPressed: () {
              SmartDialog.show(
                builder: (_) => AlertDialog(
                  backgroundColor:
                      isDark ? AppColors.surfaceDark : Colors.white,
                  title: Text('确认删除',
                      style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary)),
                  content: Text('确定要删除这篇日记吗？删除后无法恢复。',
                      style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => SmartDialog.dismiss(),
                      child: Text('取消',
                          style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () async {
                        SmartDialog.dismiss(); // Dismiss dialog
                        SmartDialog.showLoading(msg: "删除中...");
                        try {
                          await ref
                              .read(diaryListProvider.notifier)
                              .deleteEntry(displayedEntry.id);
                          SmartDialog.showToast("删除成功");
                          if (context.mounted) {
                            context.pop(); // Pop Detail Page
                          }
                        } catch (e) {
                          SmartDialog.showToast("删除失败: $e");
                        } finally {
                          SmartDialog.dismiss();
                        }
                      },
                      child:
                          const Text('删除', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          TextButton(
            onPressed: () {
              context.pushNamed('calendar_add', extra: displayedEntry);
            },
            child: Text(
              '编辑',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HeadlineText: Date
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
              child: Text(
                dateStr,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : const Color(0xFF111518),
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // MetaText: Time · Location · Weather
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
              child: Row(
                children: [
                  Icon(Icons.schedule,
                      size: 14.sp,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF60778A)),
                  SizedBox(width: 4.w),
                  Text(
                    timeStr,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF60778A),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // TitleText
            if (displayedEntry.title != null &&
                displayedEntry.title!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                child: Text(
                  displayedEntry.title!,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF111518),
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.015 * 22.sp,
                  ),
                ),
              ),

            // BodyText
            if (displayedEntry.content != null &&
                displayedEntry.content!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Text(
                  displayedEntry.content!,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : const Color(0xFF111518),
                    fontSize: 18.sp,
                    height: 1.6, // leading-relaxed
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),

            // Image Section
            if (displayedEntry.coverUrl != null &&
                displayedEntry.coverUrl!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: displayedEntry.coverUrl!,
                    width: double.infinity,
                    height: 250.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color:
                          isDark ? AppColors.backgroundDark : Colors.grey[100],
                      height: 250.h,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color:
                          isDark ? AppColors.backgroundDark : Colors.grey[100],
                      height: 250.h,
                      child: Icon(Icons.broken_image,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : Colors.grey),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
