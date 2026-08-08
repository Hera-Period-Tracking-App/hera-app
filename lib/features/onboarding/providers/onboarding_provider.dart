import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/onboarding/models/onboarding_status.dart';
import 'package:hera_app/features/onboarding/repositories/onboarding_repository.dart';
import 'package:hera_app/features/settings/providers/auto_sync_provider.dart';
import 'package:hera_app/shared/models/privacy_mode.dart';

final onboardingProvider =
    AsyncNotifierProvider<OnboardingNotifier, OnboardingStatus>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends AsyncNotifier<OnboardingStatus> {
  @override
  Future<OnboardingStatus> build() {
    return ref.read(onboardingRepositoryProvider).getStatus();
  }

  Future<void> completeOnboarding({
    required PrivacyMode privacyMode,
    required int averageCycleLength,
    required int averageMenstruationLength,
  }) async {
    state = const AsyncLoading();
    state = AsyncData(
      await ref.read(onboardingRepositoryProvider).saveSetup(
            privacyMode: privacyMode,
            averageCycleLength: averageCycleLength,
            averageMenstruationLength: averageMenstruationLength,
          ),
    );
    ref.read(autoSyncProvider).queueSync();
  }
}
