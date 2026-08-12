import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/database/app_database.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/features/settings/models/pending_cycle_conflict.dart';

final cycleConflictRepositoryProvider = Provider<CycleConflictRepository>(
  (ref) => CycleConflictRepository(
    database: ref.watch(appDatabaseProvider),
    secureStorage: ref.watch(secureStorageDataSourceProvider),
  ),
);

final pendingCycleConflictsProvider =
    FutureProvider<List<PendingCycleConflict>>(
  (ref) => ref.watch(cycleConflictRepositoryProvider).loadConflicts(),
);

class CycleConflictRepository {
  const CycleConflictRepository({
    required AppDatabase database,
    required SecureStorageDataSource secureStorage,
  })  : _database = database,
        _secureStorage = secureStorage;

  final AppDatabase _database;
  final SecureStorageDataSource _secureStorage;

  Future<List<PendingCycleConflict>> loadConflicts() async {
    final raw = await _secureStorage.read(AppConstants.pendingCycleConflictsKey);
    if (raw == null || raw.isEmpty) {
      return const <PendingCycleConflict>[];
    }

    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return const <PendingCycleConflict>[];
    }

    if (decoded is! List) {
      return const <PendingCycleConflict>[];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((json) {
          try {
            return PendingCycleConflict.fromJson(json);
          } catch (_) {
            return null;
          }
        })
        .nonNulls
        .where((conflict) =>
            conflict.id.isNotEmpty &&
            conflict.localCycle.id.isNotEmpty &&
            conflict.remoteCycle.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<CycleEntry?> findOverlappingLocalCycle({
    required SyncCycleSnapshot remoteCycle,
  }) async {
    final cycles = await _database.select(_database.cycleEntries).get();

    for (final cycle in cycles) {
      if (cycle.id == remoteCycle.id) {
        continue;
      }

      final local = SyncCycleSnapshot.fromEntry(cycle);
      if (_cyclesOverlap(local, remoteCycle)) {
        return cycle;
      }
    }

    return null;
  }

  Future<void> saveConflict({
    required CycleEntry localCycle,
    required SyncCycleSnapshot remoteCycle,
  }) async {
    final conflicts = await loadConflicts();
    final conflictId = _conflictId(
      localCycleId: localCycle.id,
      remoteCycleId: remoteCycle.id,
    );
    final alreadyExists = conflicts.any((conflict) => conflict.id == conflictId);
    if (alreadyExists) {
      return;
    }

    final updated = [
      ...conflicts,
      PendingCycleConflict(
        id: conflictId,
        localCycle: SyncCycleSnapshot.fromEntry(localCycle),
        remoteCycle: remoteCycle,
        createdAtUtc: DateTime.now().toUtc(),
      ),
    ];
    await _saveConflicts(updated);
  }

  Future<void> resolveConflict({
    required String conflictId,
    required CycleConflictChoice choice,
  }) async {
    final conflicts = await loadConflicts();
    final conflict = conflicts
        .where((candidate) => candidate.id == conflictId)
        .firstOrNull;
    if (conflict == null) {
      return;
    }

    final keep = choice == CycleConflictChoice.local
        ? _canonicalizeLocalChoice(conflict)
        : conflict.remoteCycle;
    final discard = conflict.localCycle;
    final now = DateTime.now();

    await _database.transaction(() async {
      await (_database.update(_database.noteEntries)
            ..where((note) => note.cycleId.equals(discard.id)))
          .write(
        NoteEntriesCompanion(
          cycleId: Value(keep.id),
          updatedAt: Value(now),
        ),
      );

      if (discard.id != keep.id) {
        await (_database.delete(_database.cycleEntries)
              ..where((cycle) => cycle.id.equals(discard.id)))
            .go();
      }

      await _database.into(_database.cycleEntries).insertOnConflictUpdate(
            CycleEntriesCompanion.insert(
              id: keep.id,
              startDate: keep.startDate,
              startDateLocal: keep.startDate,
              cycleLength: keep.cycleLength,
              menstruationLength: keep.menstruationLength,
              createdAt: keep.createdAt,
              updatedAt: choice == CycleConflictChoice.local
                  ? now
                  : keep.updatedAt,
            ),
          );
    });

    await _saveConflicts(
      conflicts
          .where((candidate) => candidate.id != conflictId)
          .toList(growable: false),
    );
  }

  Future<void> _saveConflicts(List<PendingCycleConflict> conflicts) async {
    if (conflicts.isEmpty) {
      await _secureStorage.delete(AppConstants.pendingCycleConflictsKey);
      return;
    }

    await _secureStorage.write(
      AppConstants.pendingCycleConflictsKey,
      jsonEncode(
        conflicts.map((conflict) => conflict.toJson()).toList(growable: false),
      ),
    );
  }

  SyncCycleSnapshot _canonicalizeLocalChoice(PendingCycleConflict conflict) {
    final local = conflict.localCycle;
    return SyncCycleSnapshot(
      id: conflict.remoteCycle.id,
      startDate: local.startDate,
      cycleLength: local.cycleLength,
      menstruationLength: local.menstruationLength,
      createdAt: local.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool _cyclesOverlap(SyncCycleSnapshot first, SyncCycleSnapshot second) {
    return !first.endDate.isBefore(second.startDate) &&
        !first.startDate.isAfter(second.endDate);
  }

  String _conflictId({
    required String localCycleId,
    required String remoteCycleId,
  }) {
    return '$localCycleId::$remoteCycleId';
  }
}
