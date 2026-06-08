import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/profile/providers/profile_provider.dart';
import 'package:hera_app/shared/widgets/placeholder_feature_screen.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(profileSettingsProvider);

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
      ],
    );
  }
}
