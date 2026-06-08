import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageDataSourceProvider = Provider<SecureStorageDataSource>(
  (ref) => const SecureStorageDataSource(),
);

class SecureStorageDataSource {
  const SecureStorageDataSource();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }
}