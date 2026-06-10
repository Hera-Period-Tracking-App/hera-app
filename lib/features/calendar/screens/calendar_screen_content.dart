part of 'calendar_screen.dart';

extension _CalendarScreenContent on _CalendarScreenState {
  Widget _buildCalendarContent(
    ThemeData theme,
    List<CycleSummary> cycles, {
    required int? profileCycleLength,
    required int? profileMenstruationLength,
  }) {
    const double legendOverlayHeight = 108;
    final now = DateTime.now();
    final nowMonth = DateTime(now.year, now.month);
    final earliestCycleMonth =
        CalendarViewUtils.earliestCycleMonth(cycles) ?? nowMonth;
    final firstMonth = DateTime(
      earliestCycleMonth.year,
      earliestCycleMonth.month - _CalendarScreenState._monthsBeforeEarliestCycle,
    );
    final lastMonth = DateTime(
      nowMonth.year,
      nowMonth.month + _CalendarScreenState._monthsAfterCurrent,
    );
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
          child: Stack(
            children: [
              ListView.builder(
                controller: _monthScrollController,
                physics: const SlowScrollPhysics(),
                padding: const EdgeInsets.only(bottom: legendOverlayHeight + 8),
                itemCount: monthCount,
                itemBuilder: (context, index) {
                  final month = DateTime(firstMonth.year, firstMonth.month + index);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: CalendarMonthSection(
                      month: month,
                      cycles: cycles,
                      selectedDate: widget.isStartNewCycleFlow ? _selectedDate : null,
                      onDatePressed: (date) {
                        if (widget.isStartNewCycleFlow) {
                          _updateSelectedDate(DateUtils.dateOnly(date));
                          return;
                        }
                        context.push(AppRoutePaths.calendarDateDetailsFor(date));
                      },
                    ),
                  );
                },
              ),
              const Positioned(
                left: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CalendarLegendCard(),
                ),
              ),
            ],
          ),
        ),
        if (widget.isStartNewCycleFlow) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSavingCycle
                  ? null
                  : () => _startNewCycle(
                        cycles: cycles,
                        profileCycleLength: profileCycleLength,
                        profileMenstruationLength: profileMenstruationLength,
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
      ],
    );
  }
}
