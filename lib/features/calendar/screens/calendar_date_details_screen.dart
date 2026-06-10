import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/notes/repositories/note_repository.dart';

class CalendarDateDetailsScreen extends ConsumerWidget {
  const CalendarDateDetailsScreen({
    required this.date,
    super.key,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final noteAsync = ref.watch(_noteForDateProvider(normalizedDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Date Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _formatDateTitle(normalizedDate),
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            noteAsync.when(
              data: (note) {
                if (note == null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No note for this date.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Note', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          note.encryptedContent,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Could not load note: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

final _noteForDateProvider = StreamProvider.family(
  (ref, DateTime date) =>
      ref.watch(noteRepositoryProvider).watchNoteForDate(date),
);

String _formatDateTitle(DateTime date) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${weekdays[date.weekday - 1]}, '
      '${months[date.month - 1]} ${date.day}, ${date.year}';
}
