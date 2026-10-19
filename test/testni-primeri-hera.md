# Funkcionalni testi za aplikacijo Hera

Dokument povezuje pet funkcionalnih testov v mapi `test/` z deli aplikacije, ki jih preverjajo. Testi so ločeni v Dart datoteke; komentarji v vsaki datoteki vsebujejo cilj, predpogoje, podatke, korake, pričakovane rezultate, predpostavke in čiščenje. Testi `tc_*` preverjajo domensko logiko ali storitve z uporabo fake/pomnilniških objektov; samo `widget_test.dart` je UI widget test.

## Uporabljena navodila in ukazi po vrsti

### Izhodiščno navodilo uporabnika

## Uporabljeni ukazi agenta in popravki po vrsti

### 1. Začetni ukaz za prvi osnutek

```text
Generate exactly five functional test cases in Slovenian for this Flutter project Hera, acting as the requested independent agent UI test-case generator. Use project README/code features and ISO/IEC/IEEE 29119-1:2022 general concepts (do not imply it mandates a specific template; include robust recommended attributes). Provide only the first draft so parent can review and then revise the generation prompt. Each case should include ID, name/objective, linked functionality, priority, preconditions/environment, test data, numbered steps with expected result per step, final expected result, and requirement/coverage reference. Choose user-observable flows and valid/error boundaries across cycle logging, notes, calendar, settings/security, and predictions/reminders. Clearly flag assumptions where implementation docs are silent. Do not write files.
```

### 2. Zahteva za ločene datoteke `.dart`

```text
Generate exactly five functional test case for this Flutter project Hera, acting as the requested independent agent UI test-case generator. Use project README/code features and ISO/IEC/IEEE 29119-1:2022 general concepts (do not imply it mandates a specific template; include robust recommended attributes). Provide only the first draft so parent can review and then revise the generation prompt. Each case should include ID, name/objective, linked functionality, priority, preconditions/environment, test data, numbered steps with expected result per step, final expected result, and requirement/coverage reference. Choose user-observable flows and valid/error boundaries across cycle logging, notes, calendar, settings/security, and predictions/reminders. Clearly flag assumptions where implementation docs are silent. Make each test seperatly in /test map and writhe them in dart.
```

### 3. Prvi ukaz za ustvarjanje ločenih datotek

```text
Create the FIRST DRAFT requested by the user: exactly five functional test cases in Slovenian, each as its own separate Dart test file in test/. Use README and code and ISO/IEC/IEEE 29119-1:2022 general concepts, without claiming it mandates the attributes. Coverage across the five files must include cycle logging, notes, calendar, settings/security, and predictions/reminders (one of these can be combined appropriately, but all areas must appear). Each file should contain exactly one runnable Flutter test with detailed comments/docstring for ID, title/objective, functionality, priority, preconditions/environment, test data, numbered steps with expected result, final expected result, and traceability/coverage reference; explicitly flag assumptions. The test itself should assert relevant observable behavior. File names e.g. test/tc_cyc_01_....dart. Build deterministic tests with existing dependencies only. Do not change lib/, pubspec, existing tests or test/functional_test.dart; do not run tests. This is the first draft; do not revise based on parent feedback yet.
```

### 4. Ukaz za pregled in drugi osnutek

```text
Review your first draft against the project and revise it as a final second draft. Problems to fix: the cycle-overlap case did not define the existing cycle length/end date; several expected results were vague or unsupported by the documented behavior; the prediction case asks for dates to 'correspond' without a precise oracle and doesn't verify a concrete notification state. Use exactly five specific functional cases with independently reproducible test data and exact expected results wherever the app requirements/code support them. Keep all fields from draft plus explicit test-case type/design technique and postconditions/cleanup. Ensure calendar cycle range calculations are accurate (cycle length counts start date as day 1). Favor UI-observable behavior; flag any assumptions. Include at least one positive and one negative case. Base the revised set on 1) adding cycle, 2) cycle overlap or duplicate rejection with precise dataset, 3) creating and reopening a note including structured symptom/flow fields only if UI supports them, 4) period boundary edit in calendar if UI supports it or a validated setting flow otherwise, 5) one other directly supported useful functionality (e.g. app language/theme setting or predictions). Avoid exact AI predictions unless calculable from the bundled model and data.
```

### 5. Popravek po pregledu prvega drugega osnutka

