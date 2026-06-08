import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/onboarding/datasources/onboarding_local_datasource.dart';
import 'package:hera_app/features/onboarding/models/onboarding_status.dart';
import 'package:hera_app/shared/models/privacy_mode.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(ref.watch(onboardingLocalDataSourceProvider)),
);

class OnboardingRepository {
  OnboardingRepository(this._dataSource);

  final OnboardingLocalDataSource _dataSource;

  Future<OnboardingStatus> getStatus() {
    return _dataSource.loadStatus();
  }

  Future<OnboardingStatus> saveSetup({
    required PrivacyMode privacyMode,
    required int averageCycleLength,
    required int averageMenstruationLength,
  }) {
    return _dataSource.saveSetup(
      privacyMode: privacyMode,
      averageCycleLength: averageCycleLength,
      averageMenstruationLength: averageMenstruationLength,
    );
  }
}
