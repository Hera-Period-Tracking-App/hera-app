import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/auth/models/auth_credentials.dart';
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

  Future<void> signup({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signup(
            AuthCredentials(
              email: email.trim(),
              password: password,
            ),
          ),
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(
            AuthCredentials(
              email: email.trim(),
              password: password,
            ),
      ),
    );
  }

  Future<AuthSession> updateAccount({
    required String currentPassword,
    String? email,
    String? newPassword,
  }) async {
    state = const AsyncLoading();
    try {
      final session = await ref.read(authRepositoryProvider).updateAccount(
            currentPassword: currentPassword,
            email: email,
            newPassword: newPassword,
          );
      state = AsyncData(session);
      return session;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthSession(isAuthenticated: false));
  }

  Future<void> deleteAccount({required String currentPassword}) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .deleteAccount(currentPassword: currentPassword);
      state = const AsyncData(AuthSession(isAuthenticated: false));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void setSession(AuthSession session) {
    state = AsyncData(session);
  }

  Future<void> refreshSession() async {
    final session = await ref.read(authRepositoryProvider).getCurrentSession();
    state = AsyncData(session);
  }
}