```text
Parent review of first draft: keep exactly five separate .dart files, one test per case. Current gaps: required settings/security coverage is only language-code mapping; valid cycle case does not test the requested error boundary/overlap rejection; prediction/reminder assertion pairs payload `period_start` with title `Your period may start soon`, but source code pairs that title with payload `period_soon` (period_start has title Menstruation may start today). Revised distribution: (1) cycle logging case that adds one valid cycle, then attempts an overlapping start date and asserts rejection plus original data preserved (choose dates before today and within existing 28-day range); (2) note round-trip case; (3) calendar boundary; (4) settings/security UI widget case, preferably invalid PIN input displays the exact validation message without persisting/enabling lock, using a fake biometric provider; (5) prediction/reminder scheduling with corrected date/payload/title expectation. Preserve detailed Slovenian comments for all requested attributes and explicit assumptions. Ensure each test file has exactly one test/ testWidgets, use deterministic fakes, do not modify lib/, pubspec, widget_test.dart, or the old test/functional_test.dart, and do not run tests. This is the second-generation final draft; report any constraints honestly.
```

### 6. Ukaz za izdelavo ločenih končnih datotek

```text
Apply the user's exact second-draft prompt to the project files. Produce exactly five separate runnable Dart test files in test/, one case per file, based on these five distinct cases: (1) adding a valid cycle, (2) rejecting overlap or duplicate with precisely specified existing cycle and date range, (3) note text+symptom+flow codec round-trip, (4) period boundary edit, (5) local reminder scheduling with exact payload/title/date oracle. Include all requested case attributes in Slovenian comments: ID, name/objective, functionality, priority, preconditions/environment, test data, numbered steps and expected results, final expected result, traceability; additionally type/design technique and cleanup/postconditions. Favor UI-observable behavior, flag assumptions. Keep test input dates deterministic and past/future as required; ensure cycle length counts start date as day 1. Avoid exact prediction output unless calculable. Review the existing five tc_* test files and replace/rename as needed so only exactly these five new functional case files remain (preserve original test/widget_test.dart). Ensure no broken imports and concrete non-vague assertions. Do not modify app source/pubspec and do not run tests. Return a brief inventory, don't include newly authored test code in your message.
```

### 7. Popravek uvoza, najden pri pregledu

```text
One final parent-review correction: `test/tc_pred_01_opomnik_test.dart` imports `package:hera-app/...`, which is an invalid Dart package URI; correct it to `package:hera_app/...`. Keep the five separate files, attributes/comments, and one test per file unchanged otherwise. Do not run tests.
```

### 8. Popravek pričakovanja za tri prihodnje opomnike

```text
Final review found one more defect in tc_pred_01_opomnik_test.dart: the scheduler creates three `period_soon` reminders (one for each of its three future cycles), so `singleWhere` will throw. Select the first expected notification deterministically or assert all three with calculated dates. Keep exactly one runnable test per file and don't run tests.
```

### 9. Ponovljeni ukaz za končni drugi osnutek

```text
Review your first draft against the project and revise it as a final second draft. Problems to fix: the cycle-overlap case did not define the existing cycle length/end date; several expected results were vague or unsupported by the documented behavior; the prediction case asks for dates to 'correspond' without a precise oracle and doesn't verify a concrete notification state. Use exactly five specific functional cases with independently reproducible test data and exact expected results wherever the app requirements/code support them. Keep all fields from draft plus explicit test-case type/design technique and postconditions/cleanup. Ensure calendar cycle range calculations are accurate (cycle length counts start date as day 1). Favor UI-observable behavior; flag any assumptions. Include at least one positive and one negative case. Base the revised set on 1) adding cycle, 2) cycle overlap or duplicate rejection with precise dataset, 3) creating and reopening a note including structured symptom/flow fields only if UI supports them, 4) period boundary edit in calendar if UI supports it or a validated setting flow otherwise, 5) one other directly supported useful functionality (e.g. app language/theme setting or predictions). Avoid exact AI predictions unless calculable from the bundled model and data.
```

### 10. Zahteva za preverjanje in popravek testov

```text
check if there are errors in the test code and corect them
```

```text
check if there are errors in the test code and corect them. do not include the widget test but only the ones you added now
```

Analiza je najprej odkrila napačno pot importa v koledarskem testu (`calendar/utils` namesto `cycles/utils`); ta je bila popravljena pred uspešno ponovno analizo in zagonom. Widget test ni bil vključen.

## Pregled skladnosti z navodili za UI agenta

Dokument je primerjan z navodili »NAVODILA ZA UI AGENTA – PRIPRAVA FUNKCIONALNIH TESTNIH PRIMEROV«. Ocena velja za dokumentacijo in trenutno prisotne testne datoteke, ne pomeni certifikacije ali popolne skladnosti s standardom.

