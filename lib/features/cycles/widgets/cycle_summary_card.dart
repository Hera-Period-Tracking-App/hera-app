import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class CycleSummaryCard extends ConsumerWidget {
  const CycleSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycleSummaries = ref.watch(cyclesProvider);
    
    return cycleSummaries.when(
      data: (summaries) {
        if (summaries.isEmpty) {
          return const SectionPlaceholderCard(
            title: 'No Cycles Tracked',
            body: 'Start tracking your cycles to see summaries here.',
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cycles (${summaries.length})'),
                const SizedBox(height: 12),

                for (final cycle in summaries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Start: ${cycle.startDate}\n'
                      'Cycle Length: ${cycle.cycleLength}\n'
                      'Period Length: ${cycle.menstruationLength}',
                    ),
                  ),
              ],
            ),
          ),
        );
      
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => const SectionPlaceholderCard(
        title: 'Error Loading Cycles',
        body: 'An error occurred while loading your cycle summaries.',
      ),
    );
  }
}
