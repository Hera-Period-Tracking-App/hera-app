import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/aiModelSummerize/models/current_cycle_summary.dart';
import 'package:hera_app/features/aiModelSummerize/services/current_cycle_summary_service.dart';
import 'package:hera_app/features/aiModelSummerize/services/local_llama_service.dart';
import 'package:hera_app/features/cyclePrediction/providers/cycle_prediction_provider.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/cycles/utils/cycle_phase_resolver.dart';
import 'package:hera_app/features/notes/providers/notes_provider.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';

final localLlamaServiceProvider = Provider<LocalLlamaService>((ref) {
  final service = LocalLlamaService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final currentCycleSummaryServiceProvider = Provider<CurrentCycleSummaryService>(
  (ref) => CurrentCycleSummaryService(ref.watch(localLlamaServiceProvider)),
);

final currentCycleSummaryProvider = FutureProvider<CurrentCycleSummary>((
  ref,
) async {
  final cycles = await ref.watch(cyclesProvider.future);
  final notes = await ref.watch(notesProvider.future);
  final profile = await ref.watch(profileSettingsProvider.future);
  final forecast = await ref.watch(upcomingCycleForecastProvider.future);

  return ref.read(currentCycleSummaryServiceProvider).buildSummary(
        cycles: cycles,
        notes: notes,
        fallbackCycleLength: profile.averageCycleLength ?? defaultCycleLength,
        forecast: forecast,
        useModel: false,
      );
});