| Zahteva iz navodil | Stanje | Ugotovitev / dopolnitev |
|---|---|---|
| Natanko pet funkcionalnih primerov | Delno izpolnjeno | Prisotnih je pet `tc_*` funkcionalnih testov in dodatni začetni widget test. Pet funkcionalnih primerov je spodaj označenih TC-001–TC-005; pri vsakem je naveden tudi ID TC-* iz testne kode. |
| Identifikacija funkcionalnosti F-01… | Dopolnjeno v tem dokumentu | Dodana je tabela funkcionalnosti, ki jih dejanski testi pokrivajo. |
| Elementi testne pokritosti TCI-01… | Dopolnjeno v tem dokumentu | Dodana je tabela TCI z vezavo na funkcionalnost in tehniko. |
| Atributi iz 8.3.3: ID, cilj, prioriteta, sledljivost, predpogoji, vhodi, pričakovani rezultati | Delno izpolnjeno | Testne datoteke vsebujejo cilj, prioriteto, predpogoje, podatke, korake, pričakovane rezultate in sledljivost v komentarjih. Spodaj so podatki poenoteni v preglednicah. Noben od petih `tc_*` primerov ne izvede celotnega UI-toka skozi aplikacijo. |
| Testni postopek po 8.4 | Delno izpolnjeno | Vsak Dart test ima zaporedje dejanj in asercij, toda dokument ne podaja ločenih postopkov zagona/priprave/čiščenja za vse primere. Za študijsko nalogo sta specifikacija in koraki združeni, kot dovoljujejo navodila. |
| Actual Result in status | Manjka kot trajen zapis | V repozitoriju ni shranjenega poročila o rezultatih posameznih testov. Zato je dejanski rezultat označen kot »Ni zabeležen«, status pa »Ni dokumentiran«; ne sklepamo o uspehu iz same prisotnosti kode. |
| Kakovostni pregled in viri | Dopolnjeno v tem dokumentu | Dodana sta pregled kakovosti ter seznam standardov in projektnih virov. |
| Popolna skladnost s standardom | Ni zatrjevana | Dokument uporablja izbrane elemente predloge. Ne trdi popolne skladnosti z ISO/IEC/IEEE 29119-3:2021 ali 29119-4:2021. |

**Pomembna razlika v obsegu:** prvotna navodila zahtevajo UI funkcionalne primere, vendar vseh pet `tc_*` testov neposredno kliče repository, codec, domensko funkcijo ali scheduler z fake-om. Zato so to avtomatizirani funkcionalni testi na ravni kode, ne dokaz, da je uporabniški tok preverjen skozi zaslon. Poleg tega sedanja razporeditev ne vsebuje testa nastavitev/varnosti; peti primer pokriva načrtovanje obvestil.

## Opis projekta in izbrani vir zahtev

Hera je Flutter aplikacija za zasebno, lokalno sledenje menstrualnemu ciklu. README opisuje beleženje ciklov in opomb, koledarski prikaz in lokalna obvestila. Naslednje funkcionalnosti so vključene, ker jih preverja vsaj eden od petih funkcionalnih testov.

| ID funkcionalnosti | Naziv funkcionalnosti | Kratek opis | Vir zahteve |
|---|---|---|---|
| F-01 | Dodajanje cikla | Shrani datum začetka, dolžino cikla in dolžino menstruacije. | README projekta in `CycleRepository.addCycle`; testna vrednost je primer. |
| F-02 | Preprečevanje prekrivanja ciklov | Zavrne nov cikel, ki se prekriva z obstoječim ciklom. | Implementacija `CycleRepository.addCycle`; test preverja pričakovano izjemo. |
| F-03 | Strukturirana vsebina opombe | Kodira in razčleni besedilo, simptome ter menstrualni tok. | `NoteContentCodec` in `note_options.dart`; README opisuje opombe. |
| F-04 | Urejanje meje menstruacije | Uredi dolžino menstruacije z odstranitvijo izbranega zadnjega dne. | `editPeriodBoundary` v `period_boundary_editor.dart`; koledarska funkcionalnost v kodi. |
| F-05 | Lokalno razporejanje opomnikov | Načrtuje obvestila glede na cikel, napoved, nastavitev in razpoložljivost obvestil. | README lokalnih opomnikov in `CycleNotificationScheduler.reschedule`. |

## Elementi testne pokritosti

