import 'package:app_tcc/models/contact.dart';
import 'package:app_tcc/models/contact_manager.dart';
import 'package:app_tcc/models/order_product.dart';
import 'package:app_tcc/models/product.dart';
import 'package:app_tcc/models/product_size.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class OrderProductManager extends ChangeNotifier {
  Contact? contact;

  List<OrderProduct> items = [];
  num productsPrice = 0.0;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  num get totalPrice => productsPrice;

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setSelectedSize(Product product, ProductSize size) {
    if (size.hasStock) {
      product.selectedSize = size;
      print('ps: ${product.selectedSize}');
    }
  }

  void updateContact(ContactManager contactManager) {
    print('passou aq');
    contact = contactManager.findContactById(selectedContactID);
    print('up: $contact');
    productsPrice = 0.0;
    items.clear();

    if (contact != null) {
      _loadOrderItems();
    }
  }

  String _selectedContactID = '';
  String get selectedContactID => _selectedContactID;
  set selectedContactID(String id) {
    _selectedContactID = id;
    notifyListeners();
    print('cid: $selectedContactID');
  }

  String _selectedProductID = '';
  String get selectedProductID => _selectedProductID;
  set selectedProductID(String id) {
    _selectedProductID = id;
    notifyListeners();
    print('pid: $selectedProductID');
  }

  int _selectedProductQtd = 0;
  int get selectedProductQtd => _selectedProductQtd;
  set selectedProductQtd(int qtd) {
    _selectedProductQtd = qtd;
    notifyListeners();
    print('qts selecionada: $selectedProductQtd');
  }

  Future<void> _loadOrderItems() async {
    final QuerySnapshot cartSnap = await contact!.cartRef.get();

    items = cartSnap.docs
        .map((d) => OrderProduct.fromDocument(d)..addListener(_onItemUpdated))
        .toList();
  }

  void addToOrder(Product product) {
    try {
      final e = items.firstWhere((element) => element.stackable(product));
      for (int qtd = 0; qtd < selectedProductQtd; qtd++) {
        e.increment();
      }
    } catch (e) {
      final orderProduct = OrderProduct.fromProduct(product);
      orderProduct.setQtd(selectedProductQtd);
      orderProduct.addListener(_onItemUpdated);
      items.add(orderProduct);

      contact!.cartRef
          .add(orderProduct.toOrderProductMap())
          .then((doc) => orderProduct.id = doc.id);
      _onItemUpdated();
    }
    notifyListeners();
    print('items: $items');
  }

  void removeOfOrder(OrderProduct orderProduct) {
    items.removeWhere((p) => p.id == orderProduct.id);
    contact!.cartRef.doc(orderProduct.id).delete();
    orderProduct.removeListener(_onItemUpdated);
    notifyListeners();
  }

  void clear() {
    for (final cartProduct in items) {
      contact!.cartRef.doc(cartProduct.id).delete();
    }
    selectedProductQtd = 0;
    productsPrice = 0.0;
    items.clear();
    notifyListeners();
  }

  void _onItemUpdated() {
    productsPrice = 0.0;

    for (int i = 0; i < items.length; i++) {
      final orderProduct = items[i];

      if (orderProduct.quantity == 0) {
        removeOfOrder(orderProduct);
        i--;
        continue;
      }
      productsPrice += orderProduct.totalPrice;
      _updateOrderProduct(orderProduct);
    }
    notifyListeners();
  }

  bool get isOrderValid {
    for (final orderProduct in items) {
      if (!orderProduct.hasStock) return false;
    }
    return true;
  }

  int stackOrderProductQtd() {
    final List<int> qtd = [];

    try {
      for (int c = 0; c < items.length; c++) {
        qtd.add(items[c].quantity!);
      }

      final soma = qtd.reduce((soma, i) => soma + i);
      return soma;
    } catch (e) {
      return 0;
    }
  }

  void _updateOrderProduct(OrderProduct orderProduct) {
    if (orderProduct.id != null) {
      contact!.cartRef
          .doc(orderProduct.id)
          .update(orderProduct.toOrderProductMap());
    }
  }
}
