// lib/screens/base_screen.dart
import 'package:app_tcc/models/page_manager.dart';
import 'package:app_tcc/models/user_manager.dart';
import 'package:app_tcc/screens/contact/customers/contacts_screen_list.dart';
import 'package:app_tcc/screens/home/home_screen.dart';
import 'package:app_tcc/screens/login/login_screen.dart';
import 'package:app_tcc/screens/order/orders_screen.dart';
import 'package:app_tcc/screens/product/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_tcc/screens/ia/ia_screen.dart';
import 'package:provider/provider.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final PageController pageController = PageController();

  // índice da NavigationBar (3 abas)
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // sincroniza a barra inferior quando a página muda
    pageController.addListener(_onPageChange);
  }

  @override
  void dispose() {
    pageController.removeListener(_onPageChange);
    pageController.dispose();
    super.dispose();
  }

  void _onPageChange() {
    final p = pageController.hasClients && pageController.page != null
        ? pageController.page!.round()
        : 0;
    final ni = _navIndexForPage(p);
    if (ni != _navIndex) setState(() => _navIndex = ni);
  }

  // Mapeamento: PageView (5 páginas) -> NavigationBar (3 itens)
  int _navIndexForPage(int page) {
    switch (page) {
      case 0:
        return 0; // Home/Dashboard
      case 2:
        return 1; // Produtos
      case 3:
        return 2; // Pedidos
      default:
        return _navIndex; // mantém o atual em Contatos(1) / IA(4)
    }
  }

  // Mapeamento: NavigationBar -> PageView
  int _pageForNavIndex(int nav) {
    switch (nav) {
      case 0:
        return 0; // Dashboard
      case 1:
        return 2; // Produtos
      case 2:
        return 3; // Pedidos
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManager>(builder: (_, userManager, __) {
      if (!userManager.isLoggedIn) {
        return userManager.initLoading
            ? const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              )
            : const LoginScreen();
      }

      return Provider(
        create: (_) => PageManager(pageController),
        child: Scaffold(
          // ⚠️ Drawer fica nas telas internas (Home/Contatos/Produtos etc.)
          body: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const HomeScreen(),
              const ContactsScreen(),
              const ProductsScreen(),
              OrdersScreen(),
              const IaScreen(),
            ],
          ),

          // NavigationBar fixa (3 itens)
          bottomNavigationBar: NavigationBar(
            selectedIndex: _navIndex,
            onDestinationSelected: (i) {
              setState(() => _navIndex = i); // feedback visual
              final page = _pageForNavIndex(i); // 0->0, 1->2, 2->3
              pageController.jumpToPage(page); // ← muda o PageView diretamente
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
              NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined), label: 'Produtos'),
              NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined), label: 'Pedidos'),
            ],
          ),
        ),
      );
    });
  }
}
