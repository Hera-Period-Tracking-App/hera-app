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

  Future<bool> hasCycleWithStartDate(
    DateTime startDate, {
    String? excludeCycleId,
  }) async {
    final dayStart = DateTime(startDate.year, startDate.month, startDate.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final existing = await (_database.select(_database.cycleEntries)
          ..where(
            (entry) =>
                entry.startDateLocal.isBiggerOrEqualValue(dayStart) &
                entry.startDateLocal.isSmallerThanValue(dayEnd) &
                (excludeCycleId == null
                    ? const Constant(true)
                    : entry.id.equals(excludeCycleId).not()),
          ))
        .getSingleOrNull();

    return existing != null;
  }

  Future<DateTime?> nextCycleStartAfter(
    DateTime startDate, {
    String? excludeCycleId,
  }) async {
    final dayStart = DateTime(startDate.year, startDate.month, startDate.day);

    final next = await (_database.select(_database.cycleEntries)
          ..where(
            (entry) =>
                entry.startDateLocal.isBiggerThanValue(dayStart) &
                (excludeCycleId == null
                    ? const Constant(true)
                    : entry.id.equals(excludeCycleId).not()),
          )
          ..orderBy([(entry) => OrderingTerm.asc(entry.startDateLocal)]))
        .get();

    return next.isEmpty ? null : next.first.startDateLocal;
  }

  Future<CycleEntry?> previousCycleBefore(
    DateTime startDate, {
    required String excludeCycleId,
  }) {
    final dayStart = DateTime(startDate.year, startDate.month, startDate.day);
    return (_database.select(_database.cycleEntries)
          ..where(
            (entry) =>
                entry.startDateLocal.isSmallerThanValue(dayStart) &
                entry.id.equals(excludeCycleId).not(),
          )
          ..orderBy([(entry) => OrderingTerm.desc(entry.startDateLocal)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<bool> hasOverlappingCycle({
    required DateTime startDate,
    required int cycleLength,
    String? excludeCycleId,
  }) async {
    final newStart = DateTime(startDate.year, startDate.month, startDate.day);
    final newEnd = newStart.add(Duration(days: cycleLength - 1));

    final allCycles = await _database.select(_database.cycleEntries).get();

    for (final cycle in allCycles) {
      if (cycle.id == excludeCycleId) {
        continue;
      }

      final existingStart = DateTime(
        cycle.startDateLocal.year,
        cycle.startDateLocal.month,
        cycle.startDateLocal.day,
      );
      final existingEnd =
          existingStart.add(Duration(days: cycle.cycleLength - 1));

      final doesOverlap =
          !newEnd.isBefore(existingStart) && !newStart.isAfter(existingEnd);
      if (doesOverlap) {
        return true;
      }
    }

    return false;
  }

  Future<void> insertCycleEntry({
    required DateTime startDate,
    required int cycleLength,
    required int menstruationLength,
  }) {
    return _database.into(_database.cycleEntries).insert(
          CycleEntriesCompanion.insert(
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

  Future<void> updateCycleEntry({
    required String id,
    required DateTime startDate,
    required int cycleLength,
    required int menstruationLength,
  }) {
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);

    return (_database.update(_database.cycleEntries)
          ..where((entry) => entry.id.equals(id)))
        .write(
      CycleEntriesCompanion(
        startDate: Value(startDateOnly),
        startDateLocal: Value(startDateOnly),
        cycleLength: Value(cycleLength),
        menstruationLength: Value(menstruationLength),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateCycleEntryAndPreviousBoundary({
    required String id,
    required DateTime startDate,
    required int cycleLength,
    required int menstruationLength,
    CycleEntry? previousCycle,
    int? previousCycleLength,
  }) {
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final now = DateTime.now();

    return _database.transaction(() async {
      if (previousCycle != null && previousCycleLength != null) {
        await (_database.update(_database.cycleEntries)
              ..where((entry) => entry.id.equals(previousCycle.id)))
            .write(
          CycleEntriesCompanion(
            cycleLength: Value(previousCycleLength),
            updatedAt: Value(now),
          ),
        );
      }

      await (_database.update(_database.cycleEntries)
            ..where((entry) => entry.id.equals(id)))
          .write(
        CycleEntriesCompanion(
          startDate: Value(startDateOnly),
          startDateLocal: Value(startDateOnly),
          cycleLength: Value(cycleLength),
          menstruationLength: Value(menstruationLength),
          updatedAt: Value(now),
        ),
      );
    });
  }
}
