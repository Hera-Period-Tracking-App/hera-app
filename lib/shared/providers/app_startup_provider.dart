import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/datasources/notification_data_source.dart';
import 'package:hera_app/features/cyclePrediction/providers/cycle_prediction_provider.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';

final appStartupReadyProvider = FutureProvider<bool>((ref) async {
  // Ensure onboarding status is resolved first.
  await ref.watch(onboardingProvider.future);

  // Preload the first snapshots used by the homepage.
  await ref.watch(cyclesProvider.future);
  await ref.watch(profileSettingsProvider.future);
  await ref.watch(settingsProvider.future);
  await ref.watch(upcomingCycleForecastProvider.future);
  await ref.watch(notificationDataSourceProvider).initialize();

  return true;
});
