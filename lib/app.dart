import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/localization/app_language_provider.dart';
import 'package:hera_app/core/routes/app_router.dart';
import 'package:hera_app/core/theme/app_theme.dart';
import 'package:hera_app/core/theme/app_theme_style.dart';
import 'package:hera_app/core/theme/theme_style_provider.dart';
import 'package:hera_app/features/cycle_notifications/providers/cycle_notification_sync_provider.dart';
import 'package:hera_app/features/settings/providers/app_lock_provider.dart';
import 'package:hera_app/features/settings/providers/auto_sync_provider.dart';
import 'package:hera_app/features/settings/screens/app_unlock_screen.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';
import 'package:hera_app/shared/providers/app_startup_provider.dart';
import 'package:hera_app/shared/screens/startup_loading_screen.dart';

class HeraApp extends ConsumerStatefulWidget {
  const HeraApp({super.key});

  @override
  ConsumerState<HeraApp> createState() => _HeraAppState();
}

class _HeraAppState extends ConsumerState<HeraApp> with WidgetsBindingObserver {
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
    } else if (state == AppLifecycleState.inactive) {
      // Android marks the app inactive while its native fingerprint dialog is
      // open. Locking here cancels that dialog before authentication finishes.
      if (ref.read(appLockProvider.notifier).isAuthenticatingWithBiometrics) {
        return;
      }
      ref.read(appLockProvider.notifier).lock();
    } else if (state == AppLifecycleState.paused) {
      ref.read(appLockProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeStyle =
        ref.watch(themeStyleProvider).asData?.value ?? AppThemeStyle.dark;
    final language =
        ref.watch(appLanguageProvider).asData?.value ?? AppLanguage.english;
    final startupReady = ref.watch(appStartupReadyProvider);
    final appLock = ref.watch(appLockProvider);
    ref.watch(cycleNotificationSyncProvider);
    ref.watch(autoSyncProvider);

    if (!startupReady.hasValue) {
      return MaterialApp(
        title: 'Hera',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(themeStyle),
        locale: language.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const StartupLoadingScreen(),
      );
    }

    final router = ref.watch(appRouterProvider);
    final shouldLock = appLock.maybeWhen(
      data: (value) => value.enabled && value.locked,
      orElse: () => false,
    );

    return MaterialApp.router(
      title: 'Hera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(themeStyle),
      locale: language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (shouldLock) const AppUnlockScreen(),
          ],
        );
      },
    );
  }
}
