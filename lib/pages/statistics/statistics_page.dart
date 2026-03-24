import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_flutter_app/models/diary_entry.dart';
import 'package:my_flutter_app/providers/diary_provider.dart';
import 'package:my_flutter_app/res/colors.dart';
import 'package:my_flutter_app/pages/home/widgets/diary_card.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  /// Get entries for a specific day
  List<DiaryEntry> _getEntriesForDay(
      DateTime day, List<DiaryEntry> allEntries) {
    return allEntries.where((entry) {
      return isSameDay(entry.createdAt, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final diaryListAsync = ref.watch(diaryListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: diaryListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allEntries) {
          final selectedEntries = _getEntriesForDay(_selectedDay!, allEntries);

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // Custom App Bar for Calendar
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button (placeholder logic, usually not needed for main tab)
                        SizedBox(
                            width: 48
                                .w), // Placeholder for symmetry if back button existed
                        Text(
                          DateFormat('yyyy年MM月', 'zh_CN').format(_focusedDay),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : const Color(0xFF111518),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Future: Show today or options
                            setState(() {
                              _focusedDay = DateTime.now();
                              _selectedDay = DateTime.now();
                            });
                          },
                          child: Container(
                            width: 48.w,
                            height: 48.w,
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.today,
                                color: AppColors.primary, size: 24.w),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Calendar
                SliverToBoxAdapter(
                  child: TableCalendar<DiaryEntry>(
                    locale: 'zh_CN',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: _calendarFormat,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                    eventLoader: (day) {
                      return _getEntriesForDay(day, allEntries);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    headerVisible: false, // We use custom header above
                    daysOfWeekHeight: 40.h,
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF60778A),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      weekendStyle: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF60778A),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : const Color(0xFF111518),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                      weekendTextStyle: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : const Color(0xFF111518),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.primary, width: 1)),
                      todayTextStyle: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                      markerSize: 5.w,
                      markerDecoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      markersAlignment: Alignment.bottomCenter,
                      cellMargin: EdgeInsets.all(4.w),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Divider(
                        height: 1,
                        color: isDark
                            ? const Color(0xFF333333)
                            : const Color(0xFFF0F2F5)),
                  ),
                ),

                // "Today's Diary" Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Text(
                      '当日日记',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : const Color(0xFF111518),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                // Diary Entries List
                if (selectedEntries.isEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      height: 200.h,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_off,
                              size: 48.w,
                              color:
                                  isDark ? Colors.grey[700] : Colors.grey[300]),
                          SizedBox(height: 12.h),
                          Text('这一天没有写日记哦',
                              style: TextStyle(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                  fontSize: 13.sp))
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return DiaryCard(entry: selectedEntries[index]);
                      },
                      childCount: selectedEntries.length,
                    ),
                  ),

                SliverToBoxAdapter(child: SizedBox(height: 80.h)),
              ],
            ),
          );
        },
      ),
    );
  }
}
