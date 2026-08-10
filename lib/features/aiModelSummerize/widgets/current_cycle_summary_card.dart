import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/aiModelSummerize/models/current_cycle_summary.dart';
import 'package:hera_app/features/aiModelSummerize/providers/current_cycle_summary_provider.dart';
import 'package:hera_app/features/cyclePrediction/providers/cycle_prediction_provider.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/cycles/utils/cycle_phase_resolver.dart';
import 'package:hera_app/features/notes/providers/notes_provider.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class CurrentCycleSummaryCard extends ConsumerStatefulWidget {
  const CurrentCycleSummaryCard({super.key});

  @override
  ConsumerState<CurrentCycleSummaryCard> createState() =>
      _CurrentCycleSummaryCardState();
}

class _CurrentCycleSummaryCardState
    extends ConsumerState<CurrentCycleSummaryCard> {
  CurrentCycleSummary? _modelSummary;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(currentCycleSummaryProvider);

    return summaryAsync.when(
      data: (summary) => _SummaryCard(
        summary: _modelSummary ?? summary,
        isGenerating: _isGenerating,
        onGenerate: _isGenerating ? null : _generateModelSummary,
      ),
      loading: () => const SectionPlaceholderCard(
        title: 'Current cycle summary',
        body: 'Building a summary from your cycle data and notes...',
      ),
      error: (error, _) => const SectionPlaceholderCard(
        title: 'Current cycle summary',
        body: 'Could not build the current cycle summary.',
      ),
    );
  }

  Future<void> _generateModelSummary() async {
    setState(() => _isGenerating = true);

    try {
      final cycles = await ref.read(cyclesProvider.future);
      final notes = await ref.read(notesProvider.future);
      final profile = await ref.read(profileSettingsProvider.future);
      final forecast = await ref.read(upcomingCycleForecastProvider.future);
      final summary = await ref
          .read(currentCycleSummaryServiceProvider)
          .buildSummary(
            cycles: cycles,
            notes: notes,
            fallbackCycleLength:
                profile.averageCycleLength ?? defaultCycleLength,
            forecast: forecast,
            useModel: true,
          );

      if (mounted) {
        setState(() => _modelSummary = summary);
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.isGenerating,
    required this.onGenerate,
  });

  final CurrentCycleSummary summary;
  final bool isGenerating;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    summary.title,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Generate AI summary',
                  onPressed: onGenerate,
                  icon: isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              summary.body,
              style: theme.textTheme.bodyMedium,
            ),
            if (summary.noteHighlights.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Recent notes in this cycle',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              for (final item in summary.noteHighlights)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    item,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
