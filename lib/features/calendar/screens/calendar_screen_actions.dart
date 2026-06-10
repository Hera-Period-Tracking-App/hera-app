part of 'calendar_screen.dart';

extension _CalendarScreenActions on _CalendarScreenState {
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
        _setSavingCycle(false);
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
}
