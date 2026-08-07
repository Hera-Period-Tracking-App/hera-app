import 'dart:convert';
import 'dart:math';

const _historyFields = [
  'cycle_length',
  'ovulation_day',
  'first_day_of_high',
  'total_number_of_high_days',
  'total_high_post_peak',
  'total_number_of_peak_days',
  'total_days_of_fertility',
  'length_of_menses',
];

class CyclePrediction {
  CyclePrediction({
    required this.ovulationDay,
    required this.firstDayOfHigh,
    required this.totalNumberOfHighDays,
    required this.totalHighPostPeak,
    required this.totalNumberOfPeakDays,
    required this.totalDaysOfFertility,
    required this.lengthOfMenses,
  });

  final int ovulationDay;
  final int firstDayOfHigh;
  final int totalNumberOfHighDays;
  final int totalHighPostPeak;
  final int totalNumberOfPeakDays;
  final int totalDaysOfFertility;
  final int lengthOfMenses;
}

class LocalCyclePredictor {
  LocalCyclePredictor.fromJson(String jsonString)
      : _model = jsonDecode(jsonString) as Map<String, dynamic>;

  final Map<String, dynamic> _model;

  CyclePrediction predict({
    required List<Map<String, num?>> history,
  }) {
    final features = _buildFeatureVector(history);
    final raw = _predictRaw(features);

    final ovulationDay = raw[0].round().clamp(8, 35);

    return CyclePrediction(
      ovulationDay: ovulationDay,
      firstDayOfHigh: raw[1].round().clamp(1, 45),
      totalNumberOfHighDays: raw[2].round().clamp(0, 30),
      totalHighPostPeak: raw[3].round().clamp(0, 30),
      totalNumberOfPeakDays: raw[4].round().clamp(0, 10),
      totalDaysOfFertility: raw[5].round().clamp(0, 30),
      lengthOfMenses: raw[6].round().clamp(1, 15),
    );
  }

  List<double> _predictRaw(List<double?> featureValues) {
    final medians = (_model['imputer_medians'] as List).cast<num>();
    final means = (_model['scaler_mean'] as List).cast<num>();
    final scales = (_model['scaler_scale'] as List).cast<num>();
    final coefficients = (_model['coefficients'] as List).cast<List<dynamic>>();
    final intercepts = (_model['intercepts'] as List).cast<num>();

    final scaled = <double>[];
    for (var i = 0; i < featureValues.length; i++) {
      final imputed = featureValues[i] ?? medians[i].toDouble();
      scaled.add((imputed - means[i].toDouble()) / scales[i].toDouble());
    }

    return List.generate(coefficients.length, (targetIndex) {
      final coef = coefficients[targetIndex].cast<num>();
      var value = intercepts[targetIndex].toDouble();
      for (var i = 0; i < scaled.length; i++) {
        value += scaled[i] * coef[i].toDouble();
      }
      return value;
    });
  }

  List<double?> _buildFeatureVector(List<Map<String, num?>> history) {
    final recent = history.length > 3 ? history.sublist(history.length - 3) : history;
    final last = history.isNotEmpty ? history.last : <String, num?>{};

    double? value(Map<String, num?> item, String key) => item[key]?.toDouble();

    List<double> values(String key) => recent
        .map((item) => value(item, key))
        .whereType<double>()
        .toList();

    double? mean(List<double> items) {
      if (items.isEmpty) return null;
      return items.reduce((a, b) => a + b) / items.length;
    }

    double? sampleStd(List<double> items) {
      if (items.length < 2) return null;
      final avg = mean(items)!;
      final variance = items.map((item) => pow(item - avg, 2)).reduce((a, b) => a + b) / (items.length - 1);
      return sqrt(variance);
    }

    final featureVector = <double?>[history.length + 1.0];
    for (final field in _historyFields) {
      featureVector.add(value(last, field));
    }
    for (final field in _historyFields) {
      featureVector.add(mean(values(field)));
    }
    for (final field in _historyFields) {
      featureVector.add(sampleStd(values(field)));
    }
    featureVector.add(history.length.toDouble());
    return featureVector;
  }
}
