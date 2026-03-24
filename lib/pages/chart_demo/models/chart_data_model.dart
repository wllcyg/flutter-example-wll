import 'package:fl_chart/fl_chart.dart';

class ChartDataModel {
  final List<FlSpot> lineChartData;
  final List<double> barChartData;
  final List<PieChartDataModel> pieChartData;

  ChartDataModel({
    required this.lineChartData,
    required this.barChartData,
    required this.pieChartData,
  });
}

class PieChartDataModel {
  final String label;
  final double value;
  final double percentage;

  PieChartDataModel({
    required this.label,
    required this.value,
    required this.percentage,
  });
}