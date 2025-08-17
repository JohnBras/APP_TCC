import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_tcc/models/product_manager.dart';
import 'package:app_tcc/models/theme_mode_manager.dart';

import 'package:app_tcc/screens/stock/components/product_list_tile.dart';
import 'package:app_tcc/screens/stock/components/search_dialog.dart';
import 'package:app_tcc/drawer/app_drawer.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});
  // ─────────────── VARIANTE CLARA ───────────────
  // (usada no cabeçalho da AppBar)
//Cor do cabeçalho
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
    return Scaffold(
      drawer: const AppDrawer(), // habilite se tiver extraído o Drawer global
      backgroundColor: cs.surface,

      // ─────────────── APP BAR (Arena) ───────────────
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Produtos', style: TextStyle(color: Colors.white)),
        actions: [
          // buscar / limpar busca
          Consumer<ProductManager>(
            builder: (_, pm, __) => IconButton(
              tooltip: pm.search.isEmpty ? 'Buscar' : 'Limpar busca',
              icon: Icon(
                pm.search.isEmpty ? Icons.search : Icons.close,
                color: Colors.white,
              ),
              onPressed: () async {
                if (pm.search.isEmpty) {
                  final s = await showDialog<String>(
                    context: context,
                    builder: (_) => SearchDialog(pm.search),
                  );
                  if (s != null) pm.search = s;
                } else {
                  pm.search = '';
                }
              },
            ),
          ),
          // claro/escuro
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

      // ─────────────── LISTA ───────────────
      body: Consumer<ProductManager>(
        builder: (_, pm, __) {
          final products = pm.filteredProducts;
          if (products.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado.'));
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];

              return Dismissible(
                key: ValueKey(p.id ?? '$i'),
                direction: DismissDirection.endToStart, // dir → esq

                // start→end (esq → dir)
                background: Container(
                  color: cs.error,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.delete, color: cs.onError, size: 28),
                ),

                // end→start (dir → esq)
                secondaryBackground: Container(
                  color: cs.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.delete, color: cs.onError, size: 28),
                ),

                confirmDismiss: (direction) async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Remover produto'),
                      content:
                          Text('Deseja remover "${p.name ?? 'este produto'}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Remover'),
                        ),
                      ],
                    ),
                  );
                  return ok ?? false;
                },

                onDismissed: (direction) async {
                  await context.read<ProductManager>().delete(p);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produto removido')),
                  );
                },

                child: Container(
                  color: cs.surface,
                  child: ProductListTile(
                    p,
                    nameColor: cs.onSurface, // texto acompanha tema
                    priceColor: cs.secondary, // destaque Arena
                  ),
                ),
              );
            },
          );
        },
      ),

      // ─────────────── FAB ───────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: cs.surface,
        foregroundColor: cs.primary,
        onPressed: () => Navigator.of(context).pushNamed('/edit_product'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
