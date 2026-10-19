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

### 11. Navodilo za pregled skladnosti dokumentacije

```text
# NAVODILA ZA UI AGENTA – PRIPRAVA FUNKCIONALNIH TESTNIH PRIMEROV

## 1. Vloga in cilj

Deluj kot izkušen strokovnjak za zagotavljanje kakovosti programske opreme (QA Engineer), specializiran za funkcionalno testiranje in dokumentiranje testnih primerov po mednarodnem standardu ISO/IEC/IEEE 29119-3:2021.

Tvoja naloga je za izbrani programski projekt pripraviti natanko **5 kakovostnih, medsebojno smiselno različnih funkcionalnih testnih primerov**, skupaj z dokumentacijo testne pokritosti in matriko sledljivosti.

Pri pripravi upoštevaj:
- ISO/IEC/IEEE 29119-3:2021, poglavje 8.3.2 – Test coverage items.
- ISO/IEC/IEEE 29119-3:2021, poglavje 8.3.3 – Test cases.
- ISO/IEC/IEEE 29119-3:2021, poglavje 8.4 – Test procedure specification.
- Načela funkcionalnega testiranja in ustrezne tehnike načrtovanja testov, opisane v ISO/IEC/IEEE 29119-4:2021.

Dokumentacija naj bo v slovenskem jeziku, strokovno pravilna, dosledna, razumljiva in primerna za oddajo pri univerzitetnem predmetu.

## 2. Opis projekta

**Naziv projekta:** [VSTAVI NAZIV]

**Opis projekta:** [VSTAVI OPIS PROJEKTA]

**Funkcionalnosti in poslovna pravila:** [VSTAVI FUNKCIONALNOSTI IN ZAHTEVE, ČE SO ZNANE]

**Dokumentacija:** [PRILOŽI SZPO, UPORABNIŠKI PRIROČNIK ALI DRUGO DOKUMENTACIJO, ČE OBSTAJA]

Če dokumentacija ne obstaja, iz opisa projekta identificiraj samo funkcionalnosti, ki jih je mogoče utemeljeno določiti. Ne izmišljaj si neznanih poslovnih pravil, uporabniških vmesnikov ali vedenja sistema.

Če manjkajo bistvene informacije za pripravo preverljivih testov, najprej postavi vprašanja. Manjše predpostavke jasno označi in jih loči od potrjenih zahtev.

## 3. Identifikacija funkcionalnosti

Najprej določi funkcionalnosti, ki bodo predmet testiranja.

Vsaki funkcionalnosti dodeli enolični identifikator F-01, F-02 itd.

Pripravi tabelo:

| ID funkcionalnosti | Naziv funkcionalnosti | Kratek opis | Vir zahteve |
|---|---|---|---|

Vključi samo funkcionalnosti, ki jih bo preverjal vsaj eden od petih testnih primerov.

Če uradne dokumentacije ni, kot vir navedi »Opis projekta« ali »Predpostavka«, odvisno od izvora informacije.

## 4. Določitev elementov testne pokritosti (Test Coverage Items)

V skladu s poglavjem 8.3.2 standarda ISO/IEC/IEEE 29119-3:2021 identificiraj elemente testne pokritosti.

Vsak element naj vsebuje:
- Enolični identifikator (TCI-01, TCI-02 itd.).
- Opis elementa testne pokritosti.
- Prioriteto, kjer je potrebna.
- Sledljivost do funkcionalnosti oziroma testnega modela.
- Uporabljeno tehniko načrtovanja testa.

Pripravi tabelo:

| ID TCI | ID funkcionalnosti | Opis elementa testne pokritosti | Tehnika načrtovanja | Prioriteta |
|---|---|---|---|---|

Izberi tehnike, ki so primerne za konkretne funkcionalnosti, na primer:
- Razredi ekvivalence (Equivalence Partitioning).
- Analiza mejnih vrednosti (Boundary Value Analysis).
- Odločitvene tabele (Decision Table Testing).
- Prehodi med stanji (State Transition Testing).

Tehnik ne uporabljaj zgolj zaradi raznolikosti. Vsako izbrano tehniko kratko utemelji in ne uporabljaj analize mejnih vrednosti, če ni znanih ustreznih omejitev.

## 5. Izdelava petih testnih primerov (Test Case Specification)

Na podlagi določenih elementov testne pokritosti pripravi natanko pet funkcionalnih testnih primerov z oznakami TC-001 do TC-005.

Vsak testni primer mora vsebovati vse naslednje atribute, skladno s poglavjem 8.3.3 standarda:

**1. Unique Identifier (8.3.3.2)**

Enolični identifikator testnega primera, na primer TC-001.

**2. Objective (8.3.3.3)**

Kratek, jasen in nedvoumen cilj testiranja. Naziv naj opredeli, kaj test preverja.

**3. Priority (8.3.3.4)**

Prioriteta testnega primera (visoka, srednja ali nizka), določena glede na pomembnost funkcionalnosti, tveganje in posledice morebitne napake.

**4. Traceability (8.3.3.5)**

Povezava testnega primera na enega ali več elementov testne pokritosti (TCI) in pripadajoče funkcionalnosti (F).

**5. Preconditions (8.3.3.6)**

Natančno določeni predpogoji za izvedbo testa, vključno z zahtevanim stanjem sistema, testnimi podatki, uporabniškimi pravicami in omejitvami okolja, kadar so relevantni.

**6. Inputs (8.3.3.7)**

Konkretni vhodni podatki in dejanja, potrebna za izvedbo testa.

Navedi dejanske testne vrednosti, kjer je to mogoče. Dejanja predstavi v logičnem vrstnem redu in jasno opredeli njihove medsebojne odvisnosti.

**7. Expected Results (8.3.3.8)**

Natančni, objektivno preverljivi pričakovani rezultati, ki določajo pravilno vedenje sistema.

Izogibaj se nejasnim izrazom, kot so »sistem deluje pravilno«, »podatki se ustrezno shranijo« ali »prikaže se napaka«, brez dodatne konkretizacije.

Za vsak testni primer uporabi enotno obliko dokumentacije.

### Predloga posameznega testnega primera

**TC-00X – [Naziv testnega primera]**

| Atribut | Vsebina |
|---|---|
| Unique Identifier | TC-00X |
| Objective | ... |
| Priority | ... |
| Traceability | F-XX → TCI-XX → TC-00X |
| Preconditions | ... |
| Test Data | ... |

**Inputs in Expected Results**

| Korak | Dejanje / vhodni podatki | Pričakovani rezultat |
|---|---|---|
| 1 | ... | ... |
| 2 | ... | ... |
| 3 | ... | ... |

Dodaj tudi:
- Popogoje (Postconditions), kadar so relevantni.
- Dejanski rezultat (Actual Result): »Ni izvedeno«.
- Status izvedbe: »Ni izveden«.

Dodatna polja jasno loči od osnovnih elementov specifikacije testnega primera po poglavju 8.3.3.

## 6. Testni postopki (Test Procedure Specification)

Pri pripravi upoštevaj tudi poglavje 8.4 standarda ISO/IEC/IEEE 29119-3:2021.

Za vsak test zagotovi jasen in ponovljiv vrstni red izvajanja dejanj.

Ker gre za študijsko nalogo, lahko specifikacijo testnega primera in podrobne korake testnega postopka združiš v eno dokumentacijsko predlogo, vendar mora biti jasno razvidno, kateri podatki predstavljajo specifikacijo testa in kateri opisujejo njegovo izvedbo.

Če je med testi potrebna odvisnost ali posebno zaporedje, to izrecno navedi.

Ne trdi, da združena predloga predstavlja popolno samostojno specifikacijo testnega postopka po vseh določilih poglavja 8.4.

## 7. Raznolikost in kakovost testnih primerov

Izberi pet testnih primerov, ki skupaj preverjajo različne vidike funkcionalnosti.

Kjer je smiselno, vključi:
- Pozitivne testne primere z veljavnimi podatki.
- Negativne testne primere z neveljavnimi podatki.
- Preverjanje obveznih polj.
- Preverjanje mejnih vrednosti.
- Preverjanje sprememb stanja ali shranjevanja podatkov.

Ne ustvarjaj petih skoraj enakih testnih primerov.

Vsak testni primer mora biti:
- Nedvoumen.
- Ponovljiv.
- Izvedljiv.
- Neodvisen, kjer je to mogoče.
- Povezan z jasno opredeljeno funkcionalnostjo.
- Opremljen s konkretnimi vhodnimi podatki.
- Opremljen z objektivno preverljivimi pričakovanimi rezultati.

## 8. Matrika sledljivosti (Traceability Matrix)

Pripravi matriko, ki povezuje funkcionalnosti, elemente testne pokritosti in testne primere.

Uporabi naslednjo strukturo:

| ID funkcionalnosti | Naziv funkcionalnosti | ID TCI | Opis TCI | ID testnega primera |
|---|---|---|---|---|

Zagotovi:
- Vsak testni primer mora biti povezan z vsaj enim TCI.
- Vsak TCI mora biti povezan z ustrezno funkcionalnostjo.
- V matriki morajo biti zastopani vsi izdelani testni primeri.
- Identifikatorji in opisi morajo biti skladni v celotni dokumentaciji.
- Če en test preverja več elementov pokritosti, prikaži vse povezave.

## 9. Pregled in validacija rezultatov

Po pripravi dokumentacije izvedi kritičen pregled vseh petih testnih primerov.

Preveri:
1. Ali ima vsak test vse zahtevane atribute iz poglavja 8.3.3?
2. Ali so cilji testiranja jasno opredeljeni?
3. Ali so predpogoji dovolj natančni?
4. Ali so testni podatki konkretni?
5. Ali so koraki izvedbe ponovljivi?
6. Ali so pričakovani rezultati objektivno preverljivi?
7. Ali so testni primeri dovolj različni?
8. Ali so vse povezave v matriki sledljivosti pravilne?
9. Ali so vse predpostavke jasno označene?
10. Ali so testi skladni z dejansko opisanimi funkcionalnostmi?

Če ugotoviš pomanjkljivosti, popravi testne primere pred pripravo končne različice.

Na koncu dodaj kratko tabelo:

| Kriterij kakovosti | Rezultat preverjanja | Morebitne pripombe |
|---|---|---|

Ne trdi, da so bili testi dejansko izvedeni, če si pripravil samo njihovo specifikacijo.

## 10. Oblika končne dokumentacije

Pripravi enoten, profesionalno oblikovan dokument, primeren za izvoz v Word ali PDF, z naslednjo strukturo:

1. Naslovnica – Funkcionalno testiranje [naziv projekta].
2. Kratek opis projekta.
3. Pregled izbranih funkcionalnosti.
4. Elementi testne pokritosti.
5. Pet dokumentiranih funkcionalnih testnih primerov.
6. Matrika sledljivosti.
7. Pregled kakovosti testnih primerov.
8. Uporabljeni standardi in viri.

Uporabi pregledne tabele, dosledne identifikatorje, oštevilčene korake in strokovno slovensko terminologijo.

**Pomembno:** Dokumentacija naj temelji na standardu ISO/IEC/IEEE 29119-3:2021, vendar ne navajaj popolne skladnosti s standardom, če niso preverjene vse njegove zahteve.

Ne izmišljaj si rezultatov izvedbe testiranja, neobstoječih zahtev, poslovnih pravil ali virov.
```

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
| F-02 | Dodajanje opombe | Doda opombo z normaliziranim datumom in šifrirano vsebino. | README opombe ter `NoteRepository.addNote` in `EncryptionService.encrypt`; test preverja obnašanje z fake shrambo. |
| F-03 | Strukturirana vsebina opombe | Kodira in razčleni besedilo, simptome ter menstrualni tok. | `NoteContentCodec` in `note_options.dart`; README opisuje opombe. |
| F-04 | Urejanje meje menstruacije | Uredi dolžino menstruacije z odstranitvijo izbranega zadnjega dne. | `editPeriodBoundary` v `period_boundary_editor.dart`; koledarska funkcionalnost v kodi. |
| F-05 | Lokalno razporejanje opomnikov | Načrtuje obvestila glede na cikel, napoved, nastavitev in razpoložljivost obvestil. | README lokalnih opomnikov in `CycleNotificationScheduler.reschedule`. |

