import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/auth/providers/auth_provider.dart';
import 'package:hera_app/features/auth/widgets/auth_status_card.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitted = false;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authSessionProvider);
    final notifier = ref.read(authSessionProvider.notifier);
    final isBusy = authState.isLoading;
    final isAuthenticated =
        authState.asData?.value.isAuthenticated ?? false;
    final emailInvalid = _submitted && !_isValidEmail(_emailController.text);
    final passwordInvalid = _submitted && _passwordController.text.trim().length < 8;

    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          const AuthStatusCard(),
          const SizedBox(height: 16),
          SectionPlaceholderCard(
            title: 'Secure Storage',
            body: 'Bearer token, session metadata, device ID, and sync cursor stay in Flutter Secure Storage.',
          ),
          const SizedBox(height: 16),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isAuthenticated
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Connect to your API', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text(
                    'Set `--dart-define=API_BASE_URL=https://your-api-host` and use the form below for `/api/auth/signup` and `/api/auth/login`.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      errorText: emailInvalid ? 'Enter a valid email address' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Minimum 8 characters',
                      errorText: passwordInvalid ? 'Password is too short' : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (authState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        authState.error.toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: isBusy ? null : () => _submit(() => notifier.signup(
                              email: _emailController.text,
                              password: _passwordController.text,
                            )),
                        child: const Text('Sign up'),
                      ),
                      OutlinedButton(
                        onPressed: isBusy ? null : () => _submit(() => notifier.login(
                              email: _emailController.text,
                              password: _passwordController.text,
                            )),
                        child: const Text('Log in'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Connected', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text(
                    'Authentication succeeded. The login form is hidden until you sign out.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: isBusy ? null : notifier.logout,
                    child: const Text('Log out'),
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
        _passwordController.text.trim().length < 8) {
      return;
    }

    await action();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }
}
