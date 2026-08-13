import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/cycle_phase_colors.dart';
import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/cyclePrediction/providers/cycle_prediction_provider.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/cycles/utils/cycle_phase_resolver.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/providers/notes_provider.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final cyclesAsync = ref.watch(cyclesProvider);
    final profileAsync = ref.watch(profileSettingsProvider);
    final forecastAsync = ref.watch(upcomingCycleForecastProvider);
    final notesEnabled = ref.watch(settingsProvider).maybeWhen(
          data: (settings) => settings.notesEnabled,
          orElse: () => true,
        );
    final l10n = AppLocalizations.of(context);
    final cycles = cyclesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <CycleSummary>[],
    );
    final fallbackCycleLength = profileAsync.maybeWhen(
      data: (settings) => settings.averageCycleLength ?? defaultCycleLength,
      orElse: () => defaultCycleLength,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notes)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          children: [
            if (!notesEnabled)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(l10n.notesDisabledInSettings),
                ),
              )
            else
              notesAsync.when(
              data: (notes) => _NotesList(
                notes: notes,
                cycles: cycles,
                fallbackCycleLength: fallbackCycleLength,
                forecast: forecastAsync.value,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(l10n.couldNotLoadNotes(error.toString())),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesList extends StatefulWidget {
  const _NotesList({
    required this.notes,
    required this.cycles,
    required this.fallbackCycleLength,
    required this.forecast,
  });

  final List<Note> notes;
  final List<CycleSummary> cycles;
  final int fallbackCycleLength;
  final CycleForecast? forecast;

  @override
  State<_NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<_NotesList> {
  final Set<String> _manuallyExpandedGroupKeys = <String>{};
  final Set<String> _manuallyCollapsedGroupKeys = <String>{};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    if (widget.notes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            l10n.noNotesYet,
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final groups = _groupNotesByCycle(
      notes: widget.notes,
      cycles: widget.cycles,
      fallbackCycleLength: widget.fallbackCycleLength,
      forecast: widget.forecast,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          _CycleNotesGroupCard(
            group: group,
            isExpanded: _isGroupExpanded(group),
            onExpansionChanged: (isExpanded) {
              setState(() {
                if (isExpanded) {
                  _manuallyCollapsedGroupKeys.remove(group.key);
                  _manuallyExpandedGroupKeys.add(group.key);
                } else {
                  _manuallyExpandedGroupKeys.remove(group.key);
                  _manuallyCollapsedGroupKeys.add(group.key);
                }
              });
            },
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  bool _isGroupExpanded(_NoteCycleGroup group) {
    if (_manuallyExpandedGroupKeys.contains(group.key)) {
      return true;
    }
    if (_manuallyCollapsedGroupKeys.contains(group.key)) {
      return false;
    }
    return group.isCurrentCycle;
  }
}

class _CycleNotesGroupCard extends StatelessWidget {
  const _CycleNotesGroupCard({
    required this.group,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  final _NoteCycleGroup group;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: ExpansionTile(
          key: PageStorageKey<String>(group.key),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Text(
            _formatCycleRange(context, group.cycleStart, group.cycleEnd),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _NotesPhaseLine(phaseContext: group.phaseContext),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).noteCount(group.notes.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
          children: [
            for (final entry in group.notes)
              _NoteRow(entry: entry),
            ],
          ),
        ),
      );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.entry});

  final _NoteWithCycleContext entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(
        '${AppRoutePaths.calendarDateDetailsFor(entry.note.date)}?returnToNotes=true',
      ),
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 2,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _buildNoteTitleFromContext(
                        context: context,
                        date: entry.note.date,
                        phaseContext: entry.phaseContext,
                      ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.note.encryptedContent.replaceAll('\n\n', '\n'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteCycleGroup {
  const _NoteCycleGroup({
    required this.key,
    required this.cycleStart,
    required this.cycleEnd,
    required this.notes,
    required this.isCurrentCycle,
    required this.phaseContext,
  });

  final String key;
  final DateTime cycleStart;
  final DateTime cycleEnd;
  final List<_NoteWithCycleContext> notes;
  final bool isCurrentCycle;
  final CyclePhaseContext phaseContext;
}

class _NoteWithCycleContext {
  const _NoteWithCycleContext({
    required this.note,
    required this.phaseContext,
  });

  final Note note;
  final CyclePhaseContext phaseContext;
}

List<_NoteCycleGroup> _groupNotesByCycle({
  required List<Note> notes,
  required List<CycleSummary> cycles,
  required int fallbackCycleLength,
  required CycleForecast? forecast,
}) {
  final groupedEntries = <String, List<_NoteWithCycleContext>>{};
  final groupContexts = <String, CyclePhaseContext>{};

  for (final note in notes) {
    final phaseContext = cyclePhaseContextForDate(
      cycles,
      note.date,
      fallbackCycleLength: fallbackCycleLength,
      forecast: forecast,
    );
    final key = _cycleGroupKey(phaseContext);

    groupedEntries.putIfAbsent(key, () => <_NoteWithCycleContext>[]).add(
          _NoteWithCycleContext(
            note: note,
            phaseContext: phaseContext,
          ),
        );
    groupContexts.putIfAbsent(key, () => phaseContext);
  }

  final groups = groupedEntries.entries.map((entry) {
    final phaseContext = groupContexts[entry.key]!;
    final noteEntries = [...entry.value]
      ..sort((a, b) => b.note.date.compareTo(a.note.date));

    return _NoteCycleGroup(
      key: entry.key,
      cycleStart: phaseContext.cycleStart,
      cycleEnd: phaseContext.cycleEnd,
      notes: noteEntries,
      isCurrentCycle: _isCurrentCycle(phaseContext),
      phaseContext: phaseContext,
    );
  }).toList()
    ..sort(
      (a, b) => b.notes.first.phaseContext.cycleStart.compareTo(
        a.notes.first.phaseContext.cycleStart,
      ),
    );

  return groups;
}

String _cycleGroupKey(CyclePhaseContext phaseContext) {
  return _formatNoteDate(phaseContext.cycleStart);
}

bool _isCurrentCycle(CyclePhaseContext phaseContext) {
  final today = DateUtils.dateOnly(DateTime.now());
  return !today.isBefore(phaseContext.cycleStart) &&
      !today.isAfter(phaseContext.cycleEnd);
}

String _buildNoteTitleFromContext({
  required BuildContext context,
  required DateTime date,
  required CyclePhaseContext phaseContext,
}) {
  return '${_formatShortNoteDate(context, date)} - '
      '${_cyclePhaseLabel(context, phaseContext)}';
}

String _formatShortNoteDate(BuildContext context, DateTime date) {
  return DateFormat.MMMd(Localizations.localeOf(context).toString()).format(date);
}

String _formatNoteDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class _NotesPhaseLine extends StatelessWidget {
  const _NotesPhaseLine({required this.phaseContext});

  final CyclePhaseContext phaseContext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phaseColors = theme.extension<CyclePhaseColors>();
    final cycleLength = phaseContext.cycleLength.clamp(1, 90).toInt();

    return LayoutBuilder(
      builder: (context, constraints) {
        const maxDotsPerRow = 28;
        const spacing = 4.0;
        final dotsInFirstRow = cycleLength.clamp(1, maxDotsPerRow).toInt();
        final dotSize =
            ((constraints.maxWidth - (spacing * (dotsInFirstRow - 1))) /
                    dotsInFirstRow)
                .clamp(7.0, 10.0);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var day = 1; day <= cycleLength; day++)
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: _phaseDotColor(
                    context: phaseContext,
                    day: day,
                    phaseColors: phaseColors,
                    theme: theme,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        );
      },
    );
  }
}

Color _phaseDotColor({
  required CyclePhaseContext context,
  required int day,
  required CyclePhaseColors? phaseColors,
  required ThemeData theme,
}) {
  final date = context.cycleStart.add(Duration(days: day - 1));
  final phase = cyclePhaseContextForDate(
    [
      CycleSummary(
        id: 'notes-cycle-preview',
        startDate: context.cycleStart,
        cycleLength: context.cycleLength,
        menstruationLength: context.menstruationLength,
      ),
    ],
    date,
    fallbackCycleLength: context.cycleLength,
  ).phase;

  return switch (phase) {
    CyclePhase.menstruation => phaseColors?.menstrual ?? Colors.red,
    CyclePhase.follicular =>
      phaseColors?.follicular ?? theme.colorScheme.secondary,
    CyclePhase.ovulation => phaseColors?.ovulation ?? theme.colorScheme.primary,
    CyclePhase.luteal =>
      phaseColors?.luteal ?? theme.colorScheme.tertiary,
  };
}

String _formatCycleRange(BuildContext context, DateTime start, DateTime end) {
  final locale = Localizations.localeOf(context).toString();
  final startLabel = DateFormat.MMMd(locale).format(start);
  final endLabel = DateFormat.MMMd(locale).format(end);
  return '$startLabel - $endLabel ${end.year}';
}

String _cyclePhaseLabel(BuildContext context, CyclePhaseContext phaseContext) {
  final l10n = AppLocalizations.of(context);
  if (phaseContext.phase == CyclePhase.ovulation) {
    return phaseContext.isPredictedOvulationDay
        ? l10n.phaseOvulationDay
        : l10n.phaseFertileWindow;
  }
  return switch (phaseContext.phase) {
    CyclePhase.menstruation => l10n.phaseMenstruation,
    CyclePhase.follicular => l10n.phaseFollicular,
    CyclePhase.luteal => l10n.phaseLuteal,
    CyclePhase.ovulation => l10n.phaseFertileWindow,
  };
}
