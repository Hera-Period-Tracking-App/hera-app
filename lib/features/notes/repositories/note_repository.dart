import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/database/app_database.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/core/encryption/encryption_service.dart';
import 'package:hera_app/features/notes/datasources/note_local_datasource.dart';
import 'package:hera_app/features/notes/exceptions/duplicate_note_date_exception.dart';
import 'package:hera_app/features/notes/models/note.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(
    ref.watch(noteLocalDataSourceProvider),
    ref.watch(secureStorageDataSourceProvider),
    ref.watch(encryptionServiceProvider),
  ),
);

class NoteRepository {
  NoteRepository(
    this._dataSource,
    this._secureStorage,
    this._encryptionService,
  );

  final NoteLocalDataSource _dataSource;
  final SecureStorageDataSource _secureStorage;
  final EncryptionService _encryptionService;

  Stream<List<Note>> watchNotes() {
    return _dataSource.watchNoteEntries().asyncMap(
      (rows) async {
        final notes = <Note>[];
        for (final row in rows) {
          notes.add(await _toDecryptedNote(row));
        }
        return notes.toList(growable: false);
      },
    );
  }

  Stream<Note?> watchNoteForDate(DateTime date) {
    return _dataSource.watchNoteForDate(date).asyncMap((row) async {
      if (row == null) {
        return null;
      }

      return _toDecryptedNote(row);
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

  Future<void> deleteNote(Note note) async {
    final deleted = await _dataSource.deleteNoteEntry(note.id);
    if (deleted <= 0) {
      return;
    }

    final tombstones = await loadDeletedNoteTombstones();
    tombstones.removeWhere((entry) => entry.noteId == note.id);
    tombstones.add(
      DeletedNoteTombstone(
        noteId: note.id,
        deletedAtUtc: DateTime.now().toUtc(),
      ),
    );
    await _saveDeletedNoteTombstones(tombstones);
  }

  Future<void> updateNote({
    required Note note,
    required String content,
  }) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw ArgumentError('Note content cannot be empty.');
    }

    final encryptedContent = await _encryptionService.encrypt(trimmedContent);
    return _dataSource.updateNoteEntry(
      id: note.id,
      encryptedContent: encryptedContent,
    );
  }

  Future<List<DeletedNoteTombstone>> loadDeletedNoteTombstones() async {
    final raw = await _secureStorage.read(AppConstants.deletedNoteTombstonesKey);
    if (raw == null || raw.isEmpty) {
      return <DeletedNoteTombstone>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <DeletedNoteTombstone>[];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(DeletedNoteTombstone.fromJson)
        .toList(growable: false);
  }

  Future<Note> _toDecryptedNote(NoteEntry row) async {
    String content;
    try {
      content = await _decryptNoteContent(row.encryptedContent);
    } catch (_) {
      content = _looksEncrypted(row.encryptedContent)
          ? 'This note could not be decrypted on this device.'
          : row.encryptedContent;
    }

    return Note(
      id: row.id,
      cycleId: row.cycleId,
      date: row.date,
      encryptedContent: content,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<String> _decryptNoteContent(String value) async {
    var content = value;
    for (var i = 0; i < 3; i += 1) {
      if (!_looksEncrypted(content)) {
        return content;
      }
      final decrypted = await _encryptionService.decrypt(content);
      if (decrypted == content) {
        return decrypted;
      }
      content = decrypted;
    }
    return content;
  }

  bool _looksEncrypted(String value) {
    try {
      final decoded = jsonDecode(value);
      return decoded is Map<String, dynamic> &&
          decoded['alg'] == 'A256GCM' &&
          decoded['ciphertext'] is String;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveDeletedNoteTombstones(
    List<DeletedNoteTombstone> tombstones,
  ) {
    return _secureStorage.write(
      AppConstants.deletedNoteTombstonesKey,
      jsonEncode(
        tombstones.map((entry) => entry.toJson()).toList(growable: false),
      ),
    );
  }
}

class DeletedNoteTombstone {
  const DeletedNoteTombstone({
    required this.noteId,
    required this.deletedAtUtc,
  });

  final String noteId;
  final DateTime deletedAtUtc;

  Map<String, dynamic> toJson() {
    return {
      'noteId': noteId,
      'deletedAtUtc': deletedAtUtc.toUtc().toIso8601String(),
    };
  }

  factory DeletedNoteTombstone.fromJson(Map<String, dynamic> json) {
    return DeletedNoteTombstone(
      noteId: json['noteId'] as String? ?? '',
      deletedAtUtc:
          DateTime.parse(json['deletedAtUtc'] as String).toUtc(),
    );
  }
}
