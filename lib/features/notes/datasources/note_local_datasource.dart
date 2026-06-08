import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/database/app_database.dart';

final noteLocalDataSourceProvider = Provider<NoteLocalDataSource>(
  (ref) => NoteLocalDataSource(ref.watch(appDatabaseProvider)),
);

class NoteLocalDataSource {
  const NoteLocalDataSource(this._database);

  final AppDatabase _database;

  Stream<List<NoteEntry>> watchNoteEntries() {
    return _database.select(_database.noteEntries).watch();
  }
}