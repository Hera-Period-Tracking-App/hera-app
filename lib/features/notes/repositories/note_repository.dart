import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/notes/datasources/note_local_datasource.dart';
import 'package:hera_app/features/notes/models/note.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(ref.watch(noteLocalDataSourceProvider)),
);

class NoteRepository {
  NoteRepository(this._dataSource);

  final NoteLocalDataSource _dataSource;

  Stream<List<Note>> watchNotes() {
    return _dataSource.watchNoteEntries().map(
          (rows) => rows
              .map(
                (row) => Note(
                  id: row.id,
                  cycleId: row.cycleId,
                  date: row.date,
                  encryptedContent: row.encryptedContent,
                  createdAt: row.createdAt,
                  updatedAt: row.updatedAt,
                ),
              )
              .toList(growable: false),
        );
  }
}
