import 'package:app_tcc/models/order_product.dart';
import 'package:app_tcc/theme/dynamic_colors.dart';
import 'package:flutter/material.dart';

class OrderProductTile extends StatelessWidget {
  const OrderProductTile(this.cartProduct, {super.key});

  final OrderProduct cartProduct;

  @override
  Widget build(BuildContext context) {
    final onCard = DynamicColors.onCard(context);

    // Cada item agora é apenas uma linha dentro do mesmo fundo do OrderTile
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Imagem
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 60,
              height: 60,
              child: cartProduct.product.images.isNotEmpty
                  ? Image.network(
                      cartProduct.product.images.first,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: onCard.withOpacity(0.6),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Detalhes do produto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartProduct.product.name ?? '',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: onCard,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tamanho: ${cartProduct.size}',
                  style: TextStyle(
                    fontSize: 14,
                    color: onCard.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${(cartProduct.fixedPrice ?? cartProduct.unitPrice).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: onCard, // <— agora usa onCard
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Quantidade
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Qtd:',
                style: TextStyle(
                  fontSize: 14,
                  color: onCard.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${cartProduct.quantity}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: onCard, // <— agora usa onCard
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
