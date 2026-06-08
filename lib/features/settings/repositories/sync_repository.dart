import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/shared/models/privacy_mode.dart';

final syncRepositoryProvider = Provider<SyncRepository>(
  (ref) => const SyncRepository(),
);

class SyncRepository {
  const SyncRepository();

  Future<bool> isSyncAvailable(PrivacyMode privacyMode) async {
    return privacyMode == PrivacyMode.secureSync;
  }
}
