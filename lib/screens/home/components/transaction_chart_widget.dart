// lib/screens/home/components/transaction_chart_widget.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TransactionBarChart extends StatelessWidget {
  final List<double> values;
  const TransactionBarChart({required this.values, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineCol = isDark ? Colors.cyanAccent : const Color(0xFF3C78A1);
    final textCol = isDark ? Colors.white : const Color(0xFF3C78A1);

    final spots = [
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    final maxY =
        (values.fold<double>(0, (m, v) => v > m ? v : m) * 1.2).ceilToDouble();

    return AspectRatio(
      aspectRatio: 1.6,
      child: LineChart(
        LineChartData(
          maxY: maxY,
          minY: 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),

          // --------- Linha principal ----------
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 2,
              color: lineCol,
              dotData: FlDotData(
                show: true,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lineCol.withOpacity(0.3),
                    lineCol.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],

          // --------- Eixos ----------
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(
                  showTitles: false), // “D1, D2…” se quiser, adicione aqui
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: maxY / 4,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: TextStyle(color: textCol, fontSize: 10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
