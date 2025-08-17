/*
  ContactsScreen (Contatos)
  -------------------------
  O que é: Tela que lista seus contatos com suporte a busca por nome e
  filtros (drawer lateral à direita). Cada item abre ações via ContactListTile.

  Por que preciso dela: É a base do cadastro/CRM — encontrar rapidamente
  um contato (busca) e filtrar por critérios (ContactFilterDrawer) antes
  de cadastrar pedido, editar dados, etc.

  Como funciona:
  - Usa ContactManager para estado: `filteredContactsByName`, `search`.
  - AppBar no padrão Arena: gradiente (primary→secondary→tertiary),
    título centralizado, botão buscar/limpar e botão de filtros (abre endDrawer).
  - Lista com itens ContactListTile e divisórias seguindo o ColorScheme.
  - FAB para criar/editar contato.
*/

import 'package:app_tcc/drawer/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_tcc/models/contact_manager.dart';
import 'package:app_tcc/models/theme_mode_manager.dart';

import 'package:app_tcc/screens/stock/components/search_dialog.dart';
import 'package:app_tcc/screens/contact/customers/components/contact_filter_drawer.dart';
import 'package:app_tcc/screens/contact/customers/components/contact_list_tile.dart';

// Se você tiver um Drawer global, habilite aqui e no Scaffold.
// import 'package:app_tcc/widgets/app_drawer.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeMgr = context.watch<ThemeModeManager>();
    final isDark = themeMgr.mode == ThemeMode.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(), // habilite se tiver Drawer global
      endDrawer: ContactFilterDrawer(),
      backgroundColor: cs.surfaceContainerHighest,

      // ─────────────── APP BAR (Arena) ───────────────
      appBar: AppBar(
        centerTitle: true,
        title: Consumer<ContactManager>(
          builder: (_, contactManager, __) {
            if (contactManager.search.isEmpty) {
              return const Text('Contatos',
                  style: TextStyle(color: Colors.white));
            } else {
              return LayoutBuilder(
                builder: (_, constraints) => GestureDetector(
                  onTap: () async {
                    final s = await showDialog<String>(
                      context: context,
                      builder: (_) => SearchDialog(contactManager.search),
                    );
                    if (s != null) contactManager.search = s;
                  },
                  child: SizedBox(
                    width: constraints.biggest.width,
                    child: Text(
                      contactManager.search,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            }
          },
        ),
        actions: [
          Consumer<ContactManager>(
            builder: (_, cm, __) => IconButton(
              tooltip: cm.search.isEmpty ? 'Buscar' : 'Limpar busca',
              icon: Icon(cm.search.isEmpty ? Icons.search : Icons.close,
                  color: Colors.white),
              onPressed: () async {
                if (cm.search.isEmpty) {
                  final s = await showDialog<String>(
                    context: context,
                    builder: (_) => SearchDialog(cm.search),
                  );
                  if (s != null) cm.search = s;
                } else {
                  cm.search = '';
                }
              },
            ),
          ),
          IconButton(
            tooltip: 'Filtros',
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
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
                colors: [cs.primary, cs.secondary, cs.tertiary],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),
      ),

      // ─────────────── LISTA ───────────────
      body: Consumer<ContactManager>(
        builder: (_, contactManager, __) {
          final filtered = contactManager.filteredContactsByName;

          if (filtered.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Nenhum contato encontrado.'),
              ),
            );
          }

          return SafeArea(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final item = filtered[i];
                return Column(
                  children: [
                    Container(
                      color: cs.surfaceContainerHighest,
                      child: ContactListTile(item),
                    ),
                    Divider(
                        color: cs.outlineVariant.withOpacity(0.5), height: 0),
                  ],
                );
              },
            ),
          );
        },
      ),

      // ─────────────── FAB ───────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: cs.surface,
        foregroundColor: cs.primary,
        onPressed: () => Navigator.of(context).pushNamed('/edit_contact'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
