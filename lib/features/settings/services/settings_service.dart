import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/database/app_database.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
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
    final userSettings = await _readOrCreateUserSettings();

    return SettingsState(
      privacyMode: privacyMode,
      biometricsEnabled:
          await _readBool(AppConstants.biometricsEnabledKey),
      pinEnabled: await _readBool(AppConstants.pinEnabledKey),
      notificationsEnabled: appSettings.notificationsEnabled,
      notesEnabled: userSettings.notesEnabled,
      aiSummariesEnabled: userSettings.aiEnabled,
      autoSyncEnabled: appSettings.syncEnabled,
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

  Future<SettingsState> setAutoSyncEnabled(bool enabled) async {
    final database = _ref.read(appDatabaseProvider);

    await database.into(database.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            id: 'default',
            syncEnabled: Value(enabled),
          ),
        );

    return loadSettings();
  }

  Future<SettingsState> setAiSummariesEnabled(bool enabled) async {
    final database = _ref.read(appDatabaseProvider);
    final userSettings = await _readOrCreateUserSettings();

    await (database.update(database.userSettings)
          ..where((row) => row.id.equals(userSettings.id)))
        .write(
      UserSettingsCompanion(
        aiEnabled: Value(enabled),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return loadSettings();
  }

  Future<SettingsState> setNotesEnabled(bool enabled) async {
    final database = _ref.read(appDatabaseProvider);
    final userSettings = await _readOrCreateUserSettings();

    await (database.update(database.userSettings)
          ..where((row) => row.id.equals(userSettings.id)))
        .write(
      UserSettingsCompanion(
        notesEnabled: Value(enabled),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return loadSettings();
  }

  Future<SettingsState> setAppLock({
    required bool enabled,
    required bool biometricsEnabled,
    String? pin,
  }) async {
    final secureStorage = _ref.read(secureStorageDataSourceProvider);

    if (!enabled) {
      await secureStorage.delete(AppConstants.appLockEnabledKey);
      await secureStorage.delete(AppConstants.biometricsEnabledKey);
      await secureStorage.delete(AppConstants.pinEnabledKey);
      await secureStorage.delete(AppConstants.appLockPinKey);
      return loadSettings();
    }

    final normalizedPin = pin?.trim();
    if (normalizedPin == null || normalizedPin.length < 4) {
      throw ArgumentError('Set a PIN with at least 4 digits.');
    }

    await secureStorage.write(AppConstants.appLockEnabledKey, 'true');
    await secureStorage.write(
      AppConstants.biometricsEnabledKey,
      biometricsEnabled ? 'true' : 'false',
    );
    await secureStorage.write(AppConstants.pinEnabledKey, 'true');
    await secureStorage.write(AppConstants.appLockPinKey, normalizedPin);

    return loadSettings();
  }

  Future<bool> _readBool(String key) async {
    return (await _ref.read(secureStorageDataSourceProvider).read(key)) ==
        'true';
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

  Future<UserSetting> _readOrCreateUserSettings() async {
    final database = _ref.read(appDatabaseProvider);
    final existing = await (database.select(database.userSettings)
          ..where((row) => row.id.equals('default')))
        .getSingleOrNull();

    if (existing != null) {
      return existing;
    }

    final privacyMode = await _ref.read(privacyModeManagerProvider.future);
    final now = DateTime.now();
    final companion = UserSettingsCompanion.insert(
      id: 'default',
      privacyMode: privacyMode.name,
      createdAt: now,
      updatedAt: Value(now),
    );
    await database.into(database.userSettings).insert(companion);

    return (database.select(database.userSettings)
          ..where((row) => row.id.equals('default')))
        .getSingle();
  }
}
