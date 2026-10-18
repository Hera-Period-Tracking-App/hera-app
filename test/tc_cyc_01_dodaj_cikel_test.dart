import 'package:flutter_test/flutter_test.dart';
import 'package:hera_app/features/cycles/datasources/cycle_local_datasource.dart';
import 'package:hera_app/features/cycles/repositories/cycle_repository.dart';

/// ISO/IEC/IEEE 29119-1:2022 opisuje splošne testne koncepte; ne predpisuje predloge.
/// ID: TC-CYC-01 | Ime/cilj: Dodaj veljaven cikel in preveri shranjene podatke.
/// Funkcionalnost: beleženje cikla. Prioriteta: visoka.
/// Vrsta/tehnika: funkcionalni pozitivni test; preverjanje veljavnih vhodov.
/// Predpogoji/okolje: prazen pomnilniški fake CycleLocalDataSource; datum je pretekli.
/// Podatki: začetek 1. 9. 2026; cikel 28 dni (1.–28. 9., dan začetka je 1. dan);
/// menstruacija 5 dni (1.–5. 9.).
/// Koraki: 1) Dodaj cikel prek CycleRepository — pričakovano brez izjeme.
/// 2) Preveri shranjeni zapis — pričakovani datum 1. 9., dolžini 28 in 5.
/// Končni rezultat: v shrambi je natanko en cikel z navedenimi vrednostmi.
/// Sledljivost: README navaja sledenje ciklu; CycleRepository.addCycle.
/// Predpostavka/omejitev: test preverja domensko shranjevanje prek fake-a, ne UI/baze.
/// Postpogoji/čiščenje: fake je lokalno ustvarjen in se po testu zavrže.
void main() {
  test('TC-CYC-01: doda veljaven cikel', () async {
    final source = _MemoryCycles();
    await CycleRepository(source).addCycle(
      startDate: DateTime(2026, 9, 1),
      cycleLength: 28,
      menstruationLength: 5,
    );
    expect(source.cycles, hasLength(1));
    expect(source.cycles.single.startDate, DateTime(2026, 9, 1));
    expect(source.cycles.single.cycleLength, 28);
    expect(source.cycles.single.menstruationLength, 5);
  });
}

class _MemoryCycles implements CycleLocalDataSource {
  final cycles = <({DateTime startDate, int cycleLength, int menstruationLength})>[];
  @override
  Future<bool> hasCycleWithStartDate(DateTime date, {String? excludeCycleId}) async => cycles.any((c) => _sameDay(c.startDate, date));
  @override
  Future<DateTime?> nextCycleStartAfter(DateTime date, {String? excludeCycleId}) async => null;
  @override
  Future<bool> hasOverlappingCycle({required DateTime startDate, required int cycleLength, String? excludeCycleId}) async => false;
  @override
  Future<void> insertCycleEntry({required DateTime startDate, required int cycleLength, required int menstruationLength}) async {
    cycles.add((startDate: startDate, cycleLength: cycleLength, menstruationLength: menstruationLength));
  }
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
