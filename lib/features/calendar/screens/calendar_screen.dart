import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/calendar/utils/calendar_view_utils.dart';
import 'package:hera_app/features/calendar/widgets/calendar_legend_card.dart';
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
import 'package:hera_app/features/profile/providers/profile_provider.dart';

part 'calendar_screen_actions.dart';
part 'calendar_screen_content.dart';
part 'calendar_screen_scroll.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({
    this.isStartNewCycleFlow = false,
    this.focusTodayToken,
    super.key,
  });

  final bool isStartNewCycleFlow;
  final int? focusTodayToken;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const int _monthsBeforeEarliestCycle = 6;
  static const int _monthsAfterCurrent = 24;

  final ScrollController _monthScrollController = ScrollController();
  bool _positionedAtCurrentMonth = false;
  bool _forceRecenterOnBuild = false;
  DateTime? _selectedDate;
  bool _isSavingCycle = false;

  @override
  void didUpdateWidget(covariant CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final enteringStartCycleFlow =
        !oldWidget.isStartNewCycleFlow && widget.isStartNewCycleFlow;
    final focusTokenChanged =
        oldWidget.focusTodayToken != widget.focusTodayToken &&
        widget.focusTodayToken != null;

    if (enteringStartCycleFlow || focusTokenChanged) {
      _positionedAtCurrentMonth = false;
      _forceRecenterOnBuild = true;
      _selectedDate = null;
    }
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cyclesAsync = ref.watch(cyclesProvider);
    final profileAsync = ref.watch(profileSettingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: cyclesAsync.when(
            data: (cycles) {
              if (!widget.isStartNewCycleFlow) {
                return _buildCalendarContent(
                  theme,
                  cycles,
                  profileCycleLength: null,
                  profileMenstruationLength: null,
                );
              }

              return profileAsync.when(
                data: (settings) => _buildCalendarContent(
                  theme,
                  cycles,
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

  void _updateSelectedDate(DateTime? date) {
    setState(() => _selectedDate = date);
  }

  void _setSavingCycle(bool value) {
    setState(() => _isSavingCycle = value);
  }
}
