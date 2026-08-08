import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/routes/app_router.dart';
import 'package:hera_app/core/theme/app_theme.dart';
import 'package:hera_app/core/theme/app_theme_style.dart';
import 'package:hera_app/core/theme/theme_style_provider.dart';
import 'package:hera_app/features/cycle_notifications/providers/cycle_notification_sync_provider.dart';
import 'package:hera_app/features/settings/providers/auto_sync_provider.dart';

class HeraApp extends ConsumerStatefulWidget {
  const HeraApp({super.key});

  @override
  ConsumerState<HeraApp> createState() => _HeraAppState();
}

class _HeraAppState extends ConsumerState<HeraApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => ref.read(autoSyncProvider).syncOnStartup());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(autoSyncProvider).syncIfStale();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeStyle =
        ref.watch(themeStyleProvider).asData?.value ?? AppThemeStyle.dark;
    ref.watch(cycleNotificationSyncProvider);
    ref.watch(autoSyncProvider);

    return MaterialApp.router(
      title: 'Hera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(themeStyle),
      routerConfig: router,
    );
  }
}
