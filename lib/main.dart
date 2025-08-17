import 'package:app_tcc/models/contact.dart';
import 'package:app_tcc/models/contact_manager.dart';
import 'package:app_tcc/models/order.dart';
import 'package:app_tcc/models/order_manager.dart';
import 'package:app_tcc/models/order_product_manager.dart';
import 'package:app_tcc/models/product.dart';
import 'package:app_tcc/models/product_manager.dart';
import 'package:app_tcc/models/user_manager.dart';
import 'package:app_tcc/models/forecast_manager.dart';
import 'package:app_tcc/models/theme_mode_manager.dart';
import 'package:app_tcc/repositories/forecast_repository.dart';

import 'package:app_tcc/screens/base_screen.dart';
import 'package:app_tcc/screens/checkout/checkout_screen.dart';
import 'package:app_tcc/screens/contact/contact_screen_details.dart';
import 'package:app_tcc/screens/contact/edit_contact_screen.dart';
import 'package:app_tcc/screens/edit_product/edit_product_screen.dart';
import 'package:app_tcc/screens/login/login_screen.dart';
import 'package:app_tcc/screens/new_order/cart/cart_screen.dart';
import 'package:app_tcc/screens/order/orders_screen.dart';
import 'package:app_tcc/screens/product/products_screen.dart';
import 'package:app_tcc/screens/signup/signup_screen.dart';
import 'package:app_tcc/screens/forecast/forecast_screen.dart'; // use se estiver ativa

import 'package:app_tcc/theme/arena_pro_vibe.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:app_tcc/models/dashboard_filter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('pt_BR');
  Intl.defaultLocale = 'pt_BR';
  runApp(Phoenix(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final arena = ArenaProVibeTheme();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final now = DateTime.now();
            return DashboardFilter(year: now.year, month: now.month);
          },
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => UserManager(), lazy: false),
        ChangeNotifierProvider(create: (_) => ContactManager(), lazy: false),
        ChangeNotifierProvider(create: (_) => ProductManager(), lazy: false),
        ChangeNotifierProvider(
            create: (_) => OrderProductManager(), lazy: false),
        ChangeNotifierProvider(create: (_) => OrderManager(), lazy: false),
        ChangeNotifierProvider(create: (_) => Order(), lazy: false),
        ChangeNotifierProvider(
            create: (_) => ForecastManager(ForecastRepository()), lazy: false),
        ChangeNotifierProvider(create: (_) => ThemeModeManager(), lazy: false),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeModeManager>().mode;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Planeta Bola Gestão de Vendas',
            theme: arena.light,
            darkTheme: arena.dark,
            themeMode: themeMode,
            locale: const Locale('pt', 'BR'),
            supportedLocales: const [
              Locale('pt', 'BR'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/login':
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case '/signup':
                  return MaterialPageRoute(builder: (_) => SignUpScreen());
                case '/contact':
                  return MaterialPageRoute(
                    builder: (_) =>
                        ContactScreen(contact: settings.arguments as Contact?),
                  );
                case '/edit_contact':
                  return MaterialPageRoute(
                    builder: (_) =>
                        EditContactScreen(settings.arguments as Contact?),
                  );
                case '/product':
                  return MaterialPageRoute(
                      builder: (_) => const ProductsScreen());
                case '/edit_product':
                  return MaterialPageRoute(
                    builder: (_) =>
                        EditProductScreen(settings.arguments as Product?),
                  );
                case '/orders':
                  return MaterialPageRoute(
                      builder: (_) => OrdersScreen(), settings: settings);
                case '/new_order':
                  return MaterialPageRoute(
                      builder: (_) => CartScreen(), settings: settings);
                case '/checkout':
                  return MaterialPageRoute(
                      builder: (_) => const CheckoutScreen());
                case '/forecast': // mantenha se estiver usando a tela de previsões
                  return MaterialPageRoute(
                      builder: (_) => const ForecastScreen());

                // OPCIONAL: rota de compatibilidade
                case '/base':
                  return MaterialPageRoute(builder: (_) => const BaseScreen());

                case '/':
                default:
                  return MaterialPageRoute(builder: (_) => const BaseScreen());
              }
            },
          );
        },
      ),
    );
  }
}
