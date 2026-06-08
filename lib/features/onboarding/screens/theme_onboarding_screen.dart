import 'package:flutter/material.dart';
import 'package:hera_app/core/theme/app_theme_style.dart';
import 'package:hera_app/features/onboarding/widgets/theme_choice_card.dart';

class ThemeOnboardingScreen extends StatelessWidget {
  const ThemeOnboardingScreen({
    super.key,
    required this.selectedTheme,
    required this.onSelected,
  });

  final AppThemeStyle selectedTheme;
  final ValueChanged<AppThemeStyle> onSelected;

  @override
  Widget build(BuildContext context) {
    const styles = AppThemeStyle.values;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: styles.length,
      separatorBuilder: (_, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final style = styles[index];
        return ThemeChoiceCard(
          style: style,
          selected: selectedTheme == style,
          onTap: () => onSelected(style),
        );
      },
    );
  }
}
