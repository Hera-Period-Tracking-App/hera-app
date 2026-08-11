import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/auth/models/auth_credentials.dart';
import 'package:hera_app/features/auth/models/auth_session.dart';
import 'package:hera_app/features/auth/services/auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(authServiceProvider)),
);

class AuthRepository {
  AuthRepository(this._service);

  final AuthService _service;

  Future<AuthSession> getCurrentSession() {
    return _service.getCurrentSession();
  }

  Future<AuthSession> signup(AuthCredentials credentials) {
    return _service.signup(credentials);
  }

  Future<AuthSession> login(AuthCredentials credentials) {
    return _service.login(credentials);
  }

  Future<AuthSession> updateAccount({
    required String currentPassword,
    String? email,
    String? newPassword,
  }) {
    return _service.updateAccount(
      currentPassword: currentPassword,
      email: email,
      newPassword: newPassword,
    );
  }

  Future<void> deleteAccount({required String currentPassword}) {
    return _service.deleteAccount(currentPassword: currentPassword);
  }

  Future<void> logout() {
    return _service.clearSession();
  }
}
