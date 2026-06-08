import 'package:flutter/material.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class PrivacyModeCard extends StatelessWidget {
  const PrivacyModeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPlaceholderCard(
      title: 'Privacy Modes',
      body: 'Users can opt into local-only storage or a secure sync-ready mode.',
    );
  }
}
