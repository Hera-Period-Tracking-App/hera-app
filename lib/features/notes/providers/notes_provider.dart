import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/repositories/note_repository.dart';

final notesProvider = StreamProvider<List<Note>>(
  (ref) => ref.watch(noteRepositoryProvider).watchNotes(),
);
