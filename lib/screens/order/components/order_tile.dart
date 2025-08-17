import 'package:app_tcc/commom/order/dialog_cancel.dart';
import 'package:app_tcc/models/order.dart';
import 'package:app_tcc/screens/order/components/order_product_tile.dart';
import 'package:app_tcc/theme/dynamic_colors.dart';
import 'package:flutter/material.dart';

class OrderTile extends StatelessWidget {
  const OrderTile(
    this.order, {
    Key? key,
    this.showControls = false,
  }) : super(key: key);

  final Order order;
  final bool showControls;

  @override
  Widget build(BuildContext context) {
    final cardBg = DynamicColors.cardBg(context);
    final onCard = DynamicColors.onCard(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: cardBg,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            backgroundColor: cardBg,
            collapsedBackgroundColor: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            iconColor: onCard,
            collapsedIconColor: onCard,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.formattedId,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: onCard, // usa cor de texto adaptativa
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${order.price!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: onCard, // cor adaptativa para preço
                      ),
                    ),
                  ],
                ),
                Text(
                  order.statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: order.status == Status.canceled
                        ? Colors.redAccent
                        : onCard, // status também adapta cor
                  ),
                ),
              ],
            ),
            children: [
              // Detalhes dos produtos
              ...order.items!.map((item) => OrderProductTile(item)),

              // Controles (cancelar/pagamento/entrega)
              if (showControls &&
                  order.status != Status.canceled &&
                  order.status != Status.confirmed)
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Botão Cancelar
                      TextButton(
                        onPressed: () {
                          if (order.status!.index == 1) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => CancelOrderDialog(order),
                            );
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.topCenter,
                                  children: [
                                    SizedBox(
                                      height: 190,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 40, 10, 10),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Falha ao cancelar pedido!',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: onCard,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Text(
                                                'Pedido já confirmado! Não é possível cancelar!',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: onCard,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blueGrey.shade700,
                                              ),
                                              child: const Text(
                                                'Fechar',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Positioned(
                                      top: -30,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.redAccent,
                                        radius: 30,
                                        child: Icon(
                                          Icons.assistant_photo,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),

                      // Botão Pagamento / Pago
                      TextButton(
                        onPressed: order.paid,
                        child: Text(
                          order.status!.index == 2
                              ? 'Pago'
                              : 'Confirmar pagamento',
                          style: TextStyle(
                            color: order.status!.index == 2
                                ? onCard.withOpacity(0.6)
                                : onCard,
                          ),
                        ),
                      ),

                      // Botão Entrega / Entregue
                      if (order.status!.index == 2)
                        TextButton(
                          onPressed: order.delivered,
                          child: Text(
                            order.status!.index == 3
                                ? 'Entregue'
                                : 'Confirmar entrega',
                            style: TextStyle(
                              color: order.status!.index == 3
                                  ? onCard.withOpacity(0.6)
                                  : onCard,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
