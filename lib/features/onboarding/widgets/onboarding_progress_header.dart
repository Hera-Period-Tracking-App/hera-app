import 'package:flutter/material.dart';

class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    this.showStepInfo = true,
  });

  final int currentStep;
  final int totalSteps;
  final String title;
  final String subtitle;
  final bool showStepInfo;

  @override
  Widget build(BuildContext context) {
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
                      ? const Color(0xFFFFC857)
                      : Colors.white.withValues(alpha: 0.12),
                ),
              ),
            );
          }),
        ),
        if (showStepInfo) ...[
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontFamily: title.startsWith('>') ? 'monospace' : null,
                  fontSize: title.startsWith('>') ? 22 : null,
                  letterSpacing: title.startsWith('>') ? 0 : null,
                ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
            ),
          ],
        ],
      ],
    );
  }
}
