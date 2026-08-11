import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/calendar/utils/calendar_view_utils.dart';
import 'package:hera_app/features/calendar/widgets/calendar_legend_card.dart';
import 'package:hera_app/features/calendar/widgets/calendar_month_section.dart';
import 'package:hera_app/features/calendar/widgets/slow_scroll_physics.dart';
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
import 'package:hera_app/features/cycles/utils/cycle_phase_resolver.dart';
import 'package:hera_app/features/notes/exceptions/duplicate_note_date_exception.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/providers/notes_provider.dart';
import 'package:hera_app/features/notes/repositories/note_repository.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/features/settings/providers/auto_sync_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';

part 'calendar_screen_actions.dart';
part 'calendar_screen_content.dart';
part 'calendar_screen_scroll.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({
    this.isStartNewCycleFlow = false,
    this.isAddNoteFlow = false,
    this.isEditCurrentCycleFlow = false,
    this.focusTodayToken,
    this.focusAddNoteToken,
    this.focusDate,
    super.key,
  });

  final bool isStartNewCycleFlow;
  final bool isAddNoteFlow;
  final bool isEditCurrentCycleFlow;
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
  String? _editedCycleId;
  int? _editedMenstruationLength;
  bool _isSavingCycle = false;
  bool _isSavingNote = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEditCurrentCycleFlow && widget.focusDate != null) {
      _selectedDate = DateUtils.dateOnly(widget.focusDate!);
    }
  }

  @override
  void didUpdateWidget(covariant CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

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

    if (enteringStartCycleFlow ||
        enteringAddNoteFlow ||
        enteringEditCurrentCycleFlow ||
        focusTokenChanged ||
        addNoteFocusTokenChanged ||
        focusDateChanged) {
      _positionedAtCurrentMonth = false;
      _forceRecenterOnBuild = true;
      if (focusDateChanged) {
        _pendingFocusDate = widget.focusDate;
      }
      if (enteringEditCurrentCycleFlow && widget.focusDate != null) {
        _selectedDate = DateUtils.dateOnly(widget.focusDate!);
      } else if (!exitingFlow) {
        _selectedDate = null;
      }
      if (enteringEditCurrentCycleFlow || exitingFlow) {
        _editedCycleId = null;
        _editedMenstruationLength = null;
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
    final isBusy = _isSavingCycle || _isSavingNote;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          if (isFlowActive)
            TextButton(
              onPressed: isBusy ? null : _cancelCalendarFlow,
              child: const Text('Cancel'),
            )
          else
            cyclesAsync.maybeWhen(
              data: (cycles) {
                if (cycles.isEmpty) {
                  return const SizedBox.shrink();
                }

                final currentCycle = cycles.first;
                return IconButton(
                  tooltip: 'Edit current cycle start date',
                  icon: const Icon(Icons.edit_calendar),
                  onPressed: () => context.go(
                    '${AppRoutePaths.calendar}?editCurrentCycle=true&focusDate=${_formatRouteDate(currentCycle.startDate)}',
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
    _noteController.clear();
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

  void _setSavingNote(bool value) {
    setState(() => _isSavingNote = value);
  }

  void _setSavingCycle(bool value) {
    setState(() => _isSavingCycle = value);
  }

  void _focusDateAfterFlow(DateTime date) {
    _pendingFocusDate = DateUtils.dateOnly(date);
    _positionedAtCurrentMonth = false;
    _forceRecenterOnBuild = true;
  }
}

String _formatRouteDate(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}
