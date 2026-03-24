import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/models/diary_entry.dart';
import 'package:my_flutter_app/pages/home/widgets/home_header.dart';
import 'package:my_flutter_app/pages/home/widgets/diary_card.dart';
import 'package:my_flutter_app/res/colors.dart';
import 'package:my_flutter_app/providers/diary_provider.dart';
import 'package:my_flutter_app/widgets/my_card.dart';
import 'package:my_flutter_app/widgets/my_builder_list.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    initializeDateFormatting('zh_CN', null);

    final diaryListAsync = ref.watch(diaryListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 💡 状态管理：这里类似于 Vue 3 的 const selectedTag = ref('全部')
    final selectedTag = useState('全部');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: diaryListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (entries) {
          // Group entries by date (YYYY-MM-DD)
          final groupedEntries = groupBy(entries, (DiaryEntry entry) {
            return DateFormat('yyyy-MM-dd').format(entry.createdAt);
          });

          return RefreshIndicator(
            onRefresh: () => ref.refresh(diaryListProvider.future),
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: HomeHeader(),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: MyCard(
                      title: '组件封装演示 (Day 11)',
                      backgroundColor:
                          isDark ? Colors.blueGrey[900] : Colors.amber[50],
                      margin: EdgeInsets.zero, // 外部覆盖默认 margin
                      extra: Icon(Icons.info_outline,
                          color: Theme.of(context).primaryColor),
                      onAction: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('你点击了封装组件的"确认"按钮！')),
                        );
                      },
                      actionText: '点我试试',
                      footer: const Text('这是 Footer 插槽的内容',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      child: const Text(
                          '这是一个演示如何像 Vue 一样封装 Flutter 组件的例子。包含 Props, Slots 和 Emits。'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Builder 模式演示 (作用域插槽)：',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        MyChoiceBox<String>(
                          items: const ['全部', '生活', '工作', '心情'],
                          selectedItem: selectedTag.value,
                          onSelected: (val) => selectedTag.value = val,
                          itemBuilder: (context, item, isSelected) {
                            // 这里就像 Vue 的 <template #default="{ item, isSelected }">
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : (isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black),
                                  fontSize: 12.sp,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
                if (entries.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book,
                              size: 64.w,
                              color:
                                  isDark ? Colors.grey[700] : Colors.grey[300]),
                          SizedBox(height: 16.h),
                          Text(
                            '还没有日记，快去写一篇吧~',
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
                  )
                else
                  ...groupedEntries.entries.map((group) {
                    final dateStr = group.key;
                    final dayEntries = group.value;
                    final date = DateTime.parse(dateStr);
                    final formattedDate =
                        DateFormat('yyyy-MM-dd EEEE', 'zh_CN').format(date);

                    return SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 20.w, bottom: 8.h, top: 16.h),
                            child: Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : const Color(0xFF60778A),
                                letterSpacing: -0.015 * 14.sp,
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return DiaryCard(entry: dayEntries[index]);
                            },
                            childCount: dayEntries.length,
                          ),
                        ),
                      ],
                    );
                  }),
                // Add some bottom padding
                SliverToBoxAdapter(child: SizedBox(height: 80.h)),
              ],
            ),
          );
        },
      ),
    );
  }
}
