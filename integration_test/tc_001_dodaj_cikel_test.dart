import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/test_environment.dart';

/// TC-001 / F-01 / TCI-01: pozitiven vnos cikla prek koledarja.
/// Podatki: 1. 9. 2026, cikel 28 dni, menstruacija 5 dni.
/// Predpogoj: datum naprave >= 1. 9. 2026; prazna izolirana baza.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-001: dodaj veljaven cikel in ponovno odpri koledar', (tester) async {
    final env = TestEnvironment();
    addTearDown(() => env.dispose(tester));
    await env.initialize();
    await env.mount(tester, '/calendar?startNewCycle=true&focusDate=2026-09-01');

    await tapCalendarDay(tester, DateTime(2026, 9, 1));
    await tester.tap(find.text('Start new cycle').last);
    await tester.pumpAndSettle();

    final cycles = await env.cycles.watchSummaries().first;
    expect(cycles, hasLength(1));
    expect(cycles.single.startDate, DateTime(2026, 9, 1));
    expect(cycles.single.cycleLength, 28);
    expect(cycles.single.menstruationLength, 5);
    env.go('/calendar?focusDate=2026-09-01');
    await tester.pumpAndSettle();
    expect(find.textContaining('28 day cycle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
