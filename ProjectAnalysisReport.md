# Analiza projekta "Baš čelik"

**Baš Čelik** je čitač elektronskih ličnih karata, zdravstvenih knjižica i saobraćajnih dozvola. Program je osmišljen kao zamena za zvanične aplikacije poput _Čelika_. Nažalost, zvanične aplikacije mogu se pokrenuti samo na Windows operativnom sistemu, dok Baš Čelik funkcioniše na tri operativna sistema (Windows/Linux/OSX).

Baš Čelik je besplatan program, sa potpuno otvorenim kodom dostupnim na adresi [github.com/ubavic/bas-celik](https://github.com/ubavic/bas-celik).

[Komit](https://github.com/ubavic/bas-celik/commit/08d5698150e294af2a816db668c8e0d428bc923b) projekta na kom se radi analiza ima hash `08d5698150e294af2a816db668c8e0d428bc923b`.

Cilj ove analize je procena pouzdanosti, efikasnosti i kvalitet softvera. Izvršena je analiza projekta primenom alata:

- gofmt
- govulncheck
- golangci-lint
- go test, go tool cover
- go fuzz
- gocyclo

# Analiza koda korišćenjem gofmt alata

## gofmt

[**gofmt**](https://pkg.go.dev/cmd/gofmt) je alat za automatsko formatiranje Go programskog koda, ugrađen u sam Go toolchain. Vođen je stavom da postoji samo jedan ispravan način za formatiranje Go koda.

`gofmt` koristi **tab** karaktere za uvlačenje i **razmake** za poravnanja. Poravnanje podrazumeva da editor koristi font sa fiksnom širinom karaktera.

Bez navođenja putanje, `gofmt` obrađuje standardni ulaz. Kada je prosleđen fajl, obrađuje se taj fajl, a kada je prosleđen direktorijum, obrađuju se svi fajlovi sa ekstenzijom `.go` u tom direktorijumu rekurzivno (fajlovi čije ime počinje tačkom se ignorišu). Podrazumevano, `gofmt` ispisuje formatirani kod na standardni izlaz.

### Korišćenje

    gofmt [flags] [path ...]

### Podržani flagovi

#### -d

Ne ispisuje kompletan formatirani kod na standardni izlaz.
Ako se formatiranje fajla razlikuje od `gofmt` standarda, na standardni izlaz se ispisuje razlika (diff) između originalnog i formatiranog koda.

#### -e

Ispisuje sve greške, uključujući i one koje bi inače bile ignorisane ili smatrane sporednim.

#### -l

Ne ispisuje formatirani kod.
Ako se formatiranje fajla razlikuje od `gofmt` standarda, ispisuje se samo ime fajla.

#### -r rule

Primenjuje pravilo prepisivanja (rewrite rule) na izvorni kod pre formatiranja.

Primer:

    gofmt -r 'a[b:len(a)] -> a[b:]' -w file.go

#### -s

Pokušava da pojednostavi kod nakon primene rewrite pravila (ako postoji).

#### -w

Ne ispisuje formatirani kod na standardni izlaz.
Ako se formatiranje razlikuje, fajl se direktno prepisuje formatiranom verzijom.
U slučaju greške tokom upisa, originalni fajl se automatski vraća iz rezervne kopije.

## Primena alata i rezultati

Alat `gofmt` je pokrenut nad projektnim kodom sa sledećim flagovima:

- `-e` — ispis svih grešaka, uključujući i one koje se inače ne prikazuju
- `-s` — pokušaj pojednostavljenja koda primenom idiomatskih Go pravila
- `-l` — ispis samo naziva fajlova čije formatiranje odstupa od `gofmt` standarda

Cilj izvršavanja alata je identifikovanje fajlova koji odstupaju od propisanog formata. Rezultati izvršavanja prikazani su na narednoj slici.

![](./gofmt_out.png)

## Analiza rezultata

Kako je jedan od osnovnih uslova za doprinos projektu striktno poštovanje formatiranja pomoću alata `gofmt`, očekivano je da tokom analize nije identifikovan nijedan fajl koji odstupa od propisanog formata. Izostanak izlaza alata ukazuje na to da je kompletan izvorni kod već usklađen sa zvaničnim Go konvencijama formatiranja.

Ovakav rezultat potvrđuje doslednu primenu standarda u okviru projekta, kao i dobru praksu održavanja koda. Pravilno formatiran kod doprinosi boljoj čitljivosti, lakšem održavanju i smanjenju mogućnosti za greške nastale usled neujednačenog stila pisanja.

Na osnovu dobijenih rezultata može se zaključiti da je analizirani kod uredno strukturiran i u potpunosti spreman za dalji razvoj i saradnju u timskom okruženju.

# Analiza koda korišćenjem govulncheck alata

## Govulncheck

[**Govulncheck**](https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck) je alat iz Go toolchaina koji se koristi za pronalaženje poznatih ranjivosti u korišćenim Go paketima. Alat koristi statičku analizu koda i prijavljuje samo one ranjivosti koje mogu imati uticaj na samu aplikaciju.

Podrazumevano, `govulncheck` šalje zahteve bazi podataka poznatih Go ranjivosti na adresi [https://vuln.go.dev](https://vuln.go.dev). Zahtevi sadrže **samo putanje modula sa poznatim ranjivostima**, bez deljenja izvornog koda ili drugih osobina programa.

Ako želimo da koristimo drugačiju bazu podataka, koristi se flag `-db`. Baza podataka mora biti u skladu sa specifikacijom: [Go Vulnerability Database](https://go.dev/security/vuln/database).

`Govulncheck` koristi verziju Go-a za koju je konfigurisan modul ili binarni fajl:

- **Za analizu izvornog koda**: koristi se verzija Go komande koja je dostupna na `PATH`.
- **Za analizu binarnih fajlova**: koristi se verzija Go koja je korišćena prilikom kompilacije.

Pokretanje `govulncheck` radi se iz direktorijuma modula, koristeći istu sintaksu putanje paketa kao i `go` komanda:

    cd my-module
    govulncheck ./...

> **NAPOMENA:** Alat `govulncheck` se oslanja na [Go Vulnerability Database](https://vuln.go.dev/) koja u trenutku izvršavanja skripte može biti ažurirana i zbog toga može dati drugačije rezultate od prikazanih. Moguće je da se u trenutku ponovnog izvršavanja analize identifikuju dodatne ranjivosti ili da se postojeće klasifikuju drugačije.

## Primena alata i rezultati

Alat je pokrenut nad svim fajlovima projekta. Pronađene su sledeće ranjivosti:

- **Standardna biblioteka Go: 2 ranjivosti**
  - GO-2025-4175 – nepravilna primena DNS name constraints u `crypto/x509`  
    [više informacija](https://pkg.go.dev/vuln/GO-2025-4175)  
    Rešeno nadogradnjom na Go verziju 1.25.5
  - GO-2025-4155 – prekomerna potrošnja resursa pri proveri host sertifikata u `crypto/x509`  
    [više informacija](https://pkg.go.dev/vuln/GO-2025-4155)

  ![](./go_std.png)

- **Moduli: 3 ranjivosti**
  - GO-2025-4135 – neispravno definisana ograničenja u `golang.org/x/crypto/ssh/agent`
  - GO-2025-4134 – neograničeno korišćenje memorije u `golang.org/x/crypto/ssh`
  - GO-2025-4116 – potencijalni DoS u `golang.org/x/crypto/ssh/agent`

  ![](./go_module.png)

Preostale ranjivosti nisu direktno korišćene u kodu i ne utiču na trenutnu funkcionalnost aplikacije.

## Analiza rezultata

`Govulncheck` je skenirao 36 modula projekta i Go standardnu biblioteku verzije 1.25.3. Analiza je pokazala da su identifikovane ranjivosti u standardnoj biblioteci i modulima `golang.org/x/crypto`. Ove ranjivosti mogu predstavljati sigurnosni rizik.

- Za standardnu biblioteku: nadogradnja Go verzije u `go.mod` sa `go 1.24.2` na `go 1.25.5` i izvršavanje komande:

```
go mod tidy
```

- Za popravku ranjivosti u modulima `golang.org/x/crypto` primenjene su sledeće komande:

```
  go get golang.org/x/crypto@v0.45.0
  go mod tidy
```

Nakon primene ovih koraka, sve identifikovane ranjivosti su otklonjene, čime je kod sada u skladu sa preporukama sigurnosne zajednice Go-a.

Analiza korišćenjem alata `govulncheck` pokazala je da su postojale poznate ranjivosti u standardnoj biblioteci Go i u nekim korišćenim modulima. Nakon nadogradnje Go verzije i kritičnih modula, sve identifikovane ranjivosti su otklonjene.

# Analiza koda korišćenjem golangci-lint alata

## Golangci-lint

[**Golangci-lint**](https://golangci-lint.run/) je alat za statičku analizu Go koda koji objedinjuje više različitih lintera u jedinstven okvir. Omogućava istovremenu proveru stila programiranja, semantičke ispravnosti i potencijalnih bezbednosnih problema, čime doprinosi kvalitetu, čitljivosti i pouzdanosti softverskog sistema.

## Primena alata i rezultati

Alat je primenjen nad analiziranim Go projektom koristeći unapred definisanu konfiguraciju lintera (`.golangci.yml`). Korišćeni linteri su:

- **revive** – proverava usklađenost koda sa stilskim konvencijama i dobrim praksama Go jezika, uključujući imenovanje, komentare i strukturu koda
- **whitespace** – detektuje nepravilnosti u razmacima i rasporedu praznih linija u izvornom kodu
- **govet** – analizira Go kod i detektuje sumnjive konstrukcije koje mogu dovesti do semantičkih grešaka
- **staticcheck** – identifikuje potencijalne bagove, loše obrasce i neefikasan kod
- **errcheck** – detektuje neproverene povratne vrednosti funkcija koje vraćaju grešku
- **ineffassign** – otkriva dodele promenljivih čije se vrednosti nikada ne koriste
- **unused** – identifikuje neiskorišćene promenljive, konstante, funkcije i tipove
- **bodyclose** – proverava da li je HTTP odgovor pravilno zatvoren kako bi se izbeglo curenje resursa
- **gosec** – identifikuje potencijalne bezbednosne ranjivosti u Go kodu, kao što su nesigurne kriptografske operacije ili nebezbedno rukovanje podacima

Rezultati izvršavanja alata prikazani su na sledećoj slici:

![](./golangci_lint_results.png)

Neki od interesantnijih primera grešaka:

- `staticcheck` je predložio primenu De-Morganovog zakona na izraz sa negacijom ispred zagrade. Ovo je primer kako linter može pomoći u pojednostavljivanju logičkih izraza.
  ![](./de_morgans_law.png)

- `revive` je upozorio da se u funkcijama `add` i `Merge` predefiniše ugrađena funkcija `new`. Iako Go dozvoljava ovu predefiniciju, linter upozorava na potencijalnu konfuziju.
  ![](./redefine_new.png)

## Analiza rezultata

Većina upozorenja potiče od lintera `revive` (322), koji proverava imenovanje, dokumentacione komentare i strukturu koda.

Linter `errcheck` prijavio je 27 grešaka vezanih za neproveravanje povratne vrednosti funkcija koje vraćaju grešku. U nekim slučajevima bilo je preporučljivo proveriti povratnu vrednost funkcije, dok u funkcijama koje se izvršavaju kroz defer to nije bilo neophodno, jer greška ne utiče na tok programa.

Linter `gosec` je prijavio 9 potencijalnih problema, uključujući konverziju iz `int` u `uint32` koja može dovesti do prekoračenja. Kod je izmenjen kako bi se zadovoljili zahtevi lintera, iako u analiziranim slučajevima prekoračenje nije bilo moguće.

Linter `staticcheck` prijavio je 7 grešaka i predložio zamenu uzastopnih `if-else` izraza sa `switch` konstrukcijom radi preglednijeg koda.

Linter `whitespace` prijavio je 5 grešaka, sugerišući uklanjanje nepotrebnih praznih linija.

Na osnovu rezultata primene alata, nisu pronađene greške koje bi mogle uticati na izvršavanje programa, što potvrđuje da je kod projekta kvalitetan i dobro strukturisan.

Nakon ispravki u kodu, preostalo je ukupno 24 greške: 13 od `revive` i 11 od `errcheck`. Greške `revive` se odnose na imenovanje promenljivih i ponavljanje reči (stuttering), npr. `reader.ReaderPoller`, kao i na raspored parametara funkcija. Greške `errcheck` odnose se na neproveravanje povratne vrednosti kod funkcija koje su `defer`-ovane, što nije problematično i nije bilo potrebno ispravljati.

## Zaključak

Primena alata `golangci-lint` potvrđuje da je kod projekta **dobro strukturisan, čitljiv i u skladu sa stilskim i semantičkim standardima Go jezika**. Iako su pronađene određene greške one nisu značajno uticale na kvalitet koda i izvršavanje programa. Većina prijavljenih grešaka potiče od lintera `revive`. Te greške ne utiču na funkcionalnost programa, ali poboljšavaju upotrebljivost i čitljivost programa što je naročito korisno u timskom radu jer podstiče dokumentovanost i konzistentno imenovanje promenljivih.

# Unit testovi korišćenjem go test i go tool cover alata

## Go test

[Go test](https://pkg.go.dev/cmd/go/internal/test) omogućava automatsko izvršavanje testova paketa korišćenjem import paths.
Ispisuje sumirane rezultate testova u sledećem formatu:

```
ok archive/tar 0.011s
FAIL archive/zip 0.022s
ok compress/gzip 0.033s
...
```

praćeno detaljnim izlazom za svaki od paketa.

`Go test` kompajlira svaki paket zajedno sa fajlovima čiji naziv zadovoljava šablon `*_test.go`.

Ovi dodatni fajlovi mogu sadržati test funkcije, benchmark funkcije, fuzz testove i primer funkcija. Pogledajte `go help testfunc` za više informacija.  
Svaki navedeni paket uzrokuje izvršavanje posebnog test binarnog fajla.  
Fajlovi čiji nazivi počinju sa "\_" (uključujući `_test.go`) ili "." se ignorišu.

Test fajlovi koji deklarišu paket sa sufiksom `_test` biće kompajlirani kao poseban paket, a zatim povezani i izvršeni sa glavnim test binarnim fajlom.

Go alat će ignorisati direktorijum nazvan `testdata`, što ga čini dostupnim za smeštanje pomoćnih podataka potrebnih za testove.

## Go tool cover

[Cover](https://pkg.go.dev/cmd/cover) je program za analizu profila pokrivenosti (coverage) koji se generišu pomoću `go test -coverprofile=cover.out`.

## Primena alata i rezultati

S obzirom na to da projekat već sadrži određeni broj **unit testova**, alati su prvo primenjeni bez izmena i dodavanja novih testova.

`Go test` je primenjen na svim fajlovima u projektu, prvo bez dodatnih flagova, a zatim sa `-v` (verbose) i `-coverprofile` flagovima, kako bi se videlo izvršavanje svakog testa ponaosob i kako bismo generisali **coverage po linijama koda**. Iz izlaza se vidi da svi testovi prolaze, što je i očekivano.

![](./test_out.png)

`Go tool cover` primenjen na `cover.out` fajlu koji smo dobili iz `go test` komande pokazuje da je **ukupna pokrivenost koda po linijama** 18%.

![](./coverage_out.png)

Pokrivenost po fajlovima ponaosob može se videti na sledećoj slici:

![](./coverage.png)

Detaljnu pokrivenost po linijama koda možemo videti u izlaznom [HTML fajlu](./cover_before.html)

## Analiza rezultata

Svi unit testovi u projektu su uspešno prošli, što potvrđuje da trenutni testovi ne detektuju greške u delovima koda koje pokrivaju.

Međutim, ukupna pokrivenost testovima je relativno niska – svega 18% linija koda je pokriveno testovima. To znači da **većina koda nije direktno testirana**, što ostavlja prostor za eventualne greške ili regresije u neproverenim delovima projekta.

Pokrivenost po fajlovima pokazuje da su određeni moduli i funkcionalnosti gotovo u potpunosti testirani, dok su drugi gotovo potpuno nezaštićeni testovima. Ovo ukazuje na moguće prioritete za dodatno pisanje unit testova, naročito za kritične funkcije i module koji imaju veliki uticaj na funkcionalnost i stabilnost aplikacije.

Korišćenjem `go tool cover -html=cover.out` možemo vizuelno identifikovati delove koda koji nisu pokriveni testovima, što olakšava planiranje dodatnih testova i povećanje ukupne pokrivenosti. Povećanje coverage-a ne samo da smanjuje rizik od grešaka, već i poboljšava kvalitet i održivost koda u budućnosti.

## Dodati testovi

Paket `card` odabran je za pisanje dodatnih unit testova jer sadrži važne funkcionalsti vezane za čitanje elektronskih kartica.

### Test helpers i card mock

Korišćenjem paketa `testify/mock` kreirana je CardMock struktura koja omogućava da izolujemo kod koji obrađuje karticu kako bi napravili testove jedinica koda. Nasleđivanje strukture `Mock` iz paketa `testify/mock` daje nam moguđnost da određujemo povratnu vrednost funkcije na osnovu ulaza, da proveravamo da li je funkcija bila pozvana potreban broj puta i slično. Ovo u velikoj meri olakšava pisanje unit testova. Detaljna implementacija može se videti u fajlu `/unit/test_helpers/test_helpers.go`.

### Testovi

/unit/card/apollo_test.go:

- Test_InitCard - proverava da inicijalizacija Apollo kartice ne vraća grešku.
- TestApolloReadCard - simulira čitanje svih fajlova sa mock smart kartice i validira rezultate i greške.
- TestApolloSelectFile - ispituje select APDU, pozitivne i negativne statuse/greške Transmit poziva.
- TestApolloReadFile - pokriva čitanje fajla u delovima, bad header, greške čitanja i prazan chunk.
- TestApolloAtr - potvrđuje da `Atr()` vraća očekivani ATR.
- TestApolloGetDocumentError - očekuje grešku kada nedostaju učitani fajlovi pre parsiranja dokumenta.
- TestApolloTest - očekuje da self-test funkcija vraća true.

/unit/card/card_test.go:

- Test_responseOK - proverava da li status bajtovi označavaju uspeh.
- Test_read - validira čitanje binarnog fajla: korektne APDU vrednosti, kraćenje dužine i razne greške.
- Test_trim4b - testira odsecanje leading 4 bajta kada je potrebno.
- Test_DetectCardDocument - pokriva mapiranje ATR-a na tip kartice, uključujući status greške i unknown karticu.

/unit/card/gemalto_test.go:

- TestGemaltoInitCard - obuhvata sve grane inicijalizacije (tri pokušaja appleta i različite greške Transmit poziva).
- TestGemaltoReadCard - simulira čitanje dokumenata, ličnih, prebivališnih i foto fajlova sa očekivanim greškama.
- TestGemaltoGetDocument - proverava parsiranje TLV podataka u IdDocument i greške po fajlu.
- TestGemaltoAtr - potvrđuje da `Atr()` vraća postavljeni ATR.
- TestGemaltoReadFile - testira selektovanje fajla, čitanje zaglavlja/tela i scenarije loših statusa.
- TestGemaltoReadCertificateFile - validira čitanje sertifikata u segmentima i greške header/body/selektovanja.
- TestGemaltoInitCrypto - očekuje uspešnu inicijalizaciju kriptografije (SELECT AID).
- TestGemaltoChangePinSuccess - proverava tok promene PIN-a uz transakciju i vraćene pokušaje.
- TestGemaltoChangePinInvalidNew - validira odbacivanje neispravnog novog PIN-a.
- TestGemaltoReadSignatures - čita dve potpisa iz fajlova sa header+body segmentima.
- TestGemaltoLoadCertificates_Existing - čuva prethodno učitane sertifikate bez dodatnih Transmit poziva.
- TestGemaltoGetCertificates - vraća kopiju validnih sertifikata filtrirajući nil vrednosti.

/unit/card/medical_test.go:

- Test_descramble - dekodira UTF-16 polja i proverava očekivane stringove i prazne slučajeve.
- TestMedicalInitCard - gradi očekivani AID select APDU i pokriva uspeh/bad status/grešku transmitovanja.
- TestMedicalReadCard - čita četiri medicinska fajla, validira uspeh i greške na svakom koraku.
- TestMedicalGetDocument - parsira TLV zapise u MedicalDocument (muški/ženski) i pokriva sve parse greške.

/unit/card/smartCard_test.go:

- TestMakeVirtualCard - proverava konstrukciju virtualne kartice i mapiranje fajlova.
- TestVirtualCard_Status - validira Status izlaz (ATR, Reader, State).
- TestTransmit - očekuje podrazumevani uspešan odgovor na Transmit.

/unit/card/state_test.go:

- TestFormatState - formatira SCARD flagove pojedinačno i u kombinaciji u string.

/unit/card/unknownCard_test.go:

- TestAtr - validira vraćeni ATR.
- TestReadFile - očekuje grešku „not implemented”.
- TestInitCard - proverava da inicijalizacija prolazi bez greške.
- TestReadCard - očekuje da ReadCard ne vraća grešku.
- TestGetDocument - očekuje nil dokument bez greške.
- TestTest - očekuje true iz self-test funkcije.

/unit/card/vehicle_test.go:

- Test_parseVehicleCardFileSize - proverava parsiranje dužine/ofseta za različite header kombinacije i greške.
- TestVehicleCardReadCard - simulira čitanje četiri vozila fajla sa validacijom i grešnim slučajevima po fazi.
- TestVehicleCardGetDocument - BER-dekodira minimalne fajlove i mapira u VehicleDocument.

/unit/card/ber/ber_test.go:

- Test_parseBerLength - pokriva različite formate dužine i greške.
- Test_parseBerTag - proverava parsiranje taga, primitivni/konstruisani bit i greške.
- TestParseBER - gradi BER stablo iz bajt niza i proverava greške praznog ulaza.
- Test_parseBERLayer - testira parsiranje sloja u primitive/construct podslojeve i error slučajeve.
- TestBERAccess - pristupa deci prema adresi i proverava grešku za nepostojeći put.
- TestBERAdd - dodaje i spaja čvorove, validira tipove i detektuje greške.
- TestBERMerge - spaja BER stabla i hvata mismatch tagova.
- TestAssignFromAndString - dodeljuje vrednost putem adrese i proverava string prikaz stabla.

## Rezultati nakon dodavanja testova

Nakon dodavanja navedenih unit testova `go test` i `go tool cover` pokrenuti su na isti način.
Izlaz komande `go test` bez dodatnih falgova vidimo na narednoj slici:

![](./test_out_after.png)

U ovo slučaju vidimo da jedan test pada.

`Go tool cover` primenjen na `cover.out` fajlu koji smo dobili iz `go test` komande pokazuje da je **ukupna pokrivenost koda po linijama** sada 34%.

![](./coverage_out_after.png)

Odnosno po svim fajlovima ponaosob:

![](./coverage_after.png)

Detaljnu pokrivenost po linijama koda možemo videti u izlaznom [HTML fajlu](./cover_after.html)

## Analiza rezultata dodatih testova

Jedan test je pao. U pitanju je TestFormatState koji proverava prevođenje binarnih SCARD flagova u čitljive poruke. Razlog pada ovog testa je slučaj scard.StateUnaware koji ima binarnu vrednost sa svim nulama i kada se primeni bitovski AND operator rezultat je `false`, iako očekujemo da bude `true`. Razlog je najverovatnije u tome što je ovaj poseban slučaj tretiran isto kao i ostali, iako je suštinski različit i zahteva zasebnu obradu.

Kod je ranije glasio:

```
if state&scard.StateUnaware != 0 // 0&0 == 0
```

Jednostavnom izmenom u:

```
if state == 0 && state&scard.StateUnaware == 0
```

problem se rešava i test prolazi.

Ovo ukazuje na to da iako kod na prvi pogled deluje ispravno, jednostavnim unit testovima je lako pronaći nedostatke u programu.

# Fuzz testiranje korišćenjem go fuzzing

## Go fuzzing

[Go fuzzing](https://go.dev/doc/security/fuzz/) je podržan u standardnom Go toolchain-u od verzije **Go 1.18**.

### Zahtevi za fuzz testove

- Fuzz test mora biti funkcija imena `FuzzXxx`, koja prima isključivo **`*testing.F`** i nema povratnu vrednost.
- Fuzz testovi moraju biti definisani u fajlovima koji se završavaju sa `_test.go`.
- Fuzz target se definiše pozivom **`(*testing.F).Fuzz`**, koji prima `*testing.T` kao prvi argument, a zatim fuzzing argumente. Funkcija nema povratnu vrednost.
- Svaki fuzz test mora imati tačno jedan fuzz target.
- Svi seed ulazi (seed corpus) moraju imati identične tipove i isti redosled kao fuzzing argumenti, kako u pozivima `(*testing.F).Add`, tako i u fajlovima unutar direktorijuma `testdata/fuzz`.
- Dozvoljeni tipovi fuzzing argumenata su:
  - `string`, `[]byte`
  - `int`, `int8`, `int16`, `int32/rune`, `int64`
  - `uint`, `uint8/byte`, `uint16`, `uint32`, `uint64`
  - `float32`, `float64`
  - `bool`

## Primena alata i rezultati

Za potrebe fuzz testiranja odabran je paket `document`. U njemu su za tipove dokumenata **ID (Lična karta)**, **Medical (Zdravstvena knjižica)** i **Vehicle (Saobraćajna dozvola)** napisani fuzz testovi za funkcije koje generišu PDF dokument.

### Seed podaci i testovi

- **FuzzIDDocumentBuildPdf**: validira generisanje PDF-a lične karte sa seed ulazima:
  - ("ID", "Ana", "Popovic", "Belgrade")
  - ("IF", "Λάμπρος", "Παπαδόπουλος", "Thessaloniki")
  - ("RP", "Petar", "Petrović", "Novi Sad")
- **FuzzMedicalDocumentBuildPdf**: proverava PDF zdravstvene knjižice sa seed ulazima:
  - ("Ana", "Popovic", "Belgrade", "2000-01-01", "12345678901")
  - ("Mila", "Markovic", "Novi Sad", "1990-12-12", "09876543210")
- **FuzzVehicleDocumentBuildPdf**: proverava PDF saobraćajne dozvole sa seed ulazima:
  - ("BG123AA", "Petar", "Main St 1", "VW Golf")
  - ("NS987BB", "Ana", "Second St 2", "Tesla Model 3")

### Pokretanje fuzz testova

Svaki fuzz test je pokrenut komandom:

```
go test -run=^$ -fuzz="${fuzz_name}" -fuzztime=30s ./document > "${RESULTS_DIR_TMP}/gofuzz_out_${fuzz_name}.txt"
```

- `-run=^$` → sprečava pokretanje drugih testova
- `-fuzz="${fuzz_name}"` → definiše koji fuzz test pokrećeš
- `-fuzztime=30s` → postavlja trajanje fuzz testa na 30 sekundi

Rezultati su **nasumični**, jer fuzz testiranje generiše ulaze automatski i paralelno, ali svi testovi su prošli.

## Analiza rezultata

Fuzzing alat generiše sledeće informacije tokom izvršavanja:

- **baseline coverage** – koliko seed ulaza pokriva početne linije koda pre nego što fuzzing počne.
- **execs** – ukupan broj izvršenja funkcije sa generisanim ulazima.
- **new interesting** – broj ulaza koji proširuju pokrivenost koda, tj. pokreću nove grane ili funkcionalnosti koje seed ulazi nisu pokrivali.
- **PASS** – znači da fuzz test nije pronašao panic, crash ili grešku u funkciji.

Na osnovu tih podataka možemo zaključiti:

- Funkcija je robustna i bez crash-ova ili nedefinisanog ponašanja.
- Seed ulazi su pokrili početne putanje, a fuzzing je dodatno proširio pokrivenost.
- Veći broj „interesting“ ulaza pokazuje da je funkcija testirana sa raznovrsnim i neočekivanim inputima.

### Rezultati po fuzz testu

| Test    | Execs  | Total interesting |
| ------- | ------ | ----------------- |
| ID      | 16,465 | 290               |
| Medical | 3,859  | 23                |
| Vehicle | 16,319 | 136               |

> Napomena: `execs/sec` može varirati u zavisnosti od mašine i trenutnog opterećenja, ali ukupni trend rasta interesting ulaza je dobar pokazatelj širine testiranja.

### Zaključci

- Fuzz testovi su pokrili veliki broj različitih inputa, uključujući granične i strane karaktere.
- Ni jedan test nije izazvao panic, crash ili nedefinisano ponašanje funkcija za generisanje PDF dokumenata.
- Rezultati potvrđuju robustnost i sigurnost BuildPdf funkcija u paketu `document`.

# Analiza koda korišćenjem gocyclo alata

## gocyclo

[Gocyclo](https://github.com/fzipp/gocyclo) izračunava
[ciklomatičku kompleksnost](https://en.wikipedia.org/wiki/Cyclomatic_complexity)
funkcija u `Go` izvornom kodu.

Ciklomatička kompleksnost je metrika kvaliteta koda
koja može da se koristi za identifikaciju dela koda kojima je potrebno
refaktorisanje. Meri broj linearno nezavisnih putanja kroz izvorni kod
funkcije.

Ciklomatička kompleksnost funkcije računa se prema sledećim pravilima:

```
 1 is the base complexity of a function
+1 for each 'if', 'for', 'case', '&&' or '||'
```

Funkcija sa većom ciklomatičkom kompleksnošću zahteva više testova kako bi se
pokrile sve moguće putanje i potencijalno je teža za razumevanje. Kompleksnost se može smanjiti primenom uobičajenih tehnika refaktorisanja koje
vode ka manjim funkcijama.

## Primena alata i rezultati

Alat `gocyclo` primenjen je na projekat sledećom komadom:

```
gocyclo -over 10 . -ignore "_test|Godeps|vendor/"
```

Primenjeni su flagovi:

- `over 10` - prikazuju se samo funkcije koje imaju ciklomatičnu složenost veću od 10
- `ignore "_test|Godeps|vendor/"` - ignorišu se testovi kao i Godeps i vendor

Rezultati se mogu videti na sledećoj slici:

![](./gocyclo_out.png)

Vidimo da postoji par funkcija sa veoma visokom ciklomatičnom složenošću.

## Analiza rezultata

U nastavku su funkcije sa najvećom ciklomatičkom složenošću (iz izlaza `gocyclo -over 10`), uz kratak razlog visokog skora:

- **internal/read.go** `readAndSave` — složenost 31; mnoštvo grananja za različite tokove čitanja i obradu grešaka.
- **internal/gui/celiktheme/theme.go** `lightTheme` — složenost 22; veliki `switch` sa više boja.
- **internal/gui/celiktheme/theme.go** `darkTheme` — složenost 22; veliki `switch` sa više boja.
- **document/vehicle.go** `(*VehicleDocument).BuildPdf` — složenost 18; brojna uslovna dodavanja sadržaja u PDF.
- **internal/smartbox/pkcs11/vendor.go** `GetDefaultPath` — složenost 14; kombinacija OS grana i raznih vendora.
- **card/apdu.go** `buildAPDU` — složenost 13; više uslovnih puteva pri sastavljanju APDU komandi.
- **document/medical.go** `(*MedicalDocument).BuildPdf` — složenost 12; različite sekcije i opcione grane pri generisanju PDF-a.
- **card/ber/ber.go** `ParseLength` — složenost 12; više grana za različite formate dužine u BER kodiranju.
- **card/atr.go** `DetectCardDocumentByAtr` — složenost 12; niz uslova za prepoznavanje kartice na osnovu ATR vrednosti.

### Popravke

Sažetak primenjenih popravki:

- **document/medical.go**: uveden `putMedicalData` helper i korišćen postojeći `cell` kako bi se eliminisalo ponavljanje ispisa label/data sa wrap-om.
- **document/vehicle.go**: uvedeni zajednički helperi `putUnderline`, `cell` i `putParagraph` pa je `BuildPdf` očišćen od dupliranog koda (underline, paragraf, cell).
- **internal/gui/celiktheme/theme.go**: boje prebačene u mape `lightColors`/`darkColors` sa zajedničkim `defaultColor`; `lightTheme` i `darkTheme` sada rade lookup sa fallback-om.
- **internal/read.go**: izdvojeni `checkFile`, `writeFileIfNotEmpty` i `checkReaders` radi jasnijeg toka (provere fajlova, uslovno generisanje/upis, rad sa reader-ima).

Preostale funkcije sa povišenom ciklomatičkom složenošću odnose se na obradu pametnih kartica i implementaciju standardizovanih protokola (ATR detekcija, BER parsiranje, APDU formiranje).

U ovim slučajevima veći broj grananja je neophodan kako bi se eksplicitno obradili svi definisani specijalni slučajevi protokola. Dalje razlaganje funkcija bi smanjilo čitljivost i otežalo verifikaciju korektnosti, bez realnog smanjenja logičke složenosti.
