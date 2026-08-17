part of 'calendar_screen.dart';

extension _CalendarScreenActions on _CalendarScreenState {
  void _cancelCalendarFlow() {
    _clearCalendarFlowState();
    final focusToday = DateTime.now().millisecondsSinceEpoch;
    context.go('${AppRoutePaths.calendar}?focusToday=$focusToday');
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
    final menstruationLength = profileMenstruationLength ?? latestCycle?.menstruationLength;

    if (cycleLength == null || menstruationLength == null) {
      _showMessage(
        'Missing cycle settings. Please complete onboarding or profile settings first.',
      );
      return;
    }

    _setSavingCycle(true);
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
      _focusDateAfterFlow(selectedDate);
      context.go(
        '${AppRoutePaths.calendar}?focusDate=${DateTimeFormatter.toIsoDate(selectedDate)}',
      );
    } catch (error) {
      _showMessage(_cycleErrorMessage(error, 'Could not create cycle'));
    } finally {
      if (mounted) {
        _setSavingCycle(false);
      }
    }
  }

  Future<void> _updateCurrentCycle({
    required List<CycleSummary> cycles,
  }) async {
    final currentCycle = currentOrEditedCycle(cycles, _editedCycleId);
    final selectedDate = _selectedDate ?? currentCycle?.startDate;
    final cycleLength = currentCycle?.cycleLength;
    final menstruationLength = _editedMenstruationLength ?? currentCycle?.menstruationLength;

    if (currentCycle == null || selectedDate == null || cycleLength == null || menstruationLength == null) {
      _showMessage('No current cycle is available to edit.');
      return;
    }

    _setSavingCycle(true);
    try {
      await ref.read(cycleRepositoryProvider).updateCycle(
            id: currentCycle.id,
            startDate: selectedDate,
            cycleLength: cycleLength,
            menstruationLength: menstruationLength,
          );

      if (!mounted) {
        return;
      }

      _showCycleUpdatedFeedback();
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) {
        return;
      }
      final scrollOffset =
          _monthScrollController.hasClients ? _monthScrollController.offset : _lastCalendarScrollOffset;
      final scrollQuery = scrollOffset == null ? '' : '&editScrollOffset=${scrollOffset.toStringAsFixed(1)}';
      context.go(
        '${AppRoutePaths.calendar}?focusDate=${DateTimeFormatter.toIsoDate(selectedDate)}$scrollQuery',
      );
    } catch (error) {
      _showMessage(_cycleErrorMessage(error, 'Could not update cycle'));
    } finally {
      if (mounted) {
        _setSavingCycle(false);
      }
    }
  }

  void _toggleCurrentPeriodDay({
    required List<CycleSummary> cycles,
    required DateTime date,
  }) {
    final selectedDate = DateUtils.dateOnly(date);
    final currentCycle = _editableCycleForDate(cycles, selectedDate);
    final cycleLength = currentCycle?.cycleLength;
    final menstruationLength = currentCycle?.id == _editedCycleId
        ? _editedMenstruationLength ?? currentCycle?.menstruationLength
        : currentCycle?.menstruationLength;

    if (currentCycle == null || cycleLength == null || menstruationLength == null) {
      _showMessage('No current cycle is available to edit.');
      return;
    }

    final startDate = DateUtils.dateOnly(
      currentCycle.id == _editedCycleId ? _selectedDate ?? currentCycle.startDate : currentCycle.startDate,
    );
    final result = editPeriodBoundary(
      selectedDate: selectedDate,
      startDate: startDate,
      cycleLength: cycleLength,
      menstruationLength: menstruationLength,
    );
    switch (result) {
      case UpdatedPeriodBoundary(
          :final startDate,
          :final menstruationLength,
        ):
        _setEditedCycle(
          cycleId: currentCycle.id,
          startDate: startDate,
          menstruationLength: menstruationLength,
        );
      case InvalidPeriodBoundaryEdit(:final message):
        _showMessage(message);
    }
  }

  CycleSummary? _editableCycleForDate(
    List<CycleSummary> cycles,
    DateTime date,
  ) {
    final selectedDate = DateUtils.dateOnly(date);

    if (_editedCycleId != null) {
      final editedCycle = findCycleById(cycles, _editedCycleId);
      if (editedCycle != null &&
          isEditablePeriodBoundary(
            cycle: editedCycle,
            date: selectedDate,
            startDate: _selectedDate ?? editedCycle.startDate,
            menstruationLength: _editedMenstruationLength ?? editedCycle.menstruationLength,
          )) {
        return editedCycle;
      }
    }

    for (final cycle in cycles) {
      if (isEditablePeriodBoundary(
        cycle: cycle,
        date: selectedDate,
        startDate: cycle.startDate,
        menstruationLength: cycle.menstruationLength,
      )) {
        return cycle;
      }
    }

    return null;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.twilight,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  String _cycleErrorMessage(Object error, String fallback) {
    return switch (error) {
      FutureCycleException() => error.message,
      CycleLengthException() => error.message,
      MenstruationLengthException() => error.message,
      DuplicateCycleException() => error.message,
      OverlappingCycleException() => error.message,
      _ => '$fallback: $error',
    };
  }

  void _showCycleUpdatedFeedback() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
          backgroundColor: AppColors.twilight,
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFFFFC857),
              ),
              const SizedBox(width: 10),
              Text(
                'Cycle updated!',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      );
  }
}
