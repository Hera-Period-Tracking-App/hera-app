import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';

final encryptionServiceProvider = Provider<EncryptionService>(
  (ref) => EncryptionService(
    secureStorage: ref.watch(secureStorageDataSourceProvider),
  ),
);

class EncryptionService {
  static const _payloadVersion = 1;
  static const _cipherAlgorithm = 'A256GCM';
  static const _wrappedKeyFormat = 'hera.sync.master_key';
  static const _wrappedKeyKdf = 'PBKDF2-SHA256';
  static const _pbkdf2Iterations = 210000;

  EncryptionService({
    required SecureStorageDataSource secureStorage,
    AesGcm? algorithm,
  }) : _secureStorage = secureStorage,
       _algorithm = algorithm ?? AesGcm.with256bits();

  final SecureStorageDataSource _secureStorage;
  final AesGcm _algorithm;
  Uint8List? _cachedMasterKeyBytes;
  Uint8List? _cachedWrappingKeyBytes;

  Future<String> encrypt(String value) async {
    final secretKey = SecretKey(await _getOrCreateMasterKeyBytes());
    final nonce = _randomBytes(_algorithm.nonceLength);
    final secretBox = await _algorithm.encrypt(
      utf8.encode(value),
      secretKey: secretKey,
      nonce: nonce,
    );

    return jsonEncode({
      'v': _payloadVersion,
      'alg': _cipherAlgorithm,
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    });
  }

