import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/shared/models/privacy_mode.dart';

final privacyModeManagerProvider =
    AsyncNotifierProvider<PrivacyModeManager, PrivacyMode>(
  PrivacyModeManager.new,
);

class PrivacyModeManager extends AsyncNotifier<PrivacyMode> {
  @override
  Future<PrivacyMode> build() async {
    final storage = ref.read(secureStorageDataSourceProvider);
    final rawValue = await storage.read(AppConstants.privacyModeKey);

    return PrivacyMode.values.firstWhere(
      (mode) => mode.name == rawValue,
      orElse: () => PrivacyMode.localOnly,
    );
  }

  Future<void> setMode(PrivacyMode mode) async {
    state = const AsyncLoading();
    final storage = ref.read(secureStorageDataSourceProvider);
    await storage.write(AppConstants.privacyModeKey, mode.name);
    state = AsyncData(mode);
  }
}
