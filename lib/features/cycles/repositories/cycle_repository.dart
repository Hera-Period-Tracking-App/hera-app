import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/cycles/datasources/cycle_local_datasource.dart';
import 'package:hera_app/features/cycles/exceptions/cycle_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/duplicate_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/future_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/menstruation_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/overlapping_cycle_exception.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';

final cycleRepositoryProvider = Provider<CycleRepository>(
  (ref) => CycleRepository(ref.watch(cycleLocalDataSourceProvider)),
);

class CycleRepository {
  CycleRepository(this._dataSource);

  final CycleLocalDataSource _dataSource;

  Stream<List<CycleSummary>> watchSummaries() {
    return _dataSource.watchCycleEntries().map(
          (rows) => rows
              .map(
                (row) => CycleSummary(
                  id: row.id,
                  startDate: row.startDateLocal,
                  cycleLength: row.cycleLength,
                  menstruationLength: row.menstruationLength,
                ),
              )
              .toList(growable: false),
        );
  }

  Future<void> addCycle({
    required DateTime startDate,
    required int cycleLength,
    required int menstruationLength,
  }) async {
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final effectiveCycleLength = await _resolveEffectiveCycleLength(
      startDate: startDateOnly,
      providedCycleLength: cycleLength,
    );

    _validateCycle(
      startDate: startDateOnly,
      cycleLength: effectiveCycleLength,
      menstruationLength: menstruationLength,
    );

    final hasDuplicate = await _dataSource.hasCycleWithStartDate(startDateOnly);
    if (hasDuplicate) {
      throw DuplicateCycleException(
        'A cycle with this start date already exists.',
      );
    }

    final hasOverlap = await _dataSource.hasOverlappingCycle(
      startDate: startDateOnly,
      cycleLength: effectiveCycleLength,
    );
    if (hasOverlap) {
      throw OverlappingCycleException(
        'The new cycle overlaps with an existing cycle.',
      );
    }

    return _dataSource.insertCycleEntry(
      startDate: startDateOnly,
      cycleLength: effectiveCycleLength,
      menstruationLength: menstruationLength,
    );
  }

  Future<void> updateCycle({
    required String id,
    required DateTime startDate,
    required int cycleLength,
    required int menstruationLength,
  }) async {
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final effectiveCycleLength = await _resolveEffectiveCycleLength(
      startDate: startDateOnly,
      providedCycleLength: cycleLength,
      excludeCycleId: id,
    );

    _validateCycle(
      startDate: startDateOnly,
      cycleLength: effectiveCycleLength,
      menstruationLength: menstruationLength,
    );

    final previousCycle = await _dataSource.previousCycleBefore(
      startDateOnly,
      excludeCycleId: id,
    );
    final previousCycleLength = previousCycle == null
        ? null
        : startDateOnly.difference(previousCycle.startDateLocal).inDays;

    if (previousCycleLength != null &&
        (previousCycleLength < 15 || previousCycleLength > 90)) {
      throw CycleLengthException(
        'The previous cycle would need to be between 15 and 90 days.',
      );
    }

    final hasDuplicate = await _dataSource.hasCycleWithStartDate(
      startDateOnly,
      excludeCycleId: id,
    );
    if (hasDuplicate) {
      throw DuplicateCycleException(
        'A cycle with this start date already exists.',
      );
    }

    return _dataSource.updateCycleEntryAndPreviousBoundary(
      id: id,
      startDate: startDateOnly,
      cycleLength: effectiveCycleLength,
      menstruationLength: menstruationLength,
      previousCycle: previousCycle,
      previousCycleLength: previousCycleLength,
    );
  }

  Future<int> _resolveEffectiveCycleLength({
    required DateTime startDate,
    required int providedCycleLength,
    String? excludeCycleId,
  }) async {
    final nextCycleStart = await _dataSource.nextCycleStartAfter(
      startDate,
      excludeCycleId: excludeCycleId,
    );
    if (nextCycleStart == null) {
      return providedCycleLength;
    }

    final nextStartOnly = DateTime(
      nextCycleStart.year,
      nextCycleStart.month,
      nextCycleStart.day,
    );
    final boundedLength = nextStartOnly.difference(startDate).inDays;

    if (boundedLength < 15) {
      throw CycleLengthException(
        'Cycle length must be at least 15 days and end before the next cycle start.',
      );
    }

    return boundedLength;
  }

  void _validateCycle({
    required DateTime startDate,
    required int cycleLength,
    required int menstruationLength,
  }) {
    final today = DateTime.now();

    final startDateOnly = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    final todayOnly = DateTime(
      today.year,
      today.month,
      today.day,
    );

    if (startDateOnly.isAfter(todayOnly)) {
      throw const FutureCycleException();
    }

    if (cycleLength < 15 || cycleLength > 90) {
      throw CycleLengthException(
        'Cycle length must be between 15 and 90 days.',
      );
    }

    if (menstruationLength < 1 || menstruationLength > 14) {
      throw MenstruationLengthException(
        'Menstruation length must be between 1 and 14 days.',
      );
    }

    if (menstruationLength > cycleLength) {
      throw MenstruationLengthException(
        'Menstruation length cannot exceed cycle length.',
      );
    }
  }
}
