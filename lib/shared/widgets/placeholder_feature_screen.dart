import 'package:flutter/material.dart';

class PlaceholderFeatureScreen extends StatelessWidget {
  const PlaceholderFeatureScreen({
    this.title,
    this.description,
    this.actions = const [],
    required this.cards,
    super.key,
  });

  final String? title;
  final String? description;
  final List<Widget> actions;
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(child: Text(title!, style: textTheme.titleLarge)),
                ...actions,
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (description != null) ...[
            Text(description!, style: textTheme.bodyLarge),
            const SizedBox(height: 24),
          ],
          ...cards.expand(
            (card) => [
              card,
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
