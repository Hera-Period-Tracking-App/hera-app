import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/cycles/datasources/cycle_local_datasource.dart';
import 'package:hera_app/features/cycles/exceptions/cycle_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/duplicate_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/future_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/menstruation_length_exception.dart';
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
    _validateCycle(
      startDate: startDate,
      cycleLength: cycleLength,
      menstruationLength: menstruationLength,
    );

    final hasDuplicate = await _dataSource.hasCycleWithStartDate(startDate);
    if (hasDuplicate) {
      throw DuplicateCycleException(
        'A cycle with this start date already exists.',
      );
    }

    return _dataSource.insertCycleEntry(
      startDate: startDate,
      cycleLength: cycleLength,
      menstruationLength: menstruationLength,
    );
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
