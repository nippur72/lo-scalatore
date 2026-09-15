# Step 01 - Tokenizzazione e normalizzazione sintattica

## Obiettivo

Trasformare il listato VIC-20 (`original/lo_scalatore.orig.bas.txt`, o la versione
commentata `lo_scalatore_commentato.bas`) in un sorgente che il **parser del LM80C**
accetta: spazi fra keyword e operandi, righe entro 88 colonne, nomi variabile legali,
commenti con `REM`.

## 1.1 Regole applicate (e perché)

| regola VIC-20 | regola LM80C | esempio |
|---|---|---|
| keyword attaccate | **spazio obbligatorio** | `ifpeek(s+22)=62then16` -> `IF VPEEK(S+32)=0 THEN 16` |
| trattino `'` per i commenti | solo `REM` | `' commento` -> `REM commento` e `REM` sempre **in fondo** alla riga |
| nomi fino a 2 caratteri significativi (come VIC) | idem, ma **nessuna parola riservata** dentro il nome | `do(0)` ok, `forn` sarebbe illegale |
| righe lunghe fino a 88 in tokenizzato | riga di input max **88 caratteri** | le righe lunghe sono state spezzate su piu' numeri di riga |
| `{clr}`, `{home}`, `{pur}`, `{rvon}`, `{left}`, `{inst}`, `{down}` (PETSCII) | non esistono: `CLS`, `CLOCATE`, `COLOR`, `LOCATE` | vedi step 02 e 03 |
| hardware VIC (`POKE 36869`, `POKE 36878/9`, `POKE 51/52/55/56`, VIA `37154`) | rimosso: il LM80C non ha questi registri | riga 0 e 1 dell'originale |
| `SYS 828` + routine LM joystick nei `DATA 106..108` | rimossi: la lettura diventa `INKEY(0)` | vedi step 04 |

## 1.2 Mappa delle variabili

Tutte le variabili dell'originale sono mantenute (i nomi sono già legali), con questi cambi:

| originale | port | perché |
|---|---|---|
| `d` (VIA) | eliminata | solo per `POKE d,255` a fine partita |
| `p1`, `p2` (VIA) | eliminate | mai usate |
| `g` (30720, offset color RAM) | eliminata | i colori sono per-tile (color table) |
| `d(0..4)` (colori dei caratteri) | eliminata | idem |
| `a$`, `b$` (riempimento schermo) | eliminate | si usa `CLS` |
| `e4`, `e5` | eliminate | mai usate |
| `j` (56) | `J = 8` | codice del tile trave |
| `z` (57) | `Z = 16` | codice del tile scala |
| — | `DL` (nuova) | passo del ciclo di gioco (taratura, step 08) |
| — | `BA(0..11)` (nuova) | indirizzi VRAM dei 12 barili della pila |
| — | `K` (nuova) | codice del tasto letto da `INKEY(0)` |
| — | `CD(0..6)` (nuova) | codici dei tile letti dai `DATA` |

## 1.3 Struttura finale del listato

Il file `lm80c/lo_scalatore_lm80c.bas` conserva la numerazione dell'originale per la logica
di gioco (0..68), i suoi sottoprogrammi (70..99) e i `DATA` (100..113). Le righe nuove sono:
`4..9` (controllo della pila barili, fix step 05), `44` libera, `52/53` (passo di caduta,
sottoprogramma), `95..97` (stampa punteggio/vite/livello), `120..122` (fine partita),
`1000..1002` (intestazione con i crediti e la legenda dei tile).

## 1.4 Prova sull'emulatore

1. Incolla il programma con `paste(...)` (vedi step 00 §0.4).
2. `LIST` : deve elencare tutte le righe; controlla che la riga
   1000-1002 (intestazione) e la 120 (GAME OVER) siano presenti.
3. `LIST 74` e `LIST 84` : verifica che le righe piu' lunghe siano intere e che non
   ci siano caratteri persi (max 88 colonne).
4. Prova anche `lm80c/prove/p01-sintassi.bas`: deve stampare `FINE P01 ...`.

## 1.5 Risultato atteso

- Il listato entra in memoria senza errori e `LIST` è completo.
- `RUN` parte dalla riga 0: essendo le funzioni video/sonore già implementate (step 02+),
  non deve dare errori di sintassi. Se in questa fase compare un errore di sintassi,
  riporta riga e messaggio: è un problema di tokenizzazione da correggere qui.

## 1.6 Report

Riporta: eventuali righe mancanti a `LIST`, errori `?SN Error` con il numero di riga, e
l'esito del probe p01.
