import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/cyclePrediction/providers/cycle_prediction_provider.dart';
import 'package:hera_app/features/cycle_notifications/services/cycle_notification_scheduler.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';
import 'package:hera_app/features/settings/repositories/settings_repository.dart';

final cycleNotificationSyncProvider = FutureProvider<void>((ref) async {
  final onboardingStatus = await ref.watch(onboardingProvider.future);
  if (!onboardingStatus.hasCompletedOnboarding) {
    return;
  }

  final settings = await ref.watch(settingsProvider.future);
  final scheduler = ref.watch(cycleNotificationSchedulerProvider);

  if (!settings.notificationsEnabled) {
    await scheduler.reschedule(
      cycles: const [],
      forecast: null,
      enabled: false,
    );
    return;
  }

  final cycles = await ref.watch(cyclesProvider.future);
  final forecast = await ref.watch(upcomingCycleForecastProvider.future);

  final notificationsAllowed = await scheduler.reschedule(
    cycles: cycles,
    forecast: forecast,
    enabled: true,
  );
  if (!notificationsAllowed) {
    await ref
        .read(settingsRepositoryProvider)
        .setNotificationsEnabled(false);
    ref.invalidate(settingsProvider);
  }
});
