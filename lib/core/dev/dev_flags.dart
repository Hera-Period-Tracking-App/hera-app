import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enable by passing `--dart-define=SHOW_ONBOARDING=true` to flutter run
const bool _envShowOnboarding = bool.fromEnvironment('SHOW_ONBOARDING', defaultValue: false);

/// Returns true only in debug builds when `SHOW_ONBOARDING` is set.
final devShowOnboardingProvider = Provider<bool>((_) => kDebugMode && _envShowOnboarding);
