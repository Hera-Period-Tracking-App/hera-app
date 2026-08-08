import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/auth/providers/auth_provider.dart';
import 'package:hera_app/features/settings/providers/settings_provider.dart';
import 'package:hera_app/features/settings/repositories/sync_repository.dart';

final autoSyncProvider = Provider<AutoSyncController>((ref) {
  final controller = AutoSyncController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

class AutoSyncController {
  AutoSyncController(this._ref);

  static const Duration debounceDuration = Duration(seconds: 10);
  static const Duration staleDuration = Duration(minutes: 15);

  final Ref _ref;
  Timer? _debounceTimer;
  DateTime? _lastSyncAttemptAt;
  bool _isSyncing = false;

  void dispose() {
    _debounceTimer?.cancel();
  }

  Future<void> syncOnStartup() {
    return _syncIfAllowed(force: true);
  }

  Future<void> syncIfStale() {
    final lastAttempt = _lastSyncAttemptAt;
    if (lastAttempt != null &&
        DateTime.now().difference(lastAttempt) < staleDuration) {
      return Future<void>.value();
    }

    return _syncIfAllowed(force: true);
  }

  void queueSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      unawaited(_syncIfAllowed());
    });
  }

  Future<void> _syncIfAllowed({bool force = false}) async {
    if (_isSyncing) {
      return;
    }

    final settings = await _ref.read(settingsProvider.future);
    final session = await _ref.read(authSessionProvider.future);
    if (!settings.autoSyncEnabled || !session.isAuthenticated) {
      return;
    }

    final lastAttempt = _lastSyncAttemptAt;
    if (!force &&
        lastAttempt != null &&
        DateTime.now().difference(lastAttempt) < debounceDuration) {
      return;
    }

    _isSyncing = true;
    _lastSyncAttemptAt = DateTime.now();
    try {
      await _ref.read(syncRepositoryProvider).syncNow();
    } finally {
      _isSyncing = false;
    }
  }
}
