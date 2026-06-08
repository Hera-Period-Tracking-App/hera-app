import 'package:flutter/material.dart';

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    required this.canGoBack,
    required this.isSaving,
    required this.isLastStep,
    required this.canContinue,
    required this.onBack,
    required this.onContinue,
    super.key,
  });

  final bool canGoBack;
  final bool isSaving;
  final bool isLastStep;
  final bool canContinue;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (canGoBack)
          OutlinedButton(
            onPressed: isSaving ? null : onBack,
            child: const Text('Back'),
          ),
        if (canGoBack) const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: canContinue && !isSaving ? onContinue : null,
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isLastStep ? 'Start tracking' : 'Continue'),
          ),
        ),
      ],
    );
  }
}
