import 'package:flutter/material.dart';
import 'package:app_tcc/repositories/forecast_repository.dart';
import '../models/forecast.dart';

class ForecastManager extends ChangeNotifier {
  final ForecastRepository _repository;
  int _windowDays;
  List<Forecast> _demand = [];
  Forecast? _sales;

  ForecastManager(
    this._repository, {
    int initialWindowDays = 7,
  }) : _windowDays = initialWindowDays {
    _loadForecasts();
  }

  List<Forecast> get demand => _demand;
  Forecast? get sales => _sales;
  int get windowDays => _windowDays;

  Future<void> updateWindowDays(int days) async {
    _windowDays = days;
    await _loadForecasts();
  }

  Future<void> _loadForecasts() async {
    try {
      _demand = await _repository.fetchDemandForecast(_windowDays);
      _sales = await _repository.fetchSalesForecast(_windowDays);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao buscar previsões: $e');
    }
  }
}
