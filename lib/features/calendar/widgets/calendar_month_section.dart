import 'package:flutter/material.dart';
import 'package:hera_app/core/theme/cycle_phase_colors.dart';
import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/calendar/utils/calendar_view_utils.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';

class CalendarMonthSection extends StatelessWidget {
  const CalendarMonthSection({
    required this.month,
    required this.cycles,
    required this.noteDateKeys,
    required this.onDatePressed,
    required this.fallbackCycleLength,
    this.selectedDate,
    this.forecast,
    super.key,
  });

  final DateTime month;
  final List<CycleSummary> cycles;
  final Set<String> noteDateKeys;
  final ValueChanged<DateTime> onDatePressed;
  final int fallbackCycleLength;
  final DateTime? selectedDate;
  final CycleForecast? forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phaseColors = theme.extension<CyclePhaseColors>();
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;
    final phaseDates = CalendarViewUtils.phaseDatesForMonth(
      cycles,
      month,
      forecast: forecast,
    );
    final todayKey = CalendarViewUtils.dateKey(DateTime.now());
    final today = DateUtils.dateOnly(DateTime.now());
    final selectedKey =
        selectedDate == null ? null : CalendarViewUtils.dateKey(selectedDate!);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leadingEmptyCells = firstDayOfMonth.weekday - 1;
    final totalCells = ((leadingEmptyCells + daysInMonth + 6) ~/ 7) * 7;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: isCurrentMonth
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrentMonth
              ? theme.colorScheme.primary.withValues(alpha: 0.18)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: isCurrentMonth
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  CalendarViewUtils.monthLabel(month),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight:
                        isCurrentMonth ? FontWeight.w700 : FontWeight.w600,
                    color: isCurrentMonth
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (isCurrentMonth)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Current',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
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
              final isActualMenstruationDay =
                  phaseDates.actualMenstruationDates.contains(key);
              final isPredictedMenstruationDay =
                  phaseDates.predictedMenstruationDates.contains(key);
              final isActualOvulationDay =
                  phaseDates.actualOvulationDates.contains(key);
              final isPredictedOvulationDay =
                  phaseDates.predictedOvulationDates.contains(key);
              final isActualFertileDay =
                  phaseDates.actualFertileWindowDates.contains(key);
              final isPredictedFertileDay =
                  phaseDates.predictedFertileWindowDates.contains(key);
              final isPredictedDay = isPredictedMenstruationDay ||
                  isPredictedOvulationDay ||
                  isPredictedFertileDay;
              final isToday = key == todayKey;
              final isFutureDate = date.isAfter(today);
              final isSelectedDate = selectedKey == key;
              final hasNote = noteDateKeys.contains(key);

              final cellColor = isActualMenstruationDay
                  ? Colors.red.withValues(alpha: 0.18)
                  : isPredictedMenstruationDay
                      ? Colors.red.withValues(alpha: 0.09)
                  : isActualOvulationDay
                      ? (phaseColors?.ovulation ?? theme.colorScheme.secondary)
                          .withValues(alpha: 0.28)
                      : isPredictedOvulationDay
                          ? (phaseColors?.ovulation ??
                                  theme.colorScheme.secondary)
                              .withValues(alpha: 0.16)
                      : isActualFertileDay
                          ? (phaseColors?.ovulation ??
                                  theme.colorScheme.secondary)
                              .withValues(alpha: 0.14)
                          : isPredictedFertileDay
                              ? (phaseColors?.ovulation ??
                                      theme.colorScheme.secondary)
                                  .withValues(alpha: 0.07)
                          : theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: isCurrentMonth ? 0.42 : 0.35);

              final dayTextColor = isActualMenstruationDay
                  ? Colors.red.shade900
                  : isPredictedMenstruationDay
                      ? Colors.red.shade700
                  : isActualOvulationDay
                      ? (phaseColors?.ovulation ?? theme.colorScheme.secondary)
                      : isPredictedOvulationDay
                          ? (phaseColors?.ovulation ??
                                  theme.colorScheme.secondary)
                              .withValues(alpha: 0.8)
                      : isPredictedDay
                          ? theme.colorScheme.onSurfaceVariant
                          : null;

              return Opacity(
                opacity: isFutureDate && !isPredictedDay ? 0.55 : 1,
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
                              : (isToday
                                  ? theme.colorScheme.primary
                                  : Colors.transparent),
                          width: 1.4,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '$dayNumber',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: dayTextColor,
                                fontWeight:
                                    isToday ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (hasNote)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.surface,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