Tehnike v tabeli opisujejo dejansko zasnovo primerov. Razredi ekvivalence so uporabljeni le za veljaven oziroma prekrivajoč se cikel; mejna analiza je primerna za urejanje zadnjega dne. Ostali testi so usmerjeni v točno določen primer oziroma krožno kodiranje in razporejanje.

| ID TCI | ID funkcionalnosti | Opis elementa testne pokritosti | Tehnika načrtovanja | Prioriteta |
|---|---|---|---|---|
| TCI-01 | F-01 | Veljaven cikel z začetkom 1. 9. 2026, dolžino 28 dni in menstruacijo 5 dni se doda v prazno shrambo. | Razred ekvivalence: veljavna kombinacija vhodov. | Visoka |
| TCI-02 | F-02 | Nov cikel z začetkom 15. 9. 2026 se prekriva z obstoječim ciklom 1.–28. 9. 2026; dodajanje se zavrne, obstoječi zapis ostane. | Razred ekvivalence: prekrivajoč se interval (negativni primer). | Visoka |
| TCI-03 | F-03 | Kodiranje in ponovno razčlenjevanje ohrani besedilo »Blagi krči.«, simptom `Cramps` in tok `Medium`. | Testiranje krožnega pretvarjanja (round-trip) znanih vrednosti. | Srednja |
| TCI-04 | F-04 | Izbira zadnjega dne petdnevne menstruacije skrajša menstruacijo na štiri dni, začetni datum pa ostane enak. | Analiza mejne vrednosti zadnjega dne intervala. | Srednja |
| TCI-05 | F-05 | Pri omogočenih obvestilih scheduler pripravi tri `period_soon` opomnike; prvi ima pričakovani naslov in čas. | Preverjanje izhoda storitve z determinističnim fake-om in časovnim oracle-om. | Srednja |

## Specifikacija petih testnih primerov

Spodnji povzetki združujejo specifikacijo testnega primera in postopek. Testna koda je avtomatizirana; polji dejanski rezultat in status se nanašata na trajno dokumentiranje izvedbe, ki trenutno ni shranjeno v repozitoriju.

### TC-001 – Dodaj veljaven cikel (TC-CYC-01)

| Atribut | Vsebina |
|---|---|
| Unique Identifier | TC-001; ID v testni kodi TC-CYC-01; datoteka `tc_cyc_01_dodaj_cikel_test.dart` |
| Objective | Preveriti, da `CycleRepository.addCycle` doda veljaven cikel s podanimi vrednostmi. |
| Priority | Visoka |
| Traceability | F-01 → TCI-01 → TC-001 |
| Preconditions | Pomnilniški fake `CycleLocalDataSource` je prazen; test se izvaja brez baze/UI. |
| Test Data | Začetek 1. 9. 2026; cikel 28 dni; menstruacija 5 dni. |
| Inputs in Expected Results | 1) Pokliči `addCycle` z navedenimi vrednostmi → klic se zaključi brez izjeme. 2) Preveri fake → vsebuje natanko en zapis z začetkom 1. 9. 2026, dolžino 28 in menstruacijo 5. |
| Postconditions | Fake vsebuje en zapis; po testu se zavrže. |
| Actual Result / Status | Ni zabeležen / Ni dokumentiran. |

### TC-002 – Zavrni prekrivajoči se cikel (TC-CYC-02)

| Atribut | Vsebina |
|---|---|
| Unique Identifier | TC-002; ID v testni kodi TC-CYC-02; datoteka `tc_cyc_02_zavrni_prekrivanje_test.dart` |
| Objective | Preveriti, da prekrivajoč se cikel sproži `OverlappingCycleException` in ne spremeni obstoječega zapisa. |
| Priority | Visoka |
| Traceability | F-02 → TCI-02 → TC-002 |
| Preconditions | Fake vsebuje cikel z začetkom 1. 9. 2026; cikel traja 28 dni, torej vključujoče do 28. 9. 2026; menstruacija traja 5 dni. |
| Test Data | Nov cikel: začetek 15. 9. 2026, dolžina 28 dni, menstruacija 5 dni. |
| Inputs in Expected Results | 1) Poskusi dodati novi cikel → vrže se `OverlappingCycleException`. 2) Preveri fake → še vedno vsebuje natanko en prvotni cikel z istimi vrednostmi. |
| Postconditions | Fake se zavrže; trajna baza ni uporabljena. |
| Actual Result / Status | Ni zabeležen / Ni dokumentiran. |

### TC-003 – Ohrani strukturirana polja opombe (TC-NOTE-01)

