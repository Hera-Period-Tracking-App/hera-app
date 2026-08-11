import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/datasources/biometric_auth_data_source.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';

final appLockProvider = AsyncNotifierProvider<AppLockNotifier, AppLockState>(
  AppLockNotifier.new,
);

class AppLockState {
  const AppLockState({
    required this.enabled,
    required this.biometricsEnabled,
    required this.locked,
  });

  final bool enabled;
  final bool biometricsEnabled;
  final bool locked;
}

class AppLockNotifier extends AsyncNotifier<AppLockState> {
  @override
  Future<AppLockState> build() async {
    final storage = ref.read(secureStorageDataSourceProvider);
    final enabled =
        await storage.read(AppConstants.appLockEnabledKey) == 'true';
    final biometricsEnabled =
        await storage.read(AppConstants.biometricsEnabledKey) == 'true';
    return AppLockState(
      enabled: enabled,
      biometricsEnabled: biometricsEnabled,
      locked: enabled,
    );
  }

  Future<bool> unlockWithBiometrics() async {
    final current = state.asData?.value;
    if (current == null || !current.biometricsEnabled) {
      return false;
    }

    bool authenticated;
    try {
      authenticated =
          await ref.read(biometricAuthDataSourceProvider).authenticate();
    } catch (_) {
      authenticated = false;
    }
    if (authenticated) {
      _setUnlocked(current);
    }
    return authenticated;
  }

  Future<bool> unlockWithPin(String pin) async {
    final current = state.asData?.value;
    if (current == null || !current.enabled) {
      return false;
    }

    final storedPin =
        await ref.read(secureStorageDataSourceProvider).read(
              AppConstants.appLockPinKey,
            );
    final unlocked = storedPin != null && storedPin == pin.trim();
    if (unlocked) {
      _setUnlocked(current);
    }
    return unlocked;
  }

  void _setUnlocked(AppLockState current) {
    Future<void>.delayed(Duration.zero, () {
      state = AsyncData(
        AppLockState(
          enabled: current.enabled,
          biometricsEnabled: current.biometricsEnabled,
          locked: false,
        ),
      );
    });
  }

  void lock() {
    final current = state.asData?.value;
    if (current == null || !current.enabled) {
      return;
    }
    state = AsyncData(
      AppLockState(
        enabled: current.enabled,
        biometricsEnabled: current.biometricsEnabled,
        locked: true,
      ),
    );
  }

  void setConfiguration({
    required bool enabled,
    required bool biometricsEnabled,
  }) {
    Future<void>.delayed(Duration.zero, () {
      state = AsyncData(
        AppLockState(
          enabled: enabled,
          biometricsEnabled: biometricsEnabled,
          locked: false,
        ),
      );
    });
  }
}
