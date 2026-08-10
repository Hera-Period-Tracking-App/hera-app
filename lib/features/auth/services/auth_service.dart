import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/core/encryption/encryption_service.dart';
import 'package:hera_app/core/networking/api_client.dart';
import 'package:hera_app/features/auth/models/auth_credentials.dart';
import 'package:hera_app/features/auth/models/auth_session.dart';
import 'package:uuid/uuid.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    apiClient: ref.watch(apiClientProvider),
    encryptionService: ref.watch(encryptionServiceProvider),
    secureStorage: ref.watch(secureStorageDataSourceProvider),
  ),
);

class AuthService {
  AuthService({
    required ApiClient apiClient,
    required EncryptionService encryptionService,
    required SecureStorageDataSource secureStorage,
    Uuid? uuid,
  }) : _apiClient = apiClient,
       _encryptionService = encryptionService,
       _secureStorage = secureStorage,
       _uuid = uuid ?? const Uuid();

  final ApiClient _apiClient;
  final EncryptionService _encryptionService;
  final SecureStorageDataSource _secureStorage;
  final Uuid _uuid;

  Future<AuthSession> getCurrentSession() async {
    final token = await _secureStorage.read(AppConstants.authAccessTokenKey);
    final storedSession = await _secureStorage.read(AppConstants.authSessionKey);

    if (token == null || token.isEmpty || storedSession == null || storedSession.isEmpty) {
      return const AuthSession(isAuthenticated: false);
    }

    try {
      return AuthSession.fromJson(_decodeJsonMap(storedSession));
    } catch (_) {
      await clearSession();
      return const AuthSession(isAuthenticated: false);
    }
  }

  Future<AuthSession> signup(AuthCredentials credentials) {
    return _authenticate('/api/auth/signup', credentials);
  }

  Future<AuthSession> login(AuthCredentials credentials) {
    return _authenticate('/api/auth/login', credentials);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(AppConstants.authAccessTokenKey);
    await _secureStorage.delete(AppConstants.authSessionKey);
    await _secureStorage.delete(AppConstants.syncCursorKey);
    await _encryptionService.clearSyncKeys();
  }

  Future<String> requireAccessToken() async {
    final token = await _secureStorage.read(AppConstants.authAccessTokenKey);
    if (token == null || token.isEmpty) {
      throw const ApiException(message: 'You must be signed in to sync.');
    }
    return token;
  }

  Future<String> getOrCreateDeviceId() async {
    final existing = await _secureStorage.read(AppConstants.authDeviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final deviceId = _uuid.v4();
    await _secureStorage.write(AppConstants.authDeviceIdKey, deviceId);
    return deviceId;
  }

  Future<String?> getStoredCursor() {
    return _secureStorage.read(AppConstants.syncCursorKey);
  }

  Future<void> saveCursor(String? cursor) async {
    if (cursor == null || cursor.isEmpty) {
      await _secureStorage.delete(AppConstants.syncCursorKey);
      return;
    }

    await _secureStorage.write(AppConstants.syncCursorKey, cursor);
  }

  Future<AuthSession> _authenticate(
    String path,
    AuthCredentials credentials,
  ) async {
    final response = await _apiClient.postJson(
      path,
      body: credentials.toJson(),
    );
    final session = _sessionFromResponse(response, fallbackEmail: credentials.email);
    final token = _extractAccessToken(response);

    await _secureStorage.write(AppConstants.authAccessTokenKey, token);
    await _secureStorage.write(
      AppConstants.authSessionKey,
      _encodeJson(session.toJson()),
    );
    await _encryptionService.configureWrappingKeyFromCredentials(
      email: credentials.email,
      password: credentials.password,
    );

    return session;
  }

  AuthSession _sessionFromResponse(
    Map<String, dynamic> response, {
    required String fallbackEmail,
  }) {
    final payload = _primaryPayload(response);
    final user = payload['user'];
    final userMap = user is Map<String, dynamic> ? user : const <String, dynamic>{};

    return AuthSession(
      isAuthenticated: true,
      userId: _readFirstString(payload, const ['userId', 'id']) ??
          _readFirstString(userMap, const ['id', 'userId']),
      email: _readFirstString(payload, const ['email']) ??
          _readFirstString(userMap, const ['email']) ??
          fallbackEmail,
      deviceLabel: _readFirstString(payload, const ['deviceLabel']) ??
          _readFirstString(userMap, const ['deviceLabel']),
    );
  }

  String _extractAccessToken(Map<String, dynamic> response) {
    final payload = _primaryPayload(response);
    final token =
        _readFirstString(
          response,
          const ['accessToken', 'token', 'jwt', 'bearerToken'],
        ) ??
        _readFirstString(
          payload,
          const ['accessToken', 'token', 'jwt', 'bearerToken'],
        );

    if (token == null || token.isEmpty) {
      throw const ApiException(
        message:
            'Authentication succeeded but the API response did not include an access token.',
      );
    }

    return token;
  }

  Map<String, dynamic> _primaryPayload(Map<String, dynamic> response) {
    for (final key in const ['data', 'session', 'result']) {
      final value = response[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }

    return response;
  }

  String? _readFirstString(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  Map<String, dynamic> _decodeJsonMap(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }
    return decoded;
  }

  String _encodeJson(Map<String, dynamic> value) {
    return jsonEncode(value);
  }
}
