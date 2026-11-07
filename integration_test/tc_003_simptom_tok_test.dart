import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hera_app/features/notes/utils/note_content_codec.dart';
import 'package:integration_test/integration_test.dart';

import 'support/test_environment.dart';

/// TC-003 / F-03 / TCI-03: izberi simptom in tok, shrani, ponovno odpri.
/// Podatki: Blagi krči.; Cramps; Medium; 15. 9. 2026.
/// Preveri točen zapis iz specifikacije in izbiro v ponovno odprtem urejevalniku.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-003: ohrani besedilo, simptom in menstrualni tok', (tester) async {
    final env = TestEnvironment();
    addTearDown(() => env.dispose(tester));
    await env.initialize();
    await env.mount(tester, '/calendar/note/new/2026-09-15');
    await tester.enterText(find.byType(TextField), 'Blagi krči.');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Symptoms'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Cramps'));
    final medium = find.widgetWithText(ChoiceChip, 'Medium');
    await tester.ensureVisible(medium);
    await tester.tap(medium);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save note'));
    await env.waitForNoteSaved(tester);

    final note = await env.notes.watchNoteForDate(DateTime(2026, 9, 15)).first;
    expect(note, isNotNull);
    expect(note!.encryptedContent, 'Blagi krči.\n\nSymptoms: Cramps\n\nMenstrual flow: Medium');
    final content = NoteContentCodec.parse(note.encryptedContent);
    expect(content.text, 'Blagi krči.');
    expect(content.symptoms, {'Cramps'});
    expect(content.flow, 'Medium');
    env.go('/calendar/date/2026-09-15');
    await tester.pumpAndSettle();
    expect(find.textContaining('Cramps', findRichText: true), findsOneWidget);
    expect(find.textContaining('Medium', findRichText: true), findsOneWidget);
    await tester.tap(find.byTooltip('Edit note'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'Blagi krči.');
    await tester.tap(find.text('Symptoms'));
    await tester.pumpAndSettle();
    expect(tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Cramps')).selected, isTrue);
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Medium'));
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Medium')).selected, isTrue);
    expect(tester.takeException(), isNull);
  });
}
