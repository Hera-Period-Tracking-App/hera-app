import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/settings/models/settings_state.dart';
import 'package:hera_app/features/settings/services/settings_service.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(settingsServiceProvider)),
);

class SettingsRepository {
  SettingsRepository(this._service);

  final SettingsService _service;

  Future<SettingsState> getSettings() {
    return _service.loadSettings();
  }

  Future<SettingsState> setNotificationsEnabled(bool enabled) {
    return _service.setNotificationsEnabled(enabled);
  }

  Future<SettingsState> setAiSummariesEnabled(bool enabled) {
    return _service.setAiSummariesEnabled(enabled);
  }

  Future<SettingsState> setAutoSyncEnabled(bool enabled) {
    return _service.setAutoSyncEnabled(enabled);
  }
}
