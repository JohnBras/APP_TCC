import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forecast.dart';

class ForecastRepository {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Obtém previsões de demanda; usa Cloud Function ou, em caso de not-found, Firestore.
  Future<List<Forecast>> fetchDemandForecast(int windowDays) async {
    try {
      final result = await _functions
          .httpsCallable('predictDemand')
          .call({'window': windowDays});
      final List<dynamic> data = result.data as List<dynamic>;
      return data
          .map((item) => Forecast.fromJson(
              item as Map<String, dynamic>, item['product_id'] as String))
          .toList();
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'not-found') {
        final snapshot = await FirebaseFirestore.instance
            .collection('forecasts')
            .where('type', isEqualTo: 'demand')
            .get();
        return snapshot.docs
            .map((doc) => Forecast.fromJson(doc.data(), doc.id))
            .toList();
      }
      rethrow;
    }
  }

  /// Obtém previsão de vendas totais; usa Cloud Function ou, em caso de not-found, Firestore ou default.
  Future<Forecast> fetchSalesForecast(int windowDays) async {
    try {
      final result = await _functions
          .httpsCallable('predictSales')
          .call({'window': windowDays});
      final Map<String, dynamic> data = Map<String, dynamic>.from(result.data);
      return Forecast.fromJson(data, data['id'] as String);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'not-found') {
        final docSnap = await FirebaseFirestore.instance
            .collection('forecasts')
            .doc('total_sales')
            .get();
        if (docSnap.exists && docSnap.data() != null) {
          return Forecast.fromJson(docSnap.data()!, docSnap.id);
        }
        return Forecast(
          id: 'total_sales',
          predicted: 0.0,
          historicalAverage: 0.0,
          generatedAt: Timestamp.now(),
        );
      }
      rethrow;
    }
  }
}
