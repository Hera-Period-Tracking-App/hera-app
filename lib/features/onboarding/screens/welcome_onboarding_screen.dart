import 'package:flutter/material.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/features/onboarding/widgets/onboarding_info_tile.dart';

class WelcomeOnboardingScreen extends StatelessWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.95),
                AppColors.clay,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Hera',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 34,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hera helps you track cycles, symptoms, notes, and personal patterns while keeping privacy at the center of the experience.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const OnboardingInfoTile(
          icon: Icons.lock_outline_rounded,
          title: 'Privacy first',
          body: 'Choose local-only storage or secure sync during setup.',
        ),
        const SizedBox(height: 14),
        const OnboardingInfoTile(
          icon: Icons.insights_rounded,
          title: 'Patterns over time',
          body: 'Build a clearer view of cycle timing, symptoms, and notes.',
        ),
      ],
    );
  }
}
