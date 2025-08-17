import 'package:app_tcc/commom/price_card.dart';
import 'package:app_tcc/models/checkout_manager.dart';
import 'package:app_tcc/models/order_product_manager.dart';
import 'package:app_tcc/screens/new_order/cart/components/cart_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

Widget _buildPrimaryFlexibleSpace(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  // Gradiente semelhante ao da Home: topo mais intenso → base um pouco mais clara
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.6, 1.0],
        colors: [
          cs.primary, // intenso no topo
          Color.lerp(cs.primary, Colors.black, 0.08)!, // leve profundidade
          Color.lerp(cs.primary, cs.primaryContainer, 0.22)!, // base suave
        ],
      ),
    ),
  );
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDarkTheme = theme.brightness == Brightness.dark;

    // Cor do texto: preto no tema claro, branco no tema escuro (igual à arena)
    final textColor = isDarkTheme ? Colors.white : Colors.black;

    // escolhe cor dos ícones da status bar conforme a luminância do primary
    final overlay = (cs.primary.computeLuminance() > 0.5)
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;

    return ChangeNotifierProxyProvider<OrderProductManager, CheckoutManager>(
      create: (_) => CheckoutManager(),
      update: (_, cartManager, checkoutManager) =>
          checkoutManager!..updateCart(cartManager),
      lazy: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Confirmar Pedido',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
            ),
          ),
          centerTitle: theme.appBarTheme.centerTitle ?? true,
          // deixa o fundo transparente para o gradiente aparecer
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          elevation: theme.appBarTheme.elevation ?? 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: overlay,
          // === AQUI ESTÁ O flexibleSpace IGUAL AO DA HOME ===
          flexibleSpace: _buildPrimaryFlexibleSpace(context),
          // mantém estilo de título/ícones conforme Home (com fallback)
          titleTextStyle: theme.appBarTheme.titleTextStyle ??
              theme.textTheme.titleLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                fontWeight: FontWeight.w600,
              ),
          iconTheme: IconThemeData(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
          ),
          actionsIconTheme: IconThemeData(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
          ),
          shape: theme.appBarTheme.shape,
          toolbarHeight: theme.appBarTheme.toolbarHeight ?? kToolbarHeight,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Consumer<CheckoutManager>(
            builder: (_, checkoutManager, __) {
              if (checkoutManager.loading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(cs.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enviando pedido...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textColor, // Preto no tema claro
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }
              final cartManager = checkoutManager.cartManager!;
              return Form(
                key: formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                      children: cartManager.items.map((cartProduct) {
                        return AbsorbPointer(
                          absorbing: true,
                          child: CartTile(cartProduct),
                        );
                      }).toList(),
                    ),
                    PriceCard(
                      cartManager: cartManager,
                      buttonText: 'Finalizar Pedido',
                      onPressed: () {
                        if (cartManager.items.isEmpty) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topCenter,
                                children: [
                                  SizedBox(
                                    height: 160,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 48, 16, 16),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Carrinho vazio!',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              color:
                                                  textColor, // Preto no tema claro
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: cs.primary,
                                              foregroundColor: isDarkTheme
                                                  ? cs.onPrimary
                                                  : Colors.black,
                                            ),
                                            child: const Text('Fechar'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -28,
                                    child: CircleAvatar(
                                      backgroundColor: cs.error,
                                      radius: 28,
                                      child: Icon(
                                        Icons.remove_shopping_cart_outlined,
                                        color: cs.onError,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          checkoutManager.checkout(
                            onStockFail: (e) {
                              Navigator.of(context).popUntil(
                                (route) => route.settings.name == '/new_order',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$e',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: cs.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            onSuccess: (order) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/',
                                (route) => false,
                              );
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.error,
                            foregroundColor:
                                isDarkTheme ? cs.onError : Colors.black,
                            disabledBackgroundColor: cs.error.withOpacity(.38),
                            disabledForegroundColor:
                                cs.onError.withOpacity(.38),
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            cartManager.clear();
                          },
                          child: const Text('Limpar carrinho'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                cs.primary, // Azul em ambos os temas
                            foregroundColor: isDarkTheme
                                ? cs.onPrimary
                                : Colors.black, // Texto preto no tema claro
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Continuar Adicionando Item'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
