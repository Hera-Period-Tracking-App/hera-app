import 'package:hera_app/features/cyclePrediction/flutter_cycle_predictor.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/utils/cycle_phase_resolver.dart';

class CycleForecast {
  const CycleForecast({
    required this.cycleLength,
    required this.ovulationDay,
    required this.menstruationLength,
  });

  final int cycleLength;
  final int ovulationDay;
  final int menstruationLength;
}

CycleForecast? predictUpcomingCycle({
  required LocalCyclePredictor predictor,
  required List<CycleSummary> cycles,
  int fallbackCycleLength = defaultCycleLength,
  int fallbackMenstruationLength = defaultMenstruationLength,
}) {
  if (cycles.isEmpty) {
    return null;
  }

  final history = cycles
      .map(
        (cycle) => <String, num?>{
          'cycle_length': cycle.cycleLength,
          'ovulation_day': cycle.cycleLength == null || cycle.cycleLength! <= 0
              ? null
              : cycle.cycleLength! - lutealPhaseLength + 1,
          'length_of_menses': cycle.menstruationLength,
        },
      )
      .toList(growable: false);

  final prediction = predictor.predict(history: history);
  final predictedCycleLength =
      (prediction.ovulationDay + lutealPhaseLength - 1).clamp(15, 90);
  final predictedMenstruationLength = prediction.lengthOfMenses.clamp(
    1,
    predictedCycleLength,
  );

  return CycleForecast(
    cycleLength: predictedCycleLength > 0
        ? predictedCycleLength
        : fallbackCycleLength,
    ovulationDay: prediction.ovulationDay.clamp(1, predictedCycleLength),
    menstruationLength: predictedMenstruationLength > 0
        ? predictedMenstruationLength
        : fallbackMenstruationLength,
  );
}
