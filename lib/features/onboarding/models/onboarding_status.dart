import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hera_app/shared/models/privacy_mode.dart';

part 'onboarding_status.freezed.dart';
part 'onboarding_status.g.dart';

@freezed
abstract class OnboardingStatus with _$OnboardingStatus {
  const factory OnboardingStatus({
    required bool hasCompletedOnboarding,
    required PrivacyMode selectedPrivacyMode,
  }) = _OnboardingStatus;

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) => _$OnboardingStatusFromJson(json);
}
