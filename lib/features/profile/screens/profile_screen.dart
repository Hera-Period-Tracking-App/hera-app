import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/networking/api_client.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/app_colors.dart';
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
import 'package:hera_app/shared/models/privacy_mode.dart';
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
    final appSettings = ref.watch(settingsProvider);
    final authState = ref.watch(profileAuthSessionProvider);
    final session = authState.asData?.value;
    final isSignedIn = session?.isAuthenticated ?? false;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            tooltip: l10n.syncNow,
            onPressed: !isSignedIn || _isSyncing ? null : _syncNow,
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: l10n.openSettings,
            onPressed: () => context.push(AppRoutePaths.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: PlaceholderFeatureScreen(
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
          appSettings.when(
            data: (value) => _PrivacyModeCard(
              title:
                  '${l10n.privacyModeTitle} - ${_privacyModeTitle(l10n, value.privacyMode)}'
                      .toUpperCase(),
              description: _privacyModeDescription(l10n, value.privacyMode),
              showAccountPrompt: !isSignedIn,
              showManageAccountPrompt:
                  isSignedIn && value.privacyMode == PrivacyMode.secureSync,
              accountPrompt: 'HAVE AN ACCOUNT?',
              createAccountLabel: l10n.createAccount,
              loginLabel: l10n.logIn,
              manageAccountPrompt: 'MANAGE ACCOUNT',
              email: session?.email?.trim(),
              editAccountLabel: l10n.editAccount,
              logoutLabel: l10n.signOut,
              onLogout: () async {
                await ref.read(authSessionProvider.notifier).logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.signedOutMessage),
                    ),
                  );
                }
              },
            ),
            loading: () => SectionPlaceholderCard(
              title: l10n.privacyModeTitle,
              body: l10n.loadingPrivacyMode,
            ),
            error: (error, stackTrace) => SectionPlaceholderCard(
              title: l10n.privacyModeTitle,
              body: l10n.couldNotLoadPrivacyMode,
            ),
          ),
        ],
      ),
    );
  }

  String _privacyModeTitle(AppLocalizations l10n, PrivacyMode mode) {
    return switch (mode) {
      PrivacyMode.secureSync => l10n.secureSyncModeTitle,
      PrivacyMode.localOnly => l10n.localOnlyModeTitle,
    };
  }

  String _privacyModeDescription(AppLocalizations l10n, PrivacyMode mode) {
    return switch (mode) {
      PrivacyMode.secureSync => l10n.secureSyncModeDescription,
      PrivacyMode.localOnly => l10n.localOnlyModeDescription,
    };
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
          backgroundColor: AppColors.twilight,
          content: Text(
            AppLocalizations.of(context).syncCompleteShort,
            style: const TextStyle(color: Colors.white),
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

class _PrivacyModeCard extends StatelessWidget {
  const _PrivacyModeCard({
    required this.title,
    required this.description,
    required this.showAccountPrompt,
    required this.showManageAccountPrompt,
    required this.accountPrompt,
    required this.createAccountLabel,
    required this.loginLabel,
    required this.manageAccountPrompt,
    required this.email,
    required this.editAccountLabel,
    required this.logoutLabel,
    required this.onLogout,
  });

  final String title;
  final String description;
  final bool showAccountPrompt;
  final bool showManageAccountPrompt;
  final String accountPrompt;
  final String createAccountLabel;
  final String loginLabel;
  final String manageAccountPrompt;
  final String? email;
  final String editAccountLabel;
  final String logoutLabel;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: textTheme.bodyMedium,
          ),
          if (showAccountPrompt) ...[
            const SizedBox(height: 20),
            Text(
              accountPrompt,
              style: textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutePaths.authSignup),
                  icon: const Icon(Icons.person_add),
                  label: Text(createAccountLabel),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutePaths.authLogin),
                  icon: const Icon(Icons.login),
                  label: Text(loginLabel),
                ),
              ],
            ),
          ],
          if (showManageAccountPrompt) ...[
            const SizedBox(height: 20),
            Text(
              manageAccountPrompt,
              style: textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            if (email != null && email!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'E-mail: $email',
                style: textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutePaths.editAccount),
                  icon: const Icon(Icons.edit),
                  label: Text(editAccountLabel),
                ),
                FilledButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout),
                  label: Text(logoutLabel),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
