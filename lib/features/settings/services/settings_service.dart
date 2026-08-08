import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/database/app_database.dart';
import 'package:hera_app/core/services/privacy_mode_manager.dart';
import 'package:hera_app/features/settings/models/settings_state.dart';

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(ref),
);

class SettingsService {
  const SettingsService(this._ref);

  final Ref _ref;

  Future<SettingsState> loadSettings() async {
    final privacyMode = await _ref.read(privacyModeManagerProvider.future);
    final appSettings = await _readOrCreateAppSettings();

    return SettingsState(
      privacyMode: privacyMode,
      biometricsEnabled: false,
      pinEnabled: false,
      notificationsEnabled: appSettings.notificationsEnabled,
    );
  }

  Future<SettingsState> setNotificationsEnabled(bool enabled) async {
    final database = _ref.read(appDatabaseProvider);

    await database.into(database.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            id: 'default',
            notificationsEnabled: Value(enabled),
          ),
        );

    return loadSettings();
  }

  Future<AppSetting> _readOrCreateAppSettings() async {
    final database = _ref.read(appDatabaseProvider);
    final existing = await (database.select(database.appSettings)
          ..where((row) => row.id.equals('default')))
        .getSingleOrNull();

    if (existing != null) {
      return existing;
    }

    final companion = AppSettingsCompanion.insert(id: 'default');
    await database.into(database.appSettings).insert(companion);

    return (database.select(database.appSettings)
          ..where((row) => row.id.equals('default')))
        .getSingle();
  }
}
