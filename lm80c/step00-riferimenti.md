# Step 00 - Riferimenti, convenzioni e banco di prova

Questo documento è la base comune di tutti gli altri step: contiene i fatti presi dal
repository LM80C, le tabelle di conversione dal VIC-20 al LM80C e la procedura di prova
sull'emulatore. Non si scrive codice in questo step.

## 0.1 Fonti (repository github.com/leomil72/LM80C)

| file | cosa serve |
|---|---|
| `manuals/LM80C BASIC reference manual.pdf` | sintassi di `SCREEN`, `COLOR`, `CLS`, `LOCATE`, `PRINT`, `TAB`, `VPOKE`, `VPEEK`, `SOUND`, `VOLUME`, `SREG`, `INKEY`, `KEY`, `PAUSE`, `VREG` |
| `manuals/LM80C hardware reference manual.pdf` (§8 "VDP settings") | mappa dei table VRAM per ogni modo video |
| `manuals/TMS9918A_..._Data_Manual_Nov82.pdf` (§2.4.1, pag. 27-28) | formato della color table in Graphics I: 32 byte, uno per gruppo di 8 pattern |
| `include/vdp/vdp-1.08.asm` | valori reali dei registri VDP per `SCREEN 1` e caricamento del charset |
| `include/vdp/8x8fonts-r18.asm` | charset 8x8 di sistema (256 caratteri) |
| `include/psg/psg-1.02.asm` | tabella `KBMAP` con i codici ritornati da `INKEY` |
| `include/basic/basic-1.14.asm` | implementazione di `GPRINT`, `COLOR`, `CLS`, `INKEY`, `ON` |
| `BASIC examples/*.bas` | esempi reali di uso di `SCREEN`/`GPRINT`/`SOUND`/`INKEY` |

Fatti verificati che condizionano il port:

- **SCREEN 1 = TMS9918 Graphics I**, 32 colonne x 24 righe di celle 8x8:
  pattern table `$0000-$07FF` (256 pattern **condivisi**), name table `$1800-$1AFF`,
  color table `$2000-$201F`, sprite attribute `$1B00`, sprite pattern `$3800`.
  VDP reg.7 = colore di sfondo/bordo.
- La **color table** di Graphics I ha **32 byte**: il byte *n* vale `(colore_dei_bit_a_1 << 4) | colore_dei_bit_a_0`
  e vale per **tutti i 8 pattern** del gruppo `8*n .. 8*n+7`. Quindi si possono avere
  fino a 32 coppie di colori contemporanee: è l'equivalente della color RAM del VIC-20.
- `COLOR fg,bg,bordo` in modo 1 riempie tutti e 32 i byte con `(fg<<4)|bg` e scrive
  `bordo` in VDP reg.7. Il default di `SCREEN 1` è nero su bianco (`0x1F`).
- `CLS` invia il codice 12: **azzera la name table** (quindi la riempie col carattere 0)
  e **non tocca** pattern table e color table: i tile definiti con `VPOKE` sopravvivono.
- `VPOKE n,v` / `VPEEK(n)`: VRAM 0..16383. `LOCATE x,y` e `PRINT` funzionano nei modi 0, 1 e 4.- `INKEY(n)`: con n=0 **non attende**: consuma e ritorna il primo codice presente nel buffer
  (0 se non c'e' nulla); con n>=10 attende al massimo n centesimi di secondo (valori 1..9 vengono
  portati a 10, oltre 1023 danno errore). Codici da `KBMAP`: **SU 30, GIU' 31, SINISTRA 28, DESTRA 29, SPAZIO 32**,
  RETURN 13, RUN/STOP 3, ESC 27, HOME 25, CLEAR 12.
