import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/encryption/encryption_service.dart';
import 'package:hera_app/features/notes/datasources/note_local_datasource.dart';
import 'package:hera_app/features/notes/exceptions/duplicate_note_date_exception.dart';
import 'package:hera_app/features/notes/models/note.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(
    ref.watch(noteLocalDataSourceProvider),
    ref.watch(encryptionServiceProvider),
  ),
);

class NoteRepository {
  NoteRepository(this._dataSource, this._encryptionService);

  final NoteLocalDataSource _dataSource;
  final EncryptionService _encryptionService;

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

  Stream<Note?> watchNoteForDate(DateTime date) {
    return _dataSource.watchNoteForDate(date).map((row) {
      if (row == null) {
        return null;
      }

      return Note(
        id: row.id,
        cycleId: row.cycleId,
        date: row.date,
        encryptedContent: row.encryptedContent,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
    });
  }

  Future<void> addNote({
    String? cycleId,
    required DateTime date,
    required String content,
  }) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw ArgumentError('Note content cannot be empty.');
    }

    final encryptedContent = await _encryptionService.encrypt(trimmedContent);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final hasExistingNote = await _dataSource.hasNoteForDate(dateOnly);
    if (hasExistingNote) {
      throw const DuplicateNoteDateException();
    }

    return _dataSource.insertNoteEntry(
      cycleId: cycleId,
      date: dateOnly,
      encryptedContent: encryptedContent,
    );
  }
}
