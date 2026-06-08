import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

final cycleLocalDataSourceProvider = Provider<CycleLocalDataSource>(
  (ref) => CycleLocalDataSource(ref.watch(appDatabaseProvider)),
);

class CycleLocalDataSource {
  const CycleLocalDataSource(this._database);

  final AppDatabase _database;

  Stream<List<CycleEntry>> watchCycleEntries() {
    return (_database.select(_database.cycleEntries)
    ..orderBy([(entry) => OrderingTerm.desc(entry.startDate)]))
    .watch();
  }

  Future<bool> hasCycleWithStartDate(DateTime startDate) async {
    final dayStart = DateTime(startDate.year, startDate.month, startDate.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final existing = await (_database.select(_database.cycleEntries)
          ..where(
            (entry) =>
                entry.startDateLocal.isBiggerOrEqualValue(dayStart) &
                entry.startDateLocal.isSmallerThanValue(dayEnd),
          ))
        .getSingleOrNull();

    return existing != null;
  }

  Future<void> insertCycleEntry({
  required DateTime startDate,
  required int cycleLength,
  required int menstruationLength,
}) {
    return _database.into(_database.cycleEntries).insert(CycleEntriesCompanion.insert(
      id: const Uuid().v4(),
      startDate: startDate,
      startDateLocal: startDate,
      cycleLength: cycleLength,
      menstruationLength: menstruationLength,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ),
    );
  }
}