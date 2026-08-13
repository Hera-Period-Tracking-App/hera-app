import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/repositories/note_repository.dart';
import 'package:hera_app/features/settings/providers/auto_sync_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';

class CalendarDateDetailsScreen extends ConsumerWidget {
  const CalendarDateDetailsScreen({
    required this.date,
    this.returnToNotes = false,
    super.key,
  });

  final DateTime date;
  final bool returnToNotes;

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
      const SnackBar(
        backgroundColor: AppColors.twilight,
        content: Text('Note deleted.', style: TextStyle(color: Colors.white)),
      ),
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
      appBar: AppBar(
        title: Text(_formatDateTitle(normalizedDate)),
        actions: [
          if (notesEnabled)
            noteAsync.maybeWhen(
              data: (note) {
                if (note == null) {
                  return IconButton(
                    onPressed: () => context.push(_noteEditorPath(normalizedDate)),
                    icon: const Icon(Icons.add),
                    tooltip: 'Add note',
                  );
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => context.push(
                        _noteEditorPath(normalizedDate),
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
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Text(
                        'No note for this date.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  final noteDetails = _parseNoteDetails(note.encryptedContent);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (noteDetails.note.isNotEmpty)
                            _NoteDetailLine(
                              label: 'Note:',
                              value: noteDetails.note,
                            ),
                          if (noteDetails.note.isNotEmpty &&
                              noteDetails.symptoms.isNotEmpty)
                            const SizedBox(height: 12),
                          if (noteDetails.symptoms.isNotEmpty)
                            _NoteDetailLine(
                              label: 'Symptoms:',
                              value: noteDetails.symptoms,
                            ),
                          if (noteDetails.flow.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _NoteDetailLine(
                              label: 'Menstrual flow:',
                              value: noteDetails.flow,
                            ),
                          ],
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

  String _noteEditorPath(DateTime date) {
    final path = AppRoutePaths.calendarAddNoteFor(date);
    return returnToNotes ? '$path?returnToNotes=true' : path;
  }
}

final _noteForDateProvider = StreamProvider.family(
  (ref, DateTime date) =>
      ref.watch(noteRepositoryProvider).watchNoteForDate(date),
);

class _NoteDetailLine extends StatelessWidget {
  const _NoteDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodyLarge,
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

_NoteDetails _parseNoteDetails(String content) {
  final noteParts = <String>[];
  var symptoms = '';
  var flow = '';

  for (final block in content.split('\n\n')) {
    final value = block.trim();
    if (value.startsWith('Symptoms: ')) {
      symptoms = value.substring('Symptoms: '.length).trim();
    } else if (value.startsWith('Menstrual flow: ')) {
      flow = value.substring('Menstrual flow: '.length).trim();
    } else if (value.isNotEmpty) {
      noteParts.add(value);
    }
  }

  return _NoteDetails(
    note: noteParts.join('\n\n'),
    symptoms: symptoms,
    flow: flow,
  );
}

class _NoteDetails {
  const _NoteDetails({
    required this.note,
    required this.symptoms,
    required this.flow,
  });

  final String note;
  final String symptoms;
  final String flow;
}

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
      '${months[date.month - 1]} ${date.day}';
}
