import 'package:flutter/material.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/core/theme/app_text_theme.dart';
import 'package:hera_app/core/theme/app_theme_style.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build(AppThemeStyle style) {
    return switch (style) {
      AppThemeStyle.light => _themeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.forest,
            brightness: Brightness.light,
            primary: AppColors.forest,
            secondary: AppColors.clay,
            surface: Colors.white,
          ),
          scaffoldColor: AppColors.mist,
          cardColor: Colors.white,
          indicatorColor: AppColors.sand,
        ),
      AppThemeStyle.dark => _themeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.twilight,
            brightness: Brightness.dark,
            primary: AppColors.moon,
            secondary: AppColors.forest,
            surface: const Color(0xFF1B1D27),
          ),
          scaffoldColor: AppColors.twilight,
          cardColor: const Color(0xFF1B1D27),
          indicatorColor: const Color(0xFF2B2D38),
        ),
    };
  }

  static ThemeData _themeData({
    required ColorScheme colorScheme,
    required Color scaffoldColor,
    required Color cardColor,
    required Color indicatorColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldColor,
      textTheme: AppTextTheme.build(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: indicatorColor,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
