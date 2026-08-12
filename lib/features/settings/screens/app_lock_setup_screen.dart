import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/datasources/biometric_auth_data_source.dart';
import 'package:hera_app/core/widgets/app_text_field.dart';
import 'package:hera_app/features/settings/providers/app_lock_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';

class AppLockSetupScreen extends ConsumerStatefulWidget {
  const AppLockSetupScreen({super.key});

  @override
  ConsumerState<AppLockSetupScreen> createState() => _AppLockSetupScreenState();
}

class _AppLockSetupScreenState extends ConsumerState<AppLockSetupScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _useBiometrics = false;
  bool _canUseBiometrics = false;
  bool _loadedBiometrics = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadBiometrics);
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up app lock')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              'Protect Hera',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _loadedBiometrics && _canUseBiometrics
                  ? 'Use biometrics to unlock Hera. Your PIN is the backup if biometrics fails.'
                  : 'This phone will use a PIN to unlock Hera.',
            ),
            if (_loadedBiometrics && _canUseBiometrics) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.fingerprint),
                title: const Text('Use biometrics'),
                value: _useBiometrics,
                onChanged: _isSaving
                    ? null
                    : (value) => setState(() => _useBiometrics = value),
              ),
            ],
            const SizedBox(height: 20),
            AppTextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Backup PIN'),
              onChanged: (_) => _clearError(),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
              onChanged: (_) => _clearError(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _isSaving ? null : _enable,
              child: Text(_isSaving ? 'Enabling...' : 'Enable app lock'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadBiometrics() async {
    final canUseBiometrics =
        await ref.read(biometricAuthDataSourceProvider).canUseBiometrics();
    if (!mounted) {
      return;
    }
    setState(() {
      _canUseBiometrics = canUseBiometrics;
      _useBiometrics = canUseBiometrics;
      _loadedBiometrics = true;
    });
  }

  Future<void> _enable() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.length < 4 || !RegExp(r'^\d+$').hasMatch(pin)) {
      setState(() => _errorMessage = 'Enter a PIN with at least 4 digits.');
      return;
    }
    if (pin != confirmPin) {
      setState(() => _errorMessage = 'PINs do not match.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final useBiometrics = _canUseBiometrics && _useBiometrics;
      await ref.read(settingsProvider.notifier).setAppLock(
            enabled: true,
            biometricsEnabled: useBiometrics,
            pin: pin,
          );
      ref.read(appLockProvider.notifier).setConfiguration(
            enabled: true,
            biometricsEnabled: useBiometrics,
          );
      if (!mounted) {
        return;
      }
      context.pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _errorMessage = error.toString();
      });
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }
}
