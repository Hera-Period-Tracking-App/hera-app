import 'package:flutter_test/flutter_test.dart';
import 'package:hera_app/features/notes/constants/note_options.dart';
import 'package:hera_app/features/notes/utils/note_content_codec.dart';

/// ISO/IEC/IEEE 29119-1:2022 opisuje splošne koncepte; ne predpisuje zapisa.
/// ID: TC-NOTE-01 | Ime/cilj: ustvari in ponovno preberi opombo s simptomom/tokom.
/// Funkcionalnost: opombe in strukturirani simptomi/tok menstruacije. Prioriteta: srednja.
/// Vrsta/tehnika: funkcionalni pozitivni test; round-trip serijske predstavitve.
/// Predpogoji/okolje: NoteContentCodec; po končanem testu se lokalni niz zavrže.
/// Testni podatki: datum 15. 9. 2026; tekst »Blagi krči.«; simptom Cramps;
/// tok Medium (obe vrednosti sta v note_options.dart).
/// Koraki: 1) Kodiraj tekst, simptom in tok. Pričakovano vsebina vključuje tri polja.
/// 2) Razčleni kodirano vsebino. Pričakovano tekst, množica simptomov in tok se ujemajo.
/// Končni rezultat: vsa podprta strukturirana polja so enaka začetnim vrednostim.
/// Sledljivost: README opombe; NoteContentCodec; note_options.dart.
/// Predpostavka/omejitev: preizkus obsega codec, ne zaslona ali trajne baze.
/// Postpogoji/čiščenje: brez trajnih sprememb.
void main() {
  test('TC-NOTE-01: round-trip opombe ohrani tekst, simptom in tok', () {
    const text = 'Blagi krči.';
    const symptoms = {'Cramps'};
    const flow = 'Medium';
    expect(commonSymptoms, contains('Cramps'));
    expect(menstrualFlowOptions, contains('Medium'));
    final stored = NoteContentCodec.encode(text: text, symptoms: symptoms, flow: flow);
    expect(stored, 'Blagi krči.\n\nSymptoms: Cramps\n\nMenstrual flow: Medium');
    final reopened = NoteContentCodec.parse(stored);
    expect(reopened.text, text);
    expect(reopened.symptoms, symptoms);
    expect(reopened.flow, flow);
  });
}
