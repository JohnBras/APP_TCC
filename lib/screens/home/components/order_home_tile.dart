import 'package:app_tcc/models/contact_manager.dart';
import 'package:app_tcc/models/order.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderHomeTile extends StatelessWidget {
  const OrderHomeTile(this.order, {super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Cores padronizadas com o tema da Home
    final Color cardBg = isDark ? cs.surface : Colors.white;
    final Color border = (theme.colorScheme.outlineVariant);
    // Título/valores: no claro usa primary (visual da Home), no escuro usa onSurface
    final Color titleClr = isDark ? cs.onSurface : cs.primary;
    // Textos secundários (data/cliente)
    final Color subClr = isDark ? cs.onSurfaceVariant : cs.onSurfaceVariant;

    final contact =
        context.read<ContactManager>().findContactById(order.cId ?? '');

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      color: cardBg,
      elevation: isDark ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.transparent : border,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Pedido + Status ────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pedido ${order.formattedId}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: titleClr,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              order.statusText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: (order.status?.index ?? 1) == 0
                                    ? cs.error
                                    : subClr,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: subClr,
                            ),
                          ],
                        ),
                      ],
                    ),
                    // ── Valor ─────────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'R\$ ${(order.price ?? 0).toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: titleClr,
                        ),
                      ),
                    ),
                    // ── Data + Cliente ────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            order.dateFormat,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: subClr,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            contact?.name ?? 'Sem contato',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: subClr,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
