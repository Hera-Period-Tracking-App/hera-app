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
    final isFlowActive = widget.isStartNewCycleFlow || widget.isAddNoteFlow || widget.isEditCurrentCycleFlow;
    final isCycleDateFlow = widget.isStartNewCycleFlow || widget.isEditCurrentCycleFlow;
    final viewData = CalendarViewData.create(
        cycles: cycles,
        notes: notes,
        notesEnabled: notesEnabled,
        focusDate: _pendingFocusDate ?? widget.focusDate,
        isEditingCycle: widget.isEditCurrentCycleFlow,
        editedCycleId: _editedCycleId,
        editedStartDate: _selectedDate,
        editedMenstruationLength: _editedMenstruationLength,
        monthsBeforeEarliestCycle: _CalendarScreenState._monthsBeforeEarliestCycle,
        monthsAfterCurrent: _CalendarScreenState._monthsAfterCurrent);
    _precachePhaseDates(
      cycles: viewData.cycles,
      forecast: forecast,
      firstMonth: viewData.firstMonth,
      monthCount: viewData.monthCount,
    );

    _ensureCurrentMonthInitialPosition(
      firstMonth: viewData.firstMonth,
      focusedMonth: viewData.focusedMonth,
      focusedMonthIndex: viewData.focusedMonthIndex,
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
              widget.isStartNewCycleFlow ? l10n.selectNewCycleStartDate : l10n.selectNoteDate,
              style: theme.textTheme.titleMedium,
            ),
          if (!widget.isEditCurrentCycleFlow) ...[
            const SizedBox(height: 8),
            Text(
              widget.isStartNewCycleFlow ? l10n.newCycleDateRules : l10n.noteDateRules,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          if (_selectedDate != null && !widget.isEditCurrentCycleFlow)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.selectedDate(DateTimeFormatter.toIsoDate(_selectedDate!)),
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
                itemCount: viewData.monthCount,
                itemBuilder: (context, index) {
                  final month = DateTime(
                    viewData.firstMonth.year,
                    viewData.firstMonth.month + index,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: CalendarMonthSection(
                      month: month,
                      phaseDates: _phaseDatesForMonth(
                        cycles: viewData.cycles,
                        month: month,
                        forecast: forecast,
                      ),
                      cycles: viewData.cycles,
                      noteDateKeys: viewData.noteDateKeys,
                      selectedDate: widget.isStartNewCycleFlow ? _selectedDate : null,
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
                    onPressed: _isSavingCycle ? null : _cancelCalendarFlow,
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
                                  profileMenstruationLength: profileMenstruationLength,
                                ),
                    child: _isSavingCycle
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.isEditCurrentCycleFlow ? l10n.saveChanges : l10n.startNewCycle,
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
