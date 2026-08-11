import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/features/settings/providers/app_lock_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';

class AppLockDisableScreen extends ConsumerStatefulWidget {
  const AppLockDisableScreen({super.key});

  @override
  ConsumerState<AppLockDisableScreen> createState() =>
      _AppLockDisableScreenState();
}

class _AppLockDisableScreenState extends ConsumerState<AppLockDisableScreen> {
  final _pinController = TextEditingController();
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disable app lock')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your PIN',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              const Text('Confirm your PIN to disable app lock.'),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'PIN'),
                onSubmitted: (_) => _disable(),
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
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _isSaving ? null : _disable,
                child: Text(_isSaving ? 'Disabling...' : 'Disable app lock'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _disable() async {
    final unlocked =
        await ref.read(appLockProvider.notifier).unlockWithPin(
              _pinController.text,
            );
    if (!unlocked) {
      setState(() => _errorMessage = 'Incorrect PIN.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    await ref.read(settingsProvider.notifier).setAppLock(
          enabled: false,
          biometricsEnabled: false,
        );
    ref.read(appLockProvider.notifier).setConfiguration(
          enabled: false,
          biometricsEnabled: false,
        );
    if (mounted) {
      context.pop();
    }
  }
}
