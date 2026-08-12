import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/localization/app_language_provider.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/auth/providers/auth_provider.dart';
import 'package:hera_app/features/settings/providers/auto_sync_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authSessionProvider);
    final isSignedIn = authState.asData?.value.isAuthenticated ?? false;
    final language =
        ref.watch(appLanguageProvider).asData?.value ?? AppLanguage.english;
    final l10n = AppLocalizations.of(context);
    final languageLabel =
        language == AppLanguage.slovenian ? l10n.slovenian : l10n.english;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: SafeArea(
        child: settings.when(
          data: (value) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: Text(l10n.cycleNotifications),
                  subtitle: Text(l10n.cycleNotificationsDescription),
                  value: value.notificationsEnabled,
                  onChanged: (enabled) => ref
                      .read(settingsProvider.notifier)
                      .setNotificationsEnabled(enabled),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.lock_outline),
                  title: Text(l10n.appLock),
                  subtitle: Text(
                    value.biometricsEnabled
                        ? l10n.appLockBiometricsDescription
                        : value.pinEnabled
                            ? l10n.appLockPinDescription
                            : l10n.appLockDisabledDescription,
                  ),
                  value: value.pinEnabled,
                  onChanged: (enabled) async {
                    if (!enabled) {
                      context.push(AppRoutePaths.appLockDisable);
                      return;
                    }
                    context.push(AppRoutePaths.appLockSetup);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.edit_note_outlined),
                  title: Text(l10n.notes),
                  subtitle: Text(l10n.notesDescription),
                  value: value.notesEnabled,
                  onChanged: (enabled) => ref
                      .read(settingsProvider.notifier)
                      .setNotesEnabled(enabled),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.auto_awesome),
                  title: Text(l10n.aiSummaries),
                  subtitle: Text(l10n.aiSummariesDescription),
                  value: value.aiSummariesEnabled,
                  onChanged: (enabled) => ref
                      .read(settingsProvider.notifier)
                      .setAiSummariesEnabled(enabled),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.sync),
                  title: Text(l10n.automaticSync),
                  subtitle: Text(
                    isSignedIn
                        ? l10n.automaticSyncSignedInDescription
                        : l10n.automaticSyncSignedOutDescription,
                  ),
                  value: isSignedIn && value.autoSyncEnabled,
                  onChanged: isSignedIn
                      ? (enabled) async {
                          await ref
                              .read(settingsProvider.notifier)
                              .setAutoSyncEnabled(enabled);
                          if (enabled) {
                            ref.read(autoSyncProvider).syncOnStartup();
                          }
                        }
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  subtitle: Text('${l10n.languageDescription} $languageLabel'),
                  trailing: const Icon(Icons.expand_more),
                  onTap: () => _showLanguagePicker(context, ref, language),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.couldNotLoadSettings(error.toString())),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    AppLanguage currentLanguage,
  ) {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: RadioGroup<AppLanguage>(
            groupValue: currentLanguage,
            onChanged: (language) {
                  if (language == null) {
                    return;
                  }
                  ref.read(appLanguageProvider.notifier).setLanguage(language);
                  Navigator.of(sheetContext).pop();
                },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<AppLanguage>(
                  value: AppLanguage.english,
                  title: Text(l10n.english),
                ),
                RadioListTile<AppLanguage>(
                  value: AppLanguage.slovenian,
                  title: Text(l10n.slovenian),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
