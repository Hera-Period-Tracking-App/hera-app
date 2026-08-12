import 'package:flutter/material.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/core/widgets/app_text_field.dart';

class RegisterOnboardingScreen extends StatelessWidget {
  const RegisterOnboardingScreen({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.confirmPasswordController,
    required this.submitted,
    this.errorMessage,
    required this.onChanged,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? confirmPasswordController;
  final bool submitted;
  final String? errorMessage;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emailInvalid = submitted && !_isValidEmail(emailController.text);
    final passwordInvalid = submitted && passwordController.text.trim().length < 8;
    final confirmPasswordInvalid = submitted &&
        confirmPasswordController != null &&
        confirmPasswordController!.text != passwordController.text;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  const ColoredBox(
                    color: AppColors.twilight,
                    child: SizedBox(height: 230),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(36),
                        ),
                      ),
                      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set up secure sync',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Use an email address and a password with at least 8 characters.',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 34),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'EMAIL ADDRESS'),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        context,
                        hint: 'you@example.com',
                        errorText: emailInvalid
                            ? 'Enter a valid email address'
                            : null,
                      ),
                      onChanged: (_) => onChanged(),
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel(label: 'PASSWORD'),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _inputDecoration(
                        context,
                        hint: 'At least 8 characters',
                        errorText: passwordInvalid ? 'Password is too short' : null,
                      ),
                      onChanged: (_) => onChanged(),
                    ),
                    if (confirmPasswordController != null) ...[
                      const SizedBox(height: 16),
                      const _FieldLabel(label: 'CONFIRM PASSWORD'),
                      const SizedBox(height: 6),
                      AppTextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: _inputDecoration(
                          context,
                          hint: 'Write it again',
                          errorText: confirmPasswordInvalid
                              ? 'Passwords do not match'
                              : null,
                        ),
                        onChanged: (_) => onChanged(),
                      ),
                    ],
                  ],
                ),
              ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 15,
                right: 20,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/homepage/artemis-signup.png',
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    String? errorText,
  }) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    );

    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      // Reserve this line from the start, so validation never shifts either
      // field or changes the form's layout.
      helperText: ' ',
      helperStyle: const TextStyle(fontSize: 12, height: 1.2, color: Colors.transparent),
      errorStyle: TextStyle(
        fontSize: 12,
        height: 1.2,
        color: theme.colorScheme.error,
      ),
      filled: true,
      fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border,
      errorBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
    );
  }
}
