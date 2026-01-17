# Analiza projekta "Baš čelik"

Ovar repoziorijum predstavlja analizu projekta otvorenog koda u okviru kursa Verifikacija softvera na master studijama na Matematičkom fakultetu Univerziteta u Beogradu.

## Projekat "Baš čelik"

**Baš Čelik** je čitač elektronskih ličnih karata, zdravstvenih knjižica i saobraćajnih dozvola. Program je osmišljen kao zamena za zvanične aplikacije poput _Čelika_. Nažalost, zvanične aplikacije mogu se pokrenuti samo na Windows operativnom sistemu, dok Baš Čelik funkcioniše na tri operativna sistema (Windows/Linux/OSX).

Baš Čelik je besplatan program, sa potpuno otvorenim kodom dostupnim na adresi [github.com/ubavic/bas-celik](https://github.com/ubavic/bas-celik).

Grana projekta na kojoj se radi analiza: [v2](https://github.com/ubavic/bas-celik/tree/v2)

Komit projekta na kom se radi analiza:
[08d5698150e294af2a816db668c8e0d428bc923b](https://github.com/ubavic/bas-celik/commit/08d5698150e294af2a816db668c8e0d428bc923b).

## O autoru

- **Ime i prezime:** Marko Lazarević
- **Broj indeksa:** 1005/2025
- **Kontakt:** markolazarevic37@gmail.com

## Alati korišćeni za analizu

| Naziv           | Vrsta                  | Reprodukcija rezultata             | Detaljan opis                              |
| --------------- | ---------------------- | ---------------------------------- | ------------------------------------------ |
| Go Fmt          | Stilizovanje koda      | `./gofmt/run_gofmt.sh`             | [gofmt](./gofmt/README.md)                 |
| GoVulncheck     | Statička verifikacija  | `./govulncheck/run_govulncheck.sh` | [govulncheck](./govulncheck/README.MD)     |
| Golangci lint   | Statička verifikacija  | `./golangci-lint/run_golangci.sh`  | [golangci-lint](./golangci-lint/README.md) |
| Go test + cover | Dinamička verifikacija | `./gotest/run_gotest_cover.sh`     | [gotest_cover](./gotest/README.md)         |

## Zaključci
