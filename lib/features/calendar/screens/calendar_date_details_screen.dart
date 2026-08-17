import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/core/utils/date_time_formatter.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/repositories/note_repository.dart';
import 'package:hera_app/features/notes/utils/note_content_codec.dart';
import 'package:hera_app/features/notes/utils/note_option_labels.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteNoteQuestion),
          content: Text(l10n.deleteNoteWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.deleteNote),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await ref.read(noteRepositoryProvider).deleteNote(note);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.twilight,
        content: Text(l10n.noteDeleted, style: const TextStyle(color: Colors.white)),
      ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final notesEnabled = ref.watch(settingsProvider).maybeWhen(
          data: (settings) => settings.notesEnabled,
          orElse: () => true,
        );
    final noteAsync = ref.watch(_noteForDateProvider(normalizedDate));

    return Scaffold(
      appBar: AppBar(
        title: Text(DateTimeFormatter.formatDateTitle(normalizedDate)),
        actions: [
          if (notesEnabled)
            noteAsync.maybeWhen(
              data: (note) {
                if (note == null) {
                  return IconButton(
                    onPressed: () => context.push(_noteEditorPath(normalizedDate)),
                    icon: const Icon(Icons.add),
                    tooltip: l10n.newNote,
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
                      tooltip: l10n.editNote,
                    ),
                    IconButton(
                      onPressed: () => _deleteNote(context, ref, note),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: l10n.deleteNote,
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
                    l10n.notesDisabledInSettings,
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
                        l10n.noNotesYet,
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  final noteDetails = NoteContentCodec.parse(
                    note.encryptedContent,
                  );
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (noteDetails.text.isNotEmpty)
                            _NoteDetailLine(
                              label: '${l10n.notes}:',
                              value: noteDetails.text,
                            ),
                          if (noteDetails.text.isNotEmpty && noteDetails.symptoms.isNotEmpty)
                            const SizedBox(height: 12),
                          if (noteDetails.symptoms.isNotEmpty)
                            _NoteDetailLine(
                              label: '${l10n.symptoms}:',
                              value: noteDetails.symptoms.map((item) => symptomLabel(l10n, item)).join(', '),
                            ),
                          if (noteDetails.flow != null) ...[
                            const SizedBox(height: 12),
                            _NoteDetailLine(
                              label: '${l10n.menstrualFlow}:',
                              value: flowLabel(l10n, noteDetails.flow!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(l10n.couldNotLoadNotes(error.toString())),
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
  (ref, DateTime date) => ref.watch(noteRepositoryProvider).watchNoteForDate(date),
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
