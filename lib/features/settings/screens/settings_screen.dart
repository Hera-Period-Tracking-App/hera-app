import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/auth/providers/auth_provider.dart';
import 'package:hera_app/features/settings/providers/auto_sync_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authSessionProvider);
    final isSignedIn = authState.asData?.value.isAuthenticated ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: settings.when(
          data: (value) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Cycle notifications'),
                  subtitle: const Text(
                    'Reminders for upcoming menstruation, ovulation, fertile window, and late periods.',
                  ),
                  value: value.notificationsEnabled,
                  onChanged: (enabled) => ref
                      .read(settingsProvider.notifier)
                      .setNotificationsEnabled(enabled),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.edit_note_outlined),
                  title: const Text('Notes'),
                  subtitle: const Text(
                    'Show saved notes and allow adding new notes from the app.',
                  ),
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
                  title: const Text('AI summaries'),
                  subtitle: const Text(
                    'Allow Hera to generate cycle summaries from your local cycle data and notes.',
                  ),
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
                  title: const Text('Automatic sync'),
                  subtitle: Text(
                    isSignedIn
                        ? 'Automatically sync encrypted data with the server when the app runs.'
                        : 'Sign in to enable automatic server sync.',
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
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Could not load settings: $error'),
            ),
          ),
        ),
      ),
    );
  }
}
