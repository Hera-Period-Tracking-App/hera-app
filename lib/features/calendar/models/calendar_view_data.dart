import 'package:hera_app/features/calendar/utils/calendar_view_utils.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/utils/cycle_selection.dart';
import 'package:hera_app/features/notes/models/note.dart';

class CalendarViewData {
  const CalendarViewData(
      {required this.firstMonth,
      required this.monthCount,
      required this.focusedMonth,
      required this.focusedMonthIndex,
      required this.noteDateKeys,
      required this.cycles});
  final DateTime firstMonth;
  final int monthCount;
  final DateTime focusedMonth;
  final int focusedMonthIndex;
  final Set<String> noteDateKeys;
  final List<CycleSummary> cycles;

  factory CalendarViewData.create(
      {required List<CycleSummary> cycles,
      required List<Note> notes,
      required bool notesEnabled,
      required DateTime? focusDate,
      required bool isEditingCycle,
      required String? editedCycleId,
      required DateTime? editedStartDate,
      required int? editedMenstruationLength,
      required int monthsBeforeEarliestCycle,
      required int monthsAfterCurrent}) {
    final now = DateTime.now();
    final nowMonth = DateTime(now.year, now.month);
    final earliest = CalendarViewUtils.earliestCycleMonth(cycles) ?? nowMonth;
    final firstMonth = DateTime(earliest.year, earliest.month - monthsBeforeEarliestCycle);
    final lastMonth = DateTime(nowMonth.year, nowMonth.month + monthsAfterCurrent);
    final monthCount = (lastMonth.year - firstMonth.year) * 12 + lastMonth.month - firstMonth.month + 1;
    final focus = focusDate == null ? nowMonth : DateTime(focusDate.year, focusDate.month);
    final index = ((focus.year - firstMonth.year) * 12 + focus.month - firstMonth.month).clamp(0, monthCount - 1);
    final edited = findCycleById(cycles, editedCycleId);
    final displayedCycles = isEditingCycle && edited != null
        ? cycles
            .map((cycle) => cycle.id == edited.id
                ? CycleSummary(
                    id: cycle.id,
                    startDate: editedStartDate ?? cycle.startDate,
                    cycleLength: cycle.cycleLength,
                    menstruationLength: editedMenstruationLength ?? cycle.menstruationLength)
                : cycle)
            .toList(growable: false)
        : cycles;
    return CalendarViewData(
        firstMonth: firstMonth,
        monthCount: monthCount,
        focusedMonth: DateTime(firstMonth.year, firstMonth.month + index),
        focusedMonthIndex: index,
        noteDateKeys: notesEnabled ? notes.map((note) => CalendarViewUtils.dateKey(note.date)).toSet() : <String>{},
        cycles: displayedCycles);
  }
}
