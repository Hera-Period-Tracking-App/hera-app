import 'package:flutter/material.dart';
import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';

class CalendarLayout {
  const CalendarLayout._();

  static const monthTitleHeight = 32.0;
  static const monthHeaderSpacing = 12.0;
  static const monthBottomSpacing = 24.0;
  static const dayCellExtent = 42.0;
  static const dayCellSpacing = 4.0;
}

class CalendarPhaseDates {
  const CalendarPhaseDates({
    this.actualMenstruationDates = const <String>{},
    this.predictedMenstruationDates = const <String>{},
    this.actualOvulationDates = const <String>{},
    this.predictedOvulationDates = const <String>{},
    this.actualFertileWindowDates = const <String>{},
    this.predictedFertileWindowDates = const <String>{},
  });

  final Set<String> actualMenstruationDates;
  final Set<String> predictedMenstruationDates;
  final Set<String> actualOvulationDates;
  final Set<String> predictedOvulationDates;
  final Set<String> actualFertileWindowDates;
  final Set<String> predictedFertileWindowDates;
}

class CalendarViewUtils {
  const CalendarViewUtils._();

  static const int _predictionHorizonMonths = 18;

  static DateTime? earliestCycleMonth(List<CycleSummary> cycles) {
    if (cycles.isEmpty) {
      return null;
    }

    return cycles
        .map((cycle) => DateTime(cycle.startDate.year, cycle.startDate.month))
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  static CalendarPhaseDates phaseDatesForMonth(
    List<CycleSummary> cycles,
    DateTime month, {
    CycleForecast? forecast,
  }) {
    final actualMenstruationDates = <String>{};
    final predictedMenstruationDates = <String>{};
    final actualOvulationDates = <String>{};
    final predictedOvulationDates = <String>{};
    final actualFertileWindowDates = <String>{};
    final predictedFertileWindowDates = <String>{};
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final sortedCycles = [...cycles]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    for (final cycle in sortedCycles) {
      final cycleLength = cycle.cycleLength;
      if (cycleLength == null || cycleLength <= 0) {
        continue;
      }

      final cycleStart = DateTime(
        cycle.startDate.year,
        cycle.startDate.month,
        cycle.startDate.day,
      );
      final menstruationLength = (cycle.menstruationLength ?? 0) > 0
          ? cycle.menstruationLength!
          : 5;
      _addPhaseDatesForCycle(
        cycleStart: cycleStart,
        cycleLength: cycleLength,
        menstruationLength: menstruationLength,
        ovulationDayNumber: cycleLength - 12,
        monthStart: monthStart,
        monthEnd: monthEnd,
        menstruationDates: actualMenstruationDates,
        ovulationDates: actualOvulationDates,
        fertileWindowDates: actualFertileWindowDates,
      );
    }

    if (forecast != null && sortedCycles.isNotEmpty) {
      final latestCycle = sortedCycles.last;
      final latestCycleStart = DateTime(
        latestCycle.startDate.year,
        latestCycle.startDate.month,
        latestCycle.startDate.day,
      );
      final firstPredictedCycleStart = latestCycleStart.add(
        Duration(days: forecast.cycleLength),
      );
      final predictionHorizonEnd = DateTime(
        firstPredictedCycleStart.year,
        firstPredictedCycleStart.month + _predictionHorizonMonths,
        firstPredictedCycleStart.day,
      );
      var predictedCycleStart = firstPredictedCycleStart;

      while (predictedCycleStart.isBefore(predictionHorizonEnd)) {
        _addPhaseDatesForCycle(
          cycleStart: predictedCycleStart,
          cycleLength: forecast.cycleLength,
          menstruationLength: forecast.menstruationLength,
          ovulationDayNumber: forecast.ovulationDay,
          monthStart: monthStart,
          monthEnd: monthEnd,
          menstruationDates: predictedMenstruationDates,
          ovulationDates: predictedOvulationDates,
          fertileWindowDates: predictedFertileWindowDates,
        );

        predictedCycleStart = predictedCycleStart.add(
          Duration(days: forecast.cycleLength),
        );
      }
    }

    return CalendarPhaseDates(
      actualMenstruationDates: actualMenstruationDates,
      predictedMenstruationDates: predictedMenstruationDates,
      actualOvulationDates: actualOvulationDates,
      predictedOvulationDates: predictedOvulationDates,
      actualFertileWindowDates: actualFertileWindowDates,
      predictedFertileWindowDates: predictedFertileWindowDates,
    );
  }

  static Set<String> cycleStartDatesForMonth(
    List<CycleSummary> cycles,
    DateTime month,
  ) {
    final result = <String>{};

    for (final cycle in cycles) {
      final date = DateTime(
        cycle.startDate.year,
        cycle.startDate.month,
        cycle.startDate.day,
      );
      if (date.year == month.year && date.month == month.month) {
        result.add(dateKey(date));
      }
    }

    return result;
  }

  static String dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return '${d.year}-${d.month}-${d.day}';
  }

  static String monthLabel(DateTime month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${names[month.month - 1]} ${month.year}';
  }

  static double estimateMonthSectionHeight(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leadingEmptyCells = firstDayOfMonth.weekday % 7;
    final totalCells = ((leadingEmptyCells + daysInMonth + 6) ~/ 7) * 7;
    final rowCount = (totalCells / 7).round();
    final gridHeight = (rowCount * CalendarLayout.dayCellExtent) +
        ((rowCount - 1) * CalendarLayout.dayCellSpacing);

    return CalendarLayout.monthTitleHeight +
        CalendarLayout.monthHeaderSpacing +
        gridHeight +
        CalendarLayout.monthBottomSpacing;
  }

  static void _addPhaseDatesForCycle({
    required DateTime cycleStart,
    required int cycleLength,
    required int menstruationLength,
    required int ovulationDayNumber,
    required DateTime monthStart,
    required DateTime monthEnd,
    required Set<String> menstruationDates,
    required Set<String> ovulationDates,
    required Set<String> fertileWindowDates,
  }) {
    final safeCycleLength = cycleLength.clamp(15, 90);
    final safeMenstruationLength = menstruationLength.clamp(1, safeCycleLength);
    final safeOvulationDay = ovulationDayNumber.clamp(1, safeCycleLength);
    final ovulationDate = cycleStart.add(Duration(days: safeOvulationDay - 1));
    final fertileStart = ovulationDate.subtract(const Duration(days: 5));

    for (var i = 0; i < safeMenstruationLength; i++) {
      final date = cycleStart.add(Duration(days: i));
      if (!date.isBefore(monthStart) && !date.isAfter(monthEnd)) {
        menstruationDates.add(dateKey(date));
      }
    }

    if (!ovulationDate.isBefore(monthStart) && !ovulationDate.isAfter(monthEnd)) {
      ovulationDates.add(dateKey(ovulationDate));
    }

    for (var i = 0; i < 6; i++) {
      final date = fertileStart.add(Duration(days: i));
      if (!date.isBefore(monthStart) && !date.isAfter(monthEnd)) {
        fertileWindowDates.add(dateKey(date));
      }
    }
  }
}
