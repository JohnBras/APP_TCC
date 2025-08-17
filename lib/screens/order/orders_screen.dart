/*
  OrdersScreen (Pedidos)
  ----------------------
  Lista pedidos e permite filtrar por Status via bottom sheet.
  Mantém FAB "Novo pedido" no canto inferior direito.
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_tcc/models/order.dart';
import 'package:app_tcc/models/order_manager.dart';
import 'package:app_tcc/models/theme_mode_manager.dart';

import 'package:app_tcc/commom/empty_card.dart';
import 'package:app_tcc/screens/order/components/order_tile.dart';
import 'package:app_tcc/drawer/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});

  Color _lightVariant(Color base,
      {double lighten = 0.25, double desat = 0.35}) {
    final hsl = HSLColor.fromColor(base);
    final l = (hsl.lightness + lighten).clamp(0.0, 1.0);
    final s = (hsl.saturation * (1 - desat)).clamp(0.0, 1.0);
    return hsl.withLightness(l).withSaturation(s).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeMgr = context.watch<ThemeModeManager>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final headerGradientColors = isDark
        ? [cs.primary, cs.secondary, cs.tertiary]
        : [
            _lightVariant(cs.primary),
            _lightVariant(cs.secondary),
            _lightVariant(cs.tertiary)
          ];

    final headerBegin = Alignment.centerLeft;
    final headerEnd = isDark ? Alignment.centerRight : Alignment.bottomRight;

    // superfícies no padrão Arena
    final cardBg = cs.surfaceContainerHighest;

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: cs.surface,

      // ─────────────── APP BAR (Arena) ───────────────
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pedidos', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'Filtros',
            onPressed: () => _showOrderFilters(context),
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Claro/Escuro',
            onPressed: () =>
                themeMgr.toggle(isDark ? ThemeMode.light : ThemeMode.dark),
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white),
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

      // ─────────────── FAB: NOVO PEDIDO ───────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/new_order'),
        icon: const Icon(Icons.add),
        label: const Text('Novo pedido'),
      ),

      // ─────────────── LISTA DE PEDIDOS ───────────────
      body: Consumer<OrderManager>(
        builder: (_, manager, __) {
          final filtered = manager.filteredOrders;

          if (filtered.isEmpty) {
            return Center(
              child: Container(
                color: cardBg,
                padding: const EdgeInsets.all(16),
                child: const EmptyCard(
                  title: 'Nenhuma venda realizada!',
                  iconData: Icons.border_clear,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96, top: 8),
            itemCount: filtered.length,
            itemBuilder: (_, index) => Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              color: cardBg,
              child: OrderTile(
                filtered[index],
                showControls: true,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────── FILTRO (BOTTOM SHEET) ───────────────
void _showOrderFilters(BuildContext context) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: theme.colorScheme.surface,
    builder: (_) => const _OrderFiltersSheet(),
  );
}

class _OrderFiltersSheet extends StatelessWidget {
  const _OrderFiltersSheet();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final om = context.watch<OrderManager>();
    final statuses = Status.values; // canceled, made, preparing, confirmed

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filtrar por status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in statuses)
                FilterChip(
                  label: Text(Order.getStatusText(s)),
                  selected: om.statusFilter.contains(s),
                  onSelected: (sel) => context
                      .read<OrderManager>()
                      .setStatusFilter(status: s, enabled: sel),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  for (final s in statuses) {
                    context
                        .read<OrderManager>()
                        .setStatusFilter(status: s, enabled: false);
                  }
                  // Se quiser um default marcado, reative aqui:
                  // context.read<OrderManager>().setStatusFilter(status: Status.made, enabled: true);
                },
                child: const Text('Limpar'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
