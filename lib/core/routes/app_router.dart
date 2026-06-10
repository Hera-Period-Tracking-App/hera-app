import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/dev/dev_flags.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/auth/screens/auth_screen.dart';
import 'package:hera_app/features/calendar/screens/calendar_date_details_screen.dart';
import 'package:hera_app/features/calendar/screens/calendar_screen.dart';
import 'package:hera_app/features/home/screens/home_screen.dart';
import 'package:hera_app/features/notes/screens/notes_screen.dart';
import 'package:hera_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hera_app/features/onboarding/screens/onboarding_screen.dart';
import 'package:hera_app/features/profile/screens/profile_screen.dart';
import 'package:hera_app/shared/providers/app_startup_provider.dart';
import 'package:hera_app/shared/screens/startup_loading_screen.dart';
import 'package:hera_app/shared/widgets/app_shell_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingState = ref.watch(onboardingProvider);
  final startupReadyState = ref.watch(appStartupReadyProvider);
  final forceShowOnboarding = ref.watch(devShowOnboardingProvider);

  return GoRouter(
    initialLocation: AppRoutePaths.splash,
    redirect: (context, state) {
      final isSplashRoute = state.matchedLocation == AppRoutePaths.splash;
      final isOnboardingRoute = state.matchedLocation == AppRoutePaths.onboarding;

      if (onboardingState.isLoading || startupReadyState.isLoading) {
        return isSplashRoute ? null : AppRoutePaths.splash;
      }

      if (startupReadyState.hasError) {
        return isSplashRoute ? null : AppRoutePaths.splash;
      }

      if (onboardingState.hasError) {
        return isSplashRoute ? null : AppRoutePaths.splash;
      }

      final hasCompletedOnboarding =
          onboardingState.asData?.value.hasCompletedOnboarding ?? false;

      if (forceShowOnboarding) {
        return isOnboardingRoute ? null : AppRoutePaths.onboarding;
      }

      if (!hasCompletedOnboarding) {
        return isOnboardingRoute ? null : AppRoutePaths.onboarding;
      }

      if (isOnboardingRoute || isSplashRoute) {
        return AppRoutePaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutePaths.splash,
        name: 'splash',
        builder: (context, state) => const StartupLoadingScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.auth,
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.calendar,
                name: 'calendar',
                builder: (context, state) {
                  final startNewCycle =
                      state.uri.queryParameters['startNewCycle'] == 'true';
                  final focusTodayToken =
                      int.tryParse(state.uri.queryParameters['focusToday'] ?? '');
                  return CalendarScreen(
                    isStartNewCycleFlow: startNewCycle,
                    focusTodayToken: focusTodayToken,
                  );
                },
              ),
              GoRoute(
                path: AppRoutePaths.calendarDateDetails,
                name: 'calendar-date-details',
                builder: (context, state) {
                  final dateParam = state.pathParameters['date'];
                  final date = _parseCalendarRouteDate(dateParam);
                  if (date == null) {
                    return const CalendarScreen();
                  }
                  return CalendarDateDetailsScreen(date: date);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.notes,
                name: 'notes',
                builder: (context, state) => const NotesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text('Route not found: ${state.uri}'),
        ),
      );
    },
  );
});

DateTime? _parseCalendarRouteDate(String? value) {
  if (value == null) {
    return null;
  }

  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) {
    return null;
  }

  final year = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final day = int.tryParse(match.group(3)!);
  if (year == null || month == null || day == null) {
    return null;
  }

  final parsed = DateTime(year, month, day);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    return null;
  }
  return parsed;
}
