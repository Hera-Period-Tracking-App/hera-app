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
    final noteInsights = _buildNoteInsights(notes, phaseContext);
    final noteBlock = _formatNotesForPrompt(notes, phaseContext);

    return '''
Task: Write the current-cycle summary shown inside a menstrual cycle tracking app.

Persona:
You are Hera: calm, private, precise, and supportive. You summarize tracked data; you are not a clinician.

Hard rules:
- Use only the facts in INPUT.
- Never invent symptoms, moods, flow, dates, risks, diagnoses, pregnancy status, causes, or treatment.
- Treat ovulation and period dates as estimates, not certainties.
- If the notes do not show a clear repeated pattern, say the notes are still limited instead of forcing a pattern.
- Do not mention encryption, privacy, the prompt, rules, or missing internal data.
- Do not use markdown, headings, bullet points, lists, emojis, or labels.
- Output exactly 2 paragraphs separated by one blank line.
- Each paragraph must be 1-2 short sentences.
- Keep the whole answer under 85 words.

Content plan:
Paragraph 1 must state the cycle position in natural language:
day ${phaseContext.dayOfCycle} of an estimated ${phaseContext.cycleLength}-day cycle, current phase, and the next estimate that matters most.

Paragraph 2 must summarize the user's notes in normal sentences:
Do not simply list symptoms. Connect symptoms and flow to the cycle phase where they were recorded. Do not mention note dates. Example: "You experienced headache during menstruation." If there are no useful notes, invite continued tracking in one gentle sentence.

Style examples:
Good: "Today is day 18 of your estimated 28-day cycle, and you are in the luteal phase. Your next period is estimated around 2026-08-24."
Good: "Your notes mention cramps and light flow this cycle, but there is not enough repeated detail yet to call it a pattern. Keep adding short daily notes so Hera can compare changes over time."
Bad: "You may have PMS and should take painkillers."
Bad: "Based on your hormones..."
Bad: "Here is your summary:"

INPUT
Today: ${formatter.format(phaseContext.selectedDate)}
Cycle start: ${formatter.format(phaseContext.cycleStart)}
Cycle end estimate: ${formatter.format(phaseContext.cycleEnd)}
Day of cycle: ${phaseContext.dayOfCycle}
Estimated cycle length: ${phaseContext.cycleLength} days
Current phase: ${cyclePhaseLabel(phaseContext)}
Ovulation estimate: ${formatter.format(phaseContext.ovulationDay)}
Next period estimate: ${formatter.format(phaseContext.predictedNextPeriod)}

Notes from this cycle, newest first:
$noteBlock

Precomputed note insights:
- Note count: ${notes.length}
- Symptoms: ${noteInsights.symptomSummary}
- Menstrual flow: ${noteInsights.flowSummary}
- Free-text observations: ${noteInsights.observationSummary}
''';
  }

  String _buildFallbackBody(
    CyclePhaseContext phaseContext,
    List<Note> cycleNotes,
  ) {
    final phase = cyclePhaseLabel(phaseContext).toLowerCase();
    final nextEvent = _nextEventLabel(phaseContext);
    final noteSentence = _summarizeNotes(phaseContext, cycleNotes);

    return 'Today is day ${phaseContext.dayOfCycle} of an estimated ${phaseContext.cycleLength}-day cycle. '
        'You are currently in the $phase. $nextEvent $noteSentence';
  }

  String _summarizeNotes(
    CyclePhaseContext phaseContext,
    List<Note> cycleNotes,
  ) {
    if (cycleNotes.isEmpty) {
      return 'Add notes during this cycle to include more personal context.';
    }

    final insights = _buildNoteInsights(cycleNotes, phaseContext);
    final parts = <String>[];

    if (insights.symptomSummary != 'none recorded') {
      parts.add(insights.symptomSummary);
    }
    if (insights.flowSummary != 'none recorded') {
      parts.add(insights.flowSummary);
    }
    if (insights.observationSummary != 'none recorded') {
      parts.add(insights.observationSummary);
    }

    if (parts.isEmpty) {
      return 'Your recent entries do not include enough detail to summarize patterns yet.';
    }

    return parts.join(' ');
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
    final details = _parseNoteDetails(note.encryptedContent);
    final normalized = details.preview.replaceAll(RegExp(r'\s+'), ' ').trim();
    final preview = normalized.length > 96
        ? '${normalized.substring(0, 93).trimRight()}...'
        : normalized;
    return '$date: $preview';
  }

  String _formatNotesForPrompt(
    List<Note> notes,
    CyclePhaseContext phaseContext,
  ) {
    if (notes.isEmpty) {
      return 'No notes have been added for this cycle.';
    }

    return notes.take(12).map((note) {
      final details = _parseNoteDetails(note.encryptedContent);
      final phase = _phaseLabelForNoteDate(note.date, phaseContext);
      final fields = <String>[];
      if (details.symptoms.isNotEmpty) {
        fields.add('symptoms=${details.symptoms.join(', ')}');
      }
      if (details.flow.isNotEmpty) {
        fields.add('flow=${details.flow}');
      }
      if (details.observation.isNotEmpty) {
        fields.add('note=${details.observation}');
      }
      final content = fields.isEmpty ? 'empty note' : fields.join('; ');
      return '- During $phase: $content';
    }).join('\n');
  }

  _NoteInsights _buildNoteInsights(
    List<Note> notes,
    CyclePhaseContext phaseContext,
  ) {
    if (notes.isEmpty) {
      return const _NoteInsights(
        symptomSummary: 'none recorded',
        flowSummary: 'none recorded',
        observationSummary: 'none recorded',
      );
    }

    final symptomsByPhase = <String, Set<String>>{};
    final flowByPhase = <String, Set<String>>{};
    final observations = <String>[];

    for (final note in notes) {
      final details = _parseNoteDetails(note.encryptedContent);
      final notePhase = _phaseLabelForNoteDate(note.date, phaseContext);
      for (final symptom in details.symptoms) {
        symptomsByPhase.putIfAbsent(notePhase, () => <String>{}).add(symptom);
      }
      if (details.flow.isNotEmpty) {
        flowByPhase.putIfAbsent(notePhase, () => <String>{}).add(details.flow);
      }
      if (details.observation.isNotEmpty) {
        observations.add(details.observation);
      }
    }

    return _NoteInsights(
      symptomSummary: _summarizeSymptomsByPhase(symptomsByPhase),
      flowSummary: _summarizeFlowByPhase(flowByPhase),
      observationSummary: _summarizeObservations(observations),
    );
  }

  String _summarizeSymptomsByPhase(Map<String, Set<String>> values) {
    final phaseSentences = _phaseSentences(
      values,
      (items, phase) => 'You experienced ${_joinNatural(items)} during $phase.',
    );
    if (phaseSentences.isEmpty) {
      return 'none recorded';
    }

    return phaseSentences.join(' ');
  }

  String _summarizeFlowByPhase(Map<String, Set<String>> values) {
    final phaseSentences = _phaseSentences(
      values,
      (items, phase) =>
          'You recorded ${_joinNatural(items)} menstrual flow during $phase.',
    );
    if (phaseSentences.isEmpty) {
      return 'none recorded';
    }

    return phaseSentences.join(' ');
  }

  List<String> _phaseSentences(
    Map<String, Set<String>> values,
    String Function(List<String> items, String phase) buildSentence,
  ) {
    final entries = values.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList()
      ..sort((a, b) => _phaseSortOrder(a.key).compareTo(_phaseSortOrder(b.key)));

    return entries.take(3).map((entry) {
      final items = entry.value.toList()..sort();
      return buildSentence(items.take(4).toList(), entry.key);
    }).toList();
  }

  String _summarizeObservations(List<String> observations) {
    final cleaned = observations
        .map((value) => value.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (cleaned.isEmpty) {
      return 'none recorded';
    }

    final phrases = cleaned.take(2).map((value) {
      return value.length > 80
          ? '${value.substring(0, 77).trimRight()}...'
          : value;
    }).toList();

    return 'Your written notes mention ${_joinNatural(phrases)}.';
  }

  String _phaseLabelForNoteDate(
    DateTime date,
    CyclePhaseContext phaseContext,
  ) {
    final start = phaseContext.cycleStart;
    final noteDate = DateTime(date.year, date.month, date.day);
    final dayOfCycle = noteDate.difference(start).inDays + 1;
    if (dayOfCycle <= phaseContext.menstruationLength) {
      return 'menstruation';
    }

    final ovulationDay =
        phaseContext.ovulationDay.difference(start).inDays + 1;
    if (dayOfCycle >= ovulationDay - 5 && dayOfCycle <= ovulationDay) {
      return 'the fertile window';
    }
    if (dayOfCycle > ovulationDay) {
      return 'the luteal phase';
    }

    return 'the follicular phase';
  }

  int _phaseSortOrder(String phase) {
    return switch (phase) {
      'menstruation' => 0,
      'the follicular phase' => 1,
      'the fertile window' => 2,
      'the luteal phase' => 3,
      _ => 4,
    };
  }

  String _joinNatural(List<String> values) {
    if (values.isEmpty) {
      return '';
    }
    if (values.length == 1) {
      return values.first;
    }
    if (values.length == 2) {
      return '${values.first} and ${values.last}';
    }

    return '${values.take(values.length - 1).join(', ')}, and ${values.last}';
  }

  _ParsedNoteDetails _parseNoteDetails(String content) {
    final noteParts = <String>[];
    final symptoms = <String>[];
    var flow = '';

    for (final block in content.split('\n\n')) {
      final value = block.trim();
      if (value.startsWith('Symptoms: ')) {
        symptoms.addAll(
          value
              .substring('Symptoms: '.length)
              .split(',')
              .map((symptom) => symptom.trim().toLowerCase())
              .where((symptom) => symptom.isNotEmpty),
        );
      } else if (value.startsWith('Menstrual flow: ')) {
        flow = value.substring('Menstrual flow: '.length).trim().toLowerCase();
      } else if (value.isNotEmpty) {
        noteParts.add(value);
      }
    }

    return _ParsedNoteDetails(
      observation: noteParts.join(' ').trim(),
      symptoms: symptoms,
      flow: flow,
    );
  }
}

class _NoteInsights {
  const _NoteInsights({
    required this.symptomSummary,
    required this.flowSummary,
    required this.observationSummary,
  });

  final String symptomSummary;
  final String flowSummary;
  final String observationSummary;
}

class _ParsedNoteDetails {
  const _ParsedNoteDetails({
    required this.observation,
    required this.symptoms,
    required this.flow,
  });

  final String observation;
  final List<String> symptoms;
  final String flow;

  String get preview {
    final parts = <String>[];
    if (observation.isNotEmpty) {
      parts.add(observation);
    }
    if (symptoms.isNotEmpty) {
      parts.add('Symptoms: ${symptoms.join(', ')}');
    }
    if (flow.isNotEmpty) {
      parts.add('Flow: $flow');
    }
    return parts.join(' ');
  }
}
