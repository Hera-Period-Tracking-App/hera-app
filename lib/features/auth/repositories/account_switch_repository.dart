import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/database/app_database.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/core/encryption/encryption_service.dart';
import 'package:hera_app/features/auth/models/auth_session.dart';

final accountSwitchRepositoryProvider = Provider<AccountSwitchRepository>(
  (ref) => AccountSwitchRepository(
    database: ref.watch(appDatabaseProvider),
    secureStorage: ref.watch(secureStorageDataSourceProvider),
    encryptionService: ref.watch(encryptionServiceProvider),
  ),
);

class AccountSwitchRepository {
  const AccountSwitchRepository({
    required AppDatabase database,
    required SecureStorageDataSource secureStorage,
    required EncryptionService encryptionService,
  })  : _database = database,
        _secureStorage = secureStorage,
        _encryptionService = encryptionService;

  final AppDatabase _database;
  final SecureStorageDataSource _secureStorage;
  final EncryptionService _encryptionService;

  Future<bool> prepareForAuthenticatedAccount(AuthSession session) async {
    final accountKey = _accountKey(session);
    if (accountKey == null) {
      return false;
    }

    final previousAccountKey =
        await _secureStorage.read(AppConstants.lastAuthAccountKey);
    final pendingAccountKey =
        await _secureStorage.read(AppConstants.pendingAuthAccountSwitchKey);
    final isAccountSwitch = previousAccountKey != null &&
        previousAccountKey.isNotEmpty &&
        previousAccountKey != accountKey;

    if (isAccountSwitch) {
      await _preparePendingAccountSwitch(accountKey);
      return true;
    }

    if (pendingAccountKey != null && pendingAccountKey != accountKey) {
      await _secureStorage.delete(AppConstants.pendingAuthAccountSwitchKey);
    }
    await _secureStorage.write(AppConstants.lastAuthAccountKey, accountKey);
    return false;
  }

  Future<void> clearAfterAccountDeletion() async {
    await _secureStorage.delete(AppConstants.lastAuthAccountKey);
    await _secureStorage.delete(AppConstants.pendingAuthAccountSwitchKey);
    await _secureStorage.delete(AppConstants.pendingCycleConflictsKey);
    await _secureStorage.delete(AppConstants.syncCursorKey);
    await _clearLocalSyncKeysForAccountBoundary();
  }

  Future<bool> hasPendingAccountSwitch() async {
    final value =
        await _secureStorage.read(AppConstants.pendingAuthAccountSwitchKey);
    return value != null && value.isNotEmpty;
  }

  Future<String?> pendingAccountSwitchKey() {
    return _secureStorage.read(AppConstants.pendingAuthAccountSwitchKey);
  }

  Future<void> clearLocalDataForPendingAccountSwitch() async {
    await _database.transaction(() async {
      await _database.delete(_database.noteEntries).go();
      await _database.delete(_database.cycleEntries).go();
      await _database.delete(_database.userSettings).go();
      await _database.delete(_database.appSettings).go();
    });
    await _secureStorage.delete(AppConstants.syncCursorKey);
    await _secureStorage.delete(AppConstants.deletedNoteTombstonesKey);
    await _secureStorage.delete(AppConstants.pendingCycleConflictsKey);
  }

  Future<void> clearAccountScopedSyncKeysForPendingAccountSwitch() {
    return _clearLocalSyncKeysForAccountBoundary();
  }

  Future<void> completePendingAccountSwitch() async {
    final accountKey = await pendingAccountSwitchKey();
    if (accountKey != null && accountKey.isNotEmpty) {
      await _secureStorage.write(AppConstants.lastAuthAccountKey, accountKey);
    }
    await _secureStorage.delete(AppConstants.pendingAuthAccountSwitchKey);
  }

  Future<void> _preparePendingAccountSwitch(String accountKey) async {
    await _secureStorage.write(
      AppConstants.pendingAuthAccountSwitchKey,
      accountKey,
    );
  }

  Future<void> _clearLocalSyncKeysForAccountBoundary() async {
    await _encryptionService.clearAccountScopedSyncKeys();
  }

  String? _accountKey(AuthSession session) {
    final userId = session.userId?.trim();
    if (userId != null && userId.isNotEmpty) {
      return 'id:$userId';
    }

    final email = session.email?.trim().toLowerCase();
    if (email != null && email.isNotEmpty) {
      return 'email:$email';
    }

    return null;
  }
}
