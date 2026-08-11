import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/repositories/note_repository.dart';
import 'package:hera_app/features/settings/providers/auto_sync_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';

class CalendarDateDetailsScreen extends ConsumerWidget {
  const CalendarDateDetailsScreen({
    required this.date,
    super.key,
  });

  final DateTime date;

  Future<void> _deleteNote(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete note?'),
          content: const Text(
            'This note will be permanently deleted from this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await ref.read(noteRepositoryProvider).deleteNote(note);
    ref.read(autoSyncProvider).queueSync();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note deleted.')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final notesEnabled = ref.watch(settingsProvider).maybeWhen(
          data: (settings) => settings.notesEnabled,
          orElse: () => true,
        );
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
            if (!notesEnabled)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Notes are disabled in Settings.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Note',
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                              IconButton(
                                onPressed: () => context.push(
                                  AppRoutePaths.calendarAddNoteFor(
                                    normalizedDate,
                                  ),
                                  extra: note,
                                ),
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: 'Edit note',
                              ),
                              IconButton(
                                onPressed: () => _deleteNote(context, ref, note),
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete note',
                              ),
                            ],
                          ),
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
