import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';
import 'package:hera_app/shared/widgets/placeholder_feature_screen.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(profileSettingsProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile), actions: [IconButton(tooltip: l10n.openSettings, onPressed: () => context.push(AppRoutePaths.settings), icon: const Icon(Icons.settings_outlined))]),
      body: PlaceholderFeatureScreen(cards: [
        settings.when(
          data: (value) => SectionPlaceholderCard(title: l10n.averageCycleSettings, body: value.averageCycleLength == null && value.averageMenstruationLength == null ? l10n.noAverageCycleSettings : l10n.averageCycleSettingsBody(value.averageCycleLength?.toString() ?? '-', value.averageMenstruationLength?.toString() ?? '-')),
          loading: () => SectionPlaceholderCard(title: l10n.averageCycleSettings, body: l10n.loadingSavedAverages),
          error: (_, __) => SectionPlaceholderCard(title: l10n.averageCycleSettings, body: l10n.couldNotLoadSavedAverages),
        ),
        const SectionPlaceholderCard(title: 'LOCAL-ONLY', body: 'Your cycle data stays on this device. Hera does not create accounts, connect to servers, or sync data.'),
      ]),
    );
  }
}
