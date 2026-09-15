# Step 02 - Modo video, definizione dei tile e colori

## Obiettivo

Sostituire l'hardware video del VIC-20 (charset ridefinito in `7616`, color RAM con
`POKE ...+30720`, sfondo/bordo con `POKE 36879`) con i comandi del TMS9918:
`SCREEN 1`, `COLOR`, `VPOKE` nella pattern table e nella color table.

## 2.1 Cosa fa la riga 0 dell'originale e cosa diventa

| originale | port |
|---|---|
| `PRINT "{clr}"` | `SCREEN 1:COLOR 1,15,15` (SCREEN fa anche la pulizia dello schermo) |
| `POKE 51,192:POKE 52,29` / `POKE 55,192:POKE 56,29` (fine memoria a 7616) | rimossi |
| `POKE 36869,255` (charset a 7168) | `SCREEN 1` carica il charset 8x8 e punta la pattern table a `$0000` |
| `POKE 36878,15` (volume) | `VOLUME 0,15` |
| `POKE 36879,25` (bordo e sfondo bianchi) | `COLOR 1,15,15`: 3' argomento = bordo/sfondo bianco |

`COLOR 1,15,15` riempie anche tutti e 32 i byte della color table con `0x1F`
(bit a 1 = nero, bit a 0 = bianco): sfondo bianco con testo nero, come l'originale.

## 2.2 Definizione dei tile (era `DATA 101..103` + riga 109 originale)

Nel port la definizione sta nella subroutine 100-114:

```
101 DATA 0,1,8,16,24,40,41          <- codici (CD) dei 7 tile
102..103 DATA ...                   <- spazio e deviatore (8 byte di zeri)
104 DATA 255,255,153,102,102,153,255,255   <- trave
105 DATA 195,255,255,195,195,255,255,195   <- scala
106 DATA 60,66,165,153,153,165,66,60       <- barile
107 DATA 60,60,25,255,188,60,36,231        <- omino
108 DATA 0,24,36,126,126,126,126,0         <- borsa
110 DIM CD(6):FOR N=0 TO 6:READ CD(N):NEXT
111 FOR N=0 TO 6:FOR M=0 TO 7:READ DT:VPOKE CD(N)*8+M,DT:NEXT:NEXT
112 VPOKE 8193,223:VPOKE 8194,143:VPOKE 8195,191:VPOKE 8197,31
```

- `VPOKE CD*8+M` scrive i pattern a `$0000 + codice*8` nella pattern table
  (equivalente del `POKE 7616+...` del VIC, ma per tutti i caratteri).
- `8192 = $2000` è la color table: il byte *n* vale per il gruppo di pattern `8n..8n+7`.
  Poiché ogni tile è in un gruppo diverso, ogni elemento ha il suo colore:
  `223 = (13 magenta << 4) | 15 bianco` per la trave (tile 8 -> gruppo 1 = `8193`),
  `143 = (8 rosso)|15` per la scala (tile 16 -> gruppo 2 = `8194`), `191 = (11 giallo)|15` per il
  barile (tile 24 -> gruppo 3 = `8195`), `31 = (1 nero)|15` per omino e borsa (tile 40 e 41 ->
  gruppo 5 = `8197`). L'**indirizzo e' `8192 + codice#8`**: il vecchio `8201` (gruppo 9) era sbagliato
  e funzionava solo perche' `COLOR 1,15,15` lascia comunque tutti i gruppi a `0x1F` = nero su bianco.
- Nel VIC la stessa cosa si otteneva con `POKE s+g,d(t-j)` (color RAM); nel port
  **tutte quelle POKE di colore sono state eliminate** (il colore dipende dal tile).

La color table non viene piu' riscritta da nessuna `COLOR` successiva: nel port `COLOR`
viene chiamato **una sola volta**, nella riga 0, prima delle `VPOKE` della subroutine 100.

## 2.3 Prova sull'emulatore

1. Carica e lancia `lm80c/prove/p02-video.bas`.
2. Atteso sullo schermo (sfondo bianco, testo nero):
   - riga 2: cinque celle con **trave magenta**, **scala rossa**, **barile giallo**,
     **omino nero**, **borsa nera**;
   - riga 3: le etichette TRAVE / SCALA / BARILE / OMINO / BORSA sotto le celle;
   - righe 7 e 12-13: i valori riletti con `VPEEK`, che devono essere
     `223 143 191 31` e `255 255 153 102 102 153 255 255`.
3. Poi carica il gioco e lancia `RUN`: dopo pochi istanti deve comparire il campo di gioco
   (lo step 03 lo completa), senza errori.

## 2.4 Se qualcosa non torna

- **Tile invisibili o "a caso"**: la pattern table è stata scritta prima di `SCREEN 1`
  (che ricarica il charset) - controlla che l'ordine delle righe sia 0 -> 10 -> 100.
- **Tutti i tile dello stesso colore**: le `VPOKE` in `8193..8197` sono state fatte prima
  di `COLOR`, oppure è stato chiamato `COLOR` in seguito (lo riazzera).
- **Colori diversi da quelli attesi**: la color table è a `$2000` solo se `SCREEN 1`
  è attivo: verifica con `PRINT VPEEK(8193)` da direct mode.

## 2.5 Report

Riporta cosa vedi su p02 (colori e forme dei 5 tile) e i numeri stampati alle righe 7, 12-13.
