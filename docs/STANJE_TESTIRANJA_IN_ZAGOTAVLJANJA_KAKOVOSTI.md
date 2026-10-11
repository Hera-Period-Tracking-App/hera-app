# Stanje testiranja in zagotavljanja kakovosti

**Projekt:** Hera  
**Datum pregleda:** 11. oktober 2026  
**Obseg pregleda:** izvorna koda, konfiguracijske datoteke in testne datoteke v repozitoriju.

Ta dokument prikazuje aktivnosti testiranja in zagotavljanja kakovosti, ki so v repozitoriju dejansko prisotne. Izraz »prisotno« pomeni, da je aktivnost implementirana ali konfigurirana v kodi; sam repozitorij ne vsebuje trajnega poročila o uspešnem izvajanju vseh pregledov.

## Povzetek

| Aktivnost | Stanje |
| --- | --- |
| Widget/UI test | Prisotno – en testni primer |
| Statična analiza in pravila sloga | Konfigurirano |
| Generiranje kode | Konfigurirano in dokumentirano |
| Lokalizacija | Konfigurirano; generiranje je podprto |
| Integracijski/E2E testi | Ni najdeno |
| Testi na fizičnih napravah | Ni dokazil v repozitoriju |
| Meritve pokritosti | Ni najdeno |
| CI/CD avtomatizacija kakovosti | Ni najdeno |
| Varnostno/pentest preverjanje | Ni najdeno |

## Prisotne aktivnosti

| Vrsta aktivnosti | Stanje | Pokriti del rešitve | Uporabljena orodja in ogrodja | Uporaba UI in preverjanje rezultata |
| --- | --- | --- | --- | --- |
| Widget test | Implementirano; najden je en testni primer v `test/widget_test.dart`. V repozitoriju ni shranjenega poročila o rezultatu izvajanja. | Začetni prikaz aplikacije: zagon `HeraApp` z `ProviderScope` ter prisotnost besedil »Welcome to Hera« in »Continue« na onboarding zaslonu. | `flutter_test`, `flutter_riverpod`, Flutter testni poganjalnik (`flutter test`). | Za ta obstoječi test v repozitoriju ni navedena uporaba UI. Rezultat se preveri s `flutter test`; pri tem pregledu ni bilo ustvarjenega trajnega poročila o prehodu testa. |
| Statična analiza in linting | Konfigurirano v `analysis_options.yaml`. Izvedba se predvideva z ukazom `flutter analyze`. | Celotna Dart koda; iz analize so izključene generirane datoteke `*.g.dart` in `*.freezed.dart`. Pravila vključujejo Flutterjeva priporočena pravila, enojne narekovaje, paketne importe in urejenost direktiv. | `flutter_lints`, Dart analyzer, `custom_lint`, `riverpod_lint`. | Ni navedene uporabe UI. Rezultat se preveri z izpisom `flutter analyze`; v repozitoriju ni datoteke s posnetim rezultatom analize. |
| Generiranje kode kot preverjanje skladnosti modelov | Konfigurirano. Ukazi za enkratno in spremljano generiranje so navedeni v README. | Drift podatkovne tabele, Riverpod generatorji, Freezed in `json_serializable` modeli. | `build_runner`, `drift_dev`, `freezed`, `json_serializable`, `riverpod_generator`. | Ni navedene uporabe UI. Uspeh se preveri z uspešnim zaključkom `dart run build_runner build --delete-conflicting-outputs` in s prevajanjem aplikacije. |
| Generiranje lokalizacije | Konfigurirano v `l10n.yaml`; prisotni sta slovenska in angleška ARB datoteka. | Lokalizacijski viri v `lib/l10n/app_en.arb` in `lib/l10n/app_sl.arb` ter generirani dostopni razred. | Flutter localization (`flutter_localizations`, `flutter gen-l10n`). | Ni navedene uporabe UI. Uspeh se preveri z `flutter gen-l10n`, brez napak generiranja, in z ročnim pregledom besedil v obeh jezikih. |
| Ročno/preventivno preverjanje platformskih nastavitev | Delno implementirano s konfiguracijo; izvajanje na napravah ni dokazano. | Biometrija, lokalna obvestila, šifrirana lokalna baza in lokalni model so vključeni v Android/iOS konfiguracijo ter odvisnosti. | `local_auth`, `flutter_local_notifications`, `flutter_secure_storage`, SQLCipher, `fllama`; Android manifest in iOS `Info.plist`. | Ni navedene uporabe UI. Zahteva ročno preverjanje na fizičnem Android/iOS telefonu, zlasti za biometrijo, dovoljenja, obvestila in nalaganje lokalnega modela. |

## Nepokrite oziroma nedokazane aktivnosti

- **Enotski testi domenske logike:** ni najdenih ločenih unit testov za napoved cikla, repozitorije, šifrirano bazo, serializacijo ali poslovna pravila.
- **Integracijski in E2E testi:** mapa `integration_test/` oziroma primerljivi testi niso najdeni.
- **Platformski testi:** ni najdenih zapisnikov testiranja na emulatorjih ali fizičnih napravah za Android/iOS.
- **Pokritost kode:** ni konfiguriranega ali shranjenega poročila `coverage`.
- **Neprekinjena integracija:** ni najdene konfiguracije CI (npr. GitHub Actions), ki bi samodejno izvajala `flutter analyze`, `flutter test`, generiranje kode ali gradnjo aplikacije.
- **Varnost in zasebnost:** aplikacija uporablja SQLCipher in varno shrambo, vendar v repozitoriju ni najdenega dokumentiranega varnostnega pregleda, pregleda odvisnosti, penetracijskega testa ali zunanje revizije.
- **Dostopnost in uporabniško testiranje:** ni najdenih testov dostopnosti, zlatih/slikovnih testov ali dokumentiranih uporabniških testov.

## Priporočeni minimalni kontrolni seznam pred izdajo

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Poleg tega je treba ročno preveriti na podprtem fizičnem Android in iOS telefonu:

1. prvi zagon, onboarding in spremembo jezika;
2. vnos, urejanje in prikaz ciklov ter opomb po ponovnem zagonu aplikacije;
3. biometrično zaklepanje ter zavrnitev/ponovni poskus avtentikacije;
4. dovoljenje in prikaz lokalnih obvestil;
5. nalaganje ter ustvarjanje lokalnega AI povzetka;
6. namestitev čiste različice aplikacije in nadgradnjo obstoječe različice.

## Izjava o uporabi generativne umetne inteligence

Pri izdelavi dokumentacije za nalogo je bilo uporabljeno generativno orodje umetne inteligence **OpenAI Codex (agentski pomočnik)**.

| Področje uporabe | Način uporabe | Kako je bil rezultat preverjen |
| --- | --- | --- |
| Ta dokument | Codex je pregledal prisotne teste, `analysis_options.yaml`, `pubspec.yaml`, `l10n.yaml` in strukturo repozitorija ter pripravil povzetek stanja. | Ročni pregled navedb proti datotekam v repozitoriju: najden je en widget test; najdene so konfiguracije lintanja, generatorjev in lokalizacije; niso najdene mape/konfiguracije za integracijske teste, CI ali poročila o pokritosti. |

Generativna UI v okviru te naloge **ni spreminjala produkcijske Dart kode, testne kode ali platformskih nastavitev**. Njena uporaba je bila omejena na pripravo dokumentacije in povzetek dokazov, ki so bili nato preverjeni z neposrednim pregledom repozitorija.
