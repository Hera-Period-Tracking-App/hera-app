import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/auth/models/auth_session.dart';
import 'package:hera_app/features/auth/repositories/auth_repository.dart';

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionNotifier, AuthSession>(
  AuthSessionNotifier.new,
);

class AuthSessionNotifier extends AsyncNotifier<AuthSession> {
  @override
  Future<AuthSession> build() {
    return ref.read(authRepositoryProvider).getCurrentSession();
  }
}
