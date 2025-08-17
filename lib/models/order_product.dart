import 'package:app_tcc/models/product.dart';
import 'package:app_tcc/models/product_size.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class OrderProduct extends ChangeNotifier {
  String? id;
  String? productId;
  int? quantity;
  String? size;
  num? fixedPrice;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  OrderProduct({this.productId, this.quantity, this.size});

  OrderProduct.fromMap(Map<String, dynamic> map) {
    productId = map['pid'] as String;
    quantity = map['quantity'] as int;

    final rawSize = map['size'];
    size = rawSize is num ? rawSize.toString() : rawSize as String?;
    // carrega o produto assíncrono…

    firestore
        .doc('products/$productId')
        .get()
        .then((doc) => product = Product.fromDocument(doc));
  }

  OrderProduct.fromDocument(DocumentSnapshot document) {
    // 1) Documento ID
    id = document.id;

    // 2) Campos básicos
    productId = document['pid'] as String?;
    quantity = (document['quantity'] as int?) ?? 1;

    // 3) Lê o campo "size" que pode vir numérico ou string
    final rawSize = document['size'];
    if (rawSize is num) {
      size = rawSize.toString();
    } else {
      size = rawSize as String?;
    }

    // 4) Se existir fixedPrice, captura também
    fixedPrice = document.data().toString().contains('fixedPrice')
        ? document['fixedPrice'] as num?
        : null;

    firestore
        .doc('products/$productId')
        .get()
        .then((snap) => product = Product.fromDocument(snap));
  }

  OrderProduct.fromProduct(Product product) {
    // 1) Guarda o Product
    _product = product;

    // 2) Acesso direto a id e price, que não são nulos
    productId = product.id;
    quantity = 1;
    fixedPrice = product.price;

    // 3) selectedSize agora é não-nulo, então só usar ponto:
    final rawSize = product.selectedSize.sizeValue;
    size = rawSize.toString();
  }

  Product? _product;
  Product get product => _product!;
  set product(Product value) {
    _product = value;
    notifyListeners();
  }

  ProductSize? get itemSize {
    return product.findSize(size.toString());
  }

  num get unitPrice {
    return product.price ?? 0;
  }

  num get totalPrice => unitPrice * quantity!;

  Map<String, dynamic> toOrderProductMap() {
    return {
      'pid': productId,
      'quantity': quantity,
      'size': size,
    };
  }

  Map<String, dynamic> toOrderMap() {
    return {
      'pid': productId,
      'quantity': quantity,
      'size': size,
      'fixedPrice': fixedPrice ?? unitPrice,
    };
  }

  bool stackable(Product product) {
    return product.id == productId && product.selectedSize.sizeValue == size;
  }

  void setQtd(int qtd) {
    quantity = qtd;
    notifyListeners();
  }

  void increment() {
    quantity = quantity! + 1;
    notifyListeners();
  }

  void decrement() {
    quantity = quantity! - 1;
    notifyListeners();
  }

  bool get hasStock {
    if (product.deleted!) return false;

    final size = itemSize;

    if (size == null) return false;
    if (product.selectedSize.stock! <= 0) return false;
    return product.selectedSize.stock! >= quantity!;
  }

  @override
  String toString() {
    return 'OrderProduct{ID Prod: $productId, quantidade: $quantity, tamanho: $size}';
  }
}
