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