## Elementi testne pokritosti

Tehnike v tabeli opisujejo dejansko zasnovo primerov. Razred ekvivalence je uporabljen za veljaven cikel; mejna analiza je primerna za urejanje zadnjega dne. Ostali testi preverjajo dodajanje/šifriranje opombe, krožno kodiranje in razporejanje.

| ID TCI | ID funkcionalnosti | Opis elementa testne pokritosti | Tehnika načrtovanja | Prioriteta |
|---|---|---|---|---|
| TCI-01 | F-01 | Veljaven cikel z začetkom 1. 9. 2026, dolžino 28 dni in menstruacijo 5 dni se doda v prazno shrambo. | Razred ekvivalence: veljavna kombinacija vhodov. | Visoka |
| TCI-02 | F-02 | Opomba z datumom 15. 9. 2026 ob 14:30 in vsebino z robnimi presledki se shrani z datumom brez ure, vsebina pa je šifrirana in se dešifrira v obrezano besedilo. | Preverjanje transformacije in povratnega dešifriranja; fake lokalna shramba. | Srednja |
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

### TC-002 – Dodaj opombo (TC-NOTE-02)

| Atribut | Vsebina |
|---|---|
| Unique Identifier | TC-002; ID v testni kodi TC-NOTE-02; datoteka `tc_note_02_dodaj_opombo_test.dart` |
| Objective | Preveriti, da `NoteRepository.addNote` shrani opombo za datum brez ure in šifrira obrezano vsebino. |
| Priority | Srednja |
| Traceability | F-02 → TCI-02 → TC-002 |
| Preconditions | Pomnilniški fake `NoteLocalDataSource` in `SecureStorageDataSource`; uporabi se pravi `EncryptionService`, ne prava baza ali OS varna shramba. |
| Test Data | Datum 15. 9. 2026 ob 14:30; vsebina `  Blagi krči.  `; `cycleId` ni podan. |
| Inputs in Expected Results | 1) Pokliči `addNote` → klic se zaključi brez izjeme. 2) Preveri fake → vsebuje natanko en zapis z datumom 15. 9. 2026 ob 00:00, `cycleId` je `null`, vsebina ni shranjena kot čisto besedilo in JSON payload ima algoritem `A256GCM`. 3) Dešifriraj vsebino → rezultat je `Blagi krči.` brez začetnih/končnih presledkov. |
| Postconditions | Fake zapis in ključ v pomnilniku se po testu zavržeta; SQLCipher baza ni uporabljena. |
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
| F-02 | Dodajanje opombe | TCI-02 | Opombo zapiše z datumom brez ure ter šifrira in dešifrira vsebino. | [TC-002 / TC-NOTE-02](tc_note_02_dodaj_opombo_test.dart) |
| F-03 | Strukturirana vsebina opombe | TCI-03 | Round-trip ohrani besedilo, simptom `Cramps` in tok `Medium`. | [TC-003 / TC-NOTE-01](tc_note_01_opomba_simptom_tok_test.dart) |
| F-04 | Urejanje meje menstruacije | TCI-04 | Odstranitev izbranega zadnjega dne skrajša petdnevno menstruacijo na štiri dni. | [TC-004 / TC-CAL-01](tc_cal_01_meja_menstruacije_test.dart) |
| F-05 | Lokalno razporejanje opomnikov | TCI-05 | Načrtuje tri `period_soon` opomnike; test preveri naslov in čas prvega. | [TC-005 / TC-NOTIF-01](tc_notif_01_urnik_opomnika_test.dart) |

