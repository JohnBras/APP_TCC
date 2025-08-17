import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:app_tcc/models/user_manager.dart';
import 'package:app_tcc/models/page_manager.dart';
import 'package:app_tcc/models/theme_mode_manager.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, int pageIndex) {
    // Se a tela está dentro do BaseScreen/PageView, navega pelo PageManager;
    // senão, volta pra raiz e o BaseScreen abre a página padrão.
    try {
      context.read<PageManager>().setPage(pageIndex);
    } catch (_) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = context.watch<UserManager>().user;
    final themeMgr = context.watch<ThemeModeManager>();
    final isDark = themeMgr.mode == ThemeMode.dark;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Usuário'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: cs.secondary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.secondary, cs.tertiary],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),

            // ✅ Somente opções que NÃO estão na barra fixa:
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Contatos'),
              onTap: () {
                Navigator.pop(context);
                _go(context, 1); // PageView: 1 = ContactsScreen
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy_outlined),
              title: const Text('IA'),
              onTap: () {
                Navigator.pop(context);
                _go(context, 4); // PageView: 4 = IaScreen
              },
            ),

            const Divider(),

            // Tema (claro/escuro)
            SwitchListTile.adaptive(
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Tema escuro'),
              value: isDark,
              onChanged: (v) =>
                  themeMgr.toggle(v ? ThemeMode.dark : ThemeMode.light),
            ),

            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Atualizar'),
              onTap: () {
                Navigator.pop(context);
                Phoenix.rebirth(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                Navigator.pop(context);
                await context.read<UserManager>().signOut();
                if (!context.mounted) return;
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (r) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
