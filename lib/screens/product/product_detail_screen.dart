// ──────────────────────────────────────────────────────────────────────────────
// Tela de DETALHES de um produto.
// • Exibe foto, preço, descrição e tamanhos/estoque.
// • Recebe um objeto Product pela navegação (arguments).
// • No AppBar há um botão de lápis que redireciona para a tela de edição
//   passando o mesmo Product como argumento.
// ──────────────────────────────────────────────────────────────────────────────

import 'package:app_tcc/models/product.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product_detail';

  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Recebe o Product passado na navegação:
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name ?? 'Produto'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar produto',
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/edit_product',
                arguments: product,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // • Foto principal do produto
          //   – Se houver imagens, exibe a primeira.
          //   – Caso contrário, mostra ícone de “imagem indisponível”.

          if (product.images.isNotEmpty)
            Image.network(product.images.first, height: 200, fit: BoxFit.cover)
          else
            const SizedBox(
              height: 200,
              child: Center(child: Icon(Icons.image_not_supported, size: 80)),
            ),
          const SizedBox(height: 16),
          Text(
            'Preço: R\$ ${product.price?.toStringAsFixed(2) ?? '—'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            product.description ?? '',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            'Tamanhos:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          ...?product.sizes
              ?.map((s) => Text('- ${s.sizeValue} (${s.stock} em estoque)')),
        ],
      ),
    );
  }
}
