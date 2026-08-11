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

  Future<bool> isDeviceSupported() {
    return _localAuth.isDeviceSupported();
  }

  Future<bool> canUseBiometrics() async {
    return await canCheckBiometrics() && await isDeviceSupported();
  }

  Future<bool> authenticate() {
    return _localAuth.authenticate(
      localizedReason: 'Unlock Hera',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }
}
