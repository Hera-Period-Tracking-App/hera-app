import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarDateDetailsScreen extends StatelessWidget {
  const CalendarDateDetailsScreen({
    required this.date,
    super.key,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return Scaffold(
      appBar: AppBar(title: const Text('Date Details')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('EEEE, MMM d, yyyy').format(normalizedDate),
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You opened this date from the calendar.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
