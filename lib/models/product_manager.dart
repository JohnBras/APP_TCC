import 'dart:async';
import 'package:app_tcc/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProductManager extends ChangeNotifier {
  ProductManager() {
    _subscribeToProducts();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final StreamSubscription<List<Product>> _sub;

  List<Product> allProducts = [];

  // ==== busca ====
  String _search = '';
  String get search => _search;
  set search(String value) {
    _search = value;
    notifyListeners();
  }

  // ==== stream ====
  Stream<List<Product>> get productsStream => _firestore
      .collection('products')
      .where('deleted', isEqualTo: false)
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs.map((d) => Product.fromDocument(d)).toList());

  void _subscribeToProducts() {
    _sub = productsStream.listen(
      (data) {
        allProducts = data;
        notifyListeners();
      },
      onError: (e) => debugPrint('Erro ao buscar produtos: $e'),
    );
  }

  // ==== filtro ====
  List<Product> get filteredProducts {
    if (_search.isEmpty) return allProducts;
    final lower = _search.toLowerCase();
    return allProducts
        .where((p) => p.name?.toLowerCase().contains(lower) ?? false)
        .toList();
  }

  // ==== ações ====
  Future<void> update(Product p) async {
    await _firestore.collection('products').doc(p.id).update({
      'name': p.name,
      'description': p.description,
      'price': p.price,
      'sizes': p.exportSizeList(),
      'deleted': p.deleted,
      'images': p.images,
      // força refresh se nada mudou
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(Product p) async {
    await _firestore.collection('products').doc(p.id).delete();
    ({
      'deleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Busca um produto pelo ID na lista atual
  Product? findProductById(String id) {
    try {
      return allProducts.firstWhere(
        (p) => p.id == id && p.deleted == false,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
