import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/features/auth/models/auth_session.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(secureStorageDataSourceProvider)),
);

class AuthService {
  const AuthService(this._storage);

  final SecureStorageDataSource _storage;

  Future<AuthSession> getCurrentSession() async {
    final token = await _storage.read(AppConstants.accessTokenKey);
    final payload = token == null ? null : _decodeValidJwtPayload(token);

    if (payload == null) {
      return const AuthSession(isAuthenticated: false);
    }

    return AuthSession(
      isAuthenticated: true,
      userId: payload['sub']?.toString(),
      deviceLabel: payload['device_label']?.toString(),
    );
  }

  Map<String, dynamic>? _decodeValidJwtPayload(String token) {
    final segments = token.split('.');
    if (segments.length != 3) {
      return null;
    }

    try {
      final decoded = utf8.decode(base64Url.decode(base64Url.normalize(segments[1])));
      final payload = jsonDecode(decoded);
      if (payload is! Map<String, dynamic>) {
        return null;
      }

      final expiry = payload['exp'];
      final expiresAt = expiry is int
          ? expiry
          : expiry is num
              ? expiry.toInt()
              : int.tryParse(expiry?.toString() ?? '');
      if (expiresAt == null ||
          expiresAt <= DateTime.now().millisecondsSinceEpoch ~/ 1000) {
        return null;
      }

      return payload;
    } on FormatException {
      return null;
    }
  }
}
