import 'package:flutter/material.dart';

import 'package:app_tcc/drawer/app_drawer.dart';
import 'package:app_tcc/models/order_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:app_tcc/models/order.dart'; // Status.confirmed
import 'package:app_tcc/screens/home/components/sale_chart_widget.dart';
import 'package:app_tcc/models/dashboard_filter.dart';

/// Dashboard/Home no layout Arena Pro Vibe
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// clareia a cor mantendo o matiz (vira um "pastel" da mesma cor)
Color _lightVariant(Color base, {double lighten = 0.25, double desat = 0.35}) {
  final hsl = HSLColor.fromColor(base);
  final l = (hsl.lightness + lighten).clamp(0.0, 1.0);
  final s = (hsl.saturation * (1 - desat)).clamp(0.0, 1.0);
  return hsl.withLightness(l).withSaturation(s).toColor();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

// gradiente do cabeçalho (mesmas cores do escuro, porém versão "pastel" no claro)
    final headerGradientColors = isDark
        ? [cs.primary, cs.secondary, cs.tertiary]
        : [
            _lightVariant(cs.primary),
            _lightVariant(cs.secondary),
            _lightVariant(cs.tertiary)
          ];

// direção ligeiramente diferente no claro, pra dar identidade
    final headerBegin = Alignment.centerLeft;
    final headerEnd = isDark ? Alignment.centerRight : Alignment.bottomRight;

// cores do título/subtítulo
    final titleColor =
        isDark ? const Color.fromARGB(255, 29, 29, 29) : Colors.white;
    final subtitleColor =
        isDark ? const Color.fromARGB(255, 29, 29, 29) : Colors.white70;

    // controles do logo
    const double logoRight = 15;
    const double logoSize = 85;
    final double toolbarH =
        (logoSize + 20) < kToolbarHeight ? kToolbarHeight : (logoSize + 20);

    final filter = context.watch<DashboardFilter>();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        toolbarHeight: toolbarH,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Planeta Bola',
              style: TextStyle(
                color: titleColor, // ← preto no escuro, branco no claro
                fontWeight: FontWeight.w800,
                fontSize: 24,
                height: 1.0,
              ),
            ),
            Text(
              'Gestão de Vendas',
              style: TextStyle(
                color: subtitleColor, // ← preto no escuro, branco70 no claro
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.2,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: logoRight),
            child: SizedBox(
              width: logoSize,
              height: logoSize,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  'assets/image_login.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
        flexibleSpace: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: headerBegin,
                end: headerEnd,
                colors: headerGradientColors,
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<OrderManager>().refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const _SummaryCard(),
            const SizedBox(height: 16),

            // gráfico real por mês do ANO filtrado
            _Section(
              title: 'Vendas por mês (${filter.year})',
              child: SizedBox(
                height: 240,
                child: Builder(
                  builder: (context) {
                    final om = context.watch<OrderManager>();
                    final orders = om.allOrders;

                    if (om.isLoading && orders.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // apenas concluídos com data
                    final confirmed = orders
                        .where((o) =>
                            o.status == Status.confirmed && o.date != null)
                        .toList();

                    // totais por MÊS do ANO selecionado
                    final totals = List<double>.filled(12, 0);
                    for (final o in confirmed) {
                      final d = o.date!.toDate();
                      if (d.year == filter.year) {
                        totals[d.month - 1] += (o.price ?? 0).toDouble();
                      }
                    }

                    // rótulos: SOMENTE meses
                    const meses = [
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
                    ];

                    final salesMap = <String, double>{
                      for (int i = 0; i < 12; i++) meses[i]: totals[i],
                    };

                    return SaleBarChart(
                      monthlySales: salesMap,
                      selectedMonthIndex: filter.month - 1,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            _Section(
              title: 'Ações rápidas',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  Chip(label: Text('Cadastrar Produto')),
                  Chip(label: Text('Novo Pedido')),
                  Chip(label: Text('Relatórios')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _Section(title: 'Form (Input/Buttons)', child: _FormDemo()),
          ],
        ),
      ),
    );
  }
}

/// Card de Resumo com filtros de Ano/Mês e KPIs reais (apenas CONCLUÍDOS)
class _SummaryCard extends StatefulWidget {
  const _SummaryCard();
  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  late int _year;
  late int _month; // 1..12
  bool _initialized = false;

  @override
  void initState() {
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final all = context.read<OrderManager>().allOrders;
    final confirmed = all
        .where((o) => o.status == Status.confirmed && o.date != null)
        .toList();

    if (confirmed.isNotEmpty) {
      confirmed.sort((a, b) => b.date!.toDate().compareTo(a.date!.toDate()));
      final last = confirmed.first.date!.toDate();
      _year = last.year;
      _month = last.month;
    }

    // sincroniza o filtro global
    context.read<DashboardFilter>().setYearMonth(_year, _month);

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = NumberFormat.simpleCurrency(locale: 'pt_BR');

    final om = context.watch<OrderManager>();
    final all = om.allOrders;

    if (om.isLoading && all.isEmpty) {
      return Card(
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator(color: cs.primary)),
        ),
      );
    }

    // apenas concluídos
    final orders = all.where((o) => o.status == Status.confirmed).toList();

    // anos disponíveis
    final yearsList = orders
        .map((o) => o.date?.toDate().year)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();
    final years = yearsList.isEmpty ? <int>[DateTime.now().year] : yearsList;

    // filtra por ano/mês selecionados
    final filtered = orders.where((o) {
      final d = o.date?.toDate();
      if (d == null) return false;
      return d.year == _year && d.month == _month;
    }).toList();

    // soma vendas (price)
    final num total = filtered.fold<num>(0, (sum, o) => sum + (o.price ?? 0));
    final transacoes = filtered.length;

    const meses = [
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
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Pedidos (Concluídos)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                ),
                const Spacer(),
                DropdownButton<int>(
                  value: _year,
                  underline: const SizedBox.shrink(),
                  items: years
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (y) {
                    if (y == null) return;
                    setState(() => _year = y);
                    context.read<DashboardFilter>().setYear(y);
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _month,
                  underline: const SizedBox.shrink(),
                  items: List.generate(
                    12,
                    (i) =>
                        DropdownMenuItem(value: i + 1, child: Text(meses[i])),
                  ),
                  onChanged: (m) {
                    if (m == null) return;
                    setState(() => _month = m);
                    context.read<DashboardFilter>().setMonth(m);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _KpiTile(
                    title: 'Vendas (${meses[_month - 1]})',
                    value: fmt.format(total),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _KpiTile(
                    title: 'Transações',
                    value: '$transacoes',
                  ),
                ),
              ],
            ),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Sem pedidos concluídos em ${meses[_month - 1]}/$_year.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FormDemo extends StatelessWidget {
  const _FormDemo();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextField(
          decoration: InputDecoration(
            labelText: 'Buscar produto',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                  onPressed: () {}, child: const Text('Confirmar')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                  onPressed: () {}, child: const Text('Cancelar')),
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = cs.surfaceContainerHighest;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    // ← ciano no dark, PRETO (onSurface) no light
                    color: isDark ? cs.secondary : cs.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
