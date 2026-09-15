# Step 08 - Taratura dei tempi, checklist e collaudo finale

## Obiettivo

Regolare la velocita' del gioco sul LM80C (che l'originale otteneva con cicli di ritardo e con la
routine in linguaggio macchina del joystick), riepilogare tutti i requisiti del port e chiudere con
un piano di collaudo completo sull'emulatore.

## 8.1 La variabile `DL` (passo del ciclo di gioco)

L'originale non aveva un "frame rate": ogni giro del ciclo principale leggeva il joystick con
`SYS 828` e poi perdeva tempo con `forn=1to23:next` (riga 21). Nel port il tempo di un fotogramma e'
esplicito:

```
2 ...:DL=3
20 PAUSE DL:K=INKEY(0):IF NB>0 THEN NB=NB-1:K=0      (versione a tile)
```

(nella **variante a sprite** la riga 20 e' `PAUSE DL:SYS AD+16:K=PEEK(AD)`: l'input viene dalla
routine in linguaggio macchina e il centesimo di attesa di `INKEY` non c'e' piu', §8.2d)

`PAUSE n` attende **n centesimi di secondo** (0..65535, interrompibile con RUN/STOP), quindi:

| valore | fotogrammi/s | sensazione di gioco |
|---|---|---|
| 12 | ~8 | molto lento: primo default del port, usato per il collaudo |
| 6 | ~16 | vivace |
| **3** | **~33** | **default attuale**: a ogni fotogramma l'omino fa un passo, quindi ~33 celle al secondo |
| 2 | ~50 | al limite: i barili diventano difficili da seguire |

La taratura e' stata fatta a due riprese (12 -> 6 -> 3) perche' il movimento dell'omino risultava
lento: `DL` e' **l'unico orologio del gioco**, quindi dimezzarlo raddoppia sia la velocita' del
passo sia quella dei barili. Poiche' a 33 fotogrammi/s il suono del passo (`SOUND 1,3730,1`, 10 ms)
dura meno di un fotogramma, il beep resta un ticchettio breve invece di diventare un tono continuo
(vedi step 07 §7.1).

Va tarato **sull'emulatore usato**, perche' la velocita' dell'emulatore puo' differire da quella
del computer reale: se il gioco "scatta" si alza `DL`, se e' lento lo si abbassa. `DL` e' l'unico
valore da toccare per il ritmo generale.

## 8.2 Gli altri ritmi

| dove | riga | cosa regola | come si tara |
|---|---|---|---|
| durata del salto | 37 `FOR N=1 TO 5:NEXT` | quanto resta in aria l'omino | alzare il `5` per un salto piu' "lento" |
| ritmo della morte | 57 `FOR N=1 TO 17:NEXT` | velocita' della discesa sonora dell'animazione di morte | alzare il `17` allunga morte e suono insieme |
| ritmo dell'auto-repeat (**solo versione a tile**) | riga 1: `KEY 9,8,2` | dopo 0,08 s ripete ogni 0,02 s tenendo premuta una freccia; **il default del sistema e' 0,64 s**. E' **il vero limite di velocita' dell'omino**: vedi §8.2b | `KEY 9,20,6` per un movimento a meta' velocita'; il secondo parametro non ha senso sotto `2` (la matrice viene letta ogni 20 ms) |
| inibizione dell'input dopo la morte (**solo versione a tile**) | riga 58 `NB=2` + riga 20 (`IF NB>0 ...`) | per quanti fotogrammi l'input viene ignorato dopo la morte, per non far ripartire l'omino da solo | alzare il `2` (per esempio a `5`) per un'attesa piu' lunga dopo la morte |
| input da leggere per fotogramma (**variante a sprite**) | riga 20 `SYS AD+16`, routine in ML a 30736 caricata dai `DATA 1094-1111` | le 8 righe della matrice lette dalla routine in linguaggio macchina con `di` (step 04 §4.6, step 09 §9.14): nessuna attesa forzata, nessuna coda, nessun auto-repeat da tarare: **179 istruzioni, 1627 cicli = 441 us**, misurati sul core dell'emulatore | se il gioco gira troppo veloce si sale `DL` (§8.2d) |
| fine livello | 65-66 | conteggio dei barili residui con rumore + rampa | leggere, non serve modificarla |

## 8.2b Perche' l'omino era lento: l'auto-repeat e' il suo limite

L'omino puo' fare **un solo passo per fotogramma** (il gioco legge un tasto per giro, riga 20), quindi
la sua velocita' massima e' il ritmo dell'auto-repeat, non `DL`: con `KEY 9,20,6` arrivava un tasto
di ripetizione ogni 0,06 s (16 passi/s) mentre i barili avanzavano una cella per fotogramma
(~30 al secondo con `DL=3`). Meta' velocita' dei barili, ed e' per questo che il movimento sembrava
lento anche dopo aver dimezzato `DL` tre volte.

Il keyboard sniffer sta nel modulo PSG del firmware (`include/psg/psg-1.02.asm`, la matrice passa dai
port del PSG): gira **dentro l'interrupt del CTC** ma non a ogni interrupt (l'ISR fa
`ld a,(TMRCNT):rra:call nc,KEYBOARD`), quindi **una scansione ogni 2 tick = 20 ms (50 Hz)**; quando il
tasto e' lo stesso di
`LASTKEYPRSD` confronta il tempo trascorso con `KEYDEL` (prima ripetizione) e poi con `AUTOKE`
(ripetizioni successive), scrivendo il codice in `TMPKEYBFR` — il byte singolo che `INKEY` legge e
azzera. Con `AUTOKE=2` (0,02 s) c'e' **sempre** un tasto pronto a ogni fotogramma, e l'omino va
alla stessa velocita' dei barili come nell'originale (dove il joystick veniva letto a ogni giro senza
alcuna attesa di ripetizione).

