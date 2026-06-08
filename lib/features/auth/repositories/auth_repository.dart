import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}
