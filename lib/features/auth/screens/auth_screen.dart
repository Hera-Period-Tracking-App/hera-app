import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/auth/providers/auth_provider.dart';
import 'package:hera_app/features/onboarding/screens/login_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/register_onboarding_screen.dart';
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
  String? _accountErrorMessage;

  @override
  void initState() {
    super.initState();

    ref.listenManual(authSessionProvider, (previous, next) {
      final wasAuthenticated =
          previous?.asData?.value.isAuthenticated ?? false;
      final isAuthenticated = next.asData?.value.isAuthenticated ?? false;

      if (!wasAuthenticated && isAuthenticated && mounted) {
        context.go(AppRoutePaths.home);
      }
    });
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
    final isBusy = authState.isLoading;
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

    setState(() => _accountErrorMessage = null);
    await action();

    final authState = ref.read(authSessionProvider);
    if (authState.hasError && mounted) {
      setState(() {
        _accountErrorMessage = widget.mode == AuthScreenMode.signup
            ? 'There was an error creating your account. Please try again.'
            : 'Could not log in. Please check your credentials.';
      });
    }
  }

  void _clearAccountError() {
    setState(() => _accountErrorMessage = null);
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }
}
