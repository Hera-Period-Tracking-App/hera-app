import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/routes/app_router.dart';
import 'package:hera_app/core/theme/app_theme.dart';
import 'package:hera_app/core/theme/app_theme_style.dart';
import 'package:hera_app/core/theme/theme_style_provider.dart';
import 'package:hera_app/features/cycle_notifications/providers/cycle_notification_sync_provider.dart';

class HeraApp extends ConsumerWidget {
  const HeraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeStyle =
      ref.watch(themeStyleProvider).asData?.value ?? AppThemeStyle.dark;
    ref.watch(cycleNotificationSyncProvider);

    return MaterialApp.router(
      title: 'Hera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(themeStyle),
      routerConfig: router,
    );
  }
}
