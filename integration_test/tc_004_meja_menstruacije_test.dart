import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/test_environment.dart';

/// TC-004 / F-04 / TCI-04: prek koledarja odstrani 5. 9. 2026.
/// Predpogoj: cikel 1. 9. 2026, dolžina 28, menstruacija 5 dni.
/// Rezultat: ista vrstica v bazi, začetek 1. 9., trajanje 4, konec 4. 9.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-004: odstrani zadnji dan menstruacije in shrani', (tester) async {
    final env = TestEnvironment();
    addTearDown(() => env.dispose(tester));
    await env.initialize();
    requirePastDate(DateTime(2026, 9, 5));
    await env.cycles.addCycle(startDate: DateTime(2026, 9, 1), cycleLength: 28, menstruationLength: 5);
    final original = (await env.cycles.watchSummaries().first).single;
    expect(original.startDate, DateTime(2026, 9, 1));
    expect(original.cycleLength, 28);
    expect(original.menstruationLength, 5);
    await env.mount(tester, '/calendar?editCurrentCycle=true&focusDate=2026-09-05');
    await tapCalendarDay(tester, DateTime(2026, 9, 5));
    final save = find.widgetWithText(FilledButton, 'Save changes');
    await waitForElement(tester, save.hitTestable());
    await tester.tap(save);
    await waitForElement(tester, save, absent: true);
    await tester.pumpAndSettle();

    final cycles = await env.cycles.watchSummaries().first;
    expect(cycles, hasLength(1));
    expect(cycles.single.id, original.id);
    expect(cycles.single.startDate, DateTime(2026, 9, 1));
    expect(cycles.single.cycleLength, 28);
    expect(cycles.single.menstruationLength, 4);
    expect(cycles.single.startDate.add(Duration(days: cycles.single.menstruationLength! - 1)), DateTime(2026, 9, 4));
    env.go('/calendar?focusDate=2026-09-01');
    await tester.pumpAndSettle();
    expect(find.textContaining('4 day period'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
