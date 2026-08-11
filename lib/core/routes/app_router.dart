import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/dev/dev_flags.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/features/auth/screens/auth_screen.dart';
import 'package:hera_app/features/calendar/screens/add_note_screen.dart';
import 'package:hera_app/features/calendar/screens/calendar_date_details_screen.dart';
import 'package:hera_app/features/calendar/screens/calendar_screen.dart';
import 'package:hera_app/features/home/screens/home_screen.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/screens/notes_screen.dart';
import 'package:hera_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hera_app/features/onboarding/screens/onboarding_screen.dart';
import 'package:hera_app/features/profile/screens/edit_account_screen.dart';
import 'package:hera_app/features/profile/screens/profile_screen.dart';
import 'package:hera_app/features/settings/screens/settings_screen.dart';

import 'package:hera_app/shared/widgets/app_shell_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingState = ref.watch(onboardingProvider);
  final forceShowOnboarding = ref.watch(devShowOnboardingProvider);

  return GoRouter(
    initialLocation: AppRoutePaths.onboarding,
    redirect: (context, state) {
      final isOnboardingRoute =
          state.matchedLocation == AppRoutePaths.onboarding;

      if (onboardingState.isLoading || onboardingState.hasError) {
        return isOnboardingRoute ? null : AppRoutePaths.onboarding;
      }

      final hasCompletedOnboarding =
          onboardingState.asData?.value.hasCompletedOnboarding ?? false;

      if (forceShowOnboarding) {
        return isOnboardingRoute ? null : AppRoutePaths.onboarding;
      }

      if (!hasCompletedOnboarding) {
        return isOnboardingRoute ? null : AppRoutePaths.onboarding;
      }

      if (isOnboardingRoute) {
        return AppRoutePaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutePaths.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.auth,
        name: 'auth',
        builder: (context, state) => const AuthScreen(mode: AuthScreenMode.login),
      ),
      GoRoute(
        path: AppRoutePaths.authLogin,
        name: 'auth-login',
        builder: (context, state) => const AuthScreen(mode: AuthScreenMode.login),
      ),
      GoRoute(
        path: AppRoutePaths.authSignup,
        name: 'auth-signup',
        builder: (context, state) => const AuthScreen(mode: AuthScreenMode.signup),
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
                  final addNote =
                      state.uri.queryParameters['addNote'] == 'true';
                  final editCurrentCycle =
                      state.uri.queryParameters['editCurrentCycle'] == 'true';
                  final focusTodayToken = int.tryParse(
                      state.uri.queryParameters['focusToday'] ?? '');
                  final focusAddNoteToken = int.tryParse(
                      state.uri.queryParameters['focusAddNote'] ?? '');
                  final focusDate = _parseCalendarRouteDate(
                    state.uri.queryParameters['focusDate'],
                  );
                  return CalendarScreen(
                    isStartNewCycleFlow: startNewCycle,
                    isAddNoteFlow: addNote,
                    isEditCurrentCycleFlow: editCurrentCycle,
                    focusTodayToken: focusTodayToken,
                    focusAddNoteToken: focusAddNoteToken,
                    focusDate: focusDate,
                  );
                },
              ),
              GoRoute(
                path: AppRoutePaths.calendarDateDetails,
                name: 'calendar-date-details',
                pageBuilder: (context, state) {
                  final dateParam = state.pathParameters['date'];
                  final date = _parseCalendarRouteDate(dateParam);
                  if (date == null) {
                    return const MaterialPage(child: CalendarScreen());
                  }
                  return CustomTransitionPage<void>(
                    key: state.pageKey,
                    child: CalendarDateDetailsScreen(date: date),
                    transitionDuration: const Duration(milliseconds: 380),
                    reverseTransitionDuration:
                        const Duration(milliseconds: 280),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      final curvedAnimation = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                        reverseCurve: Curves.easeInCubic,
                      );
                      return FadeTransition(
                        opacity: curvedAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.16),
                            end: Offset.zero,
                          ).animate(curvedAnimation),
                          child: child,
                        ),
                      );
                    },
                  );
                },
              ),
              GoRoute(
                path: AppRoutePaths.calendarAddNote,
                name: 'calendar-add-note',
                builder: (context, state) {
                  final dateParam = state.pathParameters['date'];
                  final date = _parseCalendarRouteDate(dateParam);
                  if (date == null) {
                    return const CalendarScreen();
                  }
                  return AddNoteScreen(
                    date: date,
                    note: state.extra is Note ? state.extra as Note : null,
                  );
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
              GoRoute(
                path: AppRoutePaths.editAccount,
                name: 'edit-account',
                builder: (context, state) => const EditAccountScreen(),
              ),
              GoRoute(
                path: AppRoutePaths.settings,
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
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
