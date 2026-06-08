import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/settings/models/settings_state.dart';
import 'package:hera_app/features/settings/repositories/settings_repository.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() {
    return ref.read(settingsRepositoryProvider).getSettings();
  }
}
