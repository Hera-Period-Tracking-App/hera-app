import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/widgets/app_text_field.dart';
import 'package:hera_app/features/settings/providers/app_lock_provider.dart';

class AppUnlockScreen extends ConsumerStatefulWidget {
  const AppUnlockScreen({super.key});

  @override
  ConsumerState<AppUnlockScreen> createState() => _AppUnlockScreenState();
}

class _AppUnlockScreenState extends ConsumerState<AppUnlockScreen> {
  final _pinController = TextEditingController();
  String? _errorMessage;
  bool _biometricPrompted = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(appLockProvider).asData?.value;
    final canUseBiometrics = lockState?.biometricsEnabled ?? false;

    if (canUseBiometrics && !_biometricPrompted) {
      _biometricPrompted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            _unlockWithBiometrics(showFailureMessage: false);
          }
        });
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    canUseBiometrics
                        ? Icons.fingerprint
                        : Icons.lock_outline,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Unlock Hera',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    canUseBiometrics
                        ? 'Use biometrics or enter your backup PIN.'
                        : 'Enter your PIN to open the app.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  AppTextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'PIN'),
                    onSubmitted: (_) => _unlockWithPin(),
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _unlockWithPin,
                    child: const Text('Unlock with PIN'),
                  ),
                  if (canUseBiometrics) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _unlockWithBiometrics,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Try biometrics again'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlockWithBiometrics({
    bool showFailureMessage = true,
  }) async {
    final startedAt = DateTime.now();
    final unlocked =
        await ref.read(appLockProvider.notifier).unlockWithBiometrics();
    final elapsed = DateTime.now().difference(startedAt);
    if (!unlocked &&
        mounted &&
        showFailureMessage &&
        elapsed > const Duration(seconds: 2)) {
      setState(() {
        _errorMessage = 'Biometric unlock failed. Use your PIN.';
      });
    }
  }

  Future<void> _unlockWithPin() async {
    final unlocked =
        await ref.read(appLockProvider.notifier).unlockWithPin(
              _pinController.text,
            );
    if (!unlocked && mounted) {
      setState(() {
        _errorMessage = 'Incorrect PIN.';
      });
    }
  }
}
