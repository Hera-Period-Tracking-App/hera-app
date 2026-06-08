import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hera_app/shared/models/privacy_mode.dart';

part 'settings_state.freezed.dart';
part 'settings_state.g.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    required PrivacyMode privacyMode,
    required bool biometricsEnabled,
    required bool pinEnabled,
    required bool notificationsEnabled,
  }) = _SettingsState;

  factory SettingsState.fromJson(Map<String, dynamic> json) => _$SettingsStateFromJson(json);
}
