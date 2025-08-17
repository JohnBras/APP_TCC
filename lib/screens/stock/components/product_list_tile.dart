import 'package:app_tcc/models/product.dart';
import 'package:app_tcc/theme/dynamic_colors.dart';
import 'package:flutter/material.dart';

class ProductListTile extends StatelessWidget {
  final Product product;
  final Color? nameColor; // cor opcional do título
  final Color? cardBg; // cor opcional do fundo do card
  final Color? priceColor; // cor opcional do preço

  const ProductListTile(
    this.product, {
    Key? key,
    this.nameColor,
    this.cardBg,
    this.priceColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Paleta padrão do tema (usada quando não há override)
    final Color bg = cardBg ?? DynamicColors.cardBg(context);
    final Color onCard = DynamicColors.onCard(context);

    // Cores efetivas (aplicam override se foi passado)
    final Color effectiveNameColor = nameColor ?? onCard;
    final Color effectivePriceColor =
        priceColor ?? Theme.of(context).primaryColor;

    // Valores seguros
    final String name = product.name ?? '';
    final String priceText = (product.price ?? 0).toStringAsFixed(2);
    final String imageUrl =
        product.images.isNotEmpty ? product.images.first : '';

    return Card(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          '/edit_product',
          arguments: product,
        ),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // miniatura
              AspectRatio(
                aspectRatio: 1,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.broken_image, color: onCard),
                      )
                    : Icon(Icons.image_not_supported, color: onCard),
              ),
              const SizedBox(width: 16),
              // nome + preço
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título — agora respeita nameColor
                    Text(
                      name,
                      style: TextStyle(
                        color: effectiveNameColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600, // negrito
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Preço — azul do tema (ou override)
                    Text(
                      'R\$ $priceText',
                      style: TextStyle(
                        color: effectivePriceColor,
                        fontSize: 14,
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
