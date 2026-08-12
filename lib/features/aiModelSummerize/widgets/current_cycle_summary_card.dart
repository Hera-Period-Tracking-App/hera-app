import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/aiModelSummerize/models/current_cycle_summary.dart';
import 'package:hera_app/features/aiModelSummerize/providers/current_cycle_summary_provider.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class CurrentCycleSummaryCard extends ConsumerStatefulWidget {
  const CurrentCycleSummaryCard({super.key});

  @override
  ConsumerState<CurrentCycleSummaryCard> createState() =>
      _CurrentCycleSummaryCardState();
}

class _CurrentCycleSummaryCardState
    extends ConsumerState<CurrentCycleSummaryCard> {
  // Kept for hot-reload compatibility with the previous AI action.
  CurrentCycleSummary? _modelSummary;

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(currentCycleSummaryProvider);

    return summaryAsync.when(
      data: (summary) => _SummaryCard(summary: _modelSummary ?? summary),
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

}
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
  });

  final CurrentCycleSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Container(
            width: 2,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(
              summary.title.toUpperCase(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              summary.body,
              style: theme.textTheme.bodyMedium,
            ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}
