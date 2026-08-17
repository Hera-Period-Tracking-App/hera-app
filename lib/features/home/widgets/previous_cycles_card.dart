import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:intl/intl.dart';

class PreviousCyclesCard extends ConsumerWidget {
  const PreviousCyclesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycles = ref.watch(cyclesProvider);
    return cycles.when(
      data: (value) {
        final previousCycles = [...value]..sort((a, b) => b.startDate.compareTo(a.startDate));
        if (previousCycles.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 116,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            pageSnapping: true,
            physics: const PageScrollPhysics(),
            allowImplicitScrolling: false,
            itemCount: previousCycles.length,
            itemBuilder: (context, index) => _CycleHistoryItem(
              cycle: previousCycles[index],
              isCurrent: index == 0,
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _CycleHistoryItem extends StatelessWidget {
  const _CycleHistoryItem({required this.cycle, required this.isCurrent});
  final CycleSummary cycle;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final length = cycle.cycleLength ?? 28;
    final menstruationLength = cycle.menstruationLength ?? 5;
    final periodEnd = cycle.startDate.add(Duration(days: menstruationLength - 1));
    final ovulation = cycle.startDate.add(Duration(days: length ~/ 2 + 1));
    final format = DateFormat('dd.MM.yyyy');
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${isCurrent ? 'CURRENT CYCLE' : 'CYCLE STARTING'} - ${format.format(cycle.startDate)}', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: .6)),
        const SizedBox(height: 5),
        Text('$length cycle', style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        _PhaseDots(length: length, menstruationLength: menstruationLength),
        const SizedBox(height: 9),
        Text('Menstruation: ${format.format(cycle.startDate)} - ${format.format(periodEnd)}', style: theme.textTheme.bodySmall),
        Text('Ovulation: ${format.format(ovulation)}', style: theme.textTheme.bodySmall),
      ]),
    );
  }
}

class _PhaseDots extends StatelessWidget {
  const _PhaseDots({required this.length, required this.menstruationLength});
  final int length;
  final int menstruationLength;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 4,
    runSpacing: 4,
    children: List.generate(length, (index) {
      final color = index < menstruationLength ? const Color(0xFFFF4B4B) : index < length ~/ 2 ? const Color(0xFFFFE5C2) : index == length ~/ 2 ? const Color(0xFFFFC21A) : const Color(0xFF393050);
      return DecoratedBox(decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: const SizedBox(width: 8, height: 8));
    }),
  );
}
