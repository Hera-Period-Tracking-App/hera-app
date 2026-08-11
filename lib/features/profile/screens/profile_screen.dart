import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/auth/models/auth_session.dart';
import 'package:hera_app/features/auth/providers/auth_provider.dart';
import 'package:hera_app/features/auth/repositories/auth_repository.dart';
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
    final authState = ref.watch(profileAuthSessionProvider);
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
          title: 'Account',
          body: authState.when(
            data: (session) {
              if (!session.isAuthenticated) {
                return 'You are not signed in. Create an account or log in to use secure sync.';
              }

              final email = session.email?.trim();
              if (email == null || email.isEmpty) {
                return 'You are signed in.';
              }
              return 'You are signed in as $email.';
            },
            loading: () => 'Checking account status...',
            error: (error, stackTrace) => 'Could not load account status.',
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
                          label: const Text('Edit account'),
                        ),
                        FilledButton.icon(
                          onPressed: () async {
                            await ref
                                .read(authSessionProvider.notifier)
                                .logout();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Signed out.')),
                              );
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign out'),
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
                          label: const Text('Create account'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.push(AppRoutePaths.authLogin),
                          icon: const Icon(Icons.login),
                          label: const Text('Log in'),
                        ),
                      ],
                    ),
              loading: () => const FilledButton(
                onPressed: null,
                child: Text('Checking...'),
              ),
              error: (error, stackTrace) => OutlinedButton.icon(
                onPressed: () => ref.invalidate(authSessionProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
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

final profileAuthSessionProvider = FutureProvider.autoDispose<AuthSession>((
  ref,
) async {
  final authSession = ref.watch(authSessionProvider).asData?.value;
  if (authSession?.isAuthenticated == true) {
    return authSession!;
  }
  return ref.read(authRepositoryProvider).getCurrentSession();
});
