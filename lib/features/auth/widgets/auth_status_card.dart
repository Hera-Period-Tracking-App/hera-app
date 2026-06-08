import 'package:flutter/material.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class AuthStatusCard extends StatelessWidget {
  const AuthStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPlaceholderCard(
      title: 'Authentication Architecture',
      body: 'Session, biometric unlock, and optional secure sync start here.',
    );
  }
}
