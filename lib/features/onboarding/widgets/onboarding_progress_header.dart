import 'package:flutter/material.dart';

class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
  });

  final int currentStep;
  final int totalSteps;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final active = index <= currentStep;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.14),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
