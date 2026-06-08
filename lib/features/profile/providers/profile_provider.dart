import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/profile/models/profile_settings_summary.dart';
import 'package:hera_app/features/profile/repositories/profile_repository.dart';

final profileSettingsProvider = StreamProvider<ProfileSettingsSummary>(
  (ref) => ref.watch(profileRepositoryProvider).watchSettingsSummary(),
);
