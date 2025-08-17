import 'package:app_tcc/models/order_product_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Cart summary card used on New‑Order / Cart screens
class PriceCard extends StatelessWidget {
  const PriceCard({
    super.key,
    this.buttonText,
    this.onPressed,
    this.cartManager,
  });

  final String? buttonText;
  final VoidCallback? onPressed;
  final OrderProductManager? cartManager;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    // Usa o cartManager injetado (se houver), senão observa via Provider.
    final cm = cartManager ?? context.watch<OrderProductManager>();

    final int productQtd = cm.stackOrderProductQtd();
    final num productsPrice = cm.productsPrice;
    final num totalPrice = cm.totalPrice;

    final borderColor = (cs.outlineVariant); // fallback

    return Card(
      color: isLight ? Colors.white : cs.surface,
      elevation: isLight ? 0 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLight
            ? BorderSide(color: borderColor, width: 1)
            : BorderSide(color: Colors.transparent, width: 0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Resumo do Pedido',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isLight ? Colors.black : cs.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _RowKV(
              label: 'Quantidade de produtos',
              value: productQtd.toString(),
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isLight ? Colors.black : cs.onSurface,
              ),
              valueStyle: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: borderColor, height: 1, thickness: 1),
            const SizedBox(height: 12),
            _RowKV(
              label: 'Subtotal',
              value: 'R\$ ${productsPrice.toStringAsFixed(2)}',
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isLight ? Colors.black : cs.onSurface,
              ),
              valueStyle: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _RowKV(
              label: 'Total',
              value: 'R\$ ${totalPrice.toStringAsFixed(2)}',
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isLight ? Colors.black : cs.onSurface,
              ),
              valueStyle: theme.textTheme.titleMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              button: true,
              label: (buttonText?.trim().isEmpty ?? true)
                  ? 'Confirmar'
                  : buttonText!.trim(),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary, // bom contraste
                  disabledBackgroundColor: cs.primary.withOpacity(0.40),
                  disabledForegroundColor: cs.onPrimary.withOpacity(0.40),
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onPressed,
                child: Text(
                  (buttonText?.trim().isEmpty ?? true)
                      ? 'Confirmar'
                      : buttonText!.trim(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha chave‑valor com alinhamento e overflow seguros
class _RowKV extends StatelessWidget {
  const _RowKV({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child:
              Text(label, style: labelStyle, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: valueStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
