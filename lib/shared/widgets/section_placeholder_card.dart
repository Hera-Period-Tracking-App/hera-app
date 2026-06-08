import 'package:flutter/material.dart';

class SectionPlaceholderCard extends StatelessWidget {
  const SectionPlaceholderCard({
    required this.title,
    required this.body,
    super.key,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(body, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
