import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/features/calendar/utils/calendar_view_utils.dart';
import 'package:hera_app/features/calendar/widgets/calendar_legend_card.dart';
import 'package:hera_app/features/calendar/widgets/calendar_month_section.dart';
import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/cyclePrediction/providers/cycle_prediction_provider.dart';
import 'package:hera_app/features/cycles/exceptions/cycle_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/duplicate_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/future_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/menstruation_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/overlapping_cycle_exception.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/cycles/repositories/cycle_repository.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/providers/notes_provider.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/features/settings/providers/auto_sync_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';
import 'package:hera_app/shared/providers/shell_navigation_visibility_provider.dart';

part 'calendar_screen_actions.dart';
part 'calendar_screen_content.dart';
part 'calendar_screen_scroll.dart';

double? _lastCalendarScrollOffset;

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({
    this.isStartNewCycleFlow = false,
    this.isAddNoteFlow = false,
    this.isEditCurrentCycleFlow = false,
    this.focusTodayToken,
    this.focusAddNoteToken,
    this.focusDate,
    this.editScrollOffset,
    super.key,
  });

  final bool isStartNewCycleFlow;
  final bool isAddNoteFlow;
  final bool isEditCurrentCycleFlow;
  final int? focusTodayToken;
  final int? focusAddNoteToken;
  final DateTime? focusDate;
  final double? editScrollOffset;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const int _monthsBeforeEarliestCycle = 6;
  static const int _monthsAfterCurrent = 24;

  late final ScrollController _monthScrollController;
  final Map<String, CalendarPhaseDates> _phaseDatesByMonth = {};
  String? _phaseDatesCacheVersion;
  bool _isCenteringMonth = false;
  bool _positionedAtCurrentMonth = false;
  bool _forceRecenterOnBuild = false;
  double? _pendingScrollOffset;
  bool _isRestoringScrollOffset = false;
  DateTime? _selectedDate;
  DateTime? _pendingFocusDate;
  String? _editedCycleId;
  int? _editedMenstruationLength;
  bool _isSavingCycle = false;
  bool _isLegendVisible = true;

  @override
  void initState() {
    super.initState();
    final restoredEditScrollOffset =
        widget.editScrollOffset ?? _lastCalendarScrollOffset;
    _monthScrollController = ScrollController(
      initialScrollOffset: widget.isEditCurrentCycleFlow
          ? restoredEditScrollOffset ?? 0.0
          : 0.0,
    );
    _monthScrollController.addListener(() {
      if (_monthScrollController.hasClients) {
        _lastCalendarScrollOffset = _monthScrollController.offset;
      }
    });
    if (widget.isEditCurrentCycleFlow && restoredEditScrollOffset != null) {
      // PageStorage restores its own offset after the controller attaches.
      // Keep the routed offset pending so it wins over a stale saved position.
      _pendingScrollOffset = restoredEditScrollOffset;
    }
    _updateShellNavigationVisibility();

  }

  @override
  void didUpdateWidget(covariant CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateShellNavigationVisibility();

    final enteringStartCycleFlow =
        !oldWidget.isStartNewCycleFlow && widget.isStartNewCycleFlow;
    final enteringAddNoteFlow =
        !oldWidget.isAddNoteFlow && widget.isAddNoteFlow;
    final enteringEditCurrentCycleFlow =
        !oldWidget.isEditCurrentCycleFlow && widget.isEditCurrentCycleFlow;
    final exitingFlow =
        (oldWidget.isStartNewCycleFlow ||
                oldWidget.isAddNoteFlow ||
                oldWidget.isEditCurrentCycleFlow) &&
            !widget.isStartNewCycleFlow &&
            !widget.isAddNoteFlow &&
            !widget.isEditCurrentCycleFlow;
    final focusTokenChanged =
        oldWidget.focusTodayToken != widget.focusTodayToken &&
            widget.focusTodayToken != null;
    final addNoteFocusTokenChanged =
        oldWidget.focusAddNoteToken != widget.focusAddNoteToken &&
            widget.focusAddNoteToken != null;
    final focusDateChanged =
        oldWidget.focusDate != widget.focusDate && widget.focusDate != null;

    // Editing should keep the month the user was already viewing.  Only the
    // selected cycle date is needed for the edit form; it must not reposition
    // the calendar underneath it.
    if (enteringEditCurrentCycleFlow) {
      _editedCycleId = null;
      _editedMenstruationLength = null;
      // CalendarScreen is kept alive by the shell between navigations, so
      // initState does not run on a second edit attempt. Reapply the offset
      // supplied by the route after the list attaches, ahead of PageStorage.
      _pendingScrollOffset = widget.editScrollOffset ??
          (_monthScrollController.hasClients
              ? _monthScrollController.offset
              : _lastCalendarScrollOffset);
      _positionedAtCurrentMonth = false;
      _forceRecenterOnBuild = false;
    }

    final shouldRecenter =
        enteringStartCycleFlow ||
        enteringAddNoteFlow ||
        focusTokenChanged ||
        addNoteFocusTokenChanged ||
        (focusDateChanged && !enteringEditCurrentCycleFlow);

    if (shouldRecenter) {
      _positionedAtCurrentMonth = false;
      _forceRecenterOnBuild = true;
      _isCenteringMonth = focusTokenChanged || exitingFlow;
      if (exitingFlow && widget.editScrollOffset != null) {
        _pendingScrollOffset = widget.editScrollOffset;
        _forceRecenterOnBuild = false;
      }
      if (focusDateChanged) {
        _pendingFocusDate = widget.focusDate;
      }
      if (!exitingFlow) {
        _selectedDate = null;
      }
      if (exitingFlow) {
        _editedCycleId = null;
        _editedMenstruationLength = null;
      }
    }
  }

  @override
  void dispose() {
    ref.read(shellNavigationVisibleProvider.notifier).setVisible(true);
    _monthScrollController.dispose();
    super.dispose();
  }

  void _updateShellNavigationVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(shellNavigationVisibleProvider.notifier)
            .setVisible(!widget.isEditCurrentCycleFlow);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cyclesAsync = ref.watch(cyclesProvider);
    final profileAsync = ref.watch(profileSettingsProvider);
    final notesAsync = ref.watch(notesProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final notesEnabled = settingsAsync.maybeWhen(
      data: (settings) => settings.notesEnabled,
      orElse: () => true,
    );
    final forecastAsync = ref.watch(upcomingCycleForecastProvider);
    final notes = notesAsync.maybeWhen(
      data: (value) => notesEnabled ? value : const <Note>[],
      orElse: () => const <Note>[],
    );
    final theme = Theme.of(context);
    final isFlowActive = widget.isStartNewCycleFlow ||
        widget.isAddNoteFlow ||
        widget.isEditCurrentCycleFlow;
    final isBusy = _isSavingCycle;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const Text('Calendar'),
        actions: [
          if (isFlowActive && !widget.isEditCurrentCycleFlow)
            TextButton(
              onPressed: isBusy ? null : _cancelCalendarFlow,
              child: const Text('Cancel'),
            )
          else ...[
            IconButton(
              tooltip: 'View predictions',
              icon: const Icon(Icons.auto_graph_outlined),
              onPressed: () => context.push(AppRoutePaths.calendarPredictions),
            ),
            if (!widget.isEditCurrentCycleFlow)
              cyclesAsync.maybeWhen(
                data: (cycles) {
                  if (cycles.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return IconButton(
                    tooltip: 'Edit current cycle start date',
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () {
                      final scrollOffset = _lastCalendarScrollOffset ??
                          (_monthScrollController.hasClients
                              ? _monthScrollController.offset
                              : null);
                      final scrollQuery = scrollOffset == null
                          ? ''
                          : '&editScrollOffset=${scrollOffset.toStringAsFixed(1)}';
                      context.go(
                        '${AppRoutePaths.calendar}?editCurrentCycle=true$scrollQuery',
                      );
                    },
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
            IconButton(
              tooltip: _isLegendVisible
                  ? 'Hide calendar legend'
                  : 'Show calendar legend',
              icon: Icon(
                _isLegendVisible
                    ? Icons.info_rounded
                    : Icons.info_outline_rounded,
              ),
              onPressed: () {
                setState(() => _isLegendVisible = !_isLegendVisible);
              },
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: widget.isEditCurrentCycleFlow ? 0 : 16,
            bottom: 16,
          ),
          child: cyclesAsync.when(
            data: (cycles) {
              if (widget.isAddNoteFlow && !notesEnabled) {
                return const Center(
                  child: Text('Notes are disabled in Settings.'),
                );
              }

              if (widget.isAddNoteFlow) {
                return notesAsync.when(
                  data: (notes) => _buildCalendarContent(
                    theme,
                    cycles,
                    notes: notesEnabled ? notes : const <Note>[],
                    notesEnabled: notesEnabled,
                    profileCycleLength: null,
                    profileMenstruationLength: null,
                    forecast: forecastAsync.value,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Could not load notes: $error'),
                  ),
                );
              }

              if (widget.isEditCurrentCycleFlow) {
                return _buildCalendarContent(
                  theme,
                  cycles,
                  notes: notes,
                  notesEnabled: notesEnabled,
                  profileCycleLength: null,
                  profileMenstruationLength: null,
                  forecast: null,
                );
              }

              if (!widget.isStartNewCycleFlow) {
                return _buildCalendarContent(
                  theme,
                  cycles,
                  notes: notes,
                  notesEnabled: notesEnabled,
                  profileCycleLength: null,
                  profileMenstruationLength: null,
                  forecast: forecastAsync.value,
                );
              }

              return profileAsync.when(
                data: (settings) => _buildCalendarContent(
                  theme,
                  cycles,
                  notes: notes,
                  notesEnabled: notesEnabled,
                  profileCycleLength: settings.averageCycleLength,
                  profileMenstruationLength: settings.averageMenstruationLength,
                  forecast: null,
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

  void _setSelectedDate(DateTime? date) {
    setState(() => _selectedDate = date);
  }

  void _clearCalendarFlowState() {
    setState(() {
      _selectedDate = null;
      _editedCycleId = null;
      _editedMenstruationLength = null;
    });
  }

  void _setEditedCycle({
    required String cycleId,
    required DateTime startDate,
    required int menstruationLength,
  }) {
    setState(() {
      _editedCycleId = cycleId;
      _selectedDate = DateUtils.dateOnly(startDate);
      _editedMenstruationLength = menstruationLength;
    });
  }

  void _setSavingCycle(bool value) {
    setState(() => _isSavingCycle = value);
  }

  void _markCurrentMonthPositioned() {
    setState(() {
      _positionedAtCurrentMonth = true;
      _forceRecenterOnBuild = false;
      _pendingFocusDate = null;
      _isCenteringMonth = false;
    });
  }

  void _focusDateAfterFlow(DateTime date) {
    _pendingFocusDate = DateUtils.dateOnly(date);
    _positionedAtCurrentMonth = false;
    _forceRecenterOnBuild = true;
  }

  CalendarPhaseDates _phaseDatesForMonth({
    required List<CycleSummary> cycles,
    required DateTime month,
    required CycleForecast? forecast,
  }) {
    _preparePhaseDatesCache(cycles: cycles, forecast: forecast);

    final monthKey = '${month.year}-${month.month}';
    return _phaseDatesByMonth.putIfAbsent(
      monthKey,
      () => CalendarViewUtils.phaseDatesForMonth(
        cycles,
        month,
        forecast: forecast,
      ),
    );
  }

  void _precachePhaseDates({
    required List<CycleSummary> cycles,
    required CycleForecast? forecast,
    required DateTime firstMonth,
    required int monthCount,
  }) {
    _preparePhaseDatesCache(cycles: cycles, forecast: forecast);

    for (var index = 0; index < monthCount; index++) {
      final month = DateTime(firstMonth.year, firstMonth.month + index);
      final monthKey = '${month.year}-${month.month}';
      _phaseDatesByMonth.putIfAbsent(
        monthKey,
        () => CalendarViewUtils.phaseDatesForMonth(
          cycles,
          month,
          forecast: forecast,
        ),
      );
    }
  }

  void _preparePhaseDatesCache({
    required List<CycleSummary> cycles,
    required CycleForecast? forecast,
  }) {
    final cacheVersion = [
      for (final cycle in cycles)
        '${cycle.id}:${cycle.startDate.toIso8601String()}:'
            '${cycle.cycleLength}:${cycle.menstruationLength}',
      if (forecast != null)
        '${forecast.cycleLength}:${forecast.ovulationDay}:'
            '${forecast.menstruationLength}',
    ].join('|');

    if (_phaseDatesCacheVersion != cacheVersion) {
      _phaseDatesByMonth.clear();
      _phaseDatesCacheVersion = cacheVersion;
    }
  }
}

String _formatRouteDate(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}
