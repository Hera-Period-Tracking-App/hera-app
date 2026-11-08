# Popravki po pregledu avtomatiziranih testov

### Izbira orodja `integration_test`

Za integracijske funkcionalne teste smo izbrali Flutterjev paket `integration_test`, ker želimo preveriti povezavo med uporabniškim vmesnikom, poslovno logiko, podatkovno bazo in platformnimi storitvami na Android emulatorju oziroma napravi. Prvotni testi z neposrednimi klici repozitorijev in nadomestnimi objekti preverjajo logiko, ne zajamejo pa interakcij skozi dejanske zaslone in delovanja pravih platformnih vtičnikov.

`integration_test` omogoča uporabo obstoječih Dart testov, izbirnikov gradnikov in asercij iz `flutter_test`. Tako lahko izvedemo vnose in klike ter preverimo rezultate v pravi SQLite bazi, šifriranje s platformno varno shrambo in registracijo opomnikov pri sistemu. Za Hera je to pomembno, ker uspešen prikaz zaslona sam po sebi še ne potrjuje pravilnega shranjevanja podatkov ali razporejanja opomnikov.

Izbira ustreza tudi obstoječemu Flutter projektu in pripravljenemu cevovodu GitHub Actions: teste zaganjamo z ukazom `flutter test` na Android emulatorju, rezultate pa shranimo kot poročilo. Uporabljamo isti jezik in testne pripomočke kot pri drugih testih projekta, zato ne potrebujemo ločenega ogrodja za avtomatizacijo.

Omejitev izbranega pristopa je zahtevnejša priprava okolja z emulatorjem, native odvisnostmi in dovoljenji. Trenutni testi uporabljajo namenski testni zaganjalnik in SQLite bazo v pomnilniku, zato ne preverjajo celotnega zagona aplikacije, ohranitve podatkov po ponovnem zagonu procesa ali dejanske prihodnje dostave obvestil. Sistemsko dovoljenje za obvestila mora biti urejeno pred zagonom testov.

### 1. Koraki, predpogoji in testni podatki

Dodal sem preverjanje, da vsak test začne s praznima tabelama ciklov in opomb, ter preverjanje datuma naprave za primera s fiksnimi datumi. Pri TC-004 in TC-005 sem dodal preverjanje pripravljenega cikla: začetnega datuma, dolžine cikla in menstruacije. Popravil sem tudi dokumentacijo, saj TC-002 ne potrebuje obstoječega cikla.

Poslovni koraki in podatki vseh petih primerov so zajeti. Integracijski testi uporabljajo pravo testno bazo in platformne storitve namesto prvotnih ponaredkov.

### 2. Preverjanje pričakovanih rezultatov

Preveril sem, da skripte primerjajo konkretne rezultate: shranjeni cikel, datum in šifriranje opombe, besedilo s simptomom in tokom, štiridnevno menstruacijo ter podatke treh opomnikov. Uspeh zato ni odvisen samo od prikaza zaslona.

Dokumentiral sem omejitve: obrezovanje besedila prav v repozitoriju in notranji tip `UpdatedPeriodBoundary` neposredno preverjata prvotna testa. Integracijska testa preverjata končni rezultat. Test opomnikov preverja registracijo pri sistemu, ne njihove prihodnje dostave.

### 3. Robustnost skript

Izbiro gumba z `.last` sem zamenjal z izbiro po vrsti gumba in besedilu. Klik po koordinatah sem zamenjal s platformnim dejanjem Nazaj. Dodal sem čakanje na zahtevano stanje elementa oziroma zaključek shranjevanja s časovno omejitvijo 30 sekund. Odstranil sem fiksno 11-sekundno pavzo pri opomnikih in s `try/finally` izboljšal čiščenje po testu.

Vseh pet testov je uspešno prestalo zagon v premešanem vrstnem redu. To potrjuje delovanje v preverjenem zaporedju, ne vseh možnih vrstnih redov.
