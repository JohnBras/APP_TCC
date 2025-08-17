import 'package:app_tcc/commom/custom_icon_button.dart';
import 'package:app_tcc/models/product.dart';
import 'package:app_tcc/models/product_size.dart';
import 'package:app_tcc/screens/edit_product/components/edit_product_size.dart';
import 'package:app_tcc/theme/dynamic_colors.dart';
import 'package:flutter/material.dart';

class SizesForm extends StatefulWidget {
  const SizesForm(this.product, {super.key});
  final Product product;

  @override
  State<SizesForm> createState() => _SizesFormState();
}

class _SizesFormState extends State<SizesForm> {
  @override
  Widget build(BuildContext context) {
    // Cores adaptativas
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onCard = DynamicColors.onCard(context);
    // Define a cor do texto: preto no tema claro, onCard no tema escuro
    final textColor = isDarkTheme ? onCard : Colors.black;

    return FormField<List<ProductSize>>(
      initialValue: widget.product.sizes,
      validator: (sizes) {
        if (sizes == null || sizes.isEmpty) return 'Insira um tamanho';
        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título e botão adicionar
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tamanhos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor, // Preto no tema claro
                    ),
                  ),
                ),
                CustomIconButton(
                  iconData: Icons.add,
                  color: textColor, // Preto no tema claro
                  onTap: () {
                    state.value!.add(ProductSize());
                    state.didChange(state.value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Lista de tamanhos
            Column(
              children: state.value!.map((size) {
                return EditItemSize(
                  key: ObjectKey(size),
                  size: size,
                  onRemove: () {
                    state.value!.remove(size);
                    state.didChange(state.value);
                  },
                );
              }).toList(),
            ),
            // Mensagem de erro
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
