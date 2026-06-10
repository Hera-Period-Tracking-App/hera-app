import 'package:flutter/material.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';

class CalendarLayout {
  const CalendarLayout._();

  static const monthTitleHeight = 32.0;
  static const monthHeaderSpacing = 12.0;
  static const monthBottomSpacing = 24.0;
  static const dayCellExtent = 50.0;
  static const dayCellSpacing = 6.0;
}

class CalendarViewUtils {
  const CalendarViewUtils._();

  static const int _lutealPhaseLength = 13;

  static DateTime? earliestCycleMonth(List<CycleSummary> cycles) {
    if (cycles.isEmpty) {
      return null;
    }

    return cycles
        .map((cycle) => DateTime(cycle.startDate.year, cycle.startDate.month))
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  static Set<String> menstruationDatesForMonth(
    List<CycleSummary> cycles,
    DateTime month,
  ) {
    final result = <String>{};
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);

    for (final cycle in cycles) {
      final length = cycle.menstruationLength;
      if (length == null || length <= 0) {
        continue;
      }

      final start = DateTime(
        cycle.startDate.year,
        cycle.startDate.month,
        cycle.startDate.day,
      );
      for (var i = 0; i < length; i++) {
        final date = start.add(Duration(days: i));
        if (date.isBefore(monthStart) || date.isAfter(monthEnd)) {
          continue;
        }
        result.add(dateKey(date));
      }
    }

    return result;
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

  static Set<String> ovulationDatesForMonth(
    List<CycleSummary> cycles,
    DateTime month,
  ) {
    final result = <String>{};
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);

    for (final cycle in cycles) {
      final cycleLength = cycle.cycleLength;
      if (cycleLength == null || cycleLength <= 0) {
        continue;
      }

      final start = DateTime(
        cycle.startDate.year,
        cycle.startDate.month,
        cycle.startDate.day,
      );
      final ovulationDay = start.add(
        Duration(days: cycleLength - _lutealPhaseLength),
      );

      if (ovulationDay.isBefore(monthStart) || ovulationDay.isAfter(monthEnd)) {
        continue;
      }
      result.add(dateKey(ovulationDay));
    }

    return result;
  }

  static Set<String> fertileWindowDatesForMonth(
    List<CycleSummary> cycles,
    DateTime month,
  ) {
    final result = <String>{};
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);

    for (final cycle in cycles) {
      final cycleLength = cycle.cycleLength;
      if (cycleLength == null || cycleLength <= 0) {
        continue;
      }

      final start = DateTime(
        cycle.startDate.year,
        cycle.startDate.month,
        cycle.startDate.day,
      );
      final ovulationDay = start.add(
        Duration(days: cycleLength - _lutealPhaseLength),
      );
      final fertileStart = ovulationDay.subtract(const Duration(days: 5));

      for (var i = 0; i < 5; i++) {
        final fertileDate = fertileStart.add(Duration(days: i));
        if (fertileDate.isBefore(monthStart) || fertileDate.isAfter(monthEnd)) {
          continue;
        }
        result.add(dateKey(fertileDate));
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
    final leadingEmptyCells = firstDayOfMonth.weekday - 1;
    final totalCells = ((leadingEmptyCells + daysInMonth + 6) ~/ 7) * 7;
    final rowCount = (totalCells / 7).round();
    final gridHeight = (rowCount * CalendarLayout.dayCellExtent) +
        ((rowCount - 1) * CalendarLayout.dayCellSpacing);

    return CalendarLayout.monthTitleHeight +
        CalendarLayout.monthHeaderSpacing +
        gridHeight +
        CalendarLayout.monthBottomSpacing;
  }
}
