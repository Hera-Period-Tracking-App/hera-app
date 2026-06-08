import 'package:flutter/material.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/core/theme/app_theme_style.dart';

class ThemeChoiceCard extends StatelessWidget {
  const ThemeChoiceCard({
    super.key,
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final AppThemeStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = switch (style) {
      AppThemeStyle.light => (
          label: 'Light',
          colors: [AppColors.forest, AppColors.sand, AppColors.mist],
          description: 'Light, clean, and calm.',
        ),
      AppThemeStyle.dark => (
          label: 'Dark',
          colors: [AppColors.twilight, AppColors.moon, AppColors.ink],
          description: 'Dark, quiet, and focused.',
        ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.18),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Row(
                children: config.colors.map((color) {
                  return Container(
                    width: 28,
                    height: 72,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(config.label, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(config.description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
