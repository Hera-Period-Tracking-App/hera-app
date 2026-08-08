import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/database/app_database.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/core/encryption/encryption_service.dart';
import 'package:hera_app/core/networking/api_client.dart';
import 'package:hera_app/features/auth/services/auth_service.dart';
import 'package:hera_app/features/notes/repositories/note_repository.dart';
import 'package:hera_app/features/settings/models/sync_models.dart';
import 'package:hera_app/shared/models/privacy_mode.dart';

final syncRepositoryProvider = Provider<SyncRepository>(
  (ref) => SyncRepository(
    database: ref.watch(appDatabaseProvider),
    secureStorage: ref.watch(secureStorageDataSourceProvider),
    encryptionService: ref.watch(encryptionServiceProvider),
    apiClient: ref.watch(apiClientProvider),
    authService: ref.watch(authServiceProvider),
  ),
);

class SyncRepository {
  static const _wrappedMasterKeyRecordId = '__hera_sync_wrapped_master_key__';

  const SyncRepository({
    required AppDatabase database,
    required SecureStorageDataSource secureStorage,
    required EncryptionService encryptionService,
    required ApiClient apiClient,
    required AuthService authService,
  }) : _database = database,
       _secureStorage = secureStorage,
       _encryptionService = encryptionService,
       _apiClient = apiClient,
       _authService = authService;

  final AppDatabase _database;
  final SecureStorageDataSource _secureStorage;
  final EncryptionService _encryptionService;
  final ApiClient _apiClient;
  final AuthService _authService;

  Future<bool> isSyncAvailable(PrivacyMode privacyMode) async {
    if (privacyMode != PrivacyMode.secureSync) {
      return false;
    }

    final session = await _authService.getCurrentSession();
    return session.isAuthenticated;
  }

  Future<SyncDownloadResult> downloadEncryptedRecords({
    String? cursor,
    String? deviceId,
  }) async {
    final token = await _authService.requireAccessToken();
    final resolvedDeviceId = deviceId ?? await _authService.getOrCreateDeviceId();
    final resolvedCursor = cursor ?? await _authService.getStoredCursor();

    final response = await _apiClient.getJson(
      '/api/sync',
      bearerToken: token,
      queryParameters: {
        if (resolvedCursor != null && resolvedCursor.isNotEmpty) 'cursor': resolvedCursor,
        if (resolvedDeviceId.isNotEmpty) 'deviceId': resolvedDeviceId,
      },
    );

    final result = SyncDownloadResult.fromJson(response);
    final wrappedMasterKeyBundle =
        result.wrappedMasterKey ??
        _extractWrappedMasterKeyBundle(result.appSettings);
    if (wrappedMasterKeyBundle != null && wrappedMasterKeyBundle.isNotEmpty) {
      await _encryptionService.importWrappedMasterKeyBundle(
        wrappedMasterKeyBundle,
      );
    }
    await _authService.saveCursor(result.cursor);
    return result;
  }

  Future<SyncUploadResult> uploadEncryptedRecords({
    required List<EncryptedSyncRecord> userSettings,
    required List<EncryptedSyncRecord> cycles,
    required List<EncryptedSyncRecord> notes,
    required List<EncryptedSyncRecord> appSettings,
    String? deviceId,
  }) async {
    final token = await _authService.requireAccessToken();
    final resolvedDeviceId = deviceId ?? await _authService.getOrCreateDeviceId();
    final wrappedMasterKey =
        await _encryptionService.getOrCreateWrappedMasterKeyBundle();
    final payload = SyncUploadPayload(
      deviceId: resolvedDeviceId,
      wrappedMasterKey: wrappedMasterKey,
      userSettings: userSettings,
      cycles: cycles,
      notes: notes,
      appSettings: [
        ...appSettings,
        EncryptedSyncRecord(
          id: _wrappedMasterKeyRecordId,
          ciphertext: wrappedMasterKey,
          updatedAtUtc: DateTime.now().toUtc(),
          isDeleted: false,
          originDeviceId: resolvedDeviceId,
        ),
      ],
    );

    Map<String, dynamic> response;
    try {
      response = await _apiClient.postJson(
        '/api/sync',
        bearerToken: token,
        body: payload.toJson(),
      );
    } on ApiException catch (error) {
      throw ApiException(
        statusCode: error.statusCode,
        uri: error.uri,
        body: error.body,
        rawBody: error.rawBody,
        message:
            '${error.message} uploadSummary=${_summarizeUploadPayload(payload)}',
      );
    }

    final result = SyncUploadResult.fromJson(response);
    if (result.cursor != null && result.cursor!.isNotEmpty) {
      await _authService.saveCursor(result.cursor);
    }
    return result;
  }

