/*
  IaScreen (IA – Previsões)
  -------------------------
  O que é: Tela com 2 abas para visualizar previsões de demanda por produto
  e tendência de vendas. Usa seus gráficos (DemandBarChart / SalesLineChart).

  Por que preciso dela: Centraliza insights da IA para ajudar no reabastecimento
  (demanda) e no planejamento de vendas (próxima semana), com seletor de janela
  (7/14/28 dias) e alertas quando a previsão supera a média histórica.

  Como funciona:
  - Lê o ForecastManager: demand (lista por produto), sales (agregado) e windowDays.
  - Abas "Demanda" e "Vendas" com gráficos e indicadores.
  - AppBar no padrão Arena (gradiente, título central) e botão claro/escuro.
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_tcc/models/forecast_manager.dart';
import 'package:app_tcc/models/theme_mode_manager.dart';

import 'package:app_tcc/widgets/charts/demand_bar_chart.dart';
import 'package:app_tcc/widgets/charts/sales_line_chart.dart';
import 'package:app_tcc/drawer/app_drawer.dart';
// Se você tiver um Drawer global, habilite o import e a linha do Scaffold.
// import 'package:app_tcc/widgets/app_drawer.dart';

class IaScreen extends StatefulWidget {
  const IaScreen({super.key});

  @override
  State<IaScreen> createState() => _IaScreenState();
}

class _IaScreenState extends State<IaScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeMgr = context.watch<ThemeModeManager>();
    final isDark = themeMgr.mode == ThemeMode.dark;
    final manager = context.watch<ForecastManager>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const AppDrawer(),
        backgroundColor: cs.surface,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('IA – Previsões',
              style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              tooltip: 'Claro/Escuro',
              onPressed: () =>
                  themeMgr.toggle(isDark ? ThemeMode.light : ThemeMode.dark),
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Demanda'),
              Tab(text: 'Vendas'),
            ],
          ),
          flexibleSpace: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.secondary, cs.tertiary],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // ─────────────── ABA DEMANDA ───────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // seletor de janela
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Janela:'),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: manager.windowDays,
                          items: const [7, 14, 28]
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text('$d dias'),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              v == null ? null : manager.updateWindowDays(v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // lista de gráficos por produto
                    Expanded(
                      child: manager.demand.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhuma previsão de demanda para os últimos ${manager.windowDays} dias.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            )
                          : ListView.builder(
                              itemCount: manager.demand.length,
                              itemBuilder: (ctx, i) {
                                final f = manager.demand[i];
                                final hist = f.historicalAverage;
                                final diffPerc = hist == 0
                                    ? 0.0
                                    : ((f.predicted - hist) / hist) * 100.0;
                                final isAlert = diffPerc >= 20.0;

                                return Card(
                                  color: cs.surfaceContainerHighest,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: cs.outlineVariant),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              f.id,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            if (isAlert)
                                              Icon(Icons.warning_amber_rounded,
                                                  color: cs.tertiary),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        AspectRatio(
                                          aspectRatio: 1.5,
                                          child: DemandBarChart(
                                            forecast: f,
                                            alertThreshold: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Previsto: ${f.predicted.toStringAsFixed(0)}  |  Média ${manager.windowDays}d: ${hist.toStringAsFixed(0)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // ─────────────── ABA VENDAS ───────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // seletor de janela
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Janela:'),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: manager.windowDays,
                          items: const [7, 14, 28]
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text('$d dias'),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              v == null ? null : manager.updateWindowDays(v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // gráfico agregado de vendas
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: SalesLineChart(
                              pastWeeks: [
                                manager.sales?.historicalAverage ?? 0
                              ],
                              predicted: manager.sales?.predicted ?? 0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Próxima Semana: ${manager.sales?.predicted.toStringAsFixed(0) ?? '-'}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
