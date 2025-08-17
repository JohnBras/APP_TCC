import 'package:app_tcc/models/order_product.dart';
import 'package:app_tcc/models/order_product_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

enum Status { canceled, made, preparing, confirmed }

class Order extends ChangeNotifier {
  String? orderId;
  String? cId;
  List<OrderProduct>? items;
  num? price;
  Status? status;
  Timestamp? date;

  Order();

  String get formattedId => '#${orderId!.padLeft(6, '0')}';

  String get statusText => getStatusText(status!);

  Order.fromOrderProductManager(OrderProductManager cartManager) {
    items = List.from(cartManager.items);
    price = cartManager.totalPrice;
    cId = cartManager.contact!.id;
    status = Status.made;
  }

  Order.fromDocument(DocumentSnapshot document) {
    orderId = document.id;

    items = (document['items'] as List<dynamic>).map((e) {
      return OrderProduct.fromMap(e as Map<String, dynamic>);
    }).toList();

    price = document['price'] as num;
    cId = document['contact'] as String;
    date = document['date'] as Timestamp;
    status = Status.values[document['status'] as int];
  }

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  DocumentReference get orderRef => firestore.collection('order').doc(orderId);

  void updateFromDocument(DocumentSnapshot document) {
    status = Status.values[document['status'] as int];
  }

  Future<void> save() async {
    firestore.collection('order').doc(orderId).set({
      'items': items!.map((e) => e.toOrderProductMap()).toList(),
      'price': price,
      'contact': cId,
      'status': status!.index,
      'date': Timestamp.now(),
    });
  }

  /*Transactions? transactions;
  DocumentReference get financeRef =>
      firestore.collection('finances').doc(transactions!.id);
*/
  Function()? get paid {
    return status!.index != Status.preparing.index
        ? () {
            status = Status.preparing;
            orderRef.update({'status': status!.index});
            //financeRef.update({'value': price});
          }
        : null;
  }

  Function()? get delivered {
    return status!.index != Status.confirmed.index
        ? () {
            status = Status.confirmed;
            orderRef.update({'status': status!.index});
          }
        : null;
  }

  Future<void> cancel() async {
    try {
      status = Status.canceled;
      orderRef.update({'status': status!.index});
    } catch (e) {
      debugPrint('Erro ao cancelar');
      return Future.error('Falha ao cancelar');
    }
  }

  late OrderProduct _selectedOrder;
  OrderProduct get selectedOrder => _selectedOrder;
  set selectedOrder(OrderProduct selectedOrder) {
    _selectedOrder = selectedOrder;
    notifyListeners();
    print('pedido indivual carregado');
  }

  String get dateFormat {
    initializeDateFormatting('pt_BR');
    final DateTime dt = date!.toDate();
    return DateFormat(DateFormat.YEAR_NUM_MONTH_DAY, 'pt_Br').format(dt);
  }

  int get monthOrder {
    initializeDateFormatting('pt_BR');
    final DateTime dt = date!.toDate();
    return int.parse(DateFormat(DateFormat.NUM_MONTH, 'pt_Br').format(dt));
  }

  int get currentMonth {
    initializeDateFormatting('pt_BR');
    return int.parse(
        DateFormat(DateFormat.NUM_MONTH, 'pt_Br').format(DateTime.now()));
  }

  int itemsByMonth(List<Order> orders, int month) {
    final List<int> validOrders = [];
    try {
      for (int o = 0; o < orders.length; o++) {
        if (orders[o].monthOrder == month) {
          validOrders.add(orders[o].items!.length);
        }
      }
      final items = validOrders.reduce((soma, i) => soma + i);
      //validOrders.addAll(orders..where((o) => o.monthOrder == month).);
      return items;
    } catch (e) {
      return 0;
    }
  }

  num? stackGainOrder(List<Order> orders) {
    final List<num> validGain = [];

    try {
      for (int o = 0; o < orders.length; o++) {
        validGain.add(orders[o].price!);
      }

      final soma = validGain.reduce((soma, i) => soma + i);
      return soma;
    } catch (e) {
      return 0;
    }
  }

  num stackGainOrderByMonth(List<Order> orders, int month) {
    final List<num> validGain = [];

    try {
      for (int o = 0; o < orders.length; o++) {
        if (orders[o].monthOrder == month) validGain.add(orders[o].price!);
      }

      final sum = validGain.reduce((sum, i) => sum + i);
      return sum;
    } catch (e) {
      return 0;
    }
  }

  num percentGain(List<Order> orders, int month) {
    try {
      final percent = stackGainOrderByMonth(orders, month) /
          stackGainOrderByMonth(orders, month - 1);
      return percent;
    } catch (e) {
      return 0;
    }
  }

  static String getStatusText(Status status) {
    switch (status) {
      case Status.canceled:
        return 'Cancelado';
      case Status.made:
        return 'Realizado';
      case Status.preparing:
        return 'Preparando entrega';
      case Status.confirmed:
        return 'Concluído';
    }
  }

  @override
  String toString() {
    return 'Pedido{orderId: $orderId, cID: $cId, price: $price, status: $status, timestamp: $date, items: $items}';
  }
}
