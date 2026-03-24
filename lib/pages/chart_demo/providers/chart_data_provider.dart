import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_flutter_app/pages/chart_demo/models/chart_data_model.dart';

class ChartDataNotifier extends StateNotifier<ChartDataModel> {
  ChartDataNotifier() : super(_generateInitialData());

  static ChartDataModel _generateInitialData() {
    final random = Random();
    
    // 折线图数据 - 6个月的数据趋势
    final lineChartData = List.generate(6, (index) {
      return FlSpot(
        (index + 1).toDouble(),
        1 + random.nextDouble() * 4, // 1-5 之间的随机值
      );
    });

    // 柱状图数据 - 一周7天的数据
    final barChartData = List.generate(7, (index) {
      return 5 + random.nextDouble() * 15; // 5-20 之间的随机值
    });

    // 饼图数据 - 5个分类的占比
    final categories = ['工作', '学习', '娱乐', '运动', '其他'];
    final values = List.generate(5, (index) => 10 + random.nextDouble() * 40);
    final total = values.reduce((a, b) => a + b);
    
    final pieChartData = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final label = entry.value;
      final value = values[index];
      final percentage = (value / total) * 100;
      
      return PieChartDataModel(
        label: label,
        value: value,
        percentage: percentage,
      );
    }).toList();

    return ChartDataModel(
      lineChartData: lineChartData,
      barChartData: barChartData,
      pieChartData: pieChartData,
    );
  }

  void refreshData() {
    state = _generateInitialData();
  }
}

final chartDataProvider = StateNotifierProvider<ChartDataNotifier, ChartDataModel>(
  (ref) => ChartDataNotifier(),
);