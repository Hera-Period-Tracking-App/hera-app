import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/calendar/utils/calendar_view_utils.dart';
import 'package:hera_app/features/calendar/widgets/calendar_month_section.dart';
import 'package:hera_app/features/calendar/widgets/slow_scroll_physics.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const int _monthsBeforeEarliestCycle = 6;
  static const int _monthsAfterCurrent = 24;

  final ScrollController _monthScrollController = ScrollController();
  bool _positionedAtCurrentMonth = false;

  @override
  void dispose() {
    _monthScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cyclesAsync = ref.watch(cyclesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: cyclesAsync.when(
            data: (cycles) => _buildCalendarContent(theme, cycles),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Could not load calendar: $error'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarContent(ThemeData theme, List<CycleSummary> cycles) {
    final now = DateTime.now();
    final nowMonth = DateTime(now.year, now.month);
    final earliestCycleMonth = CalendarViewUtils.earliestCycleMonth(cycles) ?? nowMonth;
    final firstMonth = DateTime(
      earliestCycleMonth.year,
      earliestCycleMonth.month - _monthsBeforeEarliestCycle,
    );
    final lastMonth = DateTime(nowMonth.year, nowMonth.month + _monthsAfterCurrent);
    final monthCount =
        (lastMonth.year - firstMonth.year) * 12 +
        (lastMonth.month - firstMonth.month) +
        1;
    final currentMonthIndex =
        (nowMonth.year - firstMonth.year) * 12 + (nowMonth.month - firstMonth.month);

    _ensureCurrentMonthInitialPosition(
      firstMonth: firstMonth,
      nowMonth: nowMonth,
      currentMonthIndex: currentMonthIndex,
    );

    return Column(
      children: [
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
                ),
              );
            },
          ),
        ),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            CalendarLegendItem(
              color: Colors.red.withValues(alpha: 0.18),
              label: 'Menstruation days',
            ),
            CalendarLegendItem(
              color: theme.colorScheme.primary.withValues(alpha: 0.22),
              label: 'Cycle start',
              outlined: true,
            ),
          ],
        ),
      ],
    );
  }

  void _ensureCurrentMonthInitialPosition({
    required DateTime firstMonth,
    required DateTime nowMonth,
    required int currentMonthIndex,
  }) {
    if (_positionedAtCurrentMonth) {
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
      final centeredOffset = targetOffset - ((viewport - currentMonthSectionHeight) / 2);

      final maxOffset = _monthScrollController.position.maxScrollExtent;
      _monthScrollController.jumpTo(centeredOffset.clamp(0, maxOffset));
      _positionedAtCurrentMonth = true;
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
