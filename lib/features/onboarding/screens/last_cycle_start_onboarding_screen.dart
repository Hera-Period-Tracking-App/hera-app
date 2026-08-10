import 'package:flutter/material.dart';

class LastCycleStartOnboardingScreen extends StatefulWidget {
  const LastCycleStartOnboardingScreen({
    super.key,
    required this.lastCycleStart,
    required this.onChanged,
  });

  final DateTime lastCycleStart;
  final ValueChanged<DateTime> onChanged;

  @override
  State<LastCycleStartOnboardingScreen> createState() =>
      _LastCycleStartOnboardingScreenState();
}

class _LastCycleStartOnboardingScreenState
    extends State<LastCycleStartOnboardingScreen> {
  DateTime? _visibleMonth;
  DateTime? _firstMonth;
  PageController? _monthPageController;

  @override
  void initState() {
    super.initState();
    _ensureCalendarInitialized();
  }

  void _ensureCalendarInitialized() {
    if (_firstMonth != null &&
        _visibleMonth != null &&
        _monthPageController != null) {
      return;
    }

    final now = DateTime.now();
    _firstMonth ??= DateTime(now.year - 3, now.month);
    final initialPage = _monthIndex(widget.lastCycleStart);
    _visibleMonth ??= DateTime(
      _firstMonth!.year,
      _firstMonth!.month + initialPage,
    );
    _monthPageController ??= PageController(initialPage: initialPage);
  }

  void _changeMonth(int offset) {
    _ensureCalendarInitialized();
    final targetPage = _monthIndex(_visibleMonth!) + offset;
    if (targetPage < 0 || targetPage > 36) {
      return;
    }
    _monthPageController!.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  int _monthIndex(DateTime date) =>
      (date.year - _firstMonth!.year) * 12 + date.month - _firstMonth!.month;

  void _onMonthChanged(int page) {
    setState(() {
      _visibleMonth = DateTime(_firstMonth!.year, _firstMonth!.month + page);
    });
  }

  void _selectDate(DateTime date) {
    widget.onChanged(date);
  }

  @override
  void dispose() {
    _monthPageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureCalendarInitialized();

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _CycleDateCalendar(
          visibleMonth: _visibleMonth!,
          firstMonth: _firstMonth!,
          monthPageController: _monthPageController!,
          selectedDate: widget.lastCycleStart,
          onPreviousMonth: () => _changeMonth(-1),
          onNextMonth: () => _changeMonth(1),
          onMonthChanged: _onMonthChanged,
          onSelected: _selectDate,
        ),
      ],
    );
  }
}

class _CycleDateCalendar extends StatelessWidget {
  const _CycleDateCalendar({
    required this.visibleMonth,
    required this.firstMonth,
    required this.monthPageController,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onMonthChanged,
    required this.onSelected,
  });

  final DateTime visibleMonth;
  final DateTime firstMonth;
  final PageController monthPageController;
  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = _dateOnly(DateTime.now());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Text(
                '${_monthName(visibleMonth.month)} ${visibleMonth.year}',
                style: theme.textTheme.titleMedium,
              ),
              IconButton(
                onPressed: visibleMonth.year == today.year &&
                        visibleMonth.month == today.month
                    ? null
                    : onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              _WeekdayLabel('S'),
              _WeekdayLabel('M'),
              _WeekdayLabel('T'),
              _WeekdayLabel('W'),
              _WeekdayLabel('T'),
              _WeekdayLabel('F'),
              _WeekdayLabel('S'),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: PageView.builder(
              controller: monthPageController,
              itemCount: 37,
              onPageChanged: onMonthChanged,
              itemBuilder: (context, index) => _MonthDateGrid(
                month: DateTime(firstMonth.year, firstMonth.month + index),
                selectedDate: selectedDate,
                onSelected: onSelected,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SELECTED DATE',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFFFC857),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(selectedDate),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthDateGrid extends StatelessWidget {
  const _MonthDateGrid({
    required this.month,
    required this.selectedDate,
    required this.onSelected,
  });

  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = _dateOnly(DateTime.now());
    final firstDay = DateTime(month.year, month.month);
    final leadingDays = firstDay.weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 42,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        if (index < leadingDays || index >= leadingDays + daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(month.year, month.month, index - leadingDays + 1);
        final isSelected = _sameDay(date, selectedDate);
        final isFuture = date.isAfter(today);

        return Material(
          color: isSelected ? const Color(0xFFFFC857) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: isFuture ? null : () => onSelected(date),
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: Text(
                '${date.day}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isFuture
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.25)
                      : isSelected
                          ? const Color(0xFF171820)
                          : null,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _sameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

String _monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month - 1];
}

String _formatDate(DateTime date) =>
    '${_monthName(date.month)} ${date.day}, ${date.year}';