- `KEY 9,del,rep`: regola l'auto-repeat (default 64 e 8 centesimi di secondo).
- `VOLUME chn,val` (0..15, chn=0 tutti) **prima** di ogni `SOUND`;
  `SOUND` ha **tre forme diverse** (verificate sul manuale e su `basic-1.14.asm`, vedi step 07 §7.2):
  - **tono** (canali 1-3): `SOUND ch,tone,dur` — i **tre** parametri sono obbligatori
    (`freq = 1843200/16/(4096-tone)`, `dur` in 1/100 s, 0..16383, 0 = infinito; `tone = 0`
    interrompe subito il suono);
  - **rumore** (canali 4-6 = rumore sui canali PSG 1-3): `SOUND ch,tone` — **due** parametri e
    **la riga deve finire li'** (il parser rifiuta qualsiasi cosa segua il tono), con `tone` 1..31
    (1 = piu' acuto), `tone = 0` ferma il rumore;
  - **reset**: `SOUND 0` da solo spegne tutto (toni, rumori, envelope) **e azzera i volumi**, quindi
    dopo ogni `SOUND 0` va rimesso `VOLUME 0,15`.
- `PAUSE n`: attende n centesimi di secondo (0..65535), interrompibile con RUN/STOP.
- Vincoli: spazio fra keyword e operandi, **nomi variabile significativi solo per i primi 2
  caratteri** e senza parole riservate, riga di input max **88 caratteri**, commenti con `REM`.
- **Memoria** (verificata sul firmware e sull'emulatore):
  - nel firmware **64K** (il default dell'emulatore) la ROM viene copiata in RAM e poi **disattivata**,
    quindi `$0000-$7FFF` e' RAM (il firmware copiato occupa `$0000-$53A2`); il programma BASIC parte da
    **`$560E`** e cresce verso l'alto (variabili e array sopra, spazio delle stringhe che scende
    dall'alto), lo stack del BASIC e' a `$54E0`;
  - nel firmware **32K** (`?rom=314`) la ROM sta in basso: workspace `$8000-$8240`, RAM libera per BASIC
    da `$8241` in su;
  - quindi in **tutti e due** i modelli una routine in linguaggio macchina caricata con `POKE` va messa
    in un'area che BASIC non tocca: nella variante a sprite e' `$7800` (30720), cioe' sopra la fine del
    listato e sotto la zona del DOS (`$EE1B`), che nel 64K e' libera;
- **`POKE`/`PEEK` e `SYS`** esistono e servono per caricare ed eseguire codice in linguaggio macchina
  (`POKE` `$2B71`, `PEEK` `$2B47`, `SYS` `$2B19` nel firmware r1.20): `SYS addr` salta a `addr` con A=0,
  `SYS addr,param` passa un byte in A; la routine deve tornare con `RET` **conservando i registri**
  (viene chiamata in mezzo a una riga BASIC) e **riabilitando gli interrupt** (`ei`) se li ha spenti;
  `USR(x)` invece e' disabilitato (salta su `FCERR`);
- **attenzione agli indirizzi**: `POKE`/`PEEK`/`SYS` convertono il numero con `DEINT`, che accetta solo
  **-32768..32767**: gli indirizzi da `$8000` in su non si possono scrivere direttamente (si usa il
  valore negativo, per esempio `$8241` = `-32191`). E' il motivo per cui la routine di input sta a
  `$7800`;
- i numeri si possono scrivere anche in esadecimale e binario: **`&H`** e **`&B`** (per esempio
  `POKE &H7800,0`), e `HEX$(x)`/`BIN$(x)` li stampano.

### 0.1b La matrice della tastiera (dove stanno i tasti)

La tastiera e' una matrice **8 righe x 8 colonne**. La riga si sceglie scrivendo la sua maschera nel
port B del PSG (**bit a 0 = riga attiva**), le colonne si leggono dal port A (**bit a 0 = tasto
premuto**), con la sequenza del firmware `READKBLN`: `OUT 64,15` / `OUT 65,mask` / `OUT 64,14` /
`INP(64)` (si legge da **64**, non da 65; dettagli in step 04 §4.5).

| riga | maschera | colonne, da bit 0 a bit 7 |
|---|---|---|
| 0 | **254** ($FE) | `1`, HOME, CTRL, RUN/STOP, **SPAZIO** (bit 4), CBM, `Q`, `2` |
| 1 | **253** ($FD) | `3`, `W`, `A`, SHIFT, **`Z`** (bit 4), `S`, `E`, `4` |
| 2 | **251** ($FB) | `5`, `R`, `D`, `X`, `C`, `F`, `T`, `6` |
| 3 | **247** ($F7) | `7`, `Y`, `G`, `V`, `B`, `H`, `U`, `8` |
| 4 | **239** ($EF) | `9`, **`I`** (bit 1), **`J`** (bit 2), `N`, `M`, **`K`** (bit 5), `O`, `0` |
| 5 | **223** ($DF) | **GIU'** (bit 0), `P`, **`L`** (bit 2), `,`, `.`, `:`, `-`, **SU** (bit 7) |
| 6 | **191** ($BF) | **SINISTRA** (bit 0), `*`, `;`, `/`, ESC, `=`, `+`, **DESTRA** (bit 7) |
| 7 | **127** ($7F) | DEL (backspace), RETURN, `£`, `@`, F1, F2, F3, HELP |

I **codici** che il firmware consegna a `INKEY` per ogni posizione sono nella tabella `KBMAP` di
`include/psg/psg-1.02.asm` (le otto righe nell'ordine delle maschere `$FE`,`$FD`,...,`$7F`, e per ogni
riga le otto colonne da 0 a 7): e' da li' che vengono i codici 28/29/30/31 (cursori) e 32 (SPAZIO). Le
lettere minuscole sono i codici senza SHIFT (`j` = 106), le maiuscole con SHIFT (`J` = 74): leggendo la
**matrice** invece del codice, la differenza non conta.

## 0.2 Mappa dei tile (VIC-20 -> LM80C)

| elemento | codice VIC | codice LM80C | gruppo colore | valore color table | pattern 8x8 |
|---|---|---|---|---|---|
| spazio calpestabile | 62 | **0** | 0 | (default bianco) | `00 00 00 00 00 00 00 00` |
| deviatore invisibile | 63 | **1** | 0 | (default bianco) | `00 00 00 00 00 00 00 00` |
| trave | 56 | **8** | 1 | `8193 = 223` magenta su bianco | `FF FF 99 66 66 99 FF FF` |
| scala | 57 | **16** | 2 | `8194 = 143` rosso su bianco | `C3 FF FF C3 C3 FF FF C3` |
| barile | 60 | **24** | 3 | `8195 = 191` giallo su bianco | `3C 42 A5 99 99 A5 42 3C` |
| omino | 58 | **40** | 5 | `8197 = 31` nero su bianco | `3C 3C 19 FF BC 3C 24 E7` |
| borsa | 61 | **41** | 5 | `8197 = 31` nero su bianco | `00 18 24 7E 7E 7E 7E 00` |

I bitmap sono **identici** a quelli del VIC-20 (`data 101..103` del listato originale): il
formato VIC e quello TMS9918 sono entrambi 8 byte con il bit piu' significativo a sinistra.
La bomba (codice 59) non è mai usata dall'originale ed è stata omessa.

## 0.3 Geometria e conversione indirizzi

Campo di gioco 22 colonne **centrate** in 32 (offset +5), righe 0..22, riga 0 = riga di stato.

`addr(riga,col) = 6144 + 32*riga + 5 + col = 6149 + 32*riga + col`

| originale (VIC, 22 colonne) | port LM80C |
|---|---|
| base schermo `7680` | `addr(0,0) = 6149`, stride `32` |
| passo sinistra/destra `-1/+1`, riga sotto `+22`, riga sopra `-22` | `-1/+1`, `+32`, `-32` |
| diagonali `+21`, `+23` | `+31`, `+33` |
| omino `8143+INT(RND(1)*20)` (riga 21, colonne 1..20) | `6821+INT(RND(1)*20)` |
| travi `7834..8164 step 110` | righe 7, 12, 17, 22 (`6373..6853 step 160`) |
| scale `r+88 step 22` | `r+128 step 32` |
| borse `n-21` | `n-32` |
| buchi `r+3+INT(RND(1)*16)`, `r-22` | invariati come offset, `-32` per la riga sopra |
| pila barili `7712+b(n)` | `off = b(n)+32; riga = off#22; col = off%22; addr = 6149+32*riga+col` |
| `#` a 7697 (riga 0 col 17, sopra le cifre del livello) | stampato con `PRINT` **subito prima** del numero del livello (riga 96: `PRINT "#";SC;`), cosi' resta attaccato anche quando il livello passa a due cifre |
| deviatori fine trave `7812..8142` / `7833..8163 step 110` | righe 6,11,16,21 col 0 e col 21 |
| lati pila `7710,7715,7731,7738` | `6189, 6194, 6220, 6227` |
| soglia barile `v<8164` | `v<6853` (inizio riga 22) |
| soglia omino `s>8163` | `s>6842` (ultima cella utile, riga 21 col 21) |

## 0.4 Procedura di prova sull'emulatore

1. Apri <https://nippur72.github.io/lm80c-emu/> (firmware LM80C 64K, BASIC 3.26) oppure
   `https://nippur72.github.io/lm80c-emu/?rom=64K119`. Attendi il logo e scegli **C** (cold start).
2. Carica il listato: apri la console JavaScript (F12) e usa la funzione dell'emulatore
   `paste("...")`, incollando il testo del file `.bas` fra apici inversi (backtick).
   In alternativa incolla il testo direttamente nella finestra dell'emulatore, oppure
   incolla poche righe per volta se vedi caratteri persi (la riga di input del LM80C
   è di 88 caratteri e il testo arriva dalla linea seriale).
3. Verifica la ricezione: `LIST` deve mostrare tutto il programma.
4. `RUN` per eseguire. `RUN 70` per ripartire da una riga specifica.
5. Se qualcosa non va, riporta: **numero di riga dell'errore**, messaggio del BASIC,
   cosa vedi sullo schermo e cosa ti aspettavi.

Formato del report (esempio):

```
step: 03
riga: 84
errore: ?SN Error in 84
visto: schermo bianco, nessuna trave
atteso: 4 righe di travi magenta
```

## 0.5 Criterio di completamento dello step 00

Letto e condiviso il contenuto; le tabelle 0.2 e 0.3 sono la fonte di verita' per tutti
gli altri step. Se una prova sull'emulatore mostra che un fatto di questo documento è
sbagliato, si corregge qui e si propaga negli altri step.
