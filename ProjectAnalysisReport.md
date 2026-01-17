# Analiza projekta "Baš čelik"

**Baš Čelik** je čitač elektronskih ličnih karata, zdravstvenih knjižica i saobraćajnih dozvola. Program je osmišljen kao zamena za zvanične aplikacije poput _Čelika_. Nažalost, zvanične aplikacije mogu se pokrenuti samo na Windows operativnom sistemu, dok Baš Čelik funkcioniše na tri operativna sistema (Windows/Linux/OSX).

Baš Čelik je besplatan program, sa potpuno otvorenim kodom dostupnim na adresi [github.com/ubavic/bas-celik](https://github.com/ubavic/bas-celik).

[Komit](https://github.com/ubavic/bas-celik/commit/08d5698150e294af2a816db668c8e0d428bc923b) projekta na kom se radi analiza ima hash `08d5698150e294af2a816db668c8e0d428bc923b`.

Cilj ove analize je procena pouzdanosti, efikasnosti i kvalitet softvera. Izvršena je analiza projekta primenom alata:

- gofmt
- govulncheck
- golangci-lint
- go test, go tool cover
