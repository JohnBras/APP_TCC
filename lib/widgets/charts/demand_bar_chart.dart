import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/forecast.dart';

class DemandBarChart extends StatelessWidget {
  final Forecast forecast;
  final double alertThreshold;

  const DemandBarChart({
    Key? key,
    required this.forecast,
    required this.alertThreshold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final diffPerc = ((forecast.predicted - forecast.historicalAverage) /
            forecast.historicalAverage) *
        100;
    final isAlert = diffPerc >= alertThreshold;

    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(toY: forecast.historicalAverage, width: 12),
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                toY: forecast.predicted,
                width: 12,
                color: isAlert ? Colors.redAccent : Colors.blueAccent,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
