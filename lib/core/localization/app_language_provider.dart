import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/constants/app_constants.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';

enum AppLanguage {
  english('en', 'English'),
  slovenian('sl', 'Slovenscina');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    return switch (code) {
      'sl' => AppLanguage.slovenian,
      _ => AppLanguage.english,
    };
  }
}

final appLanguageProvider =
    AsyncNotifierProvider<AppLanguageNotifier, AppLanguage>(
  AppLanguageNotifier.new,
);

class AppLanguageNotifier extends AsyncNotifier<AppLanguage> {
  @override
  Future<AppLanguage> build() async {
    final code = await ref
        .read(secureStorageDataSourceProvider)
        .read(AppConstants.appLanguageCodeKey);
    return AppLanguage.fromCode(code);
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = AsyncData(language);
    await ref
        .read(secureStorageDataSourceProvider)
        .write(AppConstants.appLanguageCodeKey, language.code);
  }
}
