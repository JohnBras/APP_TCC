import 'package:cloud_firestore/cloud_firestore.dart';

class Forecast {
  final String id;
  final double predicted;
  final double historicalAverage;
  final Timestamp generatedAt;

  Forecast({
    required this.id,
    required this.predicted,
    required this.historicalAverage,
    required this.generatedAt,
  });

  factory Forecast.fromJson(Map<String, dynamic> json, String id) {
    return Forecast(
      id: id,
      predicted: (json['predicted'] ?? 0).toDouble(),
      historicalAverage:
          (json['historical_average'] ?? json['historicalAverage'] ?? 0)
              .toDouble(),
      generatedAt: json['generated_at'] as Timestamp,
    );
  }
}
