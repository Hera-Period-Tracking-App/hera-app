part of 'month_cycle_dots_ring.dart';

enum _CyclePhase { menstruation, follicular, ovulation, luteal }

const int _defaultCycleLength = 28;
const int _defaultMenstruationLength = 5;
const int _lutealPhaseLength = 13;

class _CyclePhaseContext {
  const _CyclePhaseContext({
    required this.phase,
    required this.dayOfCycle,
    required this.cycleLength,
    required this.isPredictedOvulationDay,
    required this.cycleStart,
    required this.cycleEnd,
    required this.predictedNextPeriod,
    required this.ovulationDay,
    required this.selectedDate,
  });

  final _CyclePhase phase;
  final int dayOfCycle;
  final int cycleLength;
  final bool isPredictedOvulationDay;
  final DateTime cycleStart;
  final DateTime cycleEnd;
  final DateTime predictedNextPeriod;
  final DateTime ovulationDay;
  final DateTime selectedDate;
}

Map<int, _CyclePhase> _phasesByDayInMonth(
  List<CycleSummary> cycles,
  DateTime month,
  int fallbackCycleLength,
) {
  final result = <int, _CyclePhase>{};
  final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

  for (var day = 1; day <= daysInMonth; day++) {
    final date = DateTime(month.year, month.month, day);
    result[day] = _resolveCyclePhase(cycles, date, fallbackCycleLength);
  }

  return result;
}

_CyclePhase _resolveCyclePhase(
  List<CycleSummary> cycles,
  DateTime selectedDate,
  int fallbackCycleLength,
) {
  return _cyclePhaseContextForDate(cycles, selectedDate, fallbackCycleLength).phase;
}

_CyclePhaseContext _cyclePhaseContextForDate(
  List<CycleSummary> cycles,
  DateTime selectedDate,
  int fallbackCycleLength,
) {
  final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

  if (cycles.isEmpty) {
    return _CyclePhaseContext(
      phase: _CyclePhase.follicular,
      dayOfCycle: 1,
      cycleLength: fallbackCycleLength > 0 ? fallbackCycleLength : _defaultCycleLength,
      isPredictedOvulationDay: false,
      cycleStart: selected,
      cycleEnd: selected,
      predictedNextPeriod: selected,
      ovulationDay: selected,
      selectedDate: selected,
    );
  }

  final sortedCycles = [...cycles]..sort((a, b) => a.startDate.compareTo(b.startDate));

  CycleSummary anchorCycle = sortedCycles.first;
  for (final cycle in sortedCycles) {
    final cycleStart = DateTime(
      cycle.startDate.year,
      cycle.startDate.month,
      cycle.startDate.day,
    );
    if (cycleStart.isAfter(selected)) {
      break;
    }
    anchorCycle = cycle;
  }

  final anchorStart = DateTime(
    anchorCycle.startDate.year,
    anchorCycle.startDate.month,
    anchorCycle.startDate.day,
  );

  final cycleLength = (anchorCycle.cycleLength != null && anchorCycle.cycleLength! > 0)
      ? anchorCycle.cycleLength!
      : (fallbackCycleLength > 0 ? fallbackCycleLength : _defaultCycleLength);

  final menstruationLength =
      (anchorCycle.menstruationLength != null && anchorCycle.menstruationLength! > 0)
      ? anchorCycle.menstruationLength!
      : _defaultMenstruationLength;

  final safeMenstruationLength = menstruationLength.clamp(1, cycleLength).toInt();

  final dayDelta = selected.difference(anchorStart).inDays;
  final cycleOffset = dayDelta >= 0
      ? dayDelta ~/ cycleLength
      : ((dayDelta - (cycleLength - 1)) ~/ cycleLength);
  final effectiveStart = anchorStart.add(Duration(days: cycleOffset * cycleLength));
  final dayOfCycle = selected.difference(effectiveStart).inDays + 1;

  return _phaseForDate(
    date: selected,
    startDate: effectiveStart,
    cycleLength: cycleLength,
    menstruationLength: safeMenstruationLength,
    dayOfCycle: dayOfCycle,
  );
}

_CyclePhaseContext _phaseForDate({
  required DateTime date,
  required DateTime startDate,
  required int cycleLength,
  required int menstruationLength,
  required int dayOfCycle,
}) {
  final predictedNextPeriod = startDate.add(Duration(days: cycleLength));
  final cycleEnd = predictedNextPeriod.subtract(const Duration(days: 1));
  final ovulationDay = predictedNextPeriod.subtract(
    const Duration(days: _lutealPhaseLength),
  );
  final fertileWindowStart = ovulationDay.subtract(const Duration(days: 5));
  final fertileWindowEnd = ovulationDay;
  final menstruationEnd = startDate.add(Duration(days: menstruationLength - 1));
  final lutealEnd = predictedNextPeriod.subtract(const Duration(days: 1));

  final follicularStart = menstruationEnd.add(const Duration(days: 1));
  final follicularEnd = fertileWindowStart.subtract(const Duration(days: 1));

  _CyclePhase phase;
  if (!date.isBefore(startDate) && !date.isAfter(menstruationEnd)) {
    phase = _CyclePhase.menstruation;
  } else if (!date.isBefore(fertileWindowStart) && !date.isAfter(fertileWindowEnd)) {
    phase = _CyclePhase.ovulation;
  } else if (!date.isBefore(follicularStart) && !date.isAfter(follicularEnd)) {
    phase = _CyclePhase.follicular;
  } else if (date.isAfter(ovulationDay) && !date.isAfter(lutealEnd)) {
    phase = _CyclePhase.luteal;
  } else {
    phase = _CyclePhase.follicular;
  }

  return _CyclePhaseContext(
    phase: phase,
    dayOfCycle: dayOfCycle,
    cycleLength: cycleLength,
    isPredictedOvulationDay: date.year == ovulationDay.year &&
        date.month == ovulationDay.month &&
        date.day == ovulationDay.day,
    cycleStart: startDate,
    cycleEnd: cycleEnd,
    predictedNextPeriod: predictedNextPeriod,
    ovulationDay: ovulationDay,
    selectedDate: date,
  );
}

String _phaseLabelForContext(_CyclePhaseContext context) {
  if (context.phase == _CyclePhase.ovulation) {
    return context.isPredictedOvulationDay
        ? 'Ovulation day'
        : 'Fertile window';
  }

  return switch (context.phase) {
    _CyclePhase.menstruation => 'Menstruation',
    _CyclePhase.follicular => 'Follicular phase',
    _CyclePhase.luteal => 'Luteal phase',
    _CyclePhase.ovulation => 'Fertile window',
  };
}

String _nextEventCountdownLabel(_CyclePhaseContext context) {
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
