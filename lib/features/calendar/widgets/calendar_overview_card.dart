import 'package:flutter/material.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class CalendarOverviewCard extends StatelessWidget {
  const CalendarOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionPlaceholderCard(
      title: 'Calendar Timeline',
      body: 'Cycle phases, symptoms, and notes can converge into one monthly view.',
    );
  }
}
