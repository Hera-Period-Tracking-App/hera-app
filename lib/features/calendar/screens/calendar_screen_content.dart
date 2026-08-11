part of 'calendar_screen.dart';

extension _CalendarScreenContent on _CalendarScreenState {
  Widget _buildCalendarContent(
    ThemeData theme,
    List<CycleSummary> cycles, {
    required List<Note> notes,
    required bool notesEnabled,
    required int? profileCycleLength,
    required int? profileMenstruationLength,
    required CycleForecast? forecast,
  }) {
    const double legendOverlayHeight = 108;
    final now = DateTime.now();
    final nowMonth = DateTime(now.year, now.month);
    final earliestCycleMonth =
        CalendarViewUtils.earliestCycleMonth(cycles) ?? nowMonth;
    final firstMonth = DateTime(
      earliestCycleMonth.year,
      earliestCycleMonth.month -
          _CalendarScreenState._monthsBeforeEarliestCycle,
    );
    final lastMonth = DateTime(
      nowMonth.year,
      nowMonth.month + _CalendarScreenState._monthsAfterCurrent,
    );
    final monthCount = (lastMonth.year - firstMonth.year) * 12 +
        (lastMonth.month - firstMonth.month) +
        1;
    final targetFocusDate = _pendingFocusDate ?? widget.focusDate;
    final focusedMonth = targetFocusDate == null
        ? nowMonth
        : DateTime(targetFocusDate.year, targetFocusDate.month);
    final focusedMonthIndex = (focusedMonth.year - firstMonth.year) * 12 +
        (focusedMonth.month - firstMonth.month);
    final safeFocusedMonthIndex = focusedMonthIndex.clamp(0, monthCount - 1);
    final safeFocusedMonth = DateTime(
      firstMonth.year,
      firstMonth.month + safeFocusedMonthIndex,
    );
    final noteDateKeys = notesEnabled
        ? notes.map((note) => CalendarViewUtils.dateKey(note.date)).toSet()
        : const <String>{};
    final isFlowActive = widget.isStartNewCycleFlow ||
        widget.isAddNoteFlow ||
        widget.isEditCurrentCycleFlow;
    final isCycleDateFlow =
        widget.isStartNewCycleFlow || widget.isEditCurrentCycleFlow;
    final editedCycle = _editedCycleId == null
        ? null
        : cycles.cast<CycleSummary?>().firstWhere(
              (cycle) => cycle?.id == _editedCycleId,
              orElse: () => null,
            );
    final editedCycles = widget.isEditCurrentCycleFlow && editedCycle != null
        ? cycles
            .map(
              (cycle) => cycle.id == editedCycle.id
                  ? CycleSummary(
                      id: cycle.id,
                      startDate: _selectedDate ?? cycle.startDate,
                      cycleLength: cycle.cycleLength,
                      menstruationLength:
                          _editedMenstruationLength ?? cycle.menstruationLength,
                    )
                  : cycle,
            )
            .toList(growable: false)
        : cycles;
    final editedMenstruationLength =
        _editedMenstruationLength ?? editedCycle?.menstruationLength;

    _precachePhaseDates(
      cycles: editedCycles,
      forecast: forecast,
      firstMonth: firstMonth,
      monthCount: monthCount,
    );

    _ensureCurrentMonthInitialPosition(
      firstMonth: firstMonth,
      focusedMonth: safeFocusedMonth,
      focusedMonthIndex: safeFocusedMonthIndex,
      forceRecenter: _forceRecenterOnBuild,
    );

    return Column(
      children: [
        if (isFlowActive) ...[
          Text(
            widget.isEditCurrentCycleFlow
                ? 'Tap period days to edit your current period.'
                : widget.isStartNewCycleFlow
                ? 'Select a start date for your new cycle.'
                : 'Select a date for your note.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.isEditCurrentCycleFlow
                ? 'Tap the day before or after your period to add one day. Tap the first or last period day to remove one day.'
                : widget.isStartNewCycleFlow
                ? 'Future dates are disabled. Existing cycle rules are applied when saving.'
                : 'Each date can have one note.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.isEditCurrentCycleFlow
                    ? 'Editing period: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}${editedMenstruationLength == null ? '' : ' - $editedMenstruationLength days'}'
                    : 'Selected: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
        ],
        const Row(
          children: [
            WeekdayLabel('S'),
            WeekdayLabel('M'),
            WeekdayLabel('T'),
            WeekdayLabel('W'),
            WeekdayLabel('T'),
            WeekdayLabel('F'),
            WeekdayLabel('S'),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                controller: _monthScrollController,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: legendOverlayHeight + 8),
                cacheExtent: 300,
                itemCount: monthCount,
                itemBuilder: (context, index) {
                  final month = DateTime(firstMonth.year, firstMonth.month + index);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: CalendarMonthSection(
                      month: month,
                      phaseDates: _phaseDatesForMonth(
                        cycles: editedCycles,
                        month: month,
                        forecast: forecast,
                      ),
                      noteDateKeys: noteDateKeys,
                      selectedDate: isFlowActive ? _selectedDate : null,
                      onDatePressed: (date) {
                        if (widget.isEditCurrentCycleFlow) {
                          _toggleCurrentPeriodDay(
                            cycles: cycles,
                            date: date,
                          );
                          return;
                        }
                        if (widget.isAddNoteFlow) {
                          context.push(AppRoutePaths.calendarAddNoteFor(date));
                          return;
                        }
                        if (isFlowActive) {
                          _setSelectedDate(DateUtils.dateOnly(date));
                          return;
                        }
                        if (notesEnabled) {
                          context.push(
                            AppRoutePaths.calendarDateDetailsFor(date),
                          );
                        }
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
        if (isCycleDateFlow) ...[
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
                      : widget.isEditCurrentCycleFlow
                          ? () => _updateCurrentCycle(cycles: cycles)
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
                      : Text(
                          widget.isEditCurrentCycleFlow
                              ? 'Save changes'
                              : 'Start new cycle',
                        ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
