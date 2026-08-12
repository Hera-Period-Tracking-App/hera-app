import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/settings/models/pending_cycle_conflict.dart';
import 'package:hera_app/features/settings/providers/auto_sync_provider.dart';
import 'package:hera_app/features/settings/repositories/cycle_conflict_repository.dart';
import 'package:intl/intl.dart';

class CycleConflictResolutionScreen extends ConsumerStatefulWidget {
  const CycleConflictResolutionScreen({super.key});

  @override
  ConsumerState<CycleConflictResolutionScreen> createState() =>
      _CycleConflictResolutionScreenState();
}

class _CycleConflictResolutionScreenState
    extends ConsumerState<CycleConflictResolutionScreen> {
  bool _isResolving = false;

  @override
  Widget build(BuildContext context) {
    final conflictsAsync = ref.watch(pendingCycleConflictsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolve cycle conflict'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: conflictsAsync.when(
          data: (conflicts) {
            if (conflicts.isEmpty) {
              return _NoConflictsView(
                onContinue: () => context.go(AppRoutePaths.home),
              );
            }

            return _ConflictView(
              conflict: conflicts.first,
              remainingCount: conflicts.length,
              isResolving: _isResolving,
              onChoose: _resolveConflict,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Could not load cycle conflicts: $error'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resolveConflict(
    PendingCycleConflict conflict,
    CycleConflictChoice choice,
  ) async {
    setState(() => _isResolving = true);

    try {
      await ref.read(cycleConflictRepositoryProvider).resolveConflict(
            conflictId: conflict.id,
            choice: choice,
          );
      ref.read(autoSyncProvider).queueSync();
      ref.invalidate(pendingCycleConflictsProvider);
    } finally {
      if (mounted) {
        setState(() => _isResolving = false);
      }
    }
  }
}

class _ConflictView extends StatelessWidget {
  const _ConflictView({
    required this.conflict,
    required this.remainingCount,
    required this.isResolving,
    required this.onChoose,
  });

  final PendingCycleConflict conflict;
  final int remainingCount;
  final bool isResolving;
  final void Function(PendingCycleConflict conflict, CycleConflictChoice choice)
      onChoose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Both this device and your account have a cycle for the same time period.',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          remainingCount == 1
              ? 'Choose which cycle Hera should keep.'
              : 'Choose which cycle Hera should keep. $remainingCount conflicts need review.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        _CycleChoiceCard(
          label: 'Keep this device',
          description:
              'Uses the local cycle and updates the account copy during the next sync.',
          cycle: conflict.localCycle,
          icon: Icons.phone_android,
          isResolving: isResolving,
          onPressed: () => onChoose(conflict, CycleConflictChoice.local),
        ),
        const SizedBox(height: 12),
        _CycleChoiceCard(
          label: 'Keep account cycle',
          description: 'Uses the cycle downloaded from your existing account.',
          cycle: conflict.remoteCycle,
          icon: Icons.cloud_outlined,
          isResolving: isResolving,
          onPressed: () => onChoose(conflict, CycleConflictChoice.remote),
        ),
      ],
    );
  }
}

class _CycleChoiceCard extends StatelessWidget {
  const _CycleChoiceCard({
    required this.label,
    required this.description,
    required this.cycle,
    required this.icon,
    required this.isResolving,
    required this.onPressed,
  });

  final String label;
  final String description;
  final SyncCycleSnapshot cycle;
  final IconData icon;
  final bool isResolving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 16),
            _CycleFact(label: 'Start date', value: _formatDate(cycle.startDate)),
            _CycleFact(label: 'End date', value: _formatDate(cycle.endDate)),
            _CycleFact(
              label: 'Cycle length',
              value: '${cycle.cycleLength} days',
            ),
            _CycleFact(
              label: 'Menstruation length',
              value: '${cycle.menstruationLength} days',
            ),
            _CycleFact(label: 'Last changed', value: _formatDate(cycle.updatedAt)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isResolving ? null : onPressed,
                child: Text(isResolving ? 'Saving...' : label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CycleFact extends StatelessWidget {
  const _CycleFact({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}

class _NoConflictsView extends StatelessWidget {
  const _NoConflictsView({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 48),
            const SizedBox(height: 16),
            const Text('All cycle conflicts are resolved.'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}
