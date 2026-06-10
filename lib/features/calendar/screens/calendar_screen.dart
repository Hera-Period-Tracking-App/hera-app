import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/cycle_phase_colors.dart';
import 'package:hera_app/features/calendar/utils/calendar_view_utils.dart';
import 'package:hera_app/features/calendar/widgets/calendar_month_section.dart';
import 'package:hera_app/features/calendar/widgets/slow_scroll_physics.dart';
import 'package:hera_app/features/cycles/exceptions/cycle_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/duplicate_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/future_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/menstruation_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/overlapping_cycle_exception.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/cycles/repositories/cycle_repository.dart';
import 'package:hera_app/features/notes/exceptions/duplicate_note_date_exception.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/providers/notes_provider.dart';
import 'package:hera_app/features/notes/repositories/note_repository.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({
    this.isStartNewCycleFlow = false,
    this.isAddNoteFlow = false,
    this.focusTodayToken,
    this.focusAddNoteToken,
    this.focusDate,
    super.key,
  });

  final bool isStartNewCycleFlow;
  final bool isAddNoteFlow;
  final int? focusTodayToken;
  final int? focusAddNoteToken;
  final DateTime? focusDate;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const int _monthsBeforeEarliestCycle = 6;
  static const int _monthsAfterCurrent = 24;

  final ScrollController _monthScrollController = ScrollController();
  final TextEditingController _noteController = TextEditingController();
  bool _positionedAtCurrentMonth = false;
  bool _forceRecenterOnBuild = false;
  DateTime? _selectedDate;
  DateTime? _pendingFocusDate;
  bool _isSavingCycle = false;
  bool _isSavingNote = false;

  @override
  void didUpdateWidget(covariant CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final enteringStartCycleFlow =
        !oldWidget.isStartNewCycleFlow && widget.isStartNewCycleFlow;
    final enteringAddNoteFlow =
        !oldWidget.isAddNoteFlow && widget.isAddNoteFlow;
    final exitingFlow =
        (oldWidget.isStartNewCycleFlow || oldWidget.isAddNoteFlow) &&
            !widget.isStartNewCycleFlow &&
            !widget.isAddNoteFlow;
    final focusTokenChanged =
        oldWidget.focusTodayToken != widget.focusTodayToken &&
            widget.focusTodayToken != null;
    final addNoteFocusTokenChanged =
        oldWidget.focusAddNoteToken != widget.focusAddNoteToken &&
            widget.focusAddNoteToken != null;
    final focusDateChanged =
        oldWidget.focusDate != widget.focusDate && widget.focusDate != null;

    if (enteringStartCycleFlow ||
        enteringAddNoteFlow ||
        focusTokenChanged ||
        addNoteFocusTokenChanged ||
        focusDateChanged) {
      _positionedAtCurrentMonth = false;
      _forceRecenterOnBuild = true;
      if (focusDateChanged) {
        _pendingFocusDate = widget.focusDate;
      }
      if (!exitingFlow) {
        _selectedDate = null;
      }
      _noteController.clear();
    }
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cyclesAsync = ref.watch(cyclesProvider);
    final profileAsync = ref.watch(profileSettingsProvider);
    final notesAsync = ref.watch(notesProvider);
    final notes = notesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <Note>[],
    );
    final theme = Theme.of(context);
    final isFlowActive = widget.isStartNewCycleFlow || widget.isAddNoteFlow;
    final isBusy = _isSavingCycle || _isSavingNote;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          if (isFlowActive)
            TextButton(
              onPressed: isBusy ? null : _cancelCalendarFlow,
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: cyclesAsync.when(
            data: (cycles) {
              if (widget.isAddNoteFlow) {
                return notesAsync.when(
                  data: (notes) => _buildCalendarContent(
                    theme,
                    cycles,
                    notes: notes,
                    profileCycleLength: null,
                    profileMenstruationLength: null,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Could not load notes: $error'),
                  ),
                );
              }

              if (!widget.isStartNewCycleFlow) {
                return _buildCalendarContent(
                  theme,
                  cycles,
                  notes: notes,
                  profileCycleLength: null,
                  profileMenstruationLength: null,
                );
              }

              return profileAsync.when(
                data: (settings) => _buildCalendarContent(
                  theme,
                  cycles,
                  notes: notes,
                  profileCycleLength: settings.averageCycleLength,
                  profileMenstruationLength: settings.averageMenstruationLength,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Could not load profile settings: $error'),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Could not load calendar: $error'),
            ),
          ),
        ),
      ),
    );
  }

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
      earliestCycleMonth.month - _monthsBeforeEarliestCycle,
    );
    final lastMonth =
        DateTime(nowMonth.year, nowMonth.month + _monthsAfterCurrent);
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
                      setState(() {
                        _selectedDate = DateUtils.dateOnly(date);
                      });
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

  void _cancelStartNewCycle() {
    _cancelCalendarFlow();
  }

  void _cancelCalendarFlow() {
    setState(() => _selectedDate = null);
    _noteController.clear();
    context.go(AppRoutePaths.calendar);
  }

  Future<void> _saveNote() async {
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

    setState(() => _isSavingNote = true);
    try {
      await ref.read(noteRepositoryProvider).addNote(
            date: selectedDate,
            content: content,
          );

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
        setState(() => _isSavingNote = false);
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

    setState(() => _isSavingCycle = true);
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
        setState(() => _isSavingCycle = false);
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

  void _ensureCurrentMonthInitialPosition({
    required DateTime firstMonth,
    required DateTime focusedMonth,
    required int focusedMonthIndex,
    required bool forceRecenter,
  }) {
    if (_positionedAtCurrentMonth && !forceRecenter) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_monthScrollController.hasClients) {
        return;
      }

      final targetOffset = _estimateOffsetToMonthIndex(
        firstMonth: firstMonth,
        monthIndex: focusedMonthIndex,
      );
      final currentMonthSectionHeight =
          CalendarViewUtils.estimateMonthSectionHeight(focusedMonth);
      final viewport = _monthScrollController.position.viewportDimension;
      final centeredOffset =
          targetOffset - ((viewport - currentMonthSectionHeight) / 2);

      final maxOffset = _monthScrollController.position.maxScrollExtent;
      _monthScrollController.jumpTo(centeredOffset.clamp(0, maxOffset));
      _positionedAtCurrentMonth = true;
      _forceRecenterOnBuild = false;
      _pendingFocusDate = null;
    });
  }

  void _focusDateAfterFlow(DateTime date) {
    _pendingFocusDate = DateUtils.dateOnly(date);
    _positionedAtCurrentMonth = false;
    _forceRecenterOnBuild = true;
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

String _formatRouteDate(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}