Attenzione: il ritmo massimo **utile** di ripetizione e' **20 ms**, perche' la matrice viene letta una
volta ogni 20 ms; `AUTOKE=1` non e' piu' veloce di `AUTOKE=2`, e anche `KEYDEL` viene valutato solo
a ogni scansione (granularita' 20 ms). Per lo stesso motivo un tasto premuto e rilasciato in meno di
20 ms puo' non essere visto affatto, e il ritardo minimo fra la pressione e l'azione del gioco e' di
una scansione (~20 ms) piu' il resto del fotogramma.`INKEY(0)` ha inoltre **un'attesa di sistema di 1 centesimo di secondo** incorporata (serve allo sniffer per raccogliere almeno un tasto): un fotogramma dura quindi `DL` + ~1 centesimo, cioe' 3-4 centesimi con `DL=3`. Va tenuto presente quando si confronta il valore di `DL` con i fotogrammi al secondo reali (tabella §8.1: sono indicativi, non esatti).

Tutto questo vale per la **versione a tile**, che usa `INKEY`: la **variante a sprite** legge la
matrice con `OUT`/`INP` e non ha ne' auto-repeat ne' coda di tasti (§8.2d).

## 8.2c Il tasto che "resta in coda" (l'omino si muoveva da solo)

Dopo la morte, al momento della nuova vita l'omino faceva **un passo involontario nella direzione
dell'ultimo movimento**. Causa: il codice del tasto premuto resta in `TMPKEYBFR` finche' qualcuno non
lo legge (l'analisi del tasto avviene solo nella riga 20, e la sequenza di morte 55-62 non legge
INKEY), quindi il primo `INKEY` dopo la rinascita restituiva un tasto vecchio. E' anche il motivo per
cui lo sniffer azzera `LASTKEYPRSD` e `STATUSKEY` al rilascio, ma **non** `TMPKEYBFR` (routine
`NOKEYPRSD` di `psg-1.02.asm`): un tasto puo' quindi sopravvivere al rilascio del tasto stesso.

Rimedio: dopo la morte l'input viene ignorato per `NB` fotogrammi, e in quei fotogrammi i tasti in
coda vengono comunque **letti e scartati** (l'`INKEY` li consuma):

```
58 ...:CH=CH-1:NB=2:IF CH<0 THEN GOSUB 125:END
20 PAUSE DL:K=INKEY(0):IF NB>0 THEN NB=NB-1:K=0
```

`NB` non viene mai inizializzato: le variabili numeriche del BASIC valgono 0 all'avvio, quindi al
primo fotogramma del gioco il test `IF NB>0` e' falso e la riga si comporta come prima. La riga 20
non ha piu' il `IF K=0 THEN 41` esplicito: con `K=0` la caduta sulla riga 25 (`IF K<>31 THEN 41`)
porta allo stesso risultato, con quattro confronti in piu' sul solo fotogramma senza tasti.

Vale solo per la **versione a tile**: la variante a sprite ha tolto `NB` insieme a `INKEY` (il tasto
in coda non esiste piu', §8.2d). Li' l'omino si muove subito se il giocatore tiene premuta una
freccia quando riceve la nuova vita, ed e' **voluto**: e' quello che faceva il joystick dell'originale
(che veniva letto a ogni fotogramma, stato e non evento).

## 8.2d La variante a sprite: la tastiera letta in linguaggio macchina

La variante a sprite (`lo_scalatore_lm80c_sprites.bas`) legge la tastiera direttamente, come faceva
l'originale con il joystick, ma **da una routine in linguaggio macchina** (`lm80c/ml/lm80c_keys.asm`,
284 byte a `$7800`, caricata dai `DATA 1094-1111` e richiamata con `SYS AD+16`). Conseguenze sui
tempi:

- **il centesimo di `INKEY` non c'e' piu'**: un fotogramma non ha piu' l'attesa incorporata dello
  sniffer;
- al suo posto ci sono **8 letture della matrice** (per ognuna: seleziona registro 15, scrivi
  maschera, seleziona registro 14, leggi da 64) piu' il calcolo di `K`, il tutto con gli interrupt
  disattivati: sul core dell'emulatore la chiamata completa esegue **179 istruzioni, 1627 cicli**,
  cioe' **441 µs** a 3,6864 MHz. Molto meno del centesimo risparmiato (~5 ms in media);
- il risultato e' un fotogramma **piu' corto** di prima (con `DL=3` si passa da ~40 ms a ~33 ms),
  quindi il gioco gira un po' piu' svelto: **se risulta troppo rapido, si sale `DL` da 3 a 4**
  (tabella §8.1). Attenzione: accelerano insieme omino **e** barili, e' l'unico orologio del gioco;
- con `di` **non esiste piu' la finestra sullo sniffer**: le vecchie letture da BASIC erano esposte
  alla scansione del firmware ogni 20 ms (1,7-2,5 % di fotogrammi con `K` sbagliato, 0,6-0,75 % con la
  verifica del registro 15 descritta nella cronologia di step 04 §4.6). Ora la sequenza non puo' piu'
  essere interrotta, e il contatore GLITCH di `p08` non serve piu';
- `KEY 9,8,2` e' stato tolto dalla riga 1: l'auto-repeat non ha piu' nessun effetto sul gioco (la
  lettura e' uno stato, non un evento). Resta attivo quello di sistema, che non viene usato;
- `NB` e' stato tolto dalla riga 58 (§8.2c): non c'e' piu' un tasto in coda da smaltire.

Da verificare sull'emulatore: che il gioco **non** risulti piu' veloce del gradito (in quel caso
`DL=4`) e che tenere premuta una freccia dia un passo **per ogni** fotogramma (prima dipendeva
dall'auto-repeat, §8.2b). Il primo collaudo e' comunque `prove/p08-matrice.bas`, che mostra le otto
righe grezze e il `K` calcolato dalla routine stessa (tabella §8.4, punto 7).

## 8.2e Il primo collaudo si e' fermato: `OUT OF DATA ERROR IN LINE 110`

Il primo `RUN` della variante a sprite con la routine in ML non e' arrivato al gioco: errore
`OUT OF DATA ERROR IN LINE 110`. La routine **non c'entra**: e' il **puntatore dei `DATA`**.

Il BASIC legge i `DATA` in **ordine di numero di riga** (non di listato) e la riga 3 chiama il
caricamento **prima** che il gioco legga i suoi dati. Il caricatore (`RESTORE 1094` + 285 letture: il
`284` e i 284 byte) arriva cosi' **in fondo all'elenco del programma**, e il primo `READ` del gioco
(riga 110, `READ CD(N)` dentro il `GOSUB 100` della riga 10) non trova piu' niente. In altre parole il
blocco di `DATA` della routine, pur essendo oltre i dati del gioco, **se li mangia tutti**.

Rimedio applicato: `RESTORE 101` **in coda alla riga 146** (`...:NEXT:RESTORE 101`), che riporta il
puntatore al primo `DATA` del gioco prima che il `GOSUB 100` della riga 10 cominci a leggere. La riga
non e' cambiata di senso - stesso `LN`, stesso `POKE` - e `prove/p08-matrice.bas` ha ricevuto lo
stesso trattamento (`RESTORE 1000` in coda alla sua riga 3). Dettagli e cronologia in step 04 §4.6.

Il difetto non si vede leggendo il listato (e' un ordine di esecuzione incrociato fra riga 3 e riga
10), quindi e' entrato nella prova automatica: **`lm80c/ml/verifica.mjs` simula il puntatore dei
`DATA`** come lo vede il BASIC - caricamento compreso: legge `LN`, legge i byte, esegue il `RESTORE`
di coda, poi conta i valori dei cinque `READ` delle righe 110-115 - e pretende che i gruppi presi
siano esattamente `101`, `102-108`, `109`, `1091`, `1092-1093`. Provato al contrario: **senza** il
`RESTORE` il controllo segnala `OUT OF DATA ERROR simulato`, con `RESTORE 1094` segnala che i `READ`
pescano nel blocco della routine, con `RESTORE 102` che i gruppi sono sfasati di un valore.

## 8.3 Checklist dei requisiti richiesti

| richiesta | dove e' risolta | documento |
|---|---|---|
| 1. tokenizzazione: spazi fra keyword e operandi, righe entro 88 colonne, nomi variabile legali, `REM` al posto di `'` | tutto il listato `lm80c/lo_scalatore_lm80c.bas` | step 01 |
| 2. `PRINT` con codici PETSCII di posizionamento (`{clr}`, `{home}`, `{down}`, `{pur}`, `{left}`, `{inst}`) -> `CLS`, `LOCATE`, `COLOR`, `PRINT` | righe 70-74, 95-97, 120-122 | step 02 e 03 |
| 3. `POKE` sullo schermo -> `VPOKE`, `PEEK` dallo schermo -> `VPEEK` | tutte le righe che toccavano 7680..8191 e la color RAM 30720.. | step 03 e 05 |
| 3b. `POKE` sui colori (color RAM) -> color table del TMS9918 (un colore per tile) | righe 71-74, 112 | step 02 |
| 4. joystick -> tastiera (`SYS 828` + `ON PEEK(1)` -> `INKEY(0)` + cursori e SPAZIO) | righe 20-25 | step 04 |
| 5. suoni (`POKE 36874/36876/36877/36878`) -> `SOUND`/`VOLUME` | righe 0, 35, 40, 55-58, 66 | step 07 |
| 6. punteggio, vite, livelli e fine partita (stampe `TAB`/video inverso) | righe 36, 41, 65, 74, 95-98, 120-122 | step 06 |
| 7. correzioni dei bug noti dell'originale | righe 4-9, 74, 98 | step 05, 06 |

Non convertiti perche' inesistenti o inutili sul LM80C: la routine in linguaggio macchina del
joystick (`DATA 106..108`), il trucco `a$` + `POKE 8185` per lo scorrimento, `POKE 51/52/55/56`
(fine memoria BASIC), `POKE 36869` (charset), i registri VIA (`37154/37151/37152`), la riga morta
`69 goto 69` e la bomba (tile 59, mai usata dall'originale).

## 8.4 Piano di collaudo completo (in ordine)

Esegui i programmini di prova prima del gioco: isolano i singoli meccanismi e rendono il report
immediato.

| # | cosa lanciare | esito atteso | se fallisce |
|---|---|---|---|
| 1 | `prove/p01-sintassi.bas` | righe con `IF-THEN-ELSE`, `FOR-NEXT`, variabili di 2 caratteri e la scritta `FINE P01 - SE LEGGI QUESTO, LA SINTASSI VA BENE` | errore di sintassi: step 01 |
| 2 | `prove/p02-video.bas` | 5 tile colorati (trave magenta, scala rossa, barile giallo, omino e borsa neri) e i valori riletti con `VPEEK` | step 02 |
| 3 | `prove/p03-livello.bas` | livello completo (travi, scale, pila di 12 barili, borse) e conteggi per tipo di tile dopo SPAZIO | step 03 |
| 4 | `prove/p04-tastiera.bas` | codici tasto: SU 30, GIU' 31, SINISTRA 28, DESTRA 29, SPAZIO 32 | step 04 |
| 5 | `prove/p05-punteggio.bas` | punteggio allineato a destra, vite e livello aggiornati, `#` fuori dall'area numerica | step 06 |
| 6 | `prove/p06-suoni.bas` | i 5 suoni del gioco | step 07 |
| 7 | `prove/p08-matrice.bas` (solo variante a sprite) | la prima riga conferma `routine ML caricata: 284 byte` (se invece compare `OUT OF DATA ERROR`, il `RESTORE` in coda alla riga 3 del listato e' saltato: §8.2e); a riposo le otto righe sono tutte `........` con `K 0` e `FLAG 0`; premendo un cursore o il suo alias (`J L I K Z`) compaiono gli `0` nella riga e nella colonna giusta, `FLAG` cambia e `K` diventa 28/29/30/31; tenendo premuta una freccia e premendo SPAZIO il `K` diventa 32 **e** il flag della freccia resta acceso; `TEST 28:`... mostra il modo con parametro | step 04 §4.6, step 09 §9.14 |
| 8 | `lo_scalatore_lm80c.bas` con `RUN` (versione a tile) | partita giocabile: movimento, salto (+1000 su barile), borsa (+150), morte, vite, livelli | step 04, 05 |
| 9 | `lo_scalatore_lm80c_sprites.bas` con `RUN` (variante a sprite) | come il punto 8, con omino e barile come sprite, e **salto mentre si cammina** (tieni SINISTRA e premi SPAZIO) | step 04 §4.6, step 09 §9.10 e §9.14 |
| 10 | partita lunga | conteggio barili -> livello successivo, bonus vita a 10000, `GAME OVER` con punteggio finale | step 05, 06 |
| 11 | (facoltativo) `LIST` | tutte le righe presenti e intere, nessuna riga oltre 88 colonne | step 01 |

## 8.5 Formato del report

```
step: 05
riga: 52
errore/schermo: l'omino morendo sulla scala lascia un gradino in piu' a riga 8 col 12
atteso: la scala resta di 5 gradini
note: succede solo morendo in cima alla scala
```

Riporta nell'ordine: quale prova (numero della tabella §8.4), errore BASIC con la riga se c'e',
cosa vedi/senti, cosa ti aspettavi. Con questo si corregge il port e si aggiorna il documento
dello step relativo.

## 8.6 Limiti noti del port

- i numeri della riga di stato non sono in video inverso (`{rvon}` non esiste sul LM80C);
- il campo di gioco e' di 22 colonne centrate in 32: ai lati restano 5 colonne vuote per parte;
- i suoni sono approssimati (il PSG ha una scala lineare, il VIC-20 no);
- la bomba (tile 59) dell'originale non e' implementata, come nell'originale;
- il bug storico "morendo in cima alla scala la scala si allunga" e' presente come nell'originale:
  la correzione pronta e' indicata nello step 05 §5.4 e va applicata solo se il difetto si vede;
- (variante a sprite) i tasti premuti finiscono **anche nel buffer di input del DOS**, che il gioco
  non svuota: dopo una partita lunga il prompt BASIC puo' mostrare i codici accumulati. Valeva anche
  con `INKEY` (che non svuota quel buffer): da verificare, non e' una regressione. La routine in ML
  non passa dallo sniffer, quindi non ci aggiunge nulla di suo;
- (variante a sprite) l'input in linguaggio macchina **richiede il firmware 64K** (quello di default
  dell'emulatore): il blocco e' caricato a `$7800`, che nel modello a 32K di ROM e' memoria ROM e non
  e' scrivibile. In quel caso va riportato l'indirizzo a un'area libera della RAM alta (`$8241+`) e
  ricompilata la routine (step 04 §4.6);