## Pregled kakovosti testnih primerov

| Kriterij kakovosti | Rezultat preverjanja | Morebitne pripombe |
|---|---|---|
| Vseh pet primerov ima enoličen ID in cilj | Ustrezno po dopolnitvi | TC-001–TC-005 so dokumentacijske oznake, preslikane na enolične ID-je v imenih testov in komentarjih izvornih datotek. |
| Vhodi in pričakovani rezultati so konkretni | Večinoma ustrezno | Scheduler test uporablja relativni datum (`DateTime.now()`), a preverja konkretno relativno časovno razliko, naslov, payload in število opomnikov. |
| Primeri so različni in ponovljivi | Večinoma ustrezno | Pokrivajo dodajanje cikla, dodajanje in kodiranje opombe, mejo menstruacije ter obvestila. Scheduler je determinističen glede na lokalni datum zagona. |
| Sledljivost funkcionalnost → TCI → test | Ustrezno | Vzpostavljena je v tabelah funkcionalnosti, TCI in specifikacijah ter povzeta v matriki. |
| UI pokritost | Delno / nezadostno | Samo obstoječi `widget_test.dart` preverja UI; pet funkcionalnih primerov uporablja neposredne klice in fake objekte. |
| Pozitivni in negativni primeri | Delno | Trenutnih pet funkcionalnih testov preverja pozitivne tokove; negativen primer zavrnitve prekrivanja ciklov je bil zamenjan. Smiselna naslednja dopolnitev je test zavrnitve prazne ali podvojene opombe. |
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
