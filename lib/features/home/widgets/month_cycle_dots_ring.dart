import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/theme/cycle_phase_colors.dart';
import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/cyclePrediction/providers/cycle_prediction_provider.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/cycles/utils/cycle_phase_resolver.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

part 'month_cycle_dots_ring_header.dart';
part 'month_cycle_dots_ring_ring.dart';
part 'month_cycle_dots_ring_phase.dart';

class MonthCycleDotsRing extends ConsumerWidget {
  const MonthCycleDotsRing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cyclesAsync = ref.watch(cyclesProvider);
    final profileSettingsAsync = ref.watch(profileSettingsProvider);
    final forecastAsync = ref.watch(upcomingCycleForecastProvider);
    final averageCycleLength = profileSettingsAsync.maybeWhen(
      data: (value) => value.averageCycleLength,
      orElse: () => null,
    );
    // Keep a strict, single source of truth for the ring dot count.
    final dotsCount = averageCycleLength != null && averageCycleLength > 0
      ? averageCycleLength
      : 28;

    return cyclesAsync.when(
      data: (cycles) => _MonthCycleDotsRingView(
        cycles: cycles,
        dotsCount: dotsCount,
        forecast: forecastAsync.value,
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
    required this.forecast,
  });

  final List<CycleSummary> cycles;
  final int dotsCount;
  final CycleForecast? forecast;

  @override
  State<_MonthCycleDotsRingView> createState() => _MonthCycleDotsRingViewState();
}

class _MonthCycleDotsRingViewState extends State<_MonthCycleDotsRingView> {
  static const double _pixelsPerDay = 22;
  late DateTime _selectedDate;
  double _dragProgress = 0;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool get _isOnToday {
    return _selectedDate.year == _today.year &&
        _selectedDate.month == _today.month &&
        _selectedDate.day == _today.day;
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragProgress += -details.delta.dx / _pixelsPerDay;

      while (_dragProgress >= 1) {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day + 1,
        );
        _dragProgress -= 1;
      }

      while (_dragProgress <= -1) {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day - 1,
        );
        _dragProgress += 1;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      if (_dragProgress >= 0.5) {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day + 1,
        );
      } else if (_dragProgress <= -0.5) {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day - 1,
        );
      }

      _dragProgress = 0;
    });
  }

  void _resetToToday() {
    final today = _today;
    setState(() {
      _dragProgress = 0;
      _selectedDate = today;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final phaseContext = cyclePhaseContextForDate(
      widget.cycles,
      displayDate,
      fallbackCycleLength: widget.dotsCount,
      forecast: widget.forecast,
    );
    final cyclePhase = phaseContext.phase;
    final phasesByDay = _phasesByDayInMonth(
      widget.cycles,
      displayDate,
      widget.dotsCount,
      widget.forecast,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Column(
                children: [
                  _CycleInfoQuickRow(
                    cycleStart: phaseContext.cycleStart,
                    cycleEnd: phaseContext.cycleEnd,
                    ovulationDay: phaseContext.ovulationDay,
                  ),
                  const SizedBox(height: 10),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Column(
                      children: [
                        _CurrentDayHeader(
                          selectedDate: displayDate,
                          dragProgress: _dragProgress,
                          onSelectDate: (date) {
                            setState(() {
                              _dragProgress = 0;
                              _selectedDate = DateTime(date.year, date.month, date.day);
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _DotsRing(
                            dotsCount: widget.dotsCount,
                            currentDay: displayDate.day,
                            dragProgress: _dragProgress,
                            cyclePhase: cyclePhase,
                            phasesByDay: phasesByDay,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'Day ${phaseContext.dayOfCycle} of ${phaseContext.cycleLength}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!_isOnToday)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Material(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              shape: const CircleBorder(),
                              child: IconButton(
                                tooltip: 'Back to today',
                                onPressed: _resetToToday,
                                icon: Icon(
                                  Icons.replay,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          cyclePhaseLabel(phaseContext).toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_right_alt_rounded, size: 24),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          _nextEventCountdownLabel(phaseContext).toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleInfoQuickRow extends StatelessWidget {
  const _CycleInfoQuickRow({
    required this.cycleStart,
    required this.cycleEnd,
    required this.ovulationDay,
  });

  final DateTime cycleStart;
  final DateTime cycleEnd;
  final DateTime ovulationDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phaseColors = theme.extension<CyclePhaseColors>();
    final displayYear = cycleStart.year;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              '${_formatShortDate(cycleStart)} - ${_formatShortDate(cycleEnd)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(width: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 18,
              color: phaseColors?.ovulation ?? theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              _formatShortDate(ovulationDay),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$displayYear',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    return '${date.day}. ${months[date.month - 1]}';
  }
}