| Atribut | Vsebina |
|---|---|
| Unique Identifier | TC-003; ID v testni kodi TC-NOTE-01; datoteka `tc_note_01_opomba_simptom_tok_test.dart` |
| Objective | Preveriti, da `NoteContentCodec` po kodiranju in razčlenjevanju ohrani besedilo, simptom in tok. |
| Priority | Srednja |
| Traceability | F-03 → TCI-03 → TC-003 |
| Preconditions | Uporablja se `NoteContentCodec`; shramba in UI nista vključena. |
| Test Data | Besedilo `Blagi krči.`, simptom `Cramps`, tok `Medium`; preverjeno, da sta vrednosti med ponujenimi možnostmi. |
| Inputs in Expected Results | 1) Kodiraj besedilo, simptom in tok → nastane niz `Blagi krči.\n\nSymptoms: Cramps\n\nMenstrual flow: Medium`. 2) Razčleni niz → besedilo je `Blagi krči.`, množica simptomov je `{'Cramps'}`, tok pa `Medium`. |
| Postconditions | Vrednosti ostanejo samo v lokalnem testu. |
| Actual Result / Status | Ni zabeležen / Ni dokumentiran. |

### TC-004 – Odstrani zadnji dan menstruacije (TC-CAL-01)

| Atribut | Vsebina |
|---|---|
| Unique Identifier | TC-004; ID v testni kodi TC-CAL-01; datoteka `tc_cal_01_meja_menstruacije_test.dart` |
| Objective | Preveriti urejanje zadnjega dne menstruacije in skrajšanje njenega trajanja za en dan. |
| Priority | Srednja |
| Traceability | F-04 → TCI-04 → TC-004 |
| Preconditions | Cikel se začne 1. 9. 2026; dolžina cikla je 28 dni, menstruacija pa 5 dni. Izbrani datum je peti in zadnji dan. |
| Test Data | Izbrani datum 5. 9. 2026; začetni datum 1. 9. 2026. |
| Inputs in Expected Results | 1) Pokliči `editPeriodBoundary` z navedenimi podatki → vrne `UpdatedPeriodBoundary`. 2) Preveri rezultat → začetni datum je 1. 9. 2026, menstruacija traja 4 dni, zadnji dan pa je 4. 9. 2026. |
| Postconditions | Rezultat je lokalen; trajnih sprememb ni. |
| Actual Result / Status | Ni zabeležen / Ni dokumentiran. |

### TC-005 – Načrtuj opomnik pred menstruacijo (TC-NOTIF-01)

| Atribut | Vsebina |
|---|---|
| Unique Identifier | TC-005; ID v testni kodi TC-NOTIF-01; datoteka `tc_notif_01_urnik_opomnika_test.dart` |
| Objective | Preveriti, da scheduler ob omogočenih obvestilih pripravi opomnike `period_soon` z določljivim naslovom in časom. |
| Priority | Srednja |
| Traceability | F-05 → TCI-05 → TC-005 |
| Preconditions | Fake obvestil vrne, da so obvestila dovoljena; scheduler prejme en zabeležen cikel in napoved. |
| Test Data | Začetek cikla je lokalni datum 60 dni po današnjem datumu; dolžina 28 dni, ovulacija 14. dan in menstruacija 5 dni. |
| Inputs in Expected Results | 1) Pokliči `reschedule(enabled: true)` → vrne `true`. 2) Filtriraj po payload `period_soon` → najdeni so natanko trije opomniki. 3) Preveri prvega → naslov je `Your period may start soon`, čas pa 09:00 na datum 26 dni po začetku zabeleženega cikla. |
| Postconditions | Razporeditve so shranjene samo v fake objektu, ki se zavrže. |
| Actual Result / Status | Ni zabeležen / Ni dokumentiran. |

**Odvisnosti:** Testni primeri so zasnovani kot neodvisni. TC-002 sam pripravi svoj obstoječi cikel; TC-005 uporablja datum, izračunan iz lokalnega `DateTime.now()`, zato je ponovljiv glede na relativni datum, ne pa glede na en nespremenljiv koledarski datum.

## Matrika sledljivosti

