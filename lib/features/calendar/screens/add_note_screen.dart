import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/core/utils/date_time_formatter.dart';
import 'package:hera_app/features/calendar/widgets/symptom_picker_sheet.dart';
import 'package:hera_app/features/notes/exceptions/duplicate_note_date_exception.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/repositories/custom_symptoms_repository.dart';
import 'package:hera_app/features/notes/repositories/note_repository.dart';
import 'package:hera_app/features/notes/utils/note_content_codec.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({required this.date, this.note, this.returnToNotes = false, super.key});

  final DateTime date;
  final Note? note;
  final bool returnToNotes;

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  final _controller = TextEditingController();
  final _symptoms = <String>{};
  final _customSymptoms = <String>{};
  String? _flow;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final note = widget.note;

    if (note != null) {
      final draft = NoteContentCodec.parse(note.encryptedContent);
      _controller.text = draft.text;
      _symptoms.addAll(draft.symptoms);
      _flow = draft.flow;
    }
    _customSymptoms.addAll(await ref.read(customSymptomsRepositoryProvider).load());
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(title: Text(widget.note == null ? l10n.newNote : l10n.editNote)),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Expanded(
                  child: TextField(
                      controller: _controller,
                      expands: true,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration:
                          InputDecoration(hintText: l10n.writePrivateNoteHint, border: const OutlineInputBorder()))),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                  onPressed: _saving ? null : _openPicker,
                  icon: const Icon(Icons.add_chart_outlined),
                  label: Text(l10n.symptoms)),
              if (_symptoms.isNotEmpty) Text(_symptoms.join(', ')),
              if (_flow != null) Text(l10n.flowLabel(_flow!)),
              const SizedBox(height: 12),
              FilledButton(
                  onPressed: _saving ? null : _save, child: Text(widget.note == null ? l10n.saveNote : l10n.save)),
            ])));
  }

  Future<void> _openPicker() => showSymptomPickerSheet(
      context: context,
      selectedSymptoms: _symptoms,
      customSymptoms: _customSymptoms,
      selectedFlow: _flow,
      onChanged: (value) {
        setState(() {
          _symptoms
            ..clear()
            ..addAll(value.symptoms);
          _customSymptoms
            ..clear()
            ..addAll(value.customSymptoms);
          _flow = value.flow;
        });
        ref.read(customSymptomsRepositoryProvider).save(value.customSymptoms);
      });

  Future<void> _save() async {
    final content = NoteContentCodec.encode(text: _controller.text, symptoms: _symptoms, flow: _flow);
    final l10n = AppLocalizations.of(context);
    if (content.isEmpty) {
      _message(l10n.writeNoteOrSymptomsBeforeSaving);
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(noteRepositoryProvider);
      if (widget.note == null) {
        await repo.addNote(date: widget.date, content: content);
      } else {
        await repo.updateNote(note: widget.note!, content: content);
      }
      if (mounted) {
        _message(widget.note == null ? l10n.noteSaved : l10n.noteUpdated);
        _close();
      }
    } on DuplicateNoteDateException catch (error) {
      _message(error.message);
    } catch (error) {
      _message(l10n.couldNotSaveNote(error.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(widget.returnToNotes
          ? AppRoutePaths.notes
          : '${AppRoutePaths.calendar}?focusDate=${DateTimeFormatter.toIsoDate(widget.date)}');
    }
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.twilight, content: Text(text, style: const TextStyle(color: Colors.white))));
}
