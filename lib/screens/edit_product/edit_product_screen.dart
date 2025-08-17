import 'package:app_tcc/models/product.dart';
import 'package:app_tcc/models/product_manager.dart';
import 'package:app_tcc/screens/edit_product/components/images_form.dart';
import 'package:app_tcc/screens/edit_product/components/sizes_form.dart';
import 'package:app_tcc/theme/dynamic_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatelessWidget {
  EditProductScreen(Product? p, {super.key})
      : editing = p != null,
        product = p != null ? p.clone() : Product();
  final Product product;
  final bool editing;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDarkNow = Theme.of(context).brightness == Brightness.dark;
    final cardBg = DynamicColors.cardBg(context);
    final onCard = DynamicColors.onCard(context);

    // Cor do texto: preto no tema claro, branco no tema escuro
    final textColor = isDarkNow ? onCard : Colors.black;

    Widget sectionCard(Widget child) {
      return Card(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: product,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: Text(
            editing ? 'Editar produto' : 'Criar produto',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
            ),
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
          systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          flexibleSpace: IgnorePointer(
            child: Builder(
              builder: (context) {
                Color lightVariant(Color base,
                    {double lighten = 0.25, double desat = 0.35}) {
                  final h = HSLColor.fromColor(base);
                  final l = (h.lightness + lighten).clamp(0.0, 1.0);
                  final s = (h.saturation * (1 - desat)).clamp(0.0, 1.0);
                  return h.withLightness(l).withSaturation(s).toColor();
                }

                final isDark = Theme.of(context).brightness == Brightness.dark;
                final colors = isDark
                    ? [cs.primary, cs.secondary, cs.tertiary]
                    : [
                        lightVariant(cs.primary),
                        lightVariant(cs.secondary),
                        lightVariant(cs.tertiary),
                      ];
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            if (editing)
              IconButton(
                icon: const Icon(Icons.delete),
                // Ícone vermelho em ambos os temas
                color: const Color.fromARGB(255, 255, 0, 0),
                onPressed: () async {
                  final scheme = Theme.of(context).colorScheme;
                  final textTheme = Theme.of(context).textTheme;
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      titleTextStyle: textTheme.titleLarge
                          ?.copyWith(color: scheme.onSurface),
                      contentTextStyle: textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurface),
                      title: const Text('Remover produto'),
                      content: Text(
                          'Deseja remover "${product.name ?? 'este produto'}"?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancelar')),
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Remover')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await context.read<ProductManager>().delete(product);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
              ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // seção Imagens
              sectionCard(ImagesForm(product)),
              // seção Nome
              sectionCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Nome do Produto',
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: product.name,
                      decoration: InputDecoration(
                        hintText: 'Digite o nome do Produto',
                        filled: true,
                        fillColor: cardBg,
                        hintStyle: TextStyle(color: textColor.withOpacity(.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                      ),
                      style: TextStyle(color: textColor, fontSize: 18),
                      validator: (v) => v!.length < 3 ? 'Muito curto' : null,
                      onSaved: (v) => product.name = v,
                    ),
                  ],
                ),
              ),
              // seção Valor
              sectionCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Valor',
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'R\$',
                          style: TextStyle(
                            color: textColor, // Preto no tema claro
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            cursorColor: cs.onSurface,
                            initialValue: product.price?.toStringAsFixed(2),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9\.,]')),
                            ],
                            decoration: InputDecoration(
                              hintText: '0.00',
                              filled: true,
                              fillColor: cardBg,
                              hintStyle:
                                  TextStyle(color: textColor.withOpacity(.6)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide.none,
                              ),
                              isDense: true,
                            ),
                            style: TextStyle(
                              color: textColor, // Preto no tema claro
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: (v) {
                              final normalized = (v ?? '').replaceAll(',', '.');
                              return num.tryParse(normalized) == null
                                  ? 'Inválido'
                                  : null;
                            },
                            onSaved: (v) => product.price =
                                num.tryParse((v ?? '').replaceAll(',', '.')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // seção Descrição
              sectionCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Descrição',
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      cursorColor: cs.onSurface,
                      initialValue: product.description,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Detalhes do produto',
                        filled: true,
                        fillColor: cardBg,
                        hintStyle: TextStyle(color: textColor.withOpacity(.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                      ),
                      style: TextStyle(color: textColor, fontSize: 16),
                      validator: (v) =>
                          (v == null || v.length < 10) ? 'Muito curto' : null,
                      onSaved: (v) => product.description = v,
                    ),
                  ],
                ),
              ),
              // seção Tamanhos
              sectionCard(SizesForm(product)),
              // botão Salvar
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Consumer<Product>(
                  builder: (_, prod, __) {
                    final hasImage =
                        prod.images.isNotEmpty || prod.newImages.isNotEmpty;
                    return SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          // Cor de fundo azul em ambos os temas
                          backgroundColor: cs.primary,
                          // Cor do texto: branco no escuro, preto no claro
                          foregroundColor:
                              isDarkNow ? cs.onPrimary : Colors.black,
                        ),
                        onPressed: (!prod.loading && hasImage)
                            ? () async {
                                if (!formKey.currentState!.validate()) return;
                                formKey.currentState!.save();
                                prod.loading = true;
                                try {
                                  await prod.save();
                                  if (context.mounted)
                                    Navigator.of(context).pop();
                                } finally {
                                  prod.loading = false;
                                }
                              }
                            : null,
                        child: prod.loading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDarkNow ? cs.onPrimary : Colors.black,
                                ),
                              )
                            : Text('Salvar',
                                style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      isDarkNow ? cs.onPrimary : Colors.black,
                                )),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
