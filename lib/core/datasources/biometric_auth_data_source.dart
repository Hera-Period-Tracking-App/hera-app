import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final biometricAuthDataSourceProvider = Provider<BiometricAuthDataSource>(
  (ref) => BiometricAuthDataSource(LocalAuthentication()),
);

class BiometricAuthDataSource {
  BiometricAuthDataSource(this._localAuth);

  final LocalAuthentication _localAuth;

  Future<bool> canCheckBiometrics() {
    return _localAuth.canCheckBiometrics;
  }
}