part of 'month_cycle_dots_ring.dart';

Map<int, CyclePhase> _phasesByDayInMonth(
  List<CycleSummary> cycles,
  DateTime month,
  int fallbackCycleLength,
  CycleForecast? forecast,
) {
  final result = <int, CyclePhase>{};
  final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

  for (var day = 1; day <= daysInMonth; day++) {
    final date = DateTime(month.year, month.month, day);
    result[day] = cyclePhaseContextForDate(
      cycles,
      date,
      fallbackCycleLength: fallbackCycleLength,
      forecast: forecast,
    ).phase;
  }

  return result;
}

String _nextEventCountdownLabel(CyclePhaseContext context) {
  final selected = DateTime(
    context.selectedDate.year,
    context.selectedDate.month,
    context.selectedDate.day,
  );
  final ovulation = DateTime(
    context.ovulationDay.year,
    context.ovulationDay.month,
    context.ovulationDay.day,
  );
  final nextPeriod = DateTime(
    context.predictedNextPeriod.year,
    context.predictedNextPeriod.month,
    context.predictedNextPeriod.day,
  );

  if (selected.isBefore(ovulation)) {
    final days = ovulation.difference(selected).inDays;
    return days == 0 ? 'Ovulation today' : 'Ovulation in $days days';
  }

  final daysToPeriod = nextPeriod.difference(selected).inDays;
  return daysToPeriod == 0
      ? 'Menstruation today'
      : 'Menstruation in $daysToPeriod days';
}
