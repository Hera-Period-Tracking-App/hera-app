import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/settings/models/settings_state.dart';
import 'package:hera_app/features/settings/repositories/settings_repository.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() {
    return ref.read(settingsRepositoryProvider).getSettings();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final previous = state.asData?.value;
    if (previous != null) {
      state = AsyncData(previous.copyWith(notificationsEnabled: enabled));
    }

    state = await AsyncValue.guard(
      () => ref
          .read(settingsRepositoryProvider)
          .setNotificationsEnabled(enabled),
    );
  }

  Future<void> setAiSummariesEnabled(bool enabled) async {
    final previous = state.asData?.value;
    if (previous != null) {
      state = AsyncData(previous.copyWith(aiSummariesEnabled: enabled));
    }

    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setAiSummariesEnabled(enabled),
    );
  }

  Future<void> setNotesEnabled(bool enabled) async {
    final previous = state.asData?.value;
    if (previous != null) {
      state = AsyncData(previous.copyWith(notesEnabled: enabled));
    }

    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setNotesEnabled(enabled),
    );
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    final previous = state.asData?.value;
    if (previous != null) {
      state = AsyncData(previous.copyWith(autoSyncEnabled: enabled));
    }

    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setAutoSyncEnabled(enabled),
    );
  }

  Future<void> setAppLock({
    required bool enabled,
    required bool biometricsEnabled,
    String? pin,
  }) async {
    final previous = state.asData?.value;
    if (previous != null) {
      state = AsyncData(
        previous.copyWith(
          biometricsEnabled: enabled && biometricsEnabled,
          pinEnabled: enabled,
        ),
      );
    }

    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setAppLock(
            enabled: enabled,
            biometricsEnabled: biometricsEnabled,
            pin: pin,
          ),
    );
  }
}
