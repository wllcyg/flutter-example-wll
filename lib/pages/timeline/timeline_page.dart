import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/models/diary_entry.dart';
import 'package:my_flutter_app/pages/timeline/widgets/timeline_header.dart';
import 'package:my_flutter_app/pages/timeline/widgets/timeline_year_header.dart';
import 'package:my_flutter_app/pages/timeline/widgets/timeline_item.dart';
import 'package:my_flutter_app/providers/diary_provider.dart';
import 'package:my_flutter_app/res/colors.dart';

class TimelinePage extends ConsumerWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryListAsync = ref.watch(diaryListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: diaryListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (entries) {
          if (entries.isEmpty) {
            return CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: TimelineHeader(),
                  pinned: true,
                ),
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history,
                            size: 64.w,
                            color:
                                isDark ? Colors.grey[700] : Colors.grey[300]),
                        SizedBox(height: 16.h),
                        Text(
                          '暂无时间轴记录',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Group by Year
          final groupedByYear = groupBy(entries, (DiaryEntry entry) {
            return entry.createdAt.year.toString();
          });

          return RefreshIndicator(
            onRefresh: () => ref.refresh(diaryListProvider.future),
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: TimelineHeader(),
                  pinned: true,
                ),
                ...groupedByYear.entries.map((yearGroup) {
                  final year = yearGroup.key;
                  final yearEntries = yearGroup.value;

                  return SliverMainAxisGroup(
                    slivers: [
                      SliverPersistentHeader(
                        delegate: TimelineYearHeader(year: year),
                        pinned: true,
                      ),
                      SliverPadding(
                        padding:
                            EdgeInsets.only(left: 16.w, right: 16.w, top: 0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final isLast = index == yearEntries.length - 1;
                              return TimelineItem(
                                entry: yearEntries[index],
                                isLast: isLast,
                              );
                            },
                            childCount: yearEntries.length,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                SliverToBoxAdapter(child: SizedBox(height: 80.h)),
              ],
            ),
          );
        },
      ),
    );
  }
}
