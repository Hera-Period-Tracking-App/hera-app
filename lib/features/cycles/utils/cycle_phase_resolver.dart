import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';

enum CyclePhase { menstruation, follicular, ovulation, luteal }

const int defaultCycleLength = 28;
const int defaultMenstruationLength = 5;
const int lutealPhaseLength = 13;

class CyclePhaseContext {
  const CyclePhaseContext({
    required this.phase,
    required this.dayOfCycle,
    required this.cycleLength,
    required this.menstruationLength,
    required this.isPredictedOvulationDay,
    required this.cycleStart,
    required this.cycleEnd,
    required this.predictedNextPeriod,
    required this.ovulationDay,
    required this.selectedDate,
  });

  final CyclePhase phase;
  final int dayOfCycle;
  final int cycleLength;
  final int menstruationLength;
  final bool isPredictedOvulationDay;
  final DateTime cycleStart;
  final DateTime cycleEnd;
  final DateTime predictedNextPeriod;
  final DateTime ovulationDay;
  final DateTime selectedDate;
}

CyclePhaseContext cyclePhaseContextForDate(
  List<CycleSummary> cycles,
  DateTime selectedDate, {
  int fallbackCycleLength = defaultCycleLength,
  CycleForecast? forecast,
}) {
  final selected = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );

  if (cycles.isEmpty) {
    return CyclePhaseContext(
      phase: CyclePhase.follicular,
      dayOfCycle: 1,
      cycleLength:
          fallbackCycleLength > 0 ? fallbackCycleLength : defaultCycleLength,
      menstruationLength: defaultMenstruationLength,
      isPredictedOvulationDay: false,
      cycleStart: selected,
      cycleEnd: selected,
      predictedNextPeriod: selected,
      ovulationDay: selected,
      selectedDate: selected,
    );
  }

  final sortedCycles = [...cycles]
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
  final latestCycle = sortedCycles.last;
  final latestCycleStart = DateTime(
    latestCycle.startDate.year,
    latestCycle.startDate.month,
    latestCycle.startDate.day,
  );

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

  final useForecastForLatestCycle =
      forecast != null && !selected.isBefore(latestCycleStart);
  final cycleLength = useForecastForLatestCycle
      ? forecast.cycleLength
      : (anchorCycle.cycleLength != null && anchorCycle.cycleLength! > 0)
          ? anchorCycle.cycleLength!
          : (fallbackCycleLength > 0 ? fallbackCycleLength : defaultCycleLength);

  final menstruationLength = useForecastForLatestCycle
      ? forecast.menstruationLength
      : (anchorCycle.menstruationLength != null &&
              anchorCycle.menstruationLength! > 0)
          ? anchorCycle.menstruationLength!
          : defaultMenstruationLength;

  final safeMenstruationLength =
      menstruationLength.clamp(1, cycleLength).toInt();
  final ovulationDayNumber = useForecastForLatestCycle
      ? forecast.ovulationDay.clamp(1, cycleLength).toInt()
      : (cycleLength - lutealPhaseLength + 1).clamp(1, cycleLength).toInt();

  final dayDelta = selected.difference(anchorStart).inDays;
  final cycleOffset = dayDelta >= 0
      ? dayDelta ~/ cycleLength
      : ((dayDelta - (cycleLength - 1)) ~/ cycleLength);
  final effectiveStart =
      anchorStart.add(Duration(days: cycleOffset * cycleLength));
  final dayOfCycle = selected.difference(effectiveStart).inDays + 1;

  return _phaseForDate(
    date: selected,
    startDate: effectiveStart,
    cycleLength: cycleLength,
    menstruationLength: safeMenstruationLength,
    ovulationDayNumber: ovulationDayNumber,
    dayOfCycle: dayOfCycle,
  );
}

String cyclePhaseLabel(CyclePhaseContext context) {
  if (context.phase == CyclePhase.ovulation) {
    return context.isPredictedOvulationDay ? 'Ovulation day' : 'Fertile window';
  }

  return switch (context.phase) {
    CyclePhase.menstruation => 'Menstruation',
    CyclePhase.follicular => 'Follicular phase',
    CyclePhase.luteal => 'Luteal phase',
    CyclePhase.ovulation => 'Fertile window',
  };
}

CyclePhaseContext _phaseForDate({
  required DateTime date,
  required DateTime startDate,
  required int cycleLength,
  required int menstruationLength,
  required int ovulationDayNumber,
  required int dayOfCycle,
}) {
  final predictedNextPeriod = startDate.add(Duration(days: cycleLength));
  final cycleEnd = predictedNextPeriod.subtract(const Duration(days: 1));
  final ovulationDay = startDate.add(
    Duration(days: ovulationDayNumber - 1),
  );
  final fertileWindowStart = ovulationDay.subtract(const Duration(days: 5));
  final fertileWindowEnd = ovulationDay;
  final menstruationEnd = startDate.add(Duration(days: menstruationLength - 1));
  final lutealEnd = predictedNextPeriod.subtract(const Duration(days: 1));

  final follicularStart = menstruationEnd.add(const Duration(days: 1));
  final follicularEnd = fertileWindowStart.subtract(const Duration(days: 1));

  CyclePhase phase;
  if (!date.isBefore(startDate) && !date.isAfter(menstruationEnd)) {
    phase = CyclePhase.menstruation;
  } else if (!date.isBefore(fertileWindowStart) &&
      !date.isAfter(fertileWindowEnd)) {
    phase = CyclePhase.ovulation;
  } else if (!date.isBefore(follicularStart) && !date.isAfter(follicularEnd)) {
    phase = CyclePhase.follicular;
  } else if (date.isAfter(ovulationDay) && !date.isAfter(lutealEnd)) {
    phase = CyclePhase.luteal;
  } else {
    phase = CyclePhase.follicular;
  }

  return CyclePhaseContext(
    phase: phase,
    dayOfCycle: dayOfCycle,
    cycleLength: cycleLength,
    menstruationLength: menstruationLength,
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
