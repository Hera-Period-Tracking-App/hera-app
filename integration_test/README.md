# Integracijski funkcionalni testi Hera

Pet testov temelji na končnih primerih TC-001–TC-005 v
[`testni-primeri-hera.md`](../test/testni-primeri-hera.md).
Obstoječi testi v `test/` ostajajo nespremenjeni.

| Specifikacija | Integracijski test | Preverjanje |
|---|---|---|
| TC-001 / F-01 / TCI-01 | `tc_001_dodaj_cikel_test.dart` | Izbira 1. 9. 2026, shranjevanje cikla 28/5 prek koledarja, zapis v SQLite in ponovni prikaz. |
| TC-002 / F-02 / TCI-02 | `tc_002_dodaj_opombo_test.dart` | Vnos opombe prek UI, normalizacija datuma, AES-GCM zapis, dešifriranje s ponovno ustvarjeno storitvijo in prikaz. |
| TC-003 / F-03 / TCI-03 | `tc_003_simptom_tok_test.dart` | Vnos besedila, izbira Cramps/Medium, točen kodiran zapis, prikaz in ponovno odprtje urejevalnika. |
| TC-004 / F-04 / TCI-04 | `tc_004_meja_menstruacije_test.dart` | Odstranitev 5. 9. v urejevalniku koledarja, shranjevanje trajanja 4 dni in ponovni prikaz. |
| TC-005 / F-05 / TCI-05 | `tc_005_urnik_opomnika_test.dart` | Branje cikla iz SQLite, scheduler, pravi native vtičnik in tri čakajoče sistemske zahteve `period_soon`. |

## Okolje in izolacija

Uporabi namenski Android emulator z datumom najmanj 1. 9. 2026 in
omogočenimi obvestili za `com.example.hera_app`. Paket `fllama` in druge
native odvisnosti zahtevajo ustrezen Android SDK/NDK in JDK.
Windows za pripravo vtičnikov zahteva Developer Mode oziroma dovoljenje za
ustvarjanje simbolnih povezav.

Vsak test dobi svežo SQLite bazo v pomnilniku prek
`AppDatabase.forTesting`, prave repozitorije, šifriranje in platformno varno
shrambo z enolično predpono ključev. Baza in testni ključi se po testu odstranijo.
Produkcijska datoteka `hera.sqlite` se ne odpre. Testi zato ne preverjajo
šifriranja datoteke SQLCipher ali ohranitve podatkov po ponovnem zagonu procesa.

Testni zaganjalnik prikazuje prave zaslone z lokalizacijo in usmerjanjem,
vendar izpusti onboarding, zaklep in globalno sinhronizacijo obvestil.
To niso testi celotnega zagona aplikacije. Model napovedovanja pri prikazu
koledarja ostaja pravi; v TC-005 je napoved 28/14/5 namerno podana kot vhod,
kot določa specifikacija.

TC-005 uporablja iste ID-je opomnikov kot aplikacija, zato je namenjen
izključno testni napravi. Zahteva dovoljenje pred začetkom in ne upravlja
sistemskega dialoga. Datum preverja z opazovanjem klica pravega datasource;
ID, naslov in payload dodatno preveri pri OS. Dejanska prihodnja dostava ni
preverjena. Testna priprava prihodnjega cikla gre neposredno prek datasource,
saj običajni vnos prihodnjih ciklov ni dovoljen. Čiščenje počaka tudi na
produkcijski diagnostični časovnik in odstrani njegove opomnike.

## Zagon

```powershell
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter devices
flutter test integration_test/functional_suite.dart -d emulator-5554 --no-uninstall
```

Če je aplikacija na testnem emulatorju že nameščena, lahko na Androidu 13+
pred testom TC-005 omogočiš dovoljenje brez sistemskega dialoga:

```powershell
adb -s emulator-5554 shell pm grant com.example.hera_app android.permission.POST_NOTIFICATIONS
```

Za prvi zagon najprej namesti aplikacijo oziroma izvedi TC-001 z možnostjo
`--no-uninstall`, nato omogoči dovoljenje in zaženi vseh pet testov.
`functional_suite.dart` jih izvede z eno gradnjo in namestitvijo aplikacije.
Na CI lahko namestiš testni APK in
odobriš dovoljenje pred izvajanjem zbirke.

## Rezultati v cevovodu

GitHub Actions cevovod je pripravljen v
[`functional-tests.yml`](../.github/workflows/functional-tests.yml).
Samodejno se sproži ob `push` in `pull_request`, ročno pa prek **Actions →
Functional tests → Run workflow**. Spremembe morajo biti potisnjene na GitHub,
da se tam izvede prvi zagon.

Cevovod uporablja Ubuntu, Flutter 3.47.7, Javo 17 in Android emulator API 36.
Prenese tudi Git LFS model ter pripravi NDK/CMake, generira kodo, zgradi testni
APK in omogoči obvestila pred izvajanjem petih primerov. Skripta
[`run-integration-tests.sh`](../.github/scripts/run-integration-tests.sh)
ohrani neuspešno izhodno kodo testov in pred ustavitvijo emulatorja zbere
diagnostiko.

V razdelku **Artifacts** posameznega zagona je poročilo
`android-functional-tests-<poskus>`: dogodki JSON, standardni izhod napak,
Android logcat in izhodna koda; ob napaki tudi posnetek zaslona, če ga je mogoče
zajeti. Artefakti se hranijo 14 dni in se shranijo tudi ob neuspehu.
Za preprečevanje združitev z neuspešnimi testi v zaščiti glavne veje nastavi
preverjanje **Functional tests (Android)** kot obvezno.

Po pripravi odvisnosti, generiranju kode, zagonu emulatorja in odobritvi
obvestil izvedi naslednji korak PowerShell:

```powershell
flutter test integration_test/functional_suite.dart -d emulator-5554 --no-uninstall --machine > functional-tests.json
exit $LASTEXITCODE
```

Izhod vsebuje tok dogodkov JSON. Poročilo shrani kot artefakt tudi ob neuspehu;
izhodna koda ohrani neuspeh testov za cevovod. Za berljiv lokalni izpis izpusti
`--machine`. Zagon zahteva Android napravo; navaden `flutter test` izvaja
ločene obstoječe teste iz `test/`.

## Preverjena izvedba

- Datum: 7. 11. 2026.
- Flutter 3.47.7, Dart 3.13.5; Windows 10.
- Android emulator `emulator-5554`, Android 16 / API 36, x86_64.
- Pred zagonom je bila aplikacija nameščena z dovoljenji na namenski emulator.
- Ukaz: `flutter test --no-pub integration_test/functional_suite.dart -d emulator-5554 --no-uninstall --reporter expanded`.
- Rezultat: **5 uspešnih testov, 0 neuspešnih**; `All tests passed!`, izhodna koda 0.
- Statična analiza vseh spremenjenih Dart datotek: **No issues found!**

Pri izvajanju je bila odkrita tudi napaka ob odstranitvi koledarja: dostop
do `WidgetRef` po odstranitvi gradnika in spreminjanje stanja navigacije med
odstranjevanjem. Koledar zdaj shrani notifier med inicializacijo in obnovitev
navigacije odloži v mikronalogo, ki pred spremembo preveri veljavnost notifierja.
