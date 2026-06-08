import 'package:flutter/material.dart';

class RegisterOnboardingScreen extends StatelessWidget {
  const RegisterOnboardingScreen({
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
    final theme = Theme.of(context);
    final emailInvalid = submitted && !_isValidGmail(emailController.text);
    final passwordInvalid = submitted && passwordController.text.trim().length < 8;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set up secure sync', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(
                'Use a Gmail address and a password with at least 8 characters.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Gmail address',
                  hintText: 'you@gmail.com',
                  errorText: emailInvalid ? 'Enter a valid Gmail address' : null,
                ),
                onChanged: (_) => onChanged(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Minimum 8 characters',
                  errorText: passwordInvalid ? 'Password is too short' : null,
                ),
                onChanged: (_) => onChanged(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isValidGmail(String value) {
    return RegExp(r'^[^@\s]+@gmail\.com$').hasMatch(value.trim().toLowerCase());
  }
}
