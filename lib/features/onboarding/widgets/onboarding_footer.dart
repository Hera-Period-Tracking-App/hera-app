import 'package:flutter/material.dart';

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    required this.canGoBack,
    required this.isSaving,
    required this.isLastStep,
    required this.canContinue,
    required this.onBack,
    required this.onContinue,
    this.animateContinueLabel = false,
    this.continueLabelAnimationKey,
    this.continueLabel,
    this.infoText,
    this.secondaryAction,
    super.key,
  });

  final bool canGoBack;
  final bool isSaving;
  final bool isLastStep;
  final bool canContinue;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final bool animateContinueLabel;
  final Object? continueLabelAnimationKey;
  final String? continueLabel;
  final String? infoText;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final label = continueLabel ?? (isLastStep ? 'Start tracking' : 'Continue');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (secondaryAction != null) ...[
          secondaryAction!,
          const SizedBox(height: 8),
        ],
        if (infoText != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.72),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  infoText!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            if (canGoBack)
          IconButton(
            onPressed: isSaving ? null : onBack,
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              minimumSize: const Size(54, 54),
            ),
            icon: const Icon(Icons.chevron_left_rounded, size: 36),
          ),
            if (canGoBack) const SizedBox(width: 12),
            Expanded(
          child: FilledButton(
            onPressed: canContinue && !isSaving ? onContinue : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFC857),
              foregroundColor: const Color(0xFF171820),
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.16),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.42),
              minimumSize: const Size.fromHeight(54),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF171820),
                    ),
                  )
                : animateContinueLabel
                    ? KeyedSubtree(
                        key: ValueKey(continueLabelAnimationKey),
                        child: _TypingButtonLabel(
                          text: label,
                        ),
                      )
                    : Text(label),
          ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypingButtonLabel extends StatelessWidget {
  const _TypingButtonLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final visibleCharacters = (text.length * value).floor();
        return Text(text.substring(0, visibleCharacters));
      },
    );
  }
}
