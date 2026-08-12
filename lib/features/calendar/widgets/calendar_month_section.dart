import 'package:flutter/material.dart';
import 'package:hera_app/core/theme/cycle_phase_colors.dart';
import 'package:hera_app/features/calendar/utils/calendar_view_utils.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

class CalendarMonthSection extends StatelessWidget {
  const CalendarMonthSection({
    required this.month,
    required this.phaseDates,
    required this.noteDateKeys,
    required this.onDatePressed,
    this.selectedDate,
    super.key,
  });

  final DateTime month;
  final CalendarPhaseDates phaseDates;
  final Set<String> noteDateKeys;
  final ValueChanged<DateTime> onDatePressed;
  final DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phaseColors = theme.extension<CyclePhaseColors>();
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;
    final todayKey = CalendarViewUtils.dateKey(DateTime.now());
    final today = DateUtils.dateOnly(DateTime.now());
    final selectedKey =
        selectedDate == null ? null : CalendarViewUtils.dateKey(selectedDate!);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leadingEmptyCells = firstDayOfMonth.weekday % 7;
    final totalCells = ((leadingEmptyCells + daysInMonth + 6) ~/ 7) * 7;

    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _capitalizeFirst(
                      DateFormat.yMMMM(
                        Localizations.localeOf(context).toString(),
                      ).format(month),
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight:
                          isCurrentMonth ? FontWeight.w700 : FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isCurrentMonth)
                  Text(
                    l10n.current,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
              ],
            ),
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
              final isToday = key == todayKey;
              final isFutureDate = date.isAfter(today);
              final isSelectedDate = selectedKey == key;
              final hasNote = noteDateKeys.contains(key);

              final phaseColor = isActualMenstruationDay ||
                      isPredictedMenstruationDay
                  ? Colors.red
                  : isActualOvulationDay || isPredictedOvulationDay
                      ? phaseColors?.ovulation ?? theme.colorScheme.secondary
                      : isActualFertileDay || isPredictedFertileDay
                          ? phaseColors?.follicular ??
                              theme.colorScheme.secondary
                      : null;
              final isPredictedPhase = isPredictedMenstruationDay ||
                  isPredictedOvulationDay ||
                  isPredictedFertileDay;

              return InkWell(
                  onTap: isFutureDate
                      ? null
                      : () async {
                          await Future<void>.delayed(
                            const Duration(milliseconds: 160),
                          );
                          onDatePressed(date);
                        },
                  borderRadius: BorderRadius.circular(14),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: isSelectedDate
                          ? const Color(0xFFFFC857)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: isToday && !isSelectedDate
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 1.2,
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '$dayNumber',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelectedDate
                                  ? const Color(0xFF171820)
                                  : isFutureDate
                                      ? theme.colorScheme.onSurface
                                          .withValues(alpha: 0.25)
                                      : null,
                              fontWeight: isSelectedDate || isToday
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (phaseColor != null && !isSelectedDate)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: phaseColor.withValues(
                                  alpha: isPredictedPhase ? 0.5 : 1,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        if (hasNote)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
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

String _capitalizeFirst(String value) {
  if (value.isEmpty) {
    return value;
  }
  return value[0].toUpperCase() + value.substring(1);
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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
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
