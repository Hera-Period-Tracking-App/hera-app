import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/database/app_database.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/features/onboarding/models/onboarding_status.dart';
import 'package:hera_app/shared/models/privacy_mode.dart';

final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>(
  (ref) => OnboardingLocalDataSource(ref),
);

class OnboardingLocalDataSource {
  const OnboardingLocalDataSource(this._ref);

  final Ref _ref;

  Future<OnboardingStatus> loadStatus() async {
    final storage = _ref.read(secureStorageDataSourceProvider);
    final hasCompletedOnboarding =
        await storage.read(AppConstants.onboardingCompletedKey) == 'true';

    return OnboardingStatus(
      hasCompletedOnboarding: hasCompletedOnboarding,
      selectedPrivacyMode: PrivacyMode.localOnly,
    );
  }

  Future<OnboardingStatus> saveSetup({
    required PrivacyMode privacyMode,
    required int averageCycleLength,
    required int averageMenstruationLength,
  }) async {
    final storage = _ref.read(secureStorageDataSourceProvider);
    final database = _ref.read(appDatabaseProvider);

    await database.into(database.userSettings).insertOnConflictUpdate(
      UserSettingsCompanion.insert(
        id: 'default',
        averageCycleLength: Value(averageCycleLength),
        averageMenstruationLength: Value(averageMenstruationLength),
        privacyMode: privacyMode.name,
        createdAt: DateTime.now(),
        updatedAt: Value(DateTime.now()),
      ),
    );

    await storage.write(AppConstants.onboardingCompletedKey, 'true');

    return OnboardingStatus(
      hasCompletedOnboarding: true,
      selectedPrivacyMode: privacyMode,
    );
  }
}
