part of 'calendar_screen.dart';

extension _CalendarScreenContent on _CalendarScreenState {
  Widget _buildCalendarContent(
    ThemeData theme,
    List<CycleSummary> cycles, {
    required List<Note> notes,
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
      earliestCycleMonth.month -
          _CalendarScreenState._monthsBeforeEarliestCycle,
    );
    final lastMonth =
        DateTime(nowMonth.year, nowMonth.month + _CalendarScreenState._monthsAfterCurrent);
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
    final hasExistingNoteForSelectedDate = _selectedDate != null &&
        notes.any((note) => DateUtils.isSameDay(note.date, _selectedDate));
    final noteDateKeys =
        notes.map((note) => CalendarViewUtils.dateKey(note.date)).toSet();
    final isFlowActive = widget.isStartNewCycleFlow || widget.isAddNoteFlow;

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
            widget.isStartNewCycleFlow
                ? 'Select a start date for your new cycle.'
                : 'Select a date for your note.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.isStartNewCycleFlow
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
                  noteDateKeys: noteDateKeys,
                  selectedDate: isFlowActive ? _selectedDate : null,
                  onDatePressed: (date) {
                    if (isFlowActive) {
                      _setSelectedDate(DateUtils.dateOnly(date));
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
        if (widget.isAddNoteFlow) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Write a private note...',
              errorText: hasExistingNoteForSelectedDate
                  ? 'A note already exists for this date.'
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSavingNote ? null : _cancelCalendarFlow,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isSavingNote || hasExistingNoteForSelectedDate
                      ? null
                      : _saveNote,
                  child: _isSavingNote
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save note'),
                ),
              ),
            ],
          ),
        ],
        if (!isFlowActive)
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
}
