import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_flutter_app/res/colors.dart';
import 'package:my_flutter_app/pages/chart_demo/providers/chart_data_provider.dart';

class ChartDemoPage extends ConsumerStatefulWidget {
  const ChartDemoPage({super.key});

  @override
  ConsumerState<ChartDemoPage> createState() => _ChartDemoPageState();
}

class _ChartDemoPageState extends ConsumerState<ChartDemoPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        title: Text(
          '图表可视化',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '折线图'),
            Tab(text: '柱状图'),
            Tab(text: '饼图'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLineChartTab(isDark),
          _buildBarChartTab(isDark),
          _buildPieChartTab(isDark),
        ],
      ),
    );
  }

  Widget _buildLineChartTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('数据趋势展示', isDark),
          SizedBox(height: 16.h),
          _buildLineChart(isDark),
          SizedBox(height: 24.h),
          _buildRefreshButton(),
        ],
      ),
    );
  }

  Widget _buildBarChartTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('分类数据对比', isDark),
          SizedBox(height: 16.h),
          _buildBarChart(isDark),
          SizedBox(height: 24.h),
          _buildRefreshButton(),
        ],
      ),
    );
  }

  Widget _buildPieChartTab(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('占比分析', isDark),
          SizedBox(height: 16.h),
          _buildPieChart(isDark),
          SizedBox(height: 24.h),
          _buildRefreshButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildLineChart(bool isDark) {
    final chartData = ref.watch(chartDataProvider);
    
    return Container(
      height: 300.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final style = TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  );
                  Widget text;
                  switch (value.toInt()) {
                    case 1:
                      text = Text('1月', style: style);
                      break;
                    case 2:
                      text = Text('2月', style: style);
                      break;
                    case 3:
                      text = Text('3月', style: style);
                      break;
                    case 4:
                      text = Text('4月', style: style);
                      break;
                    case 5:
                      text = Text('5月', style: style);
                      break;
                    case 6:
                      text = Text('6月', style: style);
                      break;
                    default:
                      text = Text('', style: style);
                      break;
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: text,
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final style = TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  );
                  return Text('${value.toInt()}', style: style);
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          minX: 0,
          maxX: 7,
          minY: 0,
          maxY: 6,
          lineBarsData: [
            LineChartBarData(
              spots: chartData.lineChartData,
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.3),
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => isDark 
                  ? Colors.grey[800]! 
                  : Colors.grey[100]!,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  return LineTooltipItem(
                    '${barSpot.x.toInt()}月\n${barSpot.y.toStringAsFixed(1)}',
                    TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
            getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((spotIndex) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: AppColors.primary,
                        strokeWidth: 3,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(bool isDark) {
    final chartData = ref.watch(chartDataProvider);
    
    return Container(
      height: 300.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => isDark 
                  ? Colors.grey[800]! 
                  : Colors.grey[100]!,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String weekDay;
                switch (group.x) {
                  case 0:
                    weekDay = '周一';
                    break;
                  case 1:
                    weekDay = '周二';
                    break;
                  case 2:
                    weekDay = '周三';
                    break;
                  case 3:
                    weekDay = '周四';
                    break;
                  case 4:
                    weekDay = '周五';
                    break;
                  case 5:
                    weekDay = '周六';
                    break;
                  case 6:
                    weekDay = '周日';
                    break;
                  default:
                    weekDay = '';
                }
                return BarTooltipItem(
                  '$weekDay\n${rod.toY.round()}',
                  TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              // 可以在这里添加触摸回调逻辑
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final style = TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  );
                  Widget text;
                  switch (value.toInt()) {
                    case 0:
                      text = Text('周一', style: style);
                      break;
                    case 1:
                      text = Text('周二', style: style);
                      break;
                    case 2:
                      text = Text('周三', style: style);
                      break;
                    case 3:
                      text = Text('周四', style: style);
                      break;
                    case 4:
                      text = Text('周五', style: style);
                      break;
                    case 5:
                      text = Text('周六', style: style);
                      break;
                    case 6:
                      text = Text('周日', style: style);
                      break;
                    default:
                      text = Text('', style: style);
                      break;
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: text,
                  );
                },
                reservedSize: 38,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 5,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final style = TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  );
                  return Text('${value.toInt()}', style: style);
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: chartData.barChartData.asMap().entries.map((entry) {
            final colors = [
              AppColors.primary,
              Colors.orange,
              Colors.green,
              Colors.red,
              Colors.purple,
              Colors.teal,
              Colors.amber,
            ];
            
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  gradient: LinearGradient(
                    colors: [
                      colors[entry.key % colors.length],
                      colors[entry.key % colors.length].withValues(alpha: 0.7),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 20,
                    color: isDark 
                        ? Colors.grey[800]!.withValues(alpha: 0.3)
                        : Colors.grey[200]!.withValues(alpha: 0.3),
                  ),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(bool isDark) {
    final chartData = ref.watch(chartDataProvider);
    
    return Container(
      height: 300.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedPieIndex = -1;
                        return;
                      }
                      touchedPieIndex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: chartData.pieChartData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final isTouched = index == touchedPieIndex;
                  final fontSize = isTouched ? 14.0 : 12.0;
                  final radius = isTouched ? 70.0 : 60.0;
                  final colors = [
                    AppColors.primary,
                    Colors.orange,
                    Colors.green,
                    Colors.red,
                    Colors.purple,
                  ];
                  
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: data.value,
                    title: '${data.percentage.toStringAsFixed(1)}%',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: chartData.pieChartData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final isTouched = index == touchedPieIndex;
                final colors = [
                  AppColors.primary,
                  Colors.orange,
                  Colors.green,
                  Colors.red,
                  Colors.purple,
                ];
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTouched ? 8.w : 4.w,
                    vertical: isTouched ? 6.h : 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isTouched 
                        ? colors[index % colors.length].withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.label,
                              style: TextStyle(
                                fontSize: isTouched ? 13.sp : 12.sp,
                                fontWeight: isTouched 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            if (isTouched) ...[
                              SizedBox(height: 2.h),
                              Text(
                                '${data.value.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: isDark 
                                      ? Colors.grey[400] 
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          ref.read(chartDataProvider.notifier).refreshData();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('刷新数据'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}