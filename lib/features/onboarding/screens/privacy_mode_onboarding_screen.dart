import 'package:flutter/material.dart';
import 'package:hera_app/features/onboarding/widgets/privacy_choice_card.dart';
import 'package:hera_app/shared/models/privacy_mode.dart';

class PrivacyModeOnboardingScreen extends StatelessWidget {
  const PrivacyModeOnboardingScreen({
    super.key,
    required this.selectedPrivacyMode,
    required this.onSelected,
  });

  final PrivacyMode? selectedPrivacyMode;
  final ValueChanged<PrivacyMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PrivacyChoiceCard(
            title: 'Local Only',
            titleFontSize: 30,
            eyebrow: 'OFFLINE MODE',
            description:
                'Keep every cycle, note, and symptom on this device. No account needed.',
            supportingText:
                'Why would I need an account? I want everything only on my phone, duh!',
            selected: selectedPrivacyMode == PrivacyMode.localOnly,
            accent: const Color(0xFFFFC857),
            onTap: () => onSelected(PrivacyMode.localOnly),
            illustrationAsset: 'assets/images/homepage/hera.png',
            illustrationHeight: 270,
            illustrationOffset: const Offset(105, 60),
            contentEndPadding: 102,
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: PrivacyChoiceCard(
            title: 'Secure Space',
            titleFontSize: 30,
            eyebrow: 'ENCRYPTED BACKUP',
            description:
                'Back up encrypted data and restore it when you change devices.',
            supportingText:
                'Your data, notes, and dates are encrypted — no need to worry!',
            selected: selectedPrivacyMode == PrivacyMode.secureSync,
            accent: const Color(0xFFFFC857),
            onTap: () => onSelected(PrivacyMode.secureSync),
            illustrationAsset: 'assets/images/homepage/aphrodite.png',
            illustrationAlignment: Alignment.bottomLeft,
            illustrationHeight: 300,
            illustrationOffset: const Offset(-80, 68),
            contentStartPadding: 130,
          ),
        ),
      ],
    );
  }
}
