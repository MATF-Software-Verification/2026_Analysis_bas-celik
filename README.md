# Analiza projekta "Baš čelik"

Ovaj repozitorijum predstavlja analizu projekta otvorenog koda u okviru kursa Verifikacija softvera na master studijama na Matematičkom fakultetu Univerziteta u Beogradu.

## Projekat "Baš čelik"

**Baš Čelik** je čitač elektronskih ličnih karata, zdravstvenih knjižica i saobraćajnih dozvola. Program je osmišljen kao zamena za zvanične aplikacije poput _Čelika_. Nažalost, zvanične aplikacije mogu se pokrenuti samo na Windows operativnom sistemu, dok Baš Čelik funkcioniše na tri operativna sistema (Windows/Linux/OSX).

Baš Čelik je besplatan program, sa potpuno otvorenim kodom dostupnim na adresi [github.com/ubavic/bas-celik](https://github.com/ubavic/bas-celik).

Grana projekta na kojoj se radi analiza: [v2](https://github.com/ubavic/bas-celik/tree/v2)

Komit projekta na kom se radi analiza:
[08d5698150e294af2a816db668c8e0d428bc923b](https://github.com/ubavic/bas-celik/commit/08d5698150e294af2a816db668c8e0d428bc923b).

## O autoru

- **Ime i prezime:** Marko Lazarević
- **Broj indeksa:** 1005/2025
- **Github:** [marko-lazarevic](https://github.com/marko-lazarevic)
- **Kontakt:** markolazarevic37@gmail.com

## Alati korišćeni za analizu

### Instaliranje potrebnih alata

Uputstvo za instaliranje Go-a može se pronaći na [https://go.dev/doc/install](https://go.dev/doc/install).

> Napomena: Go verzija korišćena za analizu je `go1.25.3` (za proveru verzije pokrenuti `go version`)

> Napomena: Nakon instalacije potrebno je obezbediti da se $GOPATH/bin nalazi u PATH promenljivoj okruženja.

Za instaliranje golangci-lint i gocyclo (nisu deo standardnog toolchain-a) pokrenuti sledeće komande:

```
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.7.2
```

```
go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
```

> Napomena: Go fuzzing koristi ugrađenu podršku dostupnu od Go verzije 1.18.

### Spisak korišćenih alata

| Naziv           | Vrsta                  | Reprodukcija rezultata             | Rezultati analize                          |
| --------------- | ---------------------- | ---------------------------------- | ------------------------------------------ |
| Go Fmt          | Stilizovanje koda      | `./gofmt/run_gofmt.sh`             | [gofmt](./gofmt/README.md)                 |
| GoVulncheck     | Statička verifikacija  | `./govulncheck/run_govulncheck.sh` | [govulncheck](./govulncheck/README.md)     |
| Golangci lint   | Statička verifikacija  | `./golangci-lint/run_golangci.sh`  | [golangci-lint](./golangci-lint/README.md) |
| Go test + cover | Dinamička verifikacija | `./gotest/run_gotest_cover.sh`     | [gotest_cover](./gotest/README.md)         |
| Go fuzzing      | Dinamička verifikacija | `./gofuzz/run_gotest_fuzz.sh`      | [gotest_fuzz](./gofuzz/README.md)          |
| Gocyclo         | Statička verifikacija  | `./gocyclo/run_gocyclo.sh`         | [gocyclo](./gocyclo/README.md)             |

## Zaključci

### Gofmt

Kod je već potpuno usklađen sa `gofmt` standardom, nisu pronađena odstupanja ni greške. Formatiranje je konzistentno i projekat je spreman za dalji razvoj bez stilskih korekcija.

### GoVulncheck

Identifikovane ranjivosti su bile u standardnoj biblioteci i `golang.org/x/crypto`, otklonjene su ažuriranjem Go verzije i zavisnosti. Trenutno nema prijavljenih poznatih ranjivosti nakon nadogradnje.

### Golangci lint

Većina nalaza su stilske prirode (`revive`) i neproverene greške u `defer` tokovima (`errcheck`), funkcionalnih problema nema.

### Go test + cover

Svi postojeći testovi prolaze, dodavanjem novih testova pokrivenost je porasla na oko 34%, što je i dalje nisko. Pronađena je jedna greška dodavanjem novih testova. Prioritet je pisanje dodatnih testova za ključne module kako bi se smanjio rizik regresija.

### Go fuzzing

Fuzz testovi za generisanje PDF dokumenata (ID/Medical/Vehicle) nisu izazvali padove niti panic. Raznovrsni generisani ulazi potvrđuju robusnost u radu sa neočekivanim podacima.

### Gocyclo

Nekoliko funkcija ima višu ciklomatičku složenost, deo dupliranog koda je već refaktorisán (helperi za PDF i teme). Preostala složenost uglavnom potiče od nužnih grana u protokolima kartica (ATR/BER/APDU).

### Opšti zaključak

Sprovedena statička i dinamička analiza pokazuje da je projekat stabilan, održiv i bez kritičnih bezbednosnih problema. Korišćeni alati pokrivaju širok spektar potencijalnih grešaka — od stilskih i semantičkih problema, preko poznatih ranjivosti u zavisnostima, do grešaka koje se mogu ispoljiti tokom izvršavanja programa.

Statička analiza nije identifikovala ozbiljne logičke ili bezbednosne propuste, dok su uočeni problemi uglavnom stilske prirode ili posledica specifičnih implementacionih zahteva (npr. protokoli za obradu pametnih kartica). Dinamička analiza i fuzz testiranje dodatno potvrđuju robusnost sistema u radu sa neočekivanim ulazima.

Glavni prostor za unapređenje nalazi se u povećanju pokrivenosti testovima, naročito u ključnim delovima poslovne logike, čime bi se dodatno smanjio rizik od regresija.
