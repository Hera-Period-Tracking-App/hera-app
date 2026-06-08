import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class MonthCycleDotsRing extends ConsumerWidget {
  const MonthCycleDotsRing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cyclesAsync = ref.watch(cyclesProvider);
    final profileSettingsAsync = ref.watch(profileSettingsProvider);
    final averageCycleLength = profileSettingsAsync.maybeWhen(
      data: (value) => value.averageCycleLength,
      orElse: () => null,
    );
    final dotsCount =
        (averageCycleLength != null && averageCycleLength > 0)
            ? averageCycleLength
            : 28;

    return cyclesAsync.when(
      data: (cycles) => _MonthCycleDotsRingView(
        cycles: cycles,
        dotsCount: dotsCount,
      ),
      loading: () => const SectionPlaceholderCard(
        title: 'Cycle month ring',
        body: 'Loading cycle data...',
      ),
      error: (error, _) => const SectionPlaceholderCard(
        title: 'Cycle month ring',
        body: 'Could not load cycle data for the month ring.',
      ),
    );
  }
}

class _MonthCycleDotsRingView extends StatefulWidget {
  const _MonthCycleDotsRingView({
    required this.cycles,
    required this.dotsCount,
  });

  final List<CycleSummary> cycles;
  final int dotsCount;

  @override
  State<_MonthCycleDotsRingView> createState() => _MonthCycleDotsRingViewState();
}

class _MonthCycleDotsRingViewState extends State<_MonthCycleDotsRingView> {
  static const double _pixelsPerDay = 22;
  late DateTime _selectedDate;
  double _dragCarry = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _shiftSelectedDate(int days) {
    if (days == 0) {
      return;
    }

    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day + days,
      );
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _dragCarry += details.delta.dx;
    while (_dragCarry.abs() >= _pixelsPerDay) {
      if (_dragCarry > 0) {
        _shiftSelectedDate(-1);
        _dragCarry -= _pixelsPerDay;
      } else {
        _shiftSelectedDate(1);
        _dragCarry += _pixelsPerDay;
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _dragCarry = 0;
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final daysInMonth =
        DateUtils.getDaysInMonth(displayDate.year, displayDate.month);
    final menstruationDays = _menstruationDaysInMonth(widget.cycles, displayDate);
    final ovulationDays = _ovulationDaysInMonth(widget.cycles, displayDate);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: SizedBox(
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: 1,
            child: Column(
              children: [
                _CurrentDayHeader(
                  selectedDate: displayDate,
                  onSelectDate: (date) {
                    setState(() {
                      _selectedDate = DateTime(date.year, date.month, date.day);
                    });
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _DotsRing(
                    dotsCount: widget.dotsCount,
                    currentDay: displayDate.day,
                    menstruationDays: menstruationDays,
                    ovulationDays: ovulationDays,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Set<int> _menstruationDaysInMonth(List<CycleSummary> cycles, DateTime month) {
    final result = <int>{};
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);

    for (final cycle in cycles) {
      final menstruationLength = cycle.menstruationLength;
      if (menstruationLength == null || menstruationLength <= 0) {
        continue;
      }

      final start = DateTime(
        cycle.startDate.year,
        cycle.startDate.month,
        cycle.startDate.day,
      );

      for (var i = 0; i < menstruationLength; i++) {
        final date = start.add(Duration(days: i));
        if (date.isBefore(monthStart) || date.isAfter(monthEnd)) {
          continue;
        }
        result.add(date.day);
      }
    }

    return result;
  }

  Set<int> _ovulationDaysInMonth(List<CycleSummary> cycles, DateTime month) {
    final result = <int>{};
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

      final cycleEnd = start.add(Duration(days: cycleLength - 1));
      final ovulationStart = cycleEnd.subtract(const Duration(days: 17));

      // Ovulation phase: 17,16,15,14,13 days before cycle end (5 days total).
      for (var i = 0; i < 5; i++) {
        final date = ovulationStart.add(Duration(days: i));
        if (date.isBefore(monthStart) || date.isAfter(monthEnd)) {
          continue;
        }
        result.add(date.day);
      }
    }

    return result;
  }

}

class _CurrentDayHeader extends StatelessWidget {
  const _CurrentDayHeader({
    required this.selectedDate,
    required this.onSelectDate,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dates = List<DateTime>.generate(
      7,
      (index) => DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day + (index - 3),
      ),
    );
    final centered = dates[3];

    return SizedBox(
      height: 52,
      child: Row(
        children: [
          for (final date in dates)
            Expanded(
              child: InkWell(
                onTap: () => onSelectDate(date),
                child: _DateStripItem(
                  date: date,
                  isCenter: date == centered,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateStripItem extends StatelessWidget {
  const _DateStripItem({required this.date, required this.isCenter});

  final DateTime date;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final textColor = isCenter
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          weekdayLabels[date.weekday - 1].toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: textColor,
            fontWeight: isCenter ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${date.day}',
          style: theme.textTheme.titleSmall?.copyWith(
            color: textColor,
            fontWeight: isCenter ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 2,
          height: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isCenter
                  ? theme.colorScheme.onSurface
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    );
  }
}

class _DotsRing extends StatelessWidget {
  const _DotsRing({
    required this.dotsCount,
    required this.currentDay,
    required this.menstruationDays,
    required this.ovulationDays,
  });

  final int dotsCount;
  final int currentDay;
  final Set<int> menstruationDays;
  final Set<int> ovulationDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final ringSize = constraints.biggest.shortestSide;
        final center = ringSize / 2;
        final dotSize = (ringSize * 0.075).clamp(12.0, 26.0);
        final radius = (ringSize / 2) - (dotSize / 2);

        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              children: [
                for (var day = 1; day <= dotsCount; day++)
                  _buildDot(
                    day: day,
                    center: center,
                    radius: radius,
                    dotSize: dotSize,
                    color: menstruationDays.contains(day)
                        ? Colors.red.shade500
                        : ovulationDays.contains(day)
                            ? Colors.teal.shade400
                            : theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.38),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDot({
    required int day,
    required double center,
    required double radius,
    required double dotSize,
    required Color color,
  }) {
    final normalizedIndex =
      ((day - currentDay) % dotsCount + dotsCount) % dotsCount;

    final angle =
      (-math.pi / 2) + (2 * math.pi * normalizedIndex / dotsCount);

    final x = center + radius * math.cos(angle);
    final y = center + radius * math.sin(angle);

    return Positioned(
      left: x - (dotSize / 2),
      top: y - (dotSize / 2),
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