  Future<SyncRunResult> syncNow() async {
    final deviceId = await _authService.getOrCreateDeviceId();
    final downloadResult = await downloadEncryptedRecords(deviceId: deviceId);
    final applied = await _applyDownloadResult(downloadResult);
    final localSnapshot = await _buildLocalSnapshot(deviceId);
    final uploadResult = await uploadEncryptedRecords(
      userSettings: localSnapshot.userSettings,
      cycles: localSnapshot.cycles,
      notes: localSnapshot.notes,
      appSettings: localSnapshot.appSettings,
      deviceId: deviceId,
    );

    final now = DateTime.now().toUtc();
    await _database.into(_database.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        id: 'default',
        lastSyncAt: Value(now),
      ),
    );

    return SyncRunResult(
      uploadedCount: localSnapshot.totalCount,
      downloadedCount: downloadResult.totalCount,
      appliedCount: applied,
      ignoredCount: uploadResult.ignoredCount ?? 0,
      cursor: downloadResult.cursor ?? uploadResult.cursor,
    );
  }

  Future<_LocalSyncSnapshot> _buildLocalSnapshot(String deviceId) async {
    final userSettings = await _database.select(_database.userSettings).get();
    final cycles = await _database.select(_database.cycleEntries).get();
    final notes = await _database.select(_database.noteEntries).get();
    final deletedNotes = await _loadDeletedNoteTombstones();
    final appSettings = await _database.select(_database.appSettings).get();

    return _LocalSyncSnapshot(
      userSettings: await Future.wait(
        userSettings.map((row) => _toEncryptedRecord(
              id: row.id,
              payload: row.toJson(),
              updatedAt: (row.updatedAt ?? row.createdAt).toUtc(),
              originDeviceId: deviceId,
            )),
      ),
      cycles: await Future.wait(
        cycles.map((row) => _toEncryptedRecord(
              id: row.id,
              payload: row.toJson(),
              updatedAt: row.updatedAt.toUtc(),
              originDeviceId: deviceId,
            )),
      ),
      notes: await Future.wait(
        [
          ...notes.map((row) => _toEncryptedRecord(
                id: row.id,
                payload: row.toJson(),
                updatedAt: row.updatedAt.toUtc(),
                originDeviceId: deviceId,
              )),
          ...deletedNotes.map(
            (entry) => Future.value(
              EncryptedSyncRecord(
                id: entry.noteId,
                ciphertext: null,
                updatedAtUtc: entry.deletedAtUtc,
                isDeleted: true,
                originDeviceId: deviceId,
              ),
            ),
          ),
        ],
      ),
      appSettings: await Future.wait(
        appSettings.map((row) => _toEncryptedRecord(
              id: row.id,
              payload: row.toJson(),
              updatedAt: (row.lastSyncAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                  .toUtc(),
              originDeviceId: deviceId,
            )),
      ),
    );
  }

  Future<EncryptedSyncRecord> _toEncryptedRecord({
    required String id,
    required Map<String, dynamic> payload,
    required DateTime updatedAt,
    required String originDeviceId,
  }) async {
    return EncryptedSyncRecord(
      id: id,
      ciphertext: await _encryptionService.encrypt(_encodeJson(payload)),
      updatedAtUtc: updatedAt,
      isDeleted: false,
      originDeviceId: originDeviceId,
    );
  }

  Future<int> _applyDownloadResult(SyncDownloadResult result) async {
    var applied = 0;

    for (final record in result.userSettings) {
      applied += await _applyUserSetting(record);
    }
    for (final record in result.cycles) {
      applied += await _applyCycle(record);
    }
    for (final record in result.notes) {
      applied += await _applyNote(record);
    }
    for (final record in result.appSettings) {
      if (_isWrappedMasterKeyRecord(record)) {
        continue;
      }
      applied += await _applyAppSetting(record);
    }

    return applied;
  }

  Future<int> _applyUserSetting(EncryptedSyncRecord record) async {
    final id = record.id.toString();
    if (record.isDeleted) {
      final deleted = await (_database.delete(_database.userSettings)
            ..where((row) => row.id.equals(id)))
          .go();
      return deleted > 0 ? 1 : 0;
    }

    final existing = await (_database.select(_database.userSettings)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    final existingUpdatedAt = (existing?.updatedAt ?? existing?.createdAt)
        ?.toUtc();
    if (existingUpdatedAt != null &&
        !record.updatedAtUtc.isAfter(existingUpdatedAt)) {
      return 0;
    }

    final json = await _decodeRecord(record);
    final row = UserSetting.fromJson(json).copyWith(
      updatedAt: Value(record.updatedAtUtc),
    );
    await _database.into(_database.userSettings).insertOnConflictUpdate(row);
    return 1;
  }

  Future<int> _applyCycle(EncryptedSyncRecord record) async {
    final id = record.id.toString();
    if (record.isDeleted) {
      final deleted = await (_database.delete(_database.cycleEntries)
            ..where((row) => row.id.equals(id)))
          .go();
      return deleted > 0 ? 1 : 0;
    }

    final existing = await (_database.select(_database.cycleEntries)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (existing != null && !record.updatedAtUtc.isAfter(existing.updatedAt.toUtc())) {
      return 0;
    }

    final json = await _decodeRecord(record);
    final row = CycleEntry.fromJson(json).copyWith(updatedAt: record.updatedAtUtc);
    await _database.into(_database.cycleEntries).insertOnConflictUpdate(row);
    return 1;
  }

  Future<int> _applyNote(EncryptedSyncRecord record) async {
    final id = record.id.toString();
    if (record.isDeleted) {
      final deleted = await (_database.delete(_database.noteEntries)
            ..where((row) => row.id.equals(id)))
          .go();
      return deleted > 0 ? 1 : 0;
    }

    final existing = await (_database.select(_database.noteEntries)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (existing != null && !record.updatedAtUtc.isAfter(existing.updatedAt.toUtc())) {
      return 0;
    }

    final json = await _decodeRecord(record);
    final row = NoteEntry.fromJson(json).copyWith(updatedAt: record.updatedAtUtc);
    await _database.into(_database.noteEntries).insertOnConflictUpdate(row);
    return 1;
  }

  Future<int> _applyAppSetting(EncryptedSyncRecord record) async {
    final id = record.id.toString();
    if (record.isDeleted) {
      final deleted = await (_database.delete(_database.appSettings)
            ..where((row) => row.id.equals(id)))
          .go();
      return deleted > 0 ? 1 : 0;
    }

    final existing = await (_database.select(_database.appSettings)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    final existingUpdatedAt = existing?.lastSyncAt?.toUtc();
    if (existingUpdatedAt != null &&
        !record.updatedAtUtc.isAfter(existingUpdatedAt)) {
      return 0;
    }

    final json = await _decodeRecord(record);
    final row = AppSetting.fromJson(json).copyWith(
      lastSyncAt: Value(record.updatedAtUtc),
    );
    await _database.into(_database.appSettings).insertOnConflictUpdate(row);
    return 1;
  }

  Future<Map<String, dynamic>> _decodeRecord(EncryptedSyncRecord record) async {
    final ciphertext = record.ciphertext;
    if (ciphertext == null || ciphertext.isEmpty) {
      throw const ApiException(message: 'Sync record ciphertext is missing.');
    }

    final decrypted = await _encryptionService.decrypt(ciphertext);
    final decoded = jsonDecode(decrypted);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(message: 'Sync record payload is not a JSON object.');
    }
    return decoded;
  }

  String _encodeJson(Map<String, dynamic> payload) {
    return jsonEncode(payload);
  }

  String? _extractWrappedMasterKeyBundle(List<EncryptedSyncRecord> records) {
    for (final record in records) {
      if (_isWrappedMasterKeyRecord(record)) {
        return record.ciphertext;
      }
    }
    return null;
  }

  bool _isWrappedMasterKeyRecord(EncryptedSyncRecord record) {
    return record.id.toString() == _wrappedMasterKeyRecordId;
  }

  Future<List<DeletedNoteTombstone>> _loadDeletedNoteTombstones() async {
    final raw = await _secureStorage.read(AppConstants.deletedNoteTombstonesKey);
    if (raw == null || raw.isEmpty) {
      return const <DeletedNoteTombstone>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const <DeletedNoteTombstone>[];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(DeletedNoteTombstone.fromJson)
        .toList(growable: false);
  }

  String _summarizeUploadPayload(SyncUploadPayload payload) {
    return [
      'deviceId=${payload.deviceId}',
      _summarizeRecordList('userSettings', payload.userSettings),
      _summarizeRecordList('cycles', payload.cycles),
      _summarizeRecordList('notes', payload.notes),
      _summarizeRecordList('appSettings', payload.appSettings),
    ].join('; ');
  }

  String _summarizeRecordList(
    String label,
    List<EncryptedSyncRecord> records,
  ) {
    if (records.isEmpty) {
      return '$label=0';
    }

    final first = records.first;
    final ciphertextLength = first.ciphertext?.length ?? 0;
    return '$label=${records.length}'
        '(firstId=${first.id},idType=${first.id.runtimeType},'
        'deleted=${first.isDeleted},ciphertextLength=$ciphertextLength,'
        'updatedAtUtc=${first.updatedAtUtc.toIso8601String()})';
  }
}

class SyncRunResult {
  const SyncRunResult({
    required this.uploadedCount,
    required this.downloadedCount,
    required this.appliedCount,
    required this.ignoredCount,
    this.cursor,
  });

  final int uploadedCount;
  final int downloadedCount;
  final int appliedCount;
  final int ignoredCount;
  final String? cursor;
}

class _LocalSyncSnapshot {
  const _LocalSyncSnapshot({
    required this.userSettings,
    required this.cycles,
    required this.notes,
    required this.appSettings,
  });

  final List<EncryptedSyncRecord> userSettings;
  final List<EncryptedSyncRecord> cycles;
  final List<EncryptedSyncRecord> notes;
  final List<EncryptedSyncRecord> appSettings;

  int get totalCount =>
      userSettings.length + cycles.length + notes.length + appSettings.length;
}
