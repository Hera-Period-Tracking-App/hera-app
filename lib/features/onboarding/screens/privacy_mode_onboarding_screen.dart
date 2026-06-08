import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/features/onboarding/widgets/privacy_choice_card.dart';
import 'package:hera_app/shared/models/privacy_mode.dart';

class PrivacyModeOnboardingScreen extends StatefulWidget {
  const PrivacyModeOnboardingScreen({
    super.key,
    required this.selectedPrivacyMode,
    required this.onSelected,
  });

  final PrivacyMode? selectedPrivacyMode;
  final ValueChanged<PrivacyMode> onSelected;

  @override
  State<PrivacyModeOnboardingScreen> createState() =>
      _PrivacyModeOnboardingScreenState();
}

class _PrivacyModeOnboardingScreenState
    extends State<PrivacyModeOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(math.sin(_pulseController.value * math.pi * 2) * 8, 0),
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.shield_moon_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'You can start offline today and switch to secure sync later.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        PrivacyChoiceCard(
          title: 'Local only',
          description: 'Everything stays on this device for an offline setup.',
          icon: Icons.phone_iphone_rounded,
          selected: widget.selectedPrivacyMode == PrivacyMode.localOnly,
          accent: AppColors.forest,
          onTap: () => widget.onSelected(PrivacyMode.localOnly),
        ),
        const SizedBox(height: 14),
        PrivacyChoiceCard(
          title: 'Secure sync',
          description: 'Create an account so encrypted data can be restored later.',
          icon: Icons.cloud_done_rounded,
          selected: widget.selectedPrivacyMode == PrivacyMode.secureSync,
          accent: AppColors.forest,
          animatedBadge: true,
          onTap: () => widget.onSelected(PrivacyMode.secureSync),
        ),
      ],
    );
  }
}
