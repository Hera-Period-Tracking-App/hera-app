import 'package:flutter/material.dart';
import 'package:hera_app/features/notes/widgets/notes_security_card.dart';
import 'package:hera_app/shared/widgets/placeholder_feature_screen.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureScreen(
      title: 'Notes',
      description:
          'Sensitive note content remains isolated behind repositories and encryption services.',
      cards: [
        NotesSecurityCard(),
        SectionPlaceholderCard(
          title: 'Repository Boundary',
          body: 'Widgets only consume Riverpod state and never touch SQL or secrets directly.',
        ),
      ],
    );
  }
}
