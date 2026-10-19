import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hera_app/core/datasources/secure_storage_data_source.dart';
import 'package:hera_app/core/encryption/encryption_service.dart';
import 'package:hera_app/features/notes/datasources/note_local_datasource.dart';
import 'package:hera_app/features/notes/repositories/note_repository.dart';

/// ISO/IEC/IEEE 29119-1:2022 opisuje splošne testne koncepte; ne predpisuje predloge.
/// ID: TC-NOTE-02 | Ime/cilj: doda opombo in preveri njeno lokalno zavarovanje.
/// Funkcionalnost: ustvarjanje opombe. Prioriteta: srednja.
/// Vrsta/tehnika: funkcionalni pozitivni test; preverjanje transformacije vhoda.
/// Predpogoji/okolje: prazen pomnilniški fake NoteLocalDataSource in fake varna shramba;
/// uporablja se pravi EncryptionService, ne operacijska varna shramba ali baza.
/// Testni podatki: datum 15. 9. 2026 ob 14:30; vsebina z zunanjimi presledki
/// »  Blagi krči.  «; cycleId ni podan.
/// Koraki: 1) Pokliči NoteRepository.addNote z navedenim datumom in vsebino.
/// Pričakovano se klic zaključi brez izjeme. 2) Preveri fake shrambo.
/// Pričakovano je en zapis za 15. 9. 2026, vsebina je šifrirana, cycleId je prazen.
/// 3) Dešifriraj vsebino s servisom. Pričakovano »Blagi krči.« brez presledkov.
/// Končni rezultat: opomba je dodana z datumom brez ure in šifrirano vsebino.
/// Sledljivost: README opombe; NoteRepository.addNote; EncryptionService.encrypt.
/// Predpostavka/omejitev: preverja repository s fake shrambo, ne UI ali SQLCipher baze.
/// Postpogoji/čiščenje: fake podatki in ključ v pomnilniški shrambi se zavržejo.
void main() {
  test('TC-NOTE-02: doda opombo z datumom brez ure in šifrirano vsebino', () async {
    final dataSource = _MemoryNotes();
    final secureStorage = _MemorySecureStorage();
    final encryption = EncryptionService(secureStorage: secureStorage);
    final repository = NoteRepository(dataSource, secureStorage, encryption);

    await repository.addNote(
      date: DateTime(2026, 9, 15, 14, 30),
      content: '  Blagi krči.  ',
    );

    expect(dataSource.entries, hasLength(1));
    final entry = dataSource.entries.single;
    expect(entry.date, DateTime(2026, 9, 15));
    expect(entry.cycleId, isNull);
    expect(entry.encryptedContent, isNot('Blagi krči.'));
    expect(jsonDecode(entry.encryptedContent), containsPair('alg', 'A256GCM'));
    expect(await encryption.decrypt(entry.encryptedContent), 'Blagi krči.');
  });
}

class _MemoryNotes implements NoteLocalDataSource {
  final entries = <({String? cycleId, DateTime date, String encryptedContent})>[];

  @override
  Future<bool> hasNoteForDate(DateTime date) async => entries.any(
        (entry) =>
            entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day,
      );

  @override
  Future<void> insertNoteEntry({
    String? cycleId,
    required DateTime date,
    required String encryptedContent,
  }) async {
    entries.add((
      cycleId: cycleId,
      date: date,
      encryptedContent: encryptedContent,
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemorySecureStorage implements SecureStorageDataSource {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
