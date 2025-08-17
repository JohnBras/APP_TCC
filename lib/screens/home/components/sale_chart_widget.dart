import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class SaleBarChart extends StatelessWidget {
  /// Mapa "Jan".."Dez" -> total vendido no mês
  final Map<String, double> monthlySales;

  /// 0..11 para destacar o mês selecionado (opcional)
  final int? selectedMonthIndex;

  const SaleBarChart({
    required this.monthlySales,
    this.selectedMonthIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlySales.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('Sem dados de vendas')),
      );
    }

    // ----- Cores dependentes do tema -----
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? Colors.cyanAccent : const Color(0xFF3C78A1);
    final textColor = isDark ? Colors.white : const Color(0xFF3C78A1);

    // Formatter com 2 casas (sem símbolo)
    final numFmt = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );

    // Ordena por mês para garantir a sequência correta no eixo X
    final ordered = monthlySales.entries.toList()
      ..sort((a, b) => _monthToInt(a.key).compareTo(_monthToInt(b.key)));

    final labels = ordered.map((e) => e.key).toList();
    final values = ordered.map((e) => (e.value).toDouble()).toList();

    // Constrói os pontos da linha
    final spots = <FlSpot>[
      for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    // Escala “bonita” do eixo Y
    final rawMax = values.fold<double>(0, (m, v) => v > m ? v : m);
    final maxY = _niceUpper(rawMax * 1.2); // folga de 20%
    final stepY = _niceStep(maxY / 4);

    // Seleção válida?
    final sel = (selectedMonthIndex != null &&
            selectedMonthIndex! >= 0 &&
            selectedMonthIndex! < labels.length)
        ? selectedMonthIndex
        : null;

    return AspectRatio(
      aspectRatio: 1.6,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(0, labels.length - 1).toDouble(),
          minY: 0,
          maxY: maxY == 0 ? 1 : maxY,

          // Tooltip com 2 casas decimais (somente o essencial p/ compatibilidade)
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots.map((barSpot) {
                final i = barSpot.x.toInt();
                final mes = (i >= 0 && i < labels.length) ? labels[i] : '';
                final valor = numFmt.format(barSpot.y);
                return LineTooltipItem(
                  '$mes\n$valor',
                  TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),

          // Linha principal
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: lineColor,
              dotData: FlDotData(
                show: sel != null,
                getDotPainter: (spot, _, __, index) {
                  final isSel = sel != null && index == sel;
                  return FlDotCirclePainter(
                    radius: isSel ? 4 : 2,
                    color: lineColor,
                    strokeWidth: isSel ? 2 : 0,
                    strokeColor: lineColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lineColor.withOpacity(0.22),
                    lineColor.withOpacity(0.04),
                  ],
                ),
              ),
            ),
          ],

          // Linha vertical no mês selecionado
          extraLinesData: ExtraLinesData(
            verticalLines: sel == null
                ? const []
                : [
                    VerticalLine(
                      x: sel
                          .toDouble(), // o '!' aqui é opcional; pode trocar por sel.toDouble()
                      color: lineColor.withOpacity(0.25),
                      strokeWidth: 1,
                      dashArray: const [4, 3],
                    ),
                  ],
          ),

          // ---------- Eixos ----------
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length)
                    return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i], // só meses
                      style: TextStyle(color: textColor, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: stepY == 0 ? 1 : stepY,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(), // mantém inteiros no eixo Y
                  style: TextStyle(color: textColor, fontSize: 10),
                ),
              ),
            ),
          ),

          // Grade e bordas
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            verticalInterval: 1, // um grid por rótulo de mês
            horizontalInterval: stepY == 0 ? 1 : stepY,
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // Mapeia "Jan".."Dez" -> 0..11
  int _monthToInt(String abbr) => const [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez'
      ].indexOf(abbr);

  // Arredonda para um “teto” bonito (1, 2, 5 * 10^n)
  double _niceUpper(double x) {
    if (x <= 0) return 0;
    final exp = (math.log(x) / math.ln10).floor();
    final base = math.pow(10, exp).toDouble();
    final scaled = x / base;
    final nice = (scaled <= 1)
        ? 1
        : (scaled <= 2)
            ? 2
            : (scaled <= 5)
                ? 5
                : 10;
    return nice * base;
  }

  // Passo “bonito” (1, 2, 5 * 10^n) próximo ao alvo
  double _niceStep(double target) {
    if (target <= 0) return 0;
    final exp = (math.log(target) / math.ln10).floor();
    final base = math.pow(10, exp).toDouble();
    final scaled = target / base;
    final nice = (scaled <= 1.5)
        ? 1
        : (scaled <= 3)
            ? 2
            : 5;
    return nice * base;
  }
}
