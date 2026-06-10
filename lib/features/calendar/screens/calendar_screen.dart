import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/cycle_phase_colors.dart';
import 'package:hera_app/features/calendar/utils/calendar_view_utils.dart';
import 'package:hera_app/features/calendar/widgets/calendar_month_section.dart';
import 'package:hera_app/features/calendar/widgets/slow_scroll_physics.dart';
import 'package:hera_app/features/cycles/exceptions/cycle_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/duplicate_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/future_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/menstruation_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/overlapping_cycle_exception.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/cycles/repositories/cycle_repository.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({
    this.isStartNewCycleFlow = false,
    this.focusTodayToken,
    super.key,
  });

  final bool isStartNewCycleFlow;
  final int? focusTodayToken;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const int _monthsBeforeEarliestCycle = 6;
  static const int _monthsAfterCurrent = 24;

  final ScrollController _monthScrollController = ScrollController();
  bool _positionedAtCurrentMonth = false;
  bool _forceRecenterOnBuild = false;
  DateTime? _selectedDate;
  bool _isSavingCycle = false;

  @override
  void didUpdateWidget(covariant CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final enteringStartCycleFlow =
        !oldWidget.isStartNewCycleFlow && widget.isStartNewCycleFlow;
    final focusTokenChanged =
        oldWidget.focusTodayToken != widget.focusTodayToken &&
            widget.focusTodayToken != null;

    if (enteringStartCycleFlow || focusTokenChanged) {
      _positionedAtCurrentMonth = false;
      _forceRecenterOnBuild = true;
      _selectedDate = null;
    }
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cyclesAsync = ref.watch(cyclesProvider);
    final profileAsync = ref.watch(profileSettingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          if (widget.isStartNewCycleFlow)
            TextButton(
              onPressed: _isSavingCycle ? null : _cancelStartNewCycle,
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: cyclesAsync.when(
            data: (cycles) {
              if (!widget.isStartNewCycleFlow) {
                return _buildCalendarContent(
                  theme,
                  cycles,
                  profileCycleLength: null,
                  profileMenstruationLength: null,
                );
              }

              return profileAsync.when(
                data: (settings) => _buildCalendarContent(
                  theme,
                  cycles,
                  profileCycleLength: settings.averageCycleLength,
                  profileMenstruationLength: settings.averageMenstruationLength,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Could not load profile settings: $error'),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Could not load calendar: $error'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarContent(
    ThemeData theme,
    List<CycleSummary> cycles, {
    required int? profileCycleLength,
    required int? profileMenstruationLength,
  }) {
    final phaseColors = theme.extension<CyclePhaseColors>();
    final now = DateTime.now();
    final nowMonth = DateTime(now.year, now.month);
    final earliestCycleMonth =
        CalendarViewUtils.earliestCycleMonth(cycles) ?? nowMonth;
    final firstMonth = DateTime(
      earliestCycleMonth.year,
      earliestCycleMonth.month - _monthsBeforeEarliestCycle,
    );
    final lastMonth =
        DateTime(nowMonth.year, nowMonth.month + _monthsAfterCurrent);
    final monthCount = (lastMonth.year - firstMonth.year) * 12 +
        (lastMonth.month - firstMonth.month) +
        1;
    final currentMonthIndex = (nowMonth.year - firstMonth.year) * 12 +
        (nowMonth.month - firstMonth.month);

    _ensureCurrentMonthInitialPosition(
      firstMonth: firstMonth,
      nowMonth: nowMonth,
      currentMonthIndex: currentMonthIndex,
      forceRecenter: _forceRecenterOnBuild,
    );

    return Column(
      children: [
        if (widget.isStartNewCycleFlow) ...[
          Text(
            'Select a start date for your new cycle.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Future dates are disabled. Existing cycle rules are applied when saving.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Selected: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
        ],
        const Row(
          children: [
            WeekdayLabel('Mon'),
            WeekdayLabel('Tue'),
            WeekdayLabel('Wed'),
            WeekdayLabel('Thu'),
            WeekdayLabel('Fri'),
            WeekdayLabel('Sat'),
            WeekdayLabel('Sun'),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            controller: _monthScrollController,
            physics: const SlowScrollPhysics(),
            itemCount: monthCount,
            itemBuilder: (context, index) {
              final month = DateTime(firstMonth.year, firstMonth.month + index);
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: CalendarMonthSection(
                  month: month,
                  cycles: cycles,
                  selectedDate:
                      widget.isStartNewCycleFlow ? _selectedDate : null,
                  onDatePressed: (date) {
                    if (widget.isStartNewCycleFlow) {
                      setState(() {
                        _selectedDate = DateUtils.dateOnly(date);
                      });
                      return;
                    }
                    context.push(AppRoutePaths.calendarDateDetailsFor(date));
                  },
                ),
              );
            },
          ),
        ),
        if (widget.isStartNewCycleFlow) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSavingCycle ? null : _cancelStartNewCycle,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isSavingCycle
                      ? null
                      : () => _startNewCycle(
                            cycles: cycles,
                            profileCycleLength: profileCycleLength,
                            profileMenstruationLength:
                                profileMenstruationLength,
                          ),
                  child: _isSavingCycle
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Start new cycle'),
                ),
              ),
            ],
          ),
        ],
        if (!widget.isStartNewCycleFlow)
          _buildLegend(theme, phaseColors)
        else
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildLegend(theme, phaseColors),
          ),
      ],
    );
  }

  Widget _buildLegend(ThemeData theme, CyclePhaseColors? phaseColors) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        CalendarLegendItem(
          color: Colors.red.withValues(alpha: 0.18),
          label: 'Menstruation days',
        ),
        CalendarLegendItem(
          color: (phaseColors?.ovulation ?? theme.colorScheme.secondary)
              .withValues(alpha: 0.14),
          label: 'Fertile window',
        ),
        CalendarLegendItem(
          color: (phaseColors?.ovulation ?? theme.colorScheme.secondary)
              .withValues(alpha: 0.28),
          label: 'Ovulation day',
        ),
        CalendarLegendItem(
          color: theme.colorScheme.primary.withValues(alpha: 0.22),
          label: 'Today',
          outlined: true,
        ),
      ],
    );
  }

  void _cancelStartNewCycle() {
    setState(() => _selectedDate = null);
    context.go(AppRoutePaths.calendar);
  }

  Future<void> _startNewCycle({
    required List<CycleSummary> cycles,
    required int? profileCycleLength,
    required int? profileMenstruationLength,
  }) async {
    final selectedDate = _selectedDate;
    if (selectedDate == null) {
      _showMessage('Please select a start date first.');
      return;
    }

    final latestCycle = cycles.isNotEmpty ? cycles.first : null;
    final cycleLength = profileCycleLength ?? latestCycle?.cycleLength;
    final menstruationLength =
        profileMenstruationLength ?? latestCycle?.menstruationLength;

    if (cycleLength == null || menstruationLength == null) {
      _showMessage(
        'Missing cycle settings. Please complete onboarding or profile settings first.',
      );
      return;
    }

    setState(() => _isSavingCycle = true);
    try {
      await ref.read(cycleRepositoryProvider).addCycle(
            startDate: selectedDate,
            cycleLength: cycleLength,
            menstruationLength: menstruationLength,
          );

      if (!mounted) {
        return;
      }

      _showMessage('New cycle started successfully.');
      context.go(AppRoutePaths.calendar);
    } on FutureCycleException catch (error) {
      _showMessage(error.message);
    } on CycleLengthException catch (error) {
      _showMessage(error.message);
    } on MenstruationLengthException catch (error) {
      _showMessage(error.message);
    } on DuplicateCycleException catch (error) {
      _showMessage(error.message);
    } on OverlappingCycleException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Could not create cycle: $error');
    } finally {
      if (mounted) {
        setState(() => _isSavingCycle = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _ensureCurrentMonthInitialPosition({
    required DateTime firstMonth,
    required DateTime nowMonth,
    required int currentMonthIndex,
    required bool forceRecenter,
  }) {
    if (_positionedAtCurrentMonth && !forceRecenter) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_monthScrollController.hasClients) {
        return;
      }

      final targetOffset = _estimateOffsetToMonthIndex(
        firstMonth: firstMonth,
        monthIndex: currentMonthIndex,
      );
      final currentMonthSectionHeight =
          CalendarViewUtils.estimateMonthSectionHeight(nowMonth);
      final viewport = _monthScrollController.position.viewportDimension;
      final centeredOffset =
          targetOffset - ((viewport - currentMonthSectionHeight) / 2);

      final maxOffset = _monthScrollController.position.maxScrollExtent;
      _monthScrollController.jumpTo(centeredOffset.clamp(0, maxOffset));
      _positionedAtCurrentMonth = true;
      _forceRecenterOnBuild = false;
    });
  }

  double _estimateOffsetToMonthIndex({
    required DateTime firstMonth,
    required int monthIndex,
  }) {
    var offset = 0.0;

    for (var i = 0; i < monthIndex; i++) {
      final month = DateTime(firstMonth.year, firstMonth.month + i);
      offset += CalendarViewUtils.estimateMonthSectionHeight(month);
    }

    return offset;
  }
}
