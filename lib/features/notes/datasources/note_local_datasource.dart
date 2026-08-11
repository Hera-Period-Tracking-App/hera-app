import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

final noteLocalDataSourceProvider = Provider<NoteLocalDataSource>(
  (ref) => NoteLocalDataSource(ref.watch(appDatabaseProvider)),
);

class NoteLocalDataSource {
  const NoteLocalDataSource(this._database);

  final AppDatabase _database;

  Stream<List<NoteEntry>> watchNoteEntries() {
    return (_database.select(_database.noteEntries)
          ..orderBy([(entry) => OrderingTerm.desc(entry.date)]))
        .watch();
  }

  Stream<NoteEntry?> watchNoteForDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return (_database.select(_database.noteEntries)
          ..where(
            (entry) =>
                entry.date.isBiggerOrEqualValue(dayStart) &
                entry.date.isSmallerThanValue(dayEnd),
          )
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<bool> hasNoteForDate(DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final existing = await (_database.select(_database.noteEntries)
          ..where(
            (entry) =>
                entry.date.isBiggerOrEqualValue(dayStart) &
                entry.date.isSmallerThanValue(dayEnd),
          ))
        .getSingleOrNull();

    return existing != null;
  }

  Future<void> insertNoteEntry({
    String? cycleId,
    required DateTime date,
    required String encryptedContent,
  }) {
    final now = DateTime.now();

    return _database.into(_database.noteEntries).insert(
          NoteEntriesCompanion.insert(
            id: const Uuid().v4(),
            cycleId: Value(cycleId),
            date: date,
            encryptedContent: encryptedContent,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<int> deleteNoteEntry(String id) {
    return (_database.delete(_database.noteEntries)
          ..where((entry) => entry.id.equals(id)))
        .go();
  }

  Future<void> updateNoteEntry({
    required String id,
    required String encryptedContent,
  }) {
    return (_database.update(_database.noteEntries)
          ..where((entry) => entry.id.equals(id)))
        .write(
      NoteEntriesCompanion(
        encryptedContent: Value(encryptedContent),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
