# Popravki po pregledu avtomatiziranih testov

### 1. Koraki, predpogoji in testni podatki

Dodal sem preverjanje, da vsak test začne s praznima tabelama ciklov in opomb, ter preverjanje datuma naprave za primera s fiksnimi datumi. Pri TC-004 in TC-005 sem dodal preverjanje pripravljenega cikla: začetnega datuma, dolžine cikla in menstruacije. Popravil sem tudi dokumentacijo, saj TC-002 ne potrebuje obstoječega cikla.

Poslovni koraki in podatki vseh petih primerov so zajeti. Integracijski testi uporabljajo pravo testno bazo in platformne storitve namesto prvotnih ponaredkov.

### 2. Preverjanje pričakovanih rezultatov

Preveril sem, da skripte primerjajo konkretne rezultate: shranjeni cikel, datum in šifriranje opombe, besedilo s simptomom in tokom, štiridnevno menstruacijo ter podatke treh opomnikov. Uspeh zato ni odvisen samo od prikaza zaslona.

Dokumentiral sem omejitve: obrezovanje besedila prav v repozitoriju in notranji tip `UpdatedPeriodBoundary` neposredno preverjata prvotna testa. Integracijska testa preverjata končni rezultat. Test opomnikov preverja registracijo pri sistemu, ne njihove prihodnje dostave.

### 3. Robustnost skript

Izbiro gumba z `.last` sem zamenjal z izbiro po vrsti gumba in besedilu. Klik po koordinatah sem zamenjal s platformnim dejanjem Nazaj. Dodal sem čakanje na zahtevano stanje elementa oziroma zaključek shranjevanja s časovno omejitvijo 30 sekund. Odstranil sem fiksno 11-sekundno pavzo pri opomnikih in s `try/finally` izboljšal čiščenje po testu.

Vseh pet testov je uspešno prestalo zagon v premešanem vrstnem redu. To potrjuje delovanje v preverjenem zaporedju, ne vseh možnih vrstnih redov.
