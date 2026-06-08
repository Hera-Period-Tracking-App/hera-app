import 'package:flutter/material.dart';

class MenstruationLengthOnboardingScreen extends StatelessWidget {
  const MenstruationLengthOnboardingScreen({
    super.key,
    required this.menstruationLength,
    required this.onChanged,
  });

  final double menstruationLength;
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
                    menstruationLength.round().toString(),
                    style: theme.textTheme.headlineLarge?.copyWith(fontSize: 42),
                  ),
                  const SizedBox(width: 10),
                  Text('days', style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'How long on average do your menstruations last?',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              Slider(
                min: 1,
                max: 10,
                divisions: 9,
                value: menstruationLength,
                label: menstruationLength.round().toString(),
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