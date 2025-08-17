import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesLineChart extends StatelessWidget {
  final List<double> pastWeeks;
  final double predicted;

  const SalesLineChart({
    super.key,
    required this.pastWeeks,
    required this.predicted,
  });

  @override
  Widget build(BuildContext context) {
    final allY = [...pastWeeks, predicted];
    final maxY = (allY.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble();

    // Estilo branco opaco (ou use Theme.of(context).colorScheme.onBackground)
    const axisStyle = TextStyle(color: Colors.white, fontSize: 10);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        borderData: FlBorderData(show: false),

        // ---------- Rótulos ----------
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (value, meta) {
                // Exibe W1, W2, …, Prev
                final idx = value.toInt();
                final isPred = idx == pastWeeks.length;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    isPred ? 'Prev' : 'W${idx + 1}',
                    style: axisStyle,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: maxY / 4,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: axisStyle,
              ),
            ),
          ),
        ),

        // ---------- Linha ----------
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < pastWeeks.length; i++)
                FlSpot(i.toDouble(), pastWeeks[i]),
              FlSpot(pastWeeks.length.toDouble(), predicted),
            ],
            isCurved: true,
            barWidth: 2,
            color: Colors.cyanAccent,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
