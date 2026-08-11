import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/cyclePrediction/providers/cycle_prediction_provider.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/cycles/utils/cycle_phase_resolver.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/providers/notes_provider.dart';
import 'package:hera_app/features/notes/widgets/notes_security_card.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';

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
    final cycles = cyclesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <CycleSummary>[],
    );
    final fallbackCycleLength = profileAsync.maybeWhen(
      data: (settings) => settings.averageCycleLength ?? defaultCycleLength,
      orElse: () => defaultCycleLength,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const NotesSecurityCard(),
            const SizedBox(height: 16),
            if (!notesEnabled)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Notes are disabled in Settings.'),
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
              error: (error, _) => Text('Could not load notes: $error'),
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

    if (widget.notes.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No notes yet.',
            style: textTheme.bodyLarge,
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
        Text('Saved notes', style: textTheme.titleLarge),
        const SizedBox(height: 12),
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
      color: colorScheme.primaryContainer.withValues(alpha: 0.28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.24),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          key: PageStorageKey<String>(group.key),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Text(
            group.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          subtitle: Text(
            '${group.notes.length} ${group.notes.length == 1 ? 'note' : 'notes'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.72),
            ),
          ),
          children: [
            for (final entry in group.notes) ...[
              _NoteRow(entry: entry),
              if (entry != group.notes.last)
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
            ],
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

    return Container(
      width: double.infinity,
      color: colorScheme.surface.withValues(alpha: 0.7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _buildNoteTitleFromContext(
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
            entry.note.encryptedContent,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCycleGroup {
  const _NoteCycleGroup({
    required this.key,
    required this.title,
    required this.notes,
    required this.isCurrentCycle,
  });

  final String key;
  final String title;
  final List<_NoteWithCycleContext> notes;
  final bool isCurrentCycle;
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
      title:
          '${_formatNoteDate(phaseContext.cycleStart)} - ${_formatNoteDate(phaseContext.cycleEnd)}',
      notes: noteEntries,
      isCurrentCycle: _isCurrentCycle(phaseContext),
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
  required DateTime date,
  required CyclePhaseContext phaseContext,
}) {
  return '${_formatNoteDate(date)} - ${cyclePhaseLabel(phaseContext)}';
}

String _formatNoteDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
