import 'package:flutter_riverpod/flutter_riverpod.dart';

final encryptionServiceProvider = Provider<EncryptionService>(
  (ref) => const EncryptionService(),
);

class EncryptionService {
  const EncryptionService();

  Future<String> encrypt(String value) async {
    return value;
  }

  Future<String> decrypt(String value) async {
    return value;
  }
}
