import 'package:flutter/material.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class NotesSecurityCard extends StatelessWidget {
  const NotesSecurityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPlaceholderCard(
      title: 'Encrypted Notes',
      body: 'Custom journal text is routed through the encryption service before storage.',
    );
  }
}