| ID funkcionalnosti | Naziv funkcionalnosti | ID TCI | Opis TCI | ID testnega primera |
|---|---|---|---|---|
| F-01 | Dodajanje cikla | TCI-01 | Doda veljaven cikel 1. 9. 2026 z dolžino 28 dni in menstruacijo 5 dni. | [TC-001 / TC-CYC-01](tc_cyc_01_dodaj_cikel_test.dart) |
| F-02 | Preprečevanje prekrivanja ciklov | TCI-02 | Zavrne cikel z začetkom 15. 9., ki se prekriva z obstoječim 1.–28. 9. 2026. | [TC-002 / TC-CYC-02](tc_cyc_02_zavrni_prekrivanje_test.dart) |
| F-03 | Strukturirana vsebina opombe | TCI-03 | Round-trip ohrani besedilo, simptom `Cramps` in tok `Medium`. | [TC-003 / TC-NOTE-01](tc_note_01_opomba_simptom_tok_test.dart) |
| F-04 | Urejanje meje menstruacije | TCI-04 | Odstranitev izbranega zadnjega dne skrajša petdnevno menstruacijo na štiri dni. | [TC-004 / TC-CAL-01](tc_cal_01_meja_menstruacije_test.dart) |
| F-05 | Lokalno razporejanje opomnikov | TCI-05 | Načrtuje tri `period_soon` opomnike; test preveri naslov in čas prvega. | [TC-005 / TC-NOTIF-01](tc_notif_01_urnik_opomnika_test.dart) |

## Pregled kakovosti testnih primerov

| Kriterij kakovosti | Rezultat preverjanja | Morebitne pripombe |
|---|---|---|
| Vseh pet primerov ima enoličen ID in cilj | Ustrezno po dopolnitvi | TC-001–TC-005 so dokumentacijske oznake, preslikane na enolične ID-je v imenih testov in komentarjih izvornih datotek. |
| Vhodi in pričakovani rezultati so konkretni | Večinoma ustrezno | Scheduler test uporablja relativni datum (`DateTime.now()`), a preverja konkretno relativno časovno razliko, naslov, payload in število opomnikov. |
| Primeri so različni in ponovljivi | Večinoma ustrezno | Pokrivajo cikel, prekrivanje, codec opombe, mejo menstruacije in obvestila. Scheduler je determinističen glede na lokalni datum zagona. |
| Sledljivost funkcionalnost → TCI → test | Ustrezno | Vzpostavljena je v tabelah funkcionalnosti, TCI in specifikacijah ter povzeta v matriki. |
| UI pokritost | Delno / nezadostno | Samo obstoječi `widget_test.dart` preverja UI; pet funkcionalnih primerov uporablja neposredne klice in fake objekte. |
| Nastavitve, varnost in prava baza | Ni pokrito s petimi primeri | Manjkajoči obsegi so izrecno navedeni zgoraj; za trditev o polni uporabniški pokritosti je treba dodati ustrezne teste. |
| Rezultat in status dejanske izvedbe | Ni trajno dokumentirano | Testna koda ne vsebuje poročila o zadnjem zagonu. Zabeležiti je treba ukaz, okolje, datum, rezultate in napake po dejanski izvedbi. |
| Predpostavke in omejitve | Večinoma navedene | Testi ne uporabljajo pravega OS obvestilnega sistema, SQLCipher baze ali zaslonov, zato teh plasti ne potrjujejo. |

## Uporabljeni standardi in viri

- ISO/IEC/IEEE 29119-3:2021, zlasti poglavja 8.3 (specifikacija testnega primera) in 8.4 (specifikacija testnega postopka). Uporabljeni so prilagojeni dokumentacijski elementi, ne celoten nabor zahtev standarda.
- ISO/IEC/IEEE 29119-4:2021, tehnike načrtovanja testov; uporabljene so samo tehnike, navedene pri konkretnih TCI-jih.
- Projektni vir: `README.md`.
- Izvorna koda: `CycleRepository`, `NoteContentCodec`, `editPeriodBoundary` in `CycleNotificationScheduler` ter pripadajoči testni viri v `test/`.

Dokument ne zatrjuje popolne skladnosti s standardoma. Zahteve in pričakovani rezultati, ki niso potrjeni z README ali implementacijo, niso predstavljeni kot potrjene produktne zahteve.

## Uporabljena generativna orodja umetne inteligence

- **OpenAI Codex (GPT-6):** pregledal projektno kodo in dokumentacijo, pregledal agentove osnutke, pripravil matriko sledljivosti ter preveril in popravil testno kodo.
- **OpenAI Codex podagent `/root/testcase_agent`:** ustvaril prvi osnutek in nato ločene Dart testne datoteke po dopolnjenih ukazih. Agentove rezultate sem pregledal in zahteval popravke, kjer asercije niso ustrezale kodi projekta.
