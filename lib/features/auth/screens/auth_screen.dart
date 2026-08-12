import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/networking/api_client.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/aiModelSummerize/providers/current_cycle_summary_provider.dart';
import 'package:hera_app/features/auth/providers/auth_provider.dart';
import 'package:hera_app/features/cyclePrediction/providers/cycle_prediction_provider.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/notes/providers/notes_provider.dart';
import 'package:hera_app/features/onboarding/screens/login_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/register_onboarding_screen.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';
import 'package:hera_app/features/settings/repositories/cycle_conflict_repository.dart';
import 'package:hera_app/features/settings/repositories/sync_repository.dart';
import 'package:hera_app/shared/screens/startup_loading_screen.dart';

enum AuthScreenMode { login, signup }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({
    super.key,
    required this.mode,
  });

  final AuthScreenMode mode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _submitted = false;
  bool _isCompletingAuth = false;
  String? _accountErrorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authSessionProvider);
    final notifier = ref.read(authSessionProvider.notifier);
    final isBusy = authState.isLoading || _isCompletingAuth;
    final isSignup = widget.mode == AuthScreenMode.signup;
    final title = isSignup ? 'Create account' : 'Log in';
    final primaryLabel = isSignup ? 'Sign up' : 'Log in';
    final alternateLabel =
        isSignup ? 'Already have an account? Log in' : 'Need an account? Sign up';

    if (isBusy) {
      return const StartupLoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: theme.cardColor,
      body: Column(
        children: [
          Expanded(
            child: isSignup
                ? RegisterOnboardingScreen(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  submitted: _submitted,
                  errorMessage: _accountErrorMessage,
                  onChanged: _clearAccountError,
                  )
                : LoginOnboardingScreen(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    submitted: _submitted,
                    errorMessage: _accountErrorMessage,
                    onChanged: _clearAccountError,
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: isBusy
                        ? null
                        : () => _submit(
                              isSignup
                                  ? () => notifier.signup(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      )
                                  : () => notifier.login(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      ),
                            ),
                    child: Text(isBusy ? 'Please wait...' : primaryLabel),
                  ),
                  TextButton(
                    onPressed: isBusy
                        ? null
                        : () => context.pushReplacement(
                              isSignup
                                  ? AppRoutePaths.authLogin
                                  : AppRoutePaths.authSignup,
                            ),
                    child: Text(alternateLabel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(Future<void> Function() action) async {
    setState(() {
      _submitted = true;
    });

    if (!_isValidEmail(_emailController.text) ||
        _passwordController.text.trim().length < 8 ||
        (widget.mode == AuthScreenMode.signup &&
            _confirmPasswordController.text != _passwordController.text)) {
      setState(() {
        _accountErrorMessage =
            'Please enter a valid email, a password with at least 8 characters, and matching confirmation password.';
      });
      return;
    }

    setState(() {
      _accountErrorMessage = null;
      _isCompletingAuth = true;
    });
    await action();

    final authState = ref.read(authSessionProvider);
    if (authState.hasError && mounted) {
      setState(() {
        _isCompletingAuth = false;
        _accountErrorMessage = widget.mode == AuthScreenMode.signup
            ? 'There was an error creating your account. Please try again.'
            : 'Could not log in. Please check your credentials.';
      });
      return;
    }

    final isAuthenticated = authState.asData?.value.isAuthenticated ?? false;
    if (isAuthenticated) {
      final didSync = await _syncAfterAuth();
      if (mounted && didSync) {
        context.go(AppRoutePaths.home);
      } else if (mounted) {
        setState(() => _isCompletingAuth = false);
      }
      return;
    }

    if (mounted) {
      setState(() => _isCompletingAuth = false);
    }
  }

  void _clearAccountError() {
    setState(() => _accountErrorMessage = null);
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  Future<bool> _syncAfterAuth() async {
    try {
      await ref
          .read(syncRepositoryProvider)
          .syncNow(forceFullDownload: true);
      await _refreshSyncedProviders();
      return true;
    } on ApiException catch (error) {
      if (!mounted) {
        return false;
      }

      if (error.isSyncKeyUnavailable) {
        final didReset = await _showResetSyncDialog(error.message);
        if (!didReset) {
          _showSyncError(error.message);
        }
        return didReset;
      }

      _showSyncError(error.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: ${error.message}')),
      );
      return false;
    } catch (error) {
      if (!mounted) {
        return false;
      }
      _showSyncError(error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $error')),
      );
      return false;
    }
  }

  void _showSyncError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _accountErrorMessage = message;
    });
  }

  Future<bool> _showResetSyncDialog(String message) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sync data cannot be opened'),
          content: Text(
            '$message\n\nYou can reset this account sync data and upload the data currently on this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reset sync data'),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) {
      return false;
    }

    try {
      await ref.read(syncRepositoryProvider).resetRemoteSyncFromLocal();
      await _refreshSyncedProviders();
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync reset failed: $error')),
        );
      }
      return false;
    }
  }

  Future<void> _refreshSyncedProviders() async {
    ref.invalidate(cyclesProvider);
    ref.invalidate(notesProvider);
    ref.invalidate(profileSettingsProvider);
    ref.invalidate(settingsProvider);
    ref.invalidate(upcomingCycleForecastProvider);
    ref.invalidate(currentCycleSummaryProvider);
    ref.invalidate(pendingCycleConflictsProvider);

    await Future.wait<Object?>([
      ref.read(cyclesProvider.future),
      ref.read(notesProvider.future),
      ref.read(profileSettingsProvider.future),
      ref.read(settingsProvider.future),
      ref.read(upcomingCycleForecastProvider.future),
      ref.read(currentCycleSummaryProvider.future),
      ref.read(pendingCycleConflictsProvider.future),
    ]);
  }
}
