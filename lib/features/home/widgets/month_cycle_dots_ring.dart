import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/theme/cycle_phase_colors.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
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
  double _dragProgress = 0;

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

  @override
  Widget build(BuildContext context) {
    final displayDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final phaseContext = _cyclePhaseContextForDate(
      widget.cycles,
      displayDate,
      widget.dotsCount,
    );
    final cyclePhase = phaseContext.phase;
    final phasesByDay = _phasesByDayInMonth(
      widget.cycles,
      displayDate,
      widget.dotsCount,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: SizedBox(
          width: double.infinity,
          child: Column(
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
              Text(
                'Day ${phaseContext.dayOfCycle} of ${phaseContext.cycleLength}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _phaseLabelForContext(phaseContext),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _nextEventCountdownLabel(phaseContext),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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

    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                _formatShortDate(ovulationDay),
                style: theme.textTheme.bodyMedium,
              ),
            ],
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
