import 'package:app_tcc/commom/custom_icon_button.dart';
import 'package:app_tcc/models/product_size.dart';
import 'package:app_tcc/theme/dynamic_colors.dart';
import 'package:flutter/material.dart';

class EditItemSize extends StatelessWidget {
  const EditItemSize({super.key, this.size, this.onRemove});
  final ProductSize? size;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    // ▶️ cores dinâmicas
    final cardBg = DynamicColors.cardBg(context);
    final onCard = DynamicColors.onCard(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Define a cor do texto: preto no tema claro, onCard no tema escuro
    final textColor = isDarkTheme ? onCard : Colors.black;

    return Container(
      color: cardBg, // fundo adaptativo
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Campo Numeração
          Expanded(
            flex: 20,
            child: TextFormField(
              initialValue: size!.sizeValue?.toString(),
              decoration: InputDecoration(
                labelText: 'Numeração',
                labelStyle: TextStyle(color: textColor.withOpacity(.7)),
                isDense: true,
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: textColor),
              keyboardType: TextInputType.number,
              validator: (v) => int.tryParse(v!) == null ? 'Inválido' : null,
              onChanged: (v) => size!.sizeValue = int.tryParse(v),
            ),
          ),
          const SizedBox(width: 12),
          // Campo Estoque
          Expanded(
            flex: 20,
            child: TextFormField(
              initialValue: size!.stock?.toString(),
              decoration: InputDecoration(
                labelText: 'Estoque',
                labelStyle: TextStyle(color: textColor.withOpacity(.7)),
                isDense: true,
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: textColor),
              keyboardType: TextInputType.number,
              validator: (v) => int.tryParse(v!) == null ? 'Inválido' : null,
              onChanged: (v) => size!.stock = int.tryParse(v),
            ),
          ),
          const SizedBox(width: 12),
          // Botão Remover tamanho e estoque
          CustomIconButton(
            iconData: Icons.clear_rounded,
            color: Colors.redAccent,
            onTap: onRemove,
          ),
        ],
      ),
    );
  }
}
