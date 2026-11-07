import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/database/app_database.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/core/theme/app_theme.dart';
import 'package:hera_app/core/theme/app_theme_style.dart';
import 'package:hera_app/features/calendar/screens/add_note_screen.dart';
import 'package:hera_app/features/calendar/screens/calendar_date_details_screen.dart';
import 'package:hera_app/features/calendar/screens/calendar_screen.dart';
import 'package:hera_app/features/cycles/repositories/cycle_repository.dart';
import 'package:hera_app/features/notes/models/note.dart';
import 'package:hera_app/features/notes/repositories/note_repository.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

/// Real SQLite, repositories, encryption and platform secure storage.
/// Each case gets a fresh database and its own secure-storage namespace.
class TestEnvironment {
  TestEnvironment() {
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(database),
      secureStorageDataSourceProvider.overrideWithValue(storage),
    ]);
  }

  final database = _testDatabase();
  final storage = TestSecureStorage();
  late final ProviderContainer container;
  GoRouter? _router;

  CycleRepository get cycles => container.read(cycleRepositoryProvider);
  NoteRepository get notes => container.read(noteRepositoryProvider);

  Future<void> initialize() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
    }
    await database.into(database.userSettings).insert(
          UserSettingsCompanion.insert(
            id: 'default',
            privacyMode: 'localOnly',
            averageCycleLength: const Value(28),
            averageMenstruationLength: const Value(5),
            createdAt: DateTime.now(),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> mount(WidgetTester tester, String location) async {
    _router = GoRouter(initialLocation: location, routes: [
      GoRoute(
        path: '/calendar',
        builder: (context, state) => CalendarScreen(
          isStartNewCycleFlow: state.uri.queryParameters['startNewCycle'] == 'true',
          isEditCurrentCycleFlow: state.uri.queryParameters['editCurrentCycle'] == 'true',
          focusDate: DateTime.tryParse(state.uri.queryParameters['focusDate'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/calendar/date/:date',
        builder: (context, state) => CalendarDateDetailsScreen(
          date: DateTime.parse(state.pathParameters['date']!),
        ),
      ),
      GoRoute(
        path: '/calendar/note/new/:date',
        builder: (context, state) => AddNoteScreen(
          date: DateTime.parse(state.pathParameters['date']!),
          note: state.extra as Note?,
        ),
      ),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.build(AppThemeStyle.dark),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: _router,
      ),
    ));
    await tester.pumpAndSettle();
  }

  void go(String location) => _router!.go(location);

  Future<void> waitForNoteSaved(WidgetTester tester) async {
    // Native key storage/encryption may still be pending when there are no
    // scheduled frames; pumpAndSettle alone does not await those operations.
    for (var attempt = 0; attempt < 300; attempt++) {
      if (find.byType(AddNoteScreen).evaluate().isEmpty) {
        await tester.pumpAndSettle();
        return;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    fail('Urejevalnik se po shranjevanju opombe ni zaprl v 30 sekundah.');
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    _router?.dispose();
    container.dispose();
    await database.close();
    await storage.clearTestKeys();
  }
}

AppDatabase _testDatabase() {
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
  return AppDatabase.forTesting(NativeDatabase.memory());
}

class TestSecureStorage extends SecureStorageDataSource {
  final _prefix = 'hera.integration.${DateTime.now().microsecondsSinceEpoch}.';
  final _keys = <String>{};

  @override
  Future<String?> read(String key) => super.read('$_prefix$key');

  @override
  Future<void> write(String key, String value) {
    _keys.add(key);
    return super.write('$_prefix$key', value);
  }

  @override
  Future<void> delete(String key) => super.delete('$_prefix$key');

  Future<void> clearTestKeys() async {
    for (final key in _keys) {
      await delete(key);
    }
  }
}

Future<void> tapCalendarDay(WidgetTester tester, DateTime date) async {
  final day = find.byKey(ValueKey('calendar-day-${date.year}-${date.month}-${date.day}'));
  await tester.scrollUntilVisible(
    day,
    200,
    scrollable: find
        .descendant(
          of: find.byKey(const PageStorageKey<String>('calendar-month-list')),
          matching: find.byType(Scrollable),
        )
        .first,
    maxScrolls: 100,
  );
  await tester.ensureVisible(day);
  await tester.tap(day);
  await tester.pumpAndSettle();
}
