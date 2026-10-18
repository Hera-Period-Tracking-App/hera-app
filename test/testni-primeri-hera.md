# Funkcionalni testi za aplikacijo Hera

Dokument povezuje pet funkcionalnih testov v mapi `` z deli aplikacije, ki jih preverjajo. Testi so ločeni v Dart datoteke; komentarji v vsaki datoteki vsebujejo cilj, predpogoje, podatke, korake, pričakovane rezultate, predpostavke in čiščenje.

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

## Matrika sledljivosti

| ID funkcionalnosti | Funkcionalnost / testna osnova | Testni primer | Pokritost |
|---|---|---|---|
| F-01 | Dodajanje veljavnega cikla in shranjevanje začetnega datuma, dolžine cikla ter menstruacije | [TC-CYC-01](</D:/hera-app-app/test/tc_cyc_01_dodaj_cikel_test.dart>) | Pozitiven tok; 28-dnevni cikel in 5-dnevna menstruacija |
| F-02 | Zavrnitev novega cikla, ki se prekriva z obstoječim | [TC-CYC-02](</D:/hera-app-app/test/tc_cyc_02_zavrni_prekrivanje_test.dart>) | Negativen tok; obstoječi cikel 1.–28. 9. 2026, poskus novega začetka 15. 9. |
| F-03 | Kodiranje in ponovni priklic besedila, simptoma in menstrualnega toka v opombi | [TC-NOTE-01](</D:/hera-app-app/test/tc_note_01_opomba_simptom_tok_test.dart>) | Round-trip polj, ki jih podpira `NoteContentCodec` |
| F-04 | Urejanje zadnjega dne menstruacije v koledarskem ciklu | [TC-CAL-01](</D:/hera-app-app/test/tc_cal_01_meja_menstruacije_test.dart>) | Mejna vrednost; 5-dnevna menstruacija se skrajša na 4 dni |
| F-05 | Načrtovanje opomnika pred napovedanim začetkom menstruacije | [TC-NOTIF-01](</D:/hera-app-app/test/tc_notif_01_urnik_opomnika_test.dart>) | Payload `period_soon`, naslov in čas 09:00, 26 dni po začetku cikla |

## Uporabljena generativna orodja umetne inteligence

- **OpenAI Codex (GPT-6):** pregledal projektno kodo in dokumentacijo, pregledal agentove osnutke, pripravil matriko sledljivosti ter preveril in popravil testno kodo.
- **OpenAI Codex podagent `/root/testcase_agent`:** ustvaril prvi osnutek in nato ločene Dart testne datoteke po dopolnjenih ukazih. Agentove rezultate sem pregledal in zahteval popravke, kjer asercije niso ustrezale kodi projekta.
