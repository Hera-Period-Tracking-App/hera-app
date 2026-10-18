import 'package:flutter_test/flutter_test.dart';
import 'package:hera_app/features/cycles/datasources/cycle_local_datasource.dart';
import 'package:hera_app/features/cycles/exceptions/overlapping_cycle_exception.dart';
import 'package:hera_app/features/cycles/repositories/cycle_repository.dart';

/// ISO/IEC/IEEE 29119-1:2022 opisuje splošne testne koncepte; ne predpisuje predloge.
/// ID: TC-CYC-02 | Ime/cilj: zavrni nov cikel, ki se prekriva z obstoječim.
/// Funkcionalnost: validacija ciklov. Prioriteta: visoka.
/// Vrsta/tehnika: funkcionalni negativni test; analiza mej intervala.
/// Predpogoji/okolje: fake vsebuje cikel 1. 9. 2026; dolžina 28 dni pomeni
/// inkluzivni obseg 1.–28. 9. 2026 (1. 9. je 1. dan); menstruacija traja 5 dni.
/// Testni podatki: poskusni cikel se začne 15. 9. 2026, dolžina 28 in menstruacija 5.
/// Koraki: 1) Poskusi dodati novi cikel. Pričakovano OverlappingCycleException.
/// 2) Preveri shrambo. Pričakovano ostane samo prvotni cikel 1. 9. 2026.
/// Končni rezultat: prekrivajoč zapis ni shranjen, prvotni zapis je nespremenjen.
/// Sledljivost: CycleRepository.addCycle; CycleLocalDataSource.hasOverlappingCycle.
/// Predpostavka/omejitev: preverja domensko validacijo s fake shrambo, ne UI.
/// Postpogoji/čiščenje: pomnilniški fake se zavrže.
void main() {
  test('TC-CYC-02: zavrne prekrivanje in ohrani obstoječi cikel', () async {
    final source = _MemoryCycles()..seed(DateTime(2026, 9, 1), 28, 5);
    final repository = CycleRepository(source);
    await expectLater(
      repository.addCycle(startDate: DateTime(2026, 9, 15), cycleLength: 28, menstruationLength: 5),
      throwsA(isA<OverlappingCycleException>()),
    );
    expect(source.cycles, hasLength(1));
    expect(source.cycles.single.startDate, DateTime(2026, 9, 1));
    expect(source.cycles.single.cycleLength, 28);
    expect(source.cycles.single.menstruationLength, 5);
  });
}

class _MemoryCycles implements CycleLocalDataSource {
  final cycles = <({DateTime startDate, int cycleLength, int menstruationLength})>[];
  void seed(DateTime startDate, int cycleLength, int menstruationLength) => cycles.add((startDate: startDate, cycleLength: cycleLength, menstruationLength: menstruationLength));
  @override
  Future<bool> hasCycleWithStartDate(DateTime date, {String? excludeCycleId}) async => cycles.any((c) => _sameDay(c.startDate, date));
  @override
  Future<DateTime?> nextCycleStartAfter(DateTime date, {String? excludeCycleId}) async {
    final dates = cycles.map((c) => c.startDate).where((d) => d.isAfter(date)).toList()..sort();
    return dates.isEmpty ? null : dates.first;
  }
  @override
  Future<bool> hasOverlappingCycle({required DateTime startDate, required int cycleLength, String? excludeCycleId}) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = start.add(Duration(days: cycleLength - 1));
    return cycles.any((c) {
      final oldEnd = c.startDate.add(Duration(days: c.cycleLength - 1));
      return !end.isBefore(c.startDate) && !start.isAfter(oldEnd);
    });
  }
  @override
  Future<void> insertCycleEntry({required DateTime startDate, required int cycleLength, required int menstruationLength}) async {
    cycles.add((startDate: startDate, cycleLength: cycleLength, menstruationLength: menstruationLength));
  }
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
