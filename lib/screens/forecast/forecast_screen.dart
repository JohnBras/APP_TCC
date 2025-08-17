import 'package:app_tcc/models/forecast.dart';
import 'package:app_tcc/models/forecast_manager.dart';
import 'package:app_tcc/models/product_manager.dart';
import 'package:app_tcc/screens/home/components/transaction_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Consumer2<ForecastManager, ProductManager>(
      builder: (_, fm, pm, __) {
        final Forecast? sales = fm.sales; // previsão total
        final List<Forecast> demand = fm.demand; // previsão por produto

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // ====== Previsão Total (KPI + minigráfico) ======
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Previsão de Vendas Totais (próx. ${fm.windowDays} dias)',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    if (sales == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Carregando previsão total...'),
                          ],
                        ),
                      )
                    else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _kpi(context, 'Previsto', sales.predicted),
                          _kpi(context, 'Média Hist.', sales.historicalAverage),
                          _kpiDelta(context, sales.predicted,
                              sales.historicalAverage),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 160,
                        child: TransactionBarChart(
                          values: [sales.historicalAverage, sales.predicted],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gerado em: ${df.format(sales.generatedAt.toDate())}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ====== Seleção de janela ======
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [7, 14, 30].map((d) {
                final selected = d == fm.windowDays;
                return ChoiceChip(
                  label: Text('${d}d'),
                  selected: selected,
                  onSelected: (v) {
                    if (!selected) fm.updateWindowDays(d);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // ====== Previsão por Produto ======
            Text('Previsão por Produto',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),

            if (demand.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Sem previsões por produto no momento.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: demand.length,
                itemBuilder: (_, i) {
                  final f = demand[i];
                  final p = pm.findProductById(f.id); // resolve nome/imagem
                  final name = p?.name ?? 'Produto ${f.id}';
                  final img =
                      (p?.images.isNotEmpty ?? false) ? p!.images.first : null;
                  final delta = f.historicalAverage == 0
                      ? 0.0
                      : ((f.predicted - f.historicalAverage) /
                              f.historicalAverage) *
                          100.0;

                  return Card(
                    child: ListTile(
                      leading: SizedBox(
                        width: 44,
                        height: 44,
                        child: (img == null || img.isEmpty)
                            ? const CircleAvatar(child: Icon(Icons.inventory_2))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(img, fit: BoxFit.cover),
                              ),
                      ),
                      title: Text(
                        name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        'Previsto: ${f.predicted.toStringAsFixed(0)}  •  '
                        'Média: ${f.historicalAverage.toStringAsFixed(0)}',
                      ),
                      trailing: _trend(delta, scheme),
                      onTap: () {
                        // Ex.: Navigator.of(context).pushNamed('/forecast_product', arguments: f.id);
                      },
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _kpi(BuildContext context, String label, double value) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(0),
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _kpiDelta(BuildContext context, double predicted, double avg) {
    final diff = predicted - avg;
    final pct = avg == 0 ? 0 : (diff / avg) * 100.0;
    final isUp = pct >= 0;
    final color = isUp ? Colors.green : Colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('Variação'),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(isUp ? Icons.trending_up : Icons.trending_down,
                color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              '${pct.abs().toStringAsFixed(1)}%',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _trend(double pct, ColorScheme scheme) {
    final isUp = pct >= 0;
    final color = isUp ? Colors.green : Colors.red;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isUp ? Icons.trending_up : Icons.trending_down, color: color),
        const SizedBox(width: 6),
        Text(
          '${pct.abs().toStringAsFixed(1)}%',
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
