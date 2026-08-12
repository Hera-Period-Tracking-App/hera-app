import 'package:hera_app/features/aiModelSummerize/models/current_cycle_summary.dart';
import 'package:hera_app/features/aiModelSummerize/services/local_llama_service.dart';
import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/utils/cycle_phase_resolver.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:intl/intl.dart';

class CurrentCycleSummaryService {
  const CurrentCycleSummaryService(this._llamaService);

  final LocalLlamaService _llamaService;

  Future<CurrentCycleSummary> buildSummary({
    required List<CycleSummary> cycles,
    required List<Note> notes,
    required int fallbackCycleLength,
    CycleForecast? forecast,
    bool useModel = false,
  }) async {
    if (cycles.isEmpty) {
      return const CurrentCycleSummary(
        title: 'Current cycle summary unavailable',
        body: 'Start tracking a cycle and add notes to build a summary here.',
        noteHighlights: <String>[],
      );
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final phaseContext = cyclePhaseContextForDate(
      cycles,
      todayOnly,
      fallbackCycleLength: fallbackCycleLength,
      forecast: forecast,
    );

    final cycleNotes = notes
        .where(
          (note) =>
              !note.date.isBefore(phaseContext.cycleStart) &&
              !note.date.isAfter(todayOnly),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final fallbackBody = _buildFallbackBody(phaseContext, cycleNotes);
    final body = useModel
        ? await _buildModelBody(
            phaseContext: phaseContext,
            notes: cycleNotes,
            fallbackBody: fallbackBody,
          )
        : fallbackBody;

    return CurrentCycleSummary(
      title: 'Current cycle summary',
      body: body,
      noteHighlights: cycleNotes.take(3).map(_formatHighlight).toList(),
    );
  }

  Future<String> _buildModelBody({
    required CyclePhaseContext phaseContext,
    required List<Note> notes,
    required String fallbackBody,
  }) async {
    try {
      final summary = await _llamaService.complete(
        _buildPrompt(
          phaseContext: phaseContext,
          notes: notes,
        ),
      );
      return summary.isEmpty ? fallbackBody : summary;
    } catch (_) {
      return fallbackBody;
    }
  }

  String _buildPrompt({
    required CyclePhaseContext phaseContext,
    required List<Note> notes,
  }) {
    final formatter = DateFormat('yyyy-MM-dd');
    final noteBlock = notes.isEmpty
        ? 'No notes have been added for this cycle.'
        : notes
            .take(12)
            .map(
              (note) =>
                  '- ${formatter.format(note.date)}: ${note.encryptedContent.trim()}',
            )
            .join('\n');

    return '''
Summarize the current menstrual cycle in 2 short, supportive paragraphs.
Use only the data below. Take the notes into account, but do not diagnose, prescribe treatment, or claim certainty.
Mention patterns from notes only if they are actually present. Keep it concise.

Cycle data:
- Today: ${formatter.format(phaseContext.selectedDate)}
- Cycle start: ${formatter.format(phaseContext.cycleStart)}
- Cycle end estimate: ${formatter.format(phaseContext.cycleEnd)}
- Day of cycle: ${phaseContext.dayOfCycle}
- Estimated cycle length: ${phaseContext.cycleLength} days
- Current phase: ${cyclePhaseLabel(phaseContext)}
- Ovulation estimate: ${formatter.format(phaseContext.ovulationDay)}
- Next period estimate: ${formatter.format(phaseContext.predictedNextPeriod)}

Notes from this cycle:
$noteBlock
''';
  }

  String _buildFallbackBody(
    CyclePhaseContext phaseContext,
    List<Note> cycleNotes,
  ) {
    final phase = cyclePhaseLabel(phaseContext).toLowerCase();
    final nextEvent = _nextEventLabel(phaseContext);
    final noteSentence = _summarizeNotes(cycleNotes);

    return 'Today is day ${phaseContext.dayOfCycle} of an estimated ${phaseContext.cycleLength}-day cycle. '
        'You are currently in the $phase. $nextEvent $noteSentence';
  }

  String _summarizeNotes(List<Note> cycleNotes) {
    if (cycleNotes.isEmpty) {
      return 'Add notes during this cycle to include more personal context.';
    }

    final recentNotes = cycleNotes.take(3).map((note) {
      return note.encryptedContent.replaceAll(RegExp(r'\s+'), ' ').trim();
    }).where((content) => content.isNotEmpty);

    if (recentNotes.isEmpty) {
      return 'Your recent entries do not include enough detail to summarize patterns yet.';
    }

    return 'Recent entries mention ${recentNotes.join('; ')}.';
  }

  String _nextEventLabel(CyclePhaseContext context) {
    final selected = DateTime(
      context.selectedDate.year,
      context.selectedDate.month,
      context.selectedDate.day,
    );
    final ovulation = DateTime(
      context.ovulationDay.year,
      context.ovulationDay.month,
      context.ovulationDay.day,
    );
    final nextPeriod = DateTime(
      context.predictedNextPeriod.year,
      context.predictedNextPeriod.month,
      context.predictedNextPeriod.day,
    );

    if (selected.isBefore(ovulation)) {
      final days = ovulation.difference(selected).inDays;
      return days == 0
          ? 'Ovulation is expected today.'
          : 'Ovulation is expected in $days days.';
    }

    final daysToPeriod = nextPeriod.difference(selected).inDays;
    return daysToPeriod == 0
        ? 'Menstruation is expected today.'
        : 'Menstruation is expected in $daysToPeriod days.';
  }

  String _formatHighlight(Note note) {
    final date = DateFormat('MMM d').format(note.date);
    final normalized =
        note.encryptedContent.replaceAll(RegExp(r'\s+'), ' ').trim();
    final preview = normalized.length > 96
        ? '${normalized.substring(0, 93).trimRight()}...'
        : normalized;
    return '$date: $preview';
  }
}
