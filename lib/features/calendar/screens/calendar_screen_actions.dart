part of 'calendar_screen.dart';

extension _CalendarScreenActions on _CalendarScreenState {
  void _cancelStartNewCycle() {
    _cancelCalendarFlow();
  }

  void _cancelCalendarFlow() {
    _clearCalendarFlowState();
    context.go(AppRoutePaths.calendar);
  }

  Future<void> _saveNote() async {
    final notesEnabled = ref.read(settingsProvider).maybeWhen(
          data: (settings) => settings.notesEnabled,
          orElse: () => true,
        );
    if (!notesEnabled) {
      _showMessage('Notes are disabled in Settings.');
      return;
    }

    final selectedDate = _selectedDate;
    final content = _noteController.text.trim();
    if (selectedDate == null) {
      _showMessage('Please select a date first.');
      return;
    }
    if (content.isEmpty) {
      _showMessage('Write a note before saving.');
      return;
    }

    _setSavingNote(true);
    try {
      await ref.read(noteRepositoryProvider).addNote(
            date: selectedDate,
            content: content,
          );
      ref.read(autoSyncProvider).queueSync();

      if (!mounted) {
        return;
      }

      _showMessage('Note saved.');
      _noteController.clear();
      _focusDateAfterFlow(selectedDate);
      context.go(
        '${AppRoutePaths.calendar}?focusDate=${_formatRouteDate(selectedDate)}',
      );
    } on DuplicateNoteDateException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Could not save note: $error');
    } finally {
      if (mounted) {
        _setSavingNote(false);
      }
    }
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

    _setSavingCycle(true);
    try {
      await ref.read(cycleRepositoryProvider).addCycle(
            startDate: selectedDate,
            cycleLength: cycleLength,
            menstruationLength: menstruationLength,
          );
      ref.read(autoSyncProvider).queueSync();

      if (!mounted) {
        return;
      }

      _showMessage('New cycle started successfully.');
      _focusDateAfterFlow(selectedDate);
      context.go(
        '${AppRoutePaths.calendar}?focusDate=${_formatRouteDate(selectedDate)}',
      );
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
        _setSavingCycle(false);
      }
    }
  }

  Future<void> _updateCurrentCycle({
    required List<CycleSummary> cycles,
  }) async {
    final selectedDate = _selectedDate;
    if (selectedDate == null) {
      _showMessage('Please select a start date first.');
      return;
    }

    final currentCycle = _editedCycleId == null
        ? (cycles.isNotEmpty ? cycles.first : null)
        : cycles.cast<CycleSummary?>().firstWhere(
              (cycle) => cycle?.id == _editedCycleId,
              orElse: () => null,
            );
    final cycleLength = currentCycle?.cycleLength;
    final menstruationLength =
        _editedMenstruationLength ?? currentCycle?.menstruationLength;

    if (currentCycle == null ||
        cycleLength == null ||
        menstruationLength == null) {
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
      ref.read(autoSyncProvider).queueSync();

      if (!mounted) {
        return;
      }

      _showMessage('Current cycle updated.');
      _focusDateAfterFlow(selectedDate);
      context.go(
        '${AppRoutePaths.calendar}?focusDate=${_formatRouteDate(selectedDate)}',
      );
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
      _showMessage('Could not update cycle: $error');
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
    final menstruationLength =
        currentCycle?.id == _editedCycleId
            ? _editedMenstruationLength ?? currentCycle?.menstruationLength
            : currentCycle?.menstruationLength;

    if (currentCycle == null ||
        cycleLength == null ||
        menstruationLength == null) {
      _showMessage('No current cycle is available to edit.');
      return;
    }

    final startDate = DateUtils.dateOnly(
      currentCycle.id == _editedCycleId
          ? _selectedDate ?? currentCycle.startDate
          : currentCycle.startDate,
    );
    final dayOffset = selectedDate.difference(startDate).inDays;
    final lastPeriodOffset = menstruationLength - 1;

    if (dayOffset == -1) {
      _setEditedCycle(
        cycleId: currentCycle.id,
        startDate: selectedDate,
        menstruationLength: menstruationLength + 1,
      );
      return;
    }

    if (dayOffset == 0) {
      if (menstruationLength == 1) {
        _showMessage('The period must have at least one day.');
        return;
      }

      _setEditedCycle(
        cycleId: currentCycle.id,
        startDate: startDate.add(const Duration(days: 1)),
        menstruationLength: menstruationLength - 1,
      );
      return;
    }

    if (dayOffset == lastPeriodOffset) {
      if (menstruationLength == 1) {
        _showMessage('The period must have at least one day.');
        return;
      }

      _setEditedCycle(
        cycleId: currentCycle.id,
        startDate: startDate,
        menstruationLength: menstruationLength - 1,
      );
      return;
    }

    if (dayOffset == menstruationLength) {
      if (dayOffset >= cycleLength || menstruationLength >= 14) {
        _showMessage('Period length must stay within the cycle and 14 days.');
        return;
      }

      _setEditedCycle(
        cycleId: currentCycle.id,
        startDate: startDate,
        menstruationLength: menstruationLength + 1,
      );
      return;
    }

    if (dayOffset < lastPeriodOffset && dayOffset > 0) {
      _showMessage('Only the first or last period day can be removed.');
      return;
    }

    if (dayOffset < -1 || dayOffset > menstruationLength) {
      _showMessage('Period length must stay within the cycle and 14 days.');
      return;
    }
  }

  CycleSummary? _editableCycleForDate(
    List<CycleSummary> cycles,
    DateTime date,
  ) {
    final selectedDate = DateUtils.dateOnly(date);

    if (_editedCycleId != null) {
      final editedCycle = cycles.cast<CycleSummary?>().firstWhere(
            (cycle) => cycle?.id == _editedCycleId,
            orElse: () => null,
          );
      if (editedCycle != null &&
          _isEditablePeriodBoundary(
            cycle: editedCycle,
            date: selectedDate,
            startDate: _selectedDate ?? editedCycle.startDate,
            menstruationLength:
                _editedMenstruationLength ?? editedCycle.menstruationLength,
          )) {
        return editedCycle;
      }
    }

    for (final cycle in cycles) {
      if (_isEditablePeriodBoundary(
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

  bool _isEditablePeriodBoundary({
    required CycleSummary cycle,
    required DateTime date,
    required DateTime startDate,
    required int? menstruationLength,
  }) {
    if (cycle.cycleLength == null || menstruationLength == null) {
      return false;
    }

    final start = DateUtils.dateOnly(startDate);
    final dayOffset = DateUtils.dateOnly(date).difference(start).inDays;
    return dayOffset == -1 ||
        dayOffset == 0 ||
        dayOffset == menstruationLength - 1 ||
        dayOffset == menstruationLength;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
