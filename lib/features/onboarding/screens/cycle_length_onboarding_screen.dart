import 'package:flutter/material.dart';

class CycleLengthOnboardingScreen extends StatelessWidget {
  const CycleLengthOnboardingScreen({
    super.key,
    required this.cycleLength,
    required this.onChanged,
  });

  final double cycleLength;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Row(
                children: [
                  Text(
                    cycleLength.round().toString(),
                    style: theme.textTheme.headlineLarge?.copyWith(fontSize: 42),
                  ),
                  const SizedBox(width: 10),
                  Text('days', style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your average cycle length. You can fine-tune this later.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              Slider(
                min: 21,
                max: 35,
                divisions: 14,
                value: cycleLength,
                label: cycleLength.round().toString(),
                onChanged: onChanged,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Shorter', style: theme.textTheme.bodyMedium),
                  Text('Longer', style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
