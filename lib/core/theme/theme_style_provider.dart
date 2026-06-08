import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/core/theme/app_theme_style.dart';

final themeStyleProvider =
    AsyncNotifierProvider<ThemeStyleNotifier, AppThemeStyle>(
  ThemeStyleNotifier.new,
);

class ThemeStyleNotifier extends AsyncNotifier<AppThemeStyle> {
  @override
  Future<AppThemeStyle> build() async {
    final storage = ref.read(secureStorageDataSourceProvider);
    final rawValue = await storage.read(AppConstants.themeStyleKey);

    return AppThemeStyle.values.firstWhere(
      (style) => style.name == rawValue,
      orElse: () => AppThemeStyle.dark,
    );
  }

  Future<void> setStyle(AppThemeStyle style) async {
    state = const AsyncLoading();
    final storage = ref.read(secureStorageDataSourceProvider);
    await storage.write(AppConstants.themeStyleKey, style.name);
    state = AsyncData(style);
  }
}
