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
    final l10n = AppLocalizations.of(context);
    final legendOverlayHeight = _isLegendVisible ? 108.0 : 0.0;
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
          if (widget.isEditCurrentCycleFlow)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.editCycleInstruction,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              widget.isStartNewCycleFlow
                  ? l10n.selectNewCycleStartDate
                  : l10n.selectNoteDate,
              style: theme.textTheme.titleMedium,
            ),
          if (!widget.isEditCurrentCycleFlow) ...[
            const SizedBox(height: 8),
            Text(
              widget.isStartNewCycleFlow
                  ? l10n.newCycleDateRules
                  : l10n.noteDateRules,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          if (_selectedDate != null && !widget.isEditCurrentCycleFlow)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.selectedDate(_formatRouteDate(_selectedDate!)),
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
                key: const PageStorageKey<String>('calendar-month-list'),
                controller: _monthScrollController,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(bottom: legendOverlayHeight + 8),
                scrollCacheExtent: const ScrollCacheExtent.pixels(300),
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
                      selectedDate: widget.isStartNewCycleFlow
                          ? _selectedDate
                          : null,
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
              if (_isLegendVisible)
                const Positioned(
                  left: 16,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CalendarLegendCard(),
                  ),
                ),
              if (_isCenteringMonth)
                Positioned.fill(
                  child: ColoredBox(color: theme.scaffoldBackgroundColor),
                ),
            ],
          ),
        ),
        if (isCycleDateFlow) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSavingCycle ? null : _cancelStartNewCycle,
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: widget.isEditCurrentCycleFlow
                        ? FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC857),
                            foregroundColor: const Color(0xFF171820),
                          )
                        : null,
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
                                ? l10n.saveChanges
                                : l10n.startNewCycle,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
