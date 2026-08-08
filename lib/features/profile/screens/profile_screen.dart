import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/auth/providers/auth_provider.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/features/settings/repositories/sync_repository.dart';
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
    final authState = ref.watch(authSessionProvider);
    final session = authState.asData?.value;
    final isSignedIn = session?.isAuthenticated ?? false;

    return PlaceholderFeatureScreen(
      title: 'Profile',
      description:
          'Basic user details, privacy controls, and app settings are grouped here.',
      cards: [
        settings.when(
          data: (value) {
            final averageCycleLength = value.averageCycleLength;
            final averageMenstruationLength = value.averageMenstruationLength;

            if (averageCycleLength == null &&
                averageMenstruationLength == null) {
              return const SectionPlaceholderCard(
                title: 'Average cycle settings',
                body:
                    'No averages saved yet. Complete onboarding to store your cycle and menstruation lengths.',
              );
            }

            return SectionPlaceholderCard(
              title: 'Average cycle settings',
              body:
                  'Average cycle length: ${averageCycleLength ?? '-'} days\nAverage menstruation length: ${averageMenstruationLength ?? '-'} days',
            );
          },
          loading: () => const SectionPlaceholderCard(
            title: 'Average cycle settings',
            body: 'Loading your saved averages...',
          ),
          error: (error, stackTrace) => const SectionPlaceholderCard(
            title: 'Average cycle settings',
            body: 'Could not load your saved averages.',
          ),
        ),
        SectionPlaceholderCard(
          title: 'Settings',
          body:
              'Manage notifications, AI summaries, and other app preferences.',
          footer: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => context.push(AppRoutePaths.settings),
              icon: const Icon(Icons.settings),
              label: const Text('Open settings'),
            ),
          ),
        ),
        SectionPlaceholderCard(
          title: 'Session',
          body: authState.when(
            data: (session) => session.isAuthenticated
                ? 'You are signed in. Sign out to remove the stored session from secure storage.'
                : 'You are currently signed out.',
            loading: () => 'Checking session status...',
            error: (error, stackTrace) => 'Could not load session status.',
          ),
          footer: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: authState.isLoading
                  ? null
                  : () async {
                      await ref.read(authSessionProvider.notifier).logout();
                      if (context.mounted) {
                        context.go(AppRoutePaths.auth);
                      }
                    },
              child: const Text('Sign out'),
            ),
          ),
        ),
        SectionPlaceholderCard(
          title: 'Sync',
          body: isSignedIn
              ? 'Upload encrypted local records, then pull newer encrypted changes from the API into the local database.'
              : 'Sign in first to sync local encrypted data with the API.',
          footer: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: !isSignedIn || _isSyncing ? null : _syncNow,
              child: Text(_isSyncing ? 'Syncing...' : 'Sync now'),
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
      final result = await ref.read(syncRepositoryProvider).syncNow();
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sync complete. Uploaded ${result.uploadedCount}, downloaded ${result.downloadedCount}, applied ${result.appliedCount}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Sync failed'),
            content: SingleChildScrollView(
              child: SelectableText(error.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }
}
