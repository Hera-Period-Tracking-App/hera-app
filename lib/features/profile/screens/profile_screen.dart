import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/networking/api_client.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/aiModelSummerize/providers/current_cycle_summary_provider.dart';
import 'package:hera_app/features/auth/models/auth_session.dart';
import 'package:hera_app/features/auth/providers/auth_provider.dart';
import 'package:hera_app/features/auth/repositories/auth_repository.dart';
import 'package:hera_app/features/cyclePrediction/providers/cycle_prediction_provider.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/notes/providers/notes_provider.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';
import 'package:hera_app/features/settings/repositories/cycle_conflict_repository.dart';
import 'package:hera_app/features/settings/repositories/sync_repository.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';
import 'package:hera_app/shared/widgets/placeholder_feature_screen.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(profileSettingsProvider);
    final authState = ref.watch(profileAuthSessionProvider);
    final session = authState.asData?.value;
    final isSignedIn = session?.isAuthenticated ?? false;
    final l10n = AppLocalizations.of(context);

    return PlaceholderFeatureScreen(
      title: l10n.profile,
      description: l10n.profileDescription,
      cards: [
        settings.when(
          data: (value) {
            final averageCycleLength = value.averageCycleLength;
            final averageMenstruationLength = value.averageMenstruationLength;

            if (averageCycleLength == null &&
                averageMenstruationLength == null) {
              return SectionPlaceholderCard(
                title: l10n.averageCycleSettings,
                body: l10n.noAverageCycleSettings,
              );
            }

            return SectionPlaceholderCard(
              title: l10n.averageCycleSettings,
              body: l10n.averageCycleSettingsBody(
                averageCycleLength?.toString() ?? '-',
                averageMenstruationLength?.toString() ?? '-',
              ),
            );
          },
          loading: () => SectionPlaceholderCard(
            title: l10n.averageCycleSettings,
            body: l10n.loadingSavedAverages,
          ),
          error: (error, stackTrace) => SectionPlaceholderCard(
            title: l10n.averageCycleSettings,
            body: l10n.couldNotLoadSavedAverages,
          ),
        ),
        SectionPlaceholderCard(
          title: l10n.settingsTitle,
          body: l10n.profileSettingsDescription,
          footer: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => context.push(AppRoutePaths.settings),
              icon: const Icon(Icons.settings),
              label: Text(l10n.openSettings),
            ),
          ),
        ),
        SectionPlaceholderCard(
          title: l10n.account,
          body: authState.when(
            data: (session) {
              if (!session.isAuthenticated) {
                return l10n.signedOutAccountDescription;
              }

              final email = session.email?.trim();
              if (email == null || email.isEmpty) {
                return l10n.signedInAccountDescription;
              }
              return l10n.signedInAsAccountDescription(email);
            },
            loading: () => l10n.checkingAccountStatus,
            error: (error, stackTrace) => l10n.couldNotLoadAccountStatus,
          ),
          footer: Align(
            alignment: Alignment.centerLeft,
            child: authState.when(
              data: (session) => session.isAuthenticated
                  ? Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.push(AppRoutePaths.editAccount),
                          icon: const Icon(Icons.edit),
                          label: Text(l10n.editAccount),
                        ),
                        FilledButton.icon(
                          onPressed: () async {
                            await ref
                                .read(authSessionProvider.notifier)
                                .logout();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.signedOutMessage)),
                              );
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: Text(l10n.signOut),
                        ),
                      ],
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () =>
                              context.push(AppRoutePaths.authSignup),
                          icon: const Icon(Icons.person_add),
                          label: Text(l10n.createAccount),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.push(AppRoutePaths.authLogin),
                          icon: const Icon(Icons.login),
                          label: Text(l10n.logIn),
                        ),
                      ],
                    ),
              loading: () => FilledButton(
                onPressed: null,
                child: Text(l10n.checking),
              ),
              error: (error, stackTrace) => OutlinedButton.icon(
                onPressed: () => ref.invalidate(authSessionProvider),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.tryAgain),
              ),
            ),
          ),
        ),
        SectionPlaceholderCard(
          title: l10n.sync,
          body: isSignedIn
              ? l10n.syncSignedInDescription
              : l10n.syncSignedOutDescription,
          footer: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: !isSignedIn || _isSyncing ? null : _syncNow,
              child: Text(_isSyncing ? l10n.syncing : l10n.syncNow),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _syncNow() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final result = await ref
          .read(syncRepositoryProvider)
          .syncNow(forceFullDownload: true);
      _refreshSyncedProviders();
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).syncComplete(
              result.uploadedCount,
              result.downloadedCount,
              result.appliedCount,
            ),
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      await _showSyncFailedDialog(error);
    } catch (error) {
      if (!mounted) {
        return;
      }

      await _showSyncFailedDialog(error);
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _showSyncFailedDialog(Object error) async {
    final canReset =
        error is ApiException && error.isSyncKeyUnavailable;
    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.syncFailed),
            content: SingleChildScrollView(
              child: SelectableText(error.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.close),
              ),
              if (canReset)
                FilledButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await _resetRemoteSyncFromLocal();
                  },
                  child: Text(l10n.resetSyncData),
                ),
            ],
          );
        },
      );
  }

  Future<void> _resetRemoteSyncFromLocal() async {
    setState(() => _isSyncing = true);
    try {
      await ref.read(syncRepositoryProvider).resetRemoteSyncFromLocal();
      _refreshSyncedProviders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).syncDataReset),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        await _showSyncFailedDialog(error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _refreshSyncedProviders() {
    ref.invalidate(cyclesProvider);
    ref.invalidate(notesProvider);
    ref.invalidate(profileSettingsProvider);
    ref.invalidate(settingsProvider);
    ref.invalidate(upcomingCycleForecastProvider);
    ref.invalidate(currentCycleSummaryProvider);
    ref.invalidate(pendingCycleConflictsProvider);
  }
}

final profileAuthSessionProvider = FutureProvider.autoDispose<AuthSession>((
  ref,
) async {
  final authSession = ref.watch(authSessionProvider).asData?.value;
  if (authSession?.isAuthenticated == true) {
    return authSession!;
  }
  return ref.read(authRepositoryProvider).getCurrentSession();
});
