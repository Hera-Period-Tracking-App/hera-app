import 'package:flutter/material.dart';
import 'package:hera_app/core/theme/cycle_phase_colors.dart';
import 'package:hera_app/features/calendar/utils/calendar_view_utils.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';

class CalendarMonthSection extends StatelessWidget {
  const CalendarMonthSection({
    required this.month,
    required this.cycles,
    required this.onDatePressed,
    this.selectedDate,
    super.key,
  });

  final DateTime month;
  final List<CycleSummary> cycles;
  final ValueChanged<DateTime> onDatePressed;
  final DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phaseColors = theme.extension<CyclePhaseColors>();
    final menstruationDates = CalendarViewUtils.menstruationDatesForMonth(cycles, month);
    final ovulationDates = CalendarViewUtils.ovulationDatesForMonth(cycles, month);
    final fertileDates = CalendarViewUtils.fertileWindowDatesForMonth(cycles, month);
    final todayKey = CalendarViewUtils.dateKey(DateTime.now());
    final today = DateUtils.dateOnly(DateTime.now());
    final selectedKey = selectedDate == null ? null : CalendarViewUtils.dateKey(selectedDate!);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leadingEmptyCells = firstDayOfMonth.weekday - 1;
    final totalCells = ((leadingEmptyCells + daysInMonth + 6) ~/ 7) * 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          CalendarViewUtils.monthLabel(month),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: CalendarLayout.monthHeaderSpacing),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: CalendarLayout.dayCellSpacing,
            mainAxisSpacing: CalendarLayout.dayCellSpacing,
            mainAxisExtent: CalendarLayout.dayCellExtent,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final dayNumber = index - leadingEmptyCells + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final date = DateTime(month.year, month.month, dayNumber);
            final key = CalendarViewUtils.dateKey(date);
            final isMenstruationDay = menstruationDates.contains(key);
            final isOvulationDay = ovulationDates.contains(key);
            final isFertileDay = fertileDates.contains(key);
            final isToday = key == todayKey;
            final isFutureDate = date.isAfter(today);
            final isSelectedDate = selectedKey == key;

            final cellColor = isMenstruationDay
              ? Colors.red.withValues(alpha: 0.18)
              : isOvulationDay
                ? (phaseColors?.ovulation ?? theme.colorScheme.secondary)
                  .withValues(alpha: 0.28)
                : isFertileDay
                  ? (phaseColors?.ovulation ?? theme.colorScheme.secondary)
                    .withValues(alpha: 0.14)
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);

            final dayTextColor = isMenstruationDay
              ? Colors.red.shade900
              : isOvulationDay
                ? (phaseColors?.ovulation ?? theme.colorScheme.secondary)
                : null;

            return Opacity(
              opacity: isFutureDate ? 0.55 : 1,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isFutureDate ? null : () => onDatePressed(date),
                  borderRadius: BorderRadius.circular(10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelectedDate
                            ? theme.colorScheme.secondary
                            : (isToday ? theme.colorScheme.primary : Colors.transparent),
                        width: 1.4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: dayTextColor,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class WeekdayLabel extends StatelessWidget {
  const WeekdayLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}

class CalendarLegendItem extends StatelessWidget {
  const CalendarLegendItem({
    required this.color,
    required this.label,
    this.outlined = false,
    super.key,
  });

  final Color color;
  final String label;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: outlined
                ? Border.all(color: theme.colorScheme.primary, width: 1.2)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
