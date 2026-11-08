# Izbira orodja in vključitev testov v cevovod

## Izbira orodja

Za avtomatizirano preverjanje funkcionalnosti aplikacije Hera smo izbrali **`flutter_test`**, ker je namenjen testiranju Flutter aplikacij, je že vključen med razvojne odvisnosti projekta in omogoča neposredno preverjanje pričakovanih rezultatov z asercijami `expect`. Testi se izvajajo brez emulatorja ali fizične naprave, zato so primerni za hitro samodejno preverjanje sprememb.

Pet pripravljenih testov preverja dodajanje cikla, dodajanje in šifriranje opombe, ohranitev strukturirane vsebine opombe, spremembo meje menstruacije ter razporejanje opomnikov. Uporabljajo neposredne klice funkcij oziroma repozitorijev in pomnilniške nadomestne objekte (fake), s katerimi vsak test sam pripravi svoje podatke. Asinhrone operacije čakajo z `await`, brez fiksnih časovnih pavz.

Ti testi preverjajo izbrane funkcionalne rezultate na ravni logike in storitev. Ne potrjujejo celotnih uporabniških poti skozi zaslone, delovanja prave baze ali prikaza sistemskih obvestil na napravi. Za te vidike bi bilo treba dodati integracijske teste, na primer z orodjem `integration_test`.

## Izvor testov ter ročni pregledi in ugotovitve

Testno kodo je napisal AI (OpenAI Codex). Pri ročnem pregledu so bila zastavljena vprašanja o zajetosti testnih primerov, preverjanju pričakovanih rezultatov in robustnosti skript. Na podlagi teh vprašanj je AI pregledal kodo, pripravil ugotovitve in izvedel zahtevani popravek. Spodaj je povzetek pregleda kode in dokumentacije; ne predstavlja zapisnika ročnega izvajanja scenarijev v aplikaciji.

| Predmet pregleda | Ugotovitev oziroma ukrep |
|---|---|
| Zajetost korakov, predpogojev in testnih podatkov | Glavni koraki in konkretni podatki petih trenutno opisanih primerov so večinoma zajeti v kodi. Izvedeni so z neposrednimi klici funkcij in repozitorijev; odpiranje zaslonov, vnos in kliki niso preverjeni. |
| Predpogoj obstoječega cikla v TC-002 | Dokumentacija je navajala, da test sam pripravi obstoječi cikel, koda pa ga ni pripravila. Na zahtevo uporabnika je bila popravljena koda: test zdaj pripravi cikel v pomnilniškem testnem objektu in preveri, da ostane ohranjen po dodajanju opombe. Opomba še vedno nima podanega `cycleId`, zato povezava opombe s ciklom ni preverjena. |
| Preverjanje pričakovanih rezultatov | Vseh pet dodanih testov z asercijami `expect` preverja konkretne rezultate: shranjene vrednosti cikla, datum in šifriranje opombe, ohranitev strukturiranih polj, skrajšanje menstruacije ter število in izbrane lastnosti opomnikov. Ne preverjajo samo uspešnega zagona. |
| Izbira elementov | Testi ne iščejo elementov na zaslonu, zato niso odvisni od položaja gumbov ali besedil vmesnika. Robustnost izbirnikov UI s temi testi ni preverjena. |
| Čakanje | Za asinhrone operacije uporabljajo `await`; fiksnih pavz ni. Čakanje na pojav elementov ni vključeno, ker testi ne izvajajo interakcij z zasloni. |
| Neodvisnost | Vsak test pripravi svoje podatke in lokalne testne objekte. Ne potrebuje rezultatov drugih testov ali skupne trajne baze. |
| Ponovljivost glede na čas | Test opomnikov uporablja `DateTime.now()`, test cikla pa fiksen datum, ki mora biti v preteklosti. Predlagana izboljšava je uporaba ure, nastavljive v testih; še ni izvedena. |
| Izbira opomnika | Test preveri število treh opomnikov `period_soon`, naslov in čas pa samo pri prvem (`reminders.first`). Odvisnost od vrstnega reda bi zmanjšali z izbiro po pričakovanem datumu ali preverjanjem vseh treh; ta izboljšava še ni izvedena. |

Obstoječi `widget_test.dart` je bil pri pregledu obravnavan ločeno: preverja prisotnost besedil »Welcome to Hera« in »Continue« na začetnem zaslonu. V cevovod petih dodanih testov ni vključen.

**Stanje preverjanja:** Poskus zagona popravljenega TC-002 je obstal brez izpisa in je bil prekinjen, zato uspeh tega zagona ni potrjen. Tudi izvajanje pripravljenega cevovoda na GitHubu še ni potrjeno. Ugotovitve ročnega pregleda kode niso dokazilo o uspešni izvedbi testov.

## Predviden način vključitve v cevovod

Za izvajanje testov je pripravljen cevovod **GitHub Actions**, definiran v datoteki [`.github/workflows/functional-tests.yml`](../.github/workflows/functional-tests.yml). Po vključitvi projekta v GitHub repozitorij z omogočenimi Actions je predviden samodejni zagon ob vsakem dogodku `push` in `pull_request`; omogočen je tudi ročni zagon z `workflow_dispatch`.

Cevovod na izvajalniku Ubuntu izvede naslednje korake:

1. Prevzame izvorno kodo in model aplikacije prek Git LFS.
2. Pripravi Flutter iz kanala `stable` in izpiše različico SDK.
3. Namesti odvisnosti z `flutter pub get --enforce-lockfile`, pri čemer upošteva `pubspec.lock`.
4. Generira lokalizacijo in Dart kodo, potrebno za prevajanje testov.
5. Zažene natanko pet izbranih testnih datotek `tc_*`. Obstoječi `widget_test.dart` ni vključen v ta izbor.
6. Shrani rezultate v obliki JSON in besedilni dnevnik kot artefakt `functional-test-results` za 14 dni. Shranjevanje se poskusi tudi ob neuspehu, če sta datoteki nastali.

Če kateri izmed testov ne uspe ali pride do napake pri pripravi okolja, je izvajanje cevovoda označeno kot neuspešno. Rezultat je viden v zavihku Actions in pri povezanem pull requestu. Za obvezno uspešno preverjanje pred združitvijo je treba v nastavitvah repozitorija posebej določiti pravilo zaščite veje oziroma ruleset, ki zahteva uspeh opravila `Five functional test cases`; sama datoteka cevovoda združitve ne blokira.
