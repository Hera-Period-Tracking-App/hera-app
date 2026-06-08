import 'package:flutter/material.dart';

class LastCycleStartOnboardingScreen extends StatelessWidget {
  const LastCycleStartOnboardingScreen({
    super.key,
    required this.lastCycleStart,
    required this.onChanged,
  });

  final DateTime lastCycleStart;
  final ValueChanged<DateTime> onChanged;

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
              Text('Last cycle start date', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                'We use this to begin your calendar with a sensible first date.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _formatDate(lastCycleStart),
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.tonal(
                onPressed: () => _pickDate(context),
                child: const Text('Choose date'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: lastCycleStart,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
