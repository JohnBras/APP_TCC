import 'package:app_tcc/models/contact_manager.dart';
import 'package:app_tcc/models/order_product_manager.dart';
import 'package:app_tcc/models/product_manager.dart';
import 'package:app_tcc/models/product_size.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String selectedContact = '';
  String selectedValue = '';
  int selectedQtd = 0;
  ProductSize? selectedSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color _lightVariant(Color base,
        {double lighten = 0.25, double desat = 0.35}) {
      final h = HSLColor.fromColor(base);
      final l = (h.lightness + lighten).clamp(0.0, 1.0);
      final s = (h.saturation * (1 - desat)).clamp(0.0, 1.0);
      return h.withLightness(l).withSaturation(s).toColor();
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          'Novo Pedido',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            // igual às outras telas: no dark o título fica preto; no claro branco
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.black : Colors.white),
        actionsIconTheme:
            IconThemeData(color: isDark ? Colors.black : Colors.white),
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        flexibleSpace: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [cs.primary, cs.secondary, cs.tertiary] // forte no dark
                    : [
                        _lightVariant(cs.primary),
                        _lightVariant(cs.secondary),
                        _lightVariant(cs.tertiary),
                      ], // pastel no claro
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),
      ),

      // fundo da página
      backgroundColor: cs.surface,

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Consumer<OrderProductManager>(
                builder: (_, cartManager, __) {
                  final product = context
                      .read<ProductManager>()
                      .findProductById(selectedValue);

                  final labelStyle =
                      TextStyle(color: cs.onSurfaceVariant, fontSize: 15);
                  final fieldTextStyle = TextStyle(
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                    fontSize: 16,
                  );
                  final dropDecoration =
                      const InputDecoration(border: InputBorder.none);

                  return Column(
                    children: [
                      // bloco superior “card” (usa o mesmo cinza das outras telas)
                      ColoredBox(
                        color: cs.surfaceContainerHighest,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // -------- Cliente --------
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text('Cliente', style: labelStyle),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('contacts')
                                          .where('deleted', isEqualTo: false)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Text('Carregando...',
                                              style: TextStyle(
                                                  color: cs.onSurface));
                                        } else {
                                          final List<DropdownMenuItem>
                                              contacts = [];
                                          for (final snap
                                              in snapshot.data!.docs) {
                                            final contact = context
                                                .read<ContactManager>()
                                                .findContactById(snap.id);
                                            if (contact?.client == true) {
                                              contacts.add(DropdownMenuItem(
                                                value: snap.id,
                                                child: Text(contact!.name ?? '',
                                                    style: fieldTextStyle),
                                              ));
                                            }
                                          }
                                          return DropdownButtonFormField<
                                              dynamic>(
                                            isExpanded: true,
                                            value: (selectedContact.isEmpty)
                                                ? null
                                                : selectedContact,
                                            items: contacts,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedContact =
                                                    newValue.toString();
                                                selectedValue = '';
                                                selectedSize = null;
                                                selectedQtd = 0;
                                              });
                                            },
                                            hint: Text('Defina o Cliente',
                                                style: TextStyle(
                                                    color:
                                                        cs.onSurfaceVariant)),
                                            style: fieldTextStyle,
                                            decoration: dropDecoration,
                                            validator: (client) =>
                                                client == null
                                                    ? 'Selecione um cliente'
                                                    : null,
                                            onSaved: (contact) =>
                                                cartManager.contact = context
                                                    .read<ContactManager>()
                                                    .findContactById(
                                                        contact.toString()),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // -------- Produto --------
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Produto', style: labelStyle),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('products')
                                          .where('deleted', isEqualTo: false)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Text('Carregando...',
                                              style: TextStyle(
                                                  color: cs.onSurface));
                                        } else {
                                          final List<DropdownMenuItem>
                                              products = [];
                                          for (final snap
                                              in snapshot.data!.docs) {
                                            final prod = context
                                                .read<ProductManager>()
                                                .findProductById(snap.id);
                                            products.add(DropdownMenuItem(
                                              value: snap.id,
                                              child: Text(prod?.name ?? '',
                                                  style: fieldTextStyle),
                                            ));
                                          }
                                          return DropdownButtonFormField<
                                              dynamic>(
                                            isExpanded: true,
                                            value: (selectedValue.isEmpty)
                                                ? null
                                                : selectedValue,
                                            items: products,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedValue =
                                                    newValue.toString();
                                                selectedSize = null;
                                                selectedQtd = 0;
                                                cartManager.selectedProductID =
                                                    selectedValue;
                                              });
                                            },
                                            hint: Text('Escolha um Produto',
                                                style: TextStyle(
                                                    color:
                                                        cs.onSurfaceVariant)),
                                            style: fieldTextStyle,
                                            decoration: dropDecoration,
                                            validator: (v) => v == null
                                                ? 'Selecione um produto'
                                                : null,
                                            onSaved: (v) =>
                                                cartManager.selectedProductID =
                                                    selectedValue,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // -------- Tamanho & Quantidade --------
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Tamanho
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Tamanho', style: labelStyle),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.28,
                                        child: Consumer<ProductManager>(
                                          builder: (_, ___, __) {
                                            final List<
                                                DropdownMenuItem<
                                                    ProductSize>> sizes = [];
                                            final prod = context
                                                .read<ProductManager>()
                                                .findProductById(cartManager
                                                    .selectedProductID);
                                            if (prod == null) {
                                              return Text(
                                                  'Selecione um produto',
                                                  style: TextStyle(
                                                      color:
                                                          cs.onSurfaceVariant));
                                            } else {
                                              for (final snap
                                                  in prod.sizes ?? []) {
                                                final hasStock = snap!.hasStock;
                                                sizes.add(DropdownMenuItem(
                                                  value: snap,
                                                  child: Text(
                                                    snap.sizeValue.toString(),
                                                    style: TextStyle(
                                                      color: hasStock
                                                          ? cs.onSurface
                                                          : cs.onSurface
                                                              .withOpacity(
                                                                  0.38),
                                                    ),
                                                  ),
                                                ));
                                              }
                                              return DropdownButtonFormField<
                                                  ProductSize>(
                                                isExpanded: true,
                                                value: selectedSize,
                                                items: sizes,
                                                onChanged: (newValue) {
                                                  final sizeAux = newValue!;
                                                  setState(() =>
                                                      selectedSize = sizeAux);
                                                  if (sizeAux.hasStock &&
                                                      product != null) {
                                                    cartManager.setSelectedSize(
                                                        product, sizeAux);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: const Text(
                                                          'Tamanho escolhido sem estoque'),
                                                      backgroundColor: cs.error,
                                                      duration: const Duration(
                                                          seconds: 2),
                                                    ));
                                                  }
                                                },
                                                style: fieldTextStyle,
                                                decoration: dropDecoration,
                                                validator: (size) =>
                                                    size == null
                                                        ? 'Selecione um tamanho'
                                                        : null,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  // QTD
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('QTD.', style: labelStyle),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.18,
                                        child: DropdownButtonFormField<int>(
                                          isExpanded: true,
                                          value: selectedQtd,
                                          items: List.generate(10, (i) => i)
                                              .map((value) =>
                                                  DropdownMenuItem<int>(
                                                    value: value,
                                                    child: Text('$value',
                                                        style: fieldTextStyle),
                                                  ))
                                              .toList(),
                                          onChanged: (newValue) => setState(
                                              () => selectedQtd = newValue!),
                                          style: fieldTextStyle,
                                          decoration: dropDecoration,
                                          validator: (qtd) {
                                            if (qtd == null)
                                              return 'Escolha a quantidade';
                                            if (selectedSize == null)
                                              return 'Selecione o tamanho';
                                            if ((selectedSize!.stock ?? 0) <
                                                qtd) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: const Text(
                                                    'Quantidade não disponível'),
                                                backgroundColor: cs.error,
                                                duration:
                                                    const Duration(seconds: 2),
                                              ));
                                            }
                                            return null;
                                          },
                                          onSaved: (qtd) => cartManager
                                              .selectedProductQtd = selectedQtd,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // -------- Botão: Adicionar item --------
                            // -------- Botão: Adicionar item --------
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                height: 48,
                                width: double.infinity,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        cs.primary, // igual nos dois temas
                                    foregroundColor:
                                        cs.onPrimary, // texto com contraste
                                  ),
                                  onPressed: !cartManager.loading
                                      ? () async {
                                          if (!formKey.currentState!.validate())
                                            return;
                                          formKey.currentState!.save();
                                          context
                                              .read<OrderProductManager>()
                                              .addToOrder(product!);
                                          if (mounted) {
                                            Navigator.of(context)
                                                .pushNamed('/checkout');
                                          }
                                        }
                                      : null,
                                  child: cartManager.loading
                                      ? CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              cs.onPrimary),
                                        )
                                      : const Text(
                                          'Adicionar item ao pedido',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FAB: segue a linguagem das outras telas
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? cs.primary : cs.surface,
        foregroundColor: isDark ? cs.onPrimary : cs.primary,
        onPressed: () => Navigator.of(context).pushNamed('/checkout'),
        child: const Icon(Icons.shopping_cart_sharp),
      ),
    );
  }
}
