import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/services/privacy_mode_manager.dart';
import 'package:hera_app/features/settings/models/settings_state.dart';

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(ref),
);

class SettingsService {
  const SettingsService(this._ref);

  final Ref _ref;

  Future<SettingsState> loadSettings() async {
    final privacyMode = await _ref.read(privacyModeManagerProvider.future);

    return SettingsState(
      privacyMode: privacyMode,
      biometricsEnabled: false,
      pinEnabled: false,
      notificationsEnabled: false,
    );
  }
}