  Future<String> decrypt(String value) async {
    final payload = _tryParseEncryptedPayload(value);
    if (payload == null) {
      return value;
    }

    final nonce = _readBase64(payload['nonce'], field: 'nonce');
    final ciphertext = _readBase64(payload['ciphertext'], field: 'ciphertext');
    final macBytes = _readBase64(payload['mac'], field: 'mac');
    final secretBox = SecretBox(
      ciphertext,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    SecretBoxAuthenticationError? lastAuthError;
    for (final keyBytes in await _getAvailableDecryptionKeyBytes()) {
      try {
        final clearText = await _algorithm.decrypt(
          secretBox,
          secretKey: SecretKey(keyBytes),
        );
        return utf8.decode(clearText);
      } on SecretBoxAuthenticationError catch (error) {
        lastAuthError = error;
      }
    }

    if (lastAuthError != null) {
      throw lastAuthError;
    }

    throw const FormatException('No decryption key is configured.');
  }

  Future<String> exportWrappedMasterKey({
    required String passphrase,
  }) async {
    final normalizedPassphrase = _normalizePassphrase(passphrase);
    final masterKeyBytes = await _getOrCreateMasterKeyBytes();
    final salt = _randomBytes(16);
    final wrappingKey = await _deriveWrappingKey(
      passphrase: normalizedPassphrase,
      salt: salt,
    );
    final wrapped = await _encryptBytes(
      plaintext: masterKeyBytes,
      secretKey: wrappingKey,
    );
    final bundle = jsonEncode({
      'v': _payloadVersion,
      'format': _wrappedKeyFormat,
      'kdf': _wrappedKeyKdf,
      'iterations': _pbkdf2Iterations,
      'salt': base64Encode(salt),
      'wrappedKey': wrapped,
    });

    await _secureStorage.write(AppConstants.syncWrappedMasterKey, bundle);
    return bundle;
  }

  Future<void> configureWrappingKeyFromCredentials({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final normalizedPassword = _normalizePassword(password);
    final salt = utf8.encode('hera.sync:$normalizedEmail');
    final derivedKey = await _deriveWrappingKey(
      passphrase: normalizedPassword,
      salt: salt,
    );
    final keyBytes = await derivedKey.extractBytes();

    await _persistWrappingKeyBytes(keyBytes);
  }

  Future<void> importWrappedMasterKeyBundle(String wrappedKeyBundle) async {
    final wrappingKey = await _requireWrappingKey();
    final bundle = _decodeJsonObject(
      wrappedKeyBundle,
      errorMessage: 'Wrapped master key bundle is not valid JSON.',
    );
    _validateWrappedKeyBundle(bundle);

    final salt = _readBase64(bundle['salt'], field: 'salt');
    final wrappedKeyPayload = bundle['wrappedKey'];
    if (wrappedKeyPayload is! Map<String, dynamic>) {
      throw const FormatException('Wrapped master key payload is missing.');
    }

    final derivedWrappingKey = await _deriveWrappingKey(
      passphrase: base64Encode(wrappingKey),
      salt: salt,
    );
    final masterKeyBytes = await _decryptBytes(
      payload: wrappedKeyPayload,
      secretKey: derivedWrappingKey,
    );

    if (masterKeyBytes.length != 32) {
      throw const FormatException('Wrapped master key has an invalid length.');
    }

    await _persistMasterKeyBytes(masterKeyBytes);
    await _secureStorage.write(
      AppConstants.syncWrappedMasterKey,
      wrappedKeyBundle,
    );
  }

  Future<void> importWrappedMasterKey({
    required String passphrase,
    required String wrappedKeyBundle,
  }) async {
    final normalizedPassphrase = _normalizePassphrase(passphrase);
    final bundle = _decodeJsonObject(
      wrappedKeyBundle,
      errorMessage: 'Wrapped master key bundle is not valid JSON.',
    );
    _validateWrappedKeyBundle(bundle);

    final salt = _readBase64(bundle['salt'], field: 'salt');
    final wrappedKeyPayload = bundle['wrappedKey'];
    if (wrappedKeyPayload is! Map<String, dynamic>) {
      throw const FormatException('Wrapped master key payload is missing.');
    }

    final wrappingKey = await _deriveWrappingKey(
      passphrase: normalizedPassphrase,
      salt: salt,
    );
    final masterKeyBytes = await _decryptBytes(
      payload: wrappedKeyPayload,
      secretKey: wrappingKey,
    );

    if (masterKeyBytes.length != 32) {
      throw const FormatException('Wrapped master key has an invalid length.');
    }

    await _persistMasterKeyBytes(masterKeyBytes);
    await _secureStorage.write(
      AppConstants.syncWrappedMasterKey,
      wrappedKeyBundle,
    );
  }

  Future<String?> getStoredWrappedMasterKey() {
    return _secureStorage.read(AppConstants.syncWrappedMasterKey);
  }

  Future<String> getOrCreateWrappedMasterKeyBundle() async {
    final existing = await getStoredWrappedMasterKey();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final wrappingKey = await _requireWrappingKey();
    final masterKeyBytes = await _getOrCreateMasterKeyBytes();
    final salt = _randomBytes(16);
    final derivedWrappingKey = await _deriveWrappingKey(
      passphrase: base64Encode(wrappingKey),
      salt: salt,
    );
    final wrapped = await _encryptBytes(
      plaintext: masterKeyBytes,
      secretKey: derivedWrappingKey,
    );
    final bundle = jsonEncode({
      'v': _payloadVersion,
      'format': _wrappedKeyFormat,
      'kdf': _wrappedKeyKdf,
      'iterations': _pbkdf2Iterations,
      'salt': base64Encode(salt),
      'wrappedKey': wrapped,
    });

    await _secureStorage.write(AppConstants.syncWrappedMasterKey, bundle);
    return bundle;
  }

  Future<bool> hasStoredWrappedMasterKey() async {
    final stored = await getStoredWrappedMasterKey();
    return stored != null && stored.isNotEmpty;
  }

  Future<void> clearSyncKeys() async {
    _cachedMasterKeyBytes = null;
    _cachedWrappingKeyBytes = null;
    await _secureStorage.delete(AppConstants.syncMasterKey);
    await _secureStorage.delete(AppConstants.syncWrappingKey);
    await _secureStorage.delete(AppConstants.syncWrappedMasterKey);
    await _secureStorage.delete(AppConstants.syncEncryptionKey);
  }

  Future<void> clearAccountScopedSyncKeys() async {
    _cachedMasterKeyBytes = null;
    await _secureStorage.delete(AppConstants.syncMasterKey);
    await _secureStorage.delete(AppConstants.syncWrappedMasterKey);
    await _secureStorage.delete(AppConstants.syncEncryptionKey);
  }

  Map<String, dynamic>? _tryParseEncryptedPayload(String value) {
    Object? decoded;
    try {
      decoded = jsonDecode(value);
    } on FormatException {
      return null;
    }

    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    if (decoded['alg'] != _cipherAlgorithm) {
      return null;
    }

    return decoded;
  }

  Future<Uint8List> _getOrCreateMasterKeyBytes() async {
    final cached = _cachedMasterKeyBytes;
    if (cached != null) {
      return cached;
    }

    final storedMasterKey = await _secureStorage.read(AppConstants.syncMasterKey);
    if (storedMasterKey != null && storedMasterKey.isNotEmpty) {
      final keyBytes = Uint8List.fromList(base64Decode(storedMasterKey));
      _cachedMasterKeyBytes = keyBytes;
      return keyBytes;
    }

    final legacyKey = await _secureStorage.read(AppConstants.syncEncryptionKey);
    if (legacyKey != null && legacyKey.isNotEmpty) {
      final keyBytes = Uint8List.fromList(base64Decode(legacyKey));
      await _persistMasterKeyBytes(keyBytes);
      return keyBytes;
    }

    final keyBytes = _randomBytes(32);
    await _persistMasterKeyBytes(keyBytes);
    return keyBytes;
  }

  Future<List<Uint8List>> _getAvailableDecryptionKeyBytes() async {
    final keys = <Uint8List>[];

    final cachedMasterKey = _cachedMasterKeyBytes;
    if (cachedMasterKey != null) {
      keys.add(cachedMasterKey);
    }

    final storedMasterKey = await _secureStorage.read(AppConstants.syncMasterKey);
    if (storedMasterKey != null && storedMasterKey.isNotEmpty) {
      final keyBytes = Uint8List.fromList(base64Decode(storedMasterKey));
      _addUniqueKey(keys, keyBytes);
      _cachedMasterKeyBytes ??= keyBytes;
    }

    final legacyKey = await _secureStorage.read(AppConstants.syncEncryptionKey);
    if (legacyKey != null && legacyKey.isNotEmpty) {
      _addUniqueKey(keys, Uint8List.fromList(base64Decode(legacyKey)));
    }

    final cachedWrappingKey = _cachedWrappingKeyBytes;
    if (cachedWrappingKey != null) {
      _addUniqueKey(keys, cachedWrappingKey);
    }

    final storedWrappingKey = await _secureStorage.read(AppConstants.syncWrappingKey);
    if (storedWrappingKey != null && storedWrappingKey.isNotEmpty) {
      final keyBytes = Uint8List.fromList(base64Decode(storedWrappingKey));
      _addUniqueKey(keys, keyBytes);
      _cachedWrappingKeyBytes ??= keyBytes;
    }

    if (keys.isEmpty) {
      keys.add(await _getOrCreateMasterKeyBytes());
    }

    return keys;
  }

  Future<Uint8List> _requireWrappingKey() async {
    final cached = _cachedWrappingKeyBytes;
    if (cached != null) {
      return cached;
    }

    final storedWrappingKey = await _secureStorage.read(AppConstants.syncWrappingKey);
    if (storedWrappingKey == null || storedWrappingKey.isEmpty) {
      throw const FormatException('Sync wrapping key is not configured.');
    }

    final keyBytes = Uint8List.fromList(base64Decode(storedWrappingKey));
    _cachedWrappingKeyBytes = keyBytes;
    return keyBytes;
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  Uint8List _readBase64(Object? value, {required String field}) {
    if (value is! String || value.isEmpty) {
      throw FormatException('Encrypted payload is missing $field.');
    }

    try {
      return base64Decode(value);
    } on FormatException {
      throw FormatException('Encrypted payload has invalid $field.');
    }
  }

  Future<SecretKey> _deriveWrappingKey({
    required String passphrase,
    required List<int> salt,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _pbkdf2Iterations,
      bits: 256,
    );

    return pbkdf2.deriveKeyFromPassword(
      password: passphrase,
      nonce: salt,
    );
  }

  Future<Map<String, dynamic>> _encryptBytes({
    required List<int> plaintext,
    required SecretKey secretKey,
  }) async {
    final nonce = _randomBytes(_algorithm.nonceLength);
    final secretBox = await _algorithm.encrypt(
      plaintext,
      secretKey: secretKey,
      nonce: nonce,
    );

    return {
      'v': _payloadVersion,
      'alg': _cipherAlgorithm,
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  Future<Uint8List> _decryptBytes({
    required Map<String, dynamic> payload,
    required SecretKey secretKey,
  }) async {
    final nonce = _readBase64(payload['nonce'], field: 'nonce');
    final ciphertext = _readBase64(payload['ciphertext'], field: 'ciphertext');
    final macBytes = _readBase64(payload['mac'], field: 'mac');
    final clearText = await _algorithm.decrypt(
      SecretBox(
        ciphertext,
        nonce: nonce,
        mac: Mac(macBytes),
      ),
      secretKey: secretKey,
    );

    return Uint8List.fromList(clearText);
  }

  Map<String, dynamic> _decodeJsonObject(
    String value, {
    required String errorMessage,
  }) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException(errorMessage);
    }
    return decoded;
  }

  void _validateWrappedKeyBundle(Map<String, dynamic> bundle) {
    if (bundle['format'] != _wrappedKeyFormat) {
      throw const FormatException('Wrapped master key format is not supported.');
    }

    if (bundle['kdf'] != _wrappedKeyKdf) {
      throw const FormatException('Wrapped master key KDF is not supported.');
    }

    if (bundle['iterations'] != _pbkdf2Iterations) {
      throw const FormatException(
        'Wrapped master key iterations do not match this app version.',
      );
    }
  }

  String _normalizePassphrase(String passphrase) {
    final normalized = passphrase.trim();
    if (normalized.isEmpty) {
      throw const FormatException('Passphrase cannot be empty.');
    }
    return normalized;
  }

  String _normalizeEmail(String email) {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw const FormatException('Email cannot be empty.');
    }
    return normalized;
  }

  String _normalizePassword(String password) {
    if (password.isEmpty) {
      throw const FormatException('Password cannot be empty.');
    }
    return password;
  }

  Future<void> _persistMasterKeyBytes(List<int> keyBytes) async {
    final normalized = Uint8List.fromList(keyBytes);
    if (normalized.length != 32) {
      throw const FormatException('Master key must be 32 bytes.');
    }

    await _secureStorage.write(
      AppConstants.syncMasterKey,
      base64Encode(normalized),
    );
    _cachedMasterKeyBytes = normalized;
  }

  Future<void> _persistWrappingKeyBytes(List<int> keyBytes) async {
    final normalized = Uint8List.fromList(keyBytes);
    if (normalized.length != 32) {
      throw const FormatException('Wrapping key must be 32 bytes.');
    }

    await _secureStorage.write(
      AppConstants.syncWrappingKey,
      base64Encode(normalized),
    );
    _cachedWrappingKeyBytes = normalized;
  }

  void _addUniqueKey(List<Uint8List> keys, Uint8List candidate) {
    final encodedCandidate = base64Encode(candidate);
    final hasMatch = keys.any((key) => base64Encode(key) == encodedCandidate);
    if (!hasMatch) {
      keys.add(candidate);
    }
  }
}
