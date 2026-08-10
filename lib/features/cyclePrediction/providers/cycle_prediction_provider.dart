import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/cyclePrediction/flutter_cycle_predictor.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/cycles/utils/cycle_phase_resolver.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';

final localCyclePredictorProvider = FutureProvider<LocalCyclePredictor>((
  ref,
) async {
  final jsonString = await rootBundle.loadString(
    'lib/features/cyclePrediction/cycle_model_local.json',
  );
  return LocalCyclePredictor.fromJson(jsonString);
});

final upcomingCycleForecastProvider = FutureProvider<CycleForecast?>((
  ref,
) async {
  final predictor = await ref.watch(localCyclePredictorProvider.future);
  final cycles = await ref.watch(cyclesProvider.future);
  final profile = await ref.watch(profileSettingsProvider.future);

  return predictUpcomingCycle(
    predictor: predictor,
    cycles: cycles,
    fallbackCycleLength: profile.averageCycleLength ?? defaultCycleLength,
    fallbackMenstruationLength:
        profile.averageMenstruationLength ?? defaultMenstruationLength,
  );
});
