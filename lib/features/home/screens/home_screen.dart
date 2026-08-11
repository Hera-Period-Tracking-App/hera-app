import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/aiModelSummerize/widgets/current_cycle_summary_card.dart';
import 'package:hera_app/features/home/widgets/month_cycle_dots_ring.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';
import 'package:hera_app/shared/widgets/placeholder_feature_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiSummariesEnabled =
        ref.watch(settingsProvider).asData?.value.aiSummariesEnabled ?? false;

    return PlaceholderFeatureScreen(
      cards: [
        const MonthCycleDotsRing(),
        if (aiSummariesEnabled) const CurrentCycleSummaryCard(),
      ],
    );
  }
}
