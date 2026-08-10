import 'package:flutter/material.dart';
import 'package:hera_app/features/onboarding/screens/register_onboarding_screen.dart';

/// The final sign-in step uses the same credential form as registration.
class LoginOnboardingScreen extends StatelessWidget {
  const LoginOnboardingScreen({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.submitted,
    required this.onChanged,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool submitted;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return RegisterOnboardingScreen(
      emailController: emailController,
      passwordController: passwordController,
      submitted: submitted,
      onChanged: onChanged,
    );
  }
}
