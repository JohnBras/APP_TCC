// lib/models/order_manager.dart
import 'dart:async';

import 'package:app_tcc/models/order.dart' as local;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderManager extends ChangeNotifier {
  OrderManager() {
    _listenToOrders();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  final List<local.Order> _orders = [];

  // Carregamento (para a UI não “zerar” durante refresh)
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// Filtro por status (use apenas em telas que precisam filtrar)
  /// Obs.: por padrão aqui está [made] só por compatibilidade com seu código.
  List<local.Status> statusFilter = [local.Status.made];

  // ---------------- Getters ----------------

  /// Lista completa, sempre ordenada por orderId (numérico se possível).
  List<local.Order> get allOrders {
    final sorted = List<local.Order>.from(_orders);
    sorted.sort(_compareOrderId);
    return sorted;
  }

  /// Mesma lista, mas aplicando o statusFilter (use quando quiser filtrar).
  List<local.Order> get filteredOrders {
    final sorted = allOrders;
    return sorted
        .where((o) => o.status != null && statusFilter.contains(o.status))
        .toList();
  }

  /// Pedidos com pagamento confirmado ou acima (ajuste o limiar se necessário).
  List<local.Order> get paidOrders =>
      allOrders.where((o) => o.status != null && o.status!.index >= 2).toList();

  // ---------------- Stream ----------------

  void _listenToOrders() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = firestore.collection('order').snapshots().listen(
      (snap) {
        // Reconstroi a lista a cada snapshot (evita duplicados e trata removals)
        final next = snap.docs.map((d) => local.Order.fromDocument(d)).toList();
        _orders
          ..clear()
          ..addAll(next);

        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Reanexa o listener sem limpar a lista atual (evita “piscar zero”).
  Future<void> refresh() async {
    await _subscription?.cancel();
    _listenToOrders();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ---------------- Ações / Utils ----------------

  void setStatusFilter({local.Status? status, bool? enabled}) {
    if (status == null) return;
    if (enabled == true) {
      if (!statusFilter.contains(status)) statusFilter.add(status);
    } else {
      statusFilter.remove(status);
    }
    notifyListeners();
  }

  local.Order? orderById(String id) {
    try {
      return allOrders.firstWhere((o) => o.orderId == id);
    } catch (_) {
      return null;
    }
  }

  // ---------------- Agregações ----------------

  /// Mapa Jan..Dez -> total vendido, usando [paidOrders].
  Map<String, double> get monthlySalesMap {
    final Map<String, double> map = {
      'Jan': 0,
      'Fev': 0,
      'Mar': 0,
      'Abr': 0,
      'Mai': 0,
      'Jun': 0,
      'Jul': 0,
      'Ago': 0,
      'Set': 0,
      'Out': 0,
      'Nov': 0,
      'Dez': 0,
    };

    for (final order in paidOrders) {
      final ts = order.date;
      final price = order.price;
      if (ts == null || price == null) continue;
      final m = ts.toDate().month;
      map[_monthAbbr(m)] = (map[_monthAbbr(m)] ?? 0) + price;
    }
    return map;
  }

  /// Versão por ano específico (útil se quiser delegar para o manager).
  Map<String, double> monthlySalesMapForYear(int year) {
    final Map<String, double> map = {
      'Jan': 0,
      'Fev': 0,
      'Mar': 0,
      'Abr': 0,
      'Mai': 0,
      'Jun': 0,
      'Jul': 0,
      'Ago': 0,
      'Set': 0,
      'Out': 0,
      'Nov': 0,
      'Dez': 0,
    };

    for (final order in paidOrders) {
      final ts = order.date;
      final price = order.price;
      if (ts == null || price == null) continue;
      final d = ts.toDate();
      if (d.year != year) continue;
      map[_monthAbbr(d.month)] = (map[_monthAbbr(d.month)] ?? 0) + price;
    }
    return map;
  }

  /// Lista simples de valores (se quiser montar gráficos de distribuição).
  List<double> get dailyTransactionsList =>
      paidOrders.map((o) => (o.price ?? 0).toDouble()).toList();

  // ---------------- Helpers ----------------

  int _compareOrderId(local.Order a, local.Order b) {
    // Tenta comparar numericamente; se não der, compara por string.
    final ai = int.tryParse(a.orderId ?? '');
    final bi = int.tryParse(b.orderId ?? '');
    if (ai != null && bi != null) return ai.compareTo(bi);
    return (a.orderId ?? '').compareTo(b.orderId ?? '');
  }

  String _monthAbbr(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
