import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hera_app/core/encryption/encryption_service.dart';
import 'package:integration_test/integration_test.dart';

import 'support/test_environment.dart';

/// TC-002 / F-02 / TCI-02: UI -> repozitorij -> AES-GCM -> SQLite -> UI.
/// Vhod: 15. 9. 2026 ob 14:30; "  Blagi krči.  ".
/// Rezultat: datum brez ure, šifrirana vsebina in ponovno prebrano obrezano besedilo.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-002: shrani šifrirano opombo in jo ponovno odpri', (tester) async {
    final env = TestEnvironment();
    addTearDown(() => env.dispose(tester));
    await env.initialize();
    await env.mount(tester, '/calendar/note/new/2026-09-15T14:30:00');
    await tester.enterText(find.byType(EditableText), '  Blagi krči.  ');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save note'));
    await env.waitForNoteSaved(tester);

    final rows = await env.database.select(env.database.noteEntries).get();
    expect(rows, hasLength(1));
    expect(rows.single.date, DateTime(2026, 9, 15));
    expect(rows.single.cycleId, isNull);
    expect(rows.single.encryptedContent, isNot(contains('Blagi krči.')));
    expect(jsonDecode(rows.single.encryptedContent)['alg'], 'A256GCM');
    // A fresh encryption service must recover the key from platform storage.
    expect(await EncryptionService(secureStorage: env.storage).decrypt(rows.single.encryptedContent), 'Blagi krči.');
    env.go('/calendar/date/2026-09-15');
    await tester.pumpAndSettle();
    expect(find.textContaining('Blagi krči.', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
