import 'package:flutter_test/flutter_test.dart';
import 'package:hera_app/features/cycles/utils/period_boundary_editor.dart';

/// ISO/IEC/IEEE 29119-1:2022 opisuje splošne koncepte; ne predpisuje te predloge.
/// ID: TC-CAL-01 | Ime/cilj: odstrani zadnji dan menstruacije prek koledarske meje.
/// Funkcionalnost: urejanje menstruacije v koledarju. Prioriteta: srednja.
/// Vrsta/tehnika: funkcionalni pozitivni test; analiza mejne vrednosti zadnjega dne.
/// Predpogoji/okolje: cikel se začne 1. 9. 2026, dolg je 28 dni; menstruacija 5 dni.
/// Testni podatki: izbrani 5. 9. 2026 je 5. (zadnji) dan; 1. dan je začetek.
/// Koraki: 1) Izvedi editPeriodBoundary za 5. 9. Pričakovano UpdatedPeriodBoundary.
/// 2) Preveri rezultat. Pričakovano začetek 1. 9. in dolžina 4 dni.
/// Končni rezultat: menstruacija zajema 1.–4. 9.; začetek ostane 1. 9.
/// Dolžina cikla se v rezultatu te funkcije ne vrne in je ta test ne preverja.
/// Sledljivost: calendar_screen_actions.dart in period_boundary_editor.dart.
/// Predpostavka/omejitev: domenska funkcija je testirana neposredno, ne kliki/UI.
/// Postpogoji/čiščenje: objekt rezultata je lokalen; ni trajnih sprememb.
void main() {
  test('TC-CAL-01: odstranitev zadnjega dne skrajša menstruacijo', () {
    final result = editPeriodBoundary(
      selectedDate: DateTime(2026, 9, 5),
      startDate: DateTime(2026, 9, 1),
      cycleLength: 28,
      menstruationLength: 5,
    );
    expect(result, isA<UpdatedPeriodBoundary>());
    final updated = result as UpdatedPeriodBoundary;
    expect(updated.startDate, DateTime(2026, 9, 1));
    expect(updated.menstruationLength, 4);
    expect(updated.startDate.add(const Duration(days: 3)), DateTime(2026, 9, 4));
  });
}
