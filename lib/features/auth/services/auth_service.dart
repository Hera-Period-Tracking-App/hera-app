import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/auth/models/auth_session.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => const AuthService(),
);

class AuthService {
  const AuthService();

  Future<AuthSession> getCurrentSession() async {
    return const AuthSession(isAuthenticated: false);
  }
}
