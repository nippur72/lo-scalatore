# Step 04 - Input da tastiera e movimento dell'omino

## Obiettivo

Sostituire `SYS 828` + `ON PEEK(1) GOTO ...` (lettura del joystick via routine in
linguaggio macchina nel buffer cassette del VIC-20) con la lettura della tastiera
tramite `INKEY(0)` del LM80C, e convertire il movimento dell'omino (righe 21-43
dell'originale).

Il port a **tile** (congelato) e' rimasto con `INKEY(0)` (§4.1-§4.5); la **variante a sprite** e'
passata a una **routine in linguaggio macchina** (§4.6) che legge la matrice della tastiera, toglie i
limiti di `INKEY`, permette di **saltare mentre si cammina** e aggiunge i **tasti alternativi**
(`J L I K Z`) perche' il C16 non ha i cursori a T rovesciata.

## 4.1 Mappa dei tasti

| azione originale | codice joystick | tasto LM80C | codice `INKEY` | riga del port |
|---|---|---|---|---|
| fire (salto) | 1 | **SPAZIO** | 32 | 21 -> 35 |
| sotto | 2 | **cursore GIU'** | 31 | 25 -> 26 |
| sinistra | 3 | **cursore SINISTRA** | 28 | 22 -> 28 |
| sopra | 4 | **cursore SU** | 30 | 23 -> 31 |
| destra | 5 | **cursore DESTRA** | 29 | 24 -> 33 |

L'originale usava `ON PEEK(1) GOTO 35,26,28,31,33`: nel port la stessa scelta è fatta
con quattro `IF` e con l'ultimo caso (GIU') lasciato in caduta sulla riga 26, mentre
"nessun tasto" e tasti non riconosciuti saltano a 41 (nessuna mossa):

```
20 PAUSE DL:K=INKEY(0):IF NB>0 THEN NB=NB-1:K=0
21 IF K=32 THEN 35          <- SPAZIO = salto (era fire)
22 IF K=28 THEN 28          <- cursore sinistra
23 IF K=30 THEN 31          <- cursore su
24 IF K=29 THEN 33          <- cursore destra
25 IF K<>31 THEN 41         <- cursore giu' e' gestito dalla riga 26
```
`INKEY` consuma e ritorna il primo codice presente nel buffer (0 se non c'e' nulla): e' quindi una
lettura del joystick per fotogramma, senza tasti "appesi". Attenzione pero' a due cose, entrambe
verificate sul firmware (`include/basic/basic-1.14.asm`, routine `INKEY`):

- `INKEY(0)` **attende comunque un centesimo di secondo** (serve allo sniffer per raccogliere almeno
  un tasto prima della lettura), quindi un fotogramma dura `DL` + ~1 centesimo;
- il codice del tasto resta in `TMPKEYBFR` finche' non viene letto: se il gioco non legge INKEY per
  un po' (come durante la sequenza di morte), alla ripresa trova **un tasto vecchio**. E' il motivo
  del `IF NB>0 THEN NB=NB-1:K=0` in riga 20: dopo la morte l'input viene ignorato per `NB` fotogrammi
  (impostato dalla riga 58), consumando e scartando i tasti rimasti in coda (step 08 §8.2c).

Il ritmo del ciclo e' dato da `PAUSE DL` (variabile `DL`, tarata nello step 08): e' questo `PAUSE` a
sostituire il ciclo `FOR N=1 TO 23:NEXT` dell'originale (riga 21), che scandiva il tempo una volta
per fotogramma.

`KEY 9,8,2` (in testa al programma) rende l'auto-repeat piu' pronto del default `64,8`: tenendo
premuta una freccia l'omino si muove ogni 2/100 s dopo 8/100 s di attesa. **E' questo il vero limite
di velocita' dell'omino** (un passo per fotogramma): con il precedente `KEY 9,20,6` arrivava un
tasto ogni 6/100 s, cioe' circa meta' della velocita' dei barili (step 08 §8.2b).

## 4.2 Conversione delle righe di movimento

| originale | port | nota |
|---|---|---|
| `poke s,t:poke s+g,d(t-j)` | `VPOKE S,T` | la POKE del colore non serve piu' |
| `if peek(s+22)=z` | `IF VPEEK(S+32)=Z` | scala sotto |
| `if peek(s+21)<62` | `IF VPEEK(S+31)>1` | "cella solida" = tile 8/16/24/40/41 (non 0 né 1) |
| `if peek(s+23)<62` | `IF VPEEK(S+33)>1` | idem a destra |
| `s=s+22` / `s=s-22` / `s=s+di` | `S=S+32` / `S=S-32` / `S=S+DI` | `DI` resta -1/+1 |
| `if t=60 then 55` | `IF T=24 THEN 55` | barile = morte |
| `if peek(s+22)>61 then 55` | `IF VPEEK(S+32)<2 THEN 55` | sotto c'è spazio (0) o deviatore (1) = morte |
| `if peek(s+22)=60` | `IF VPEEK(S+32)=24` | barile saltato = 1000 punti |
| `poke 36876,240` / `200` / `0` | `SOUND 1,3996,5` / `SOUND 1,3730,1` / `SOUND 1,0,0` | suoni (dettagli e frequenze reali nello step 07) |

Le righe del port sono: 20-27 (dispatch e discesa), 28-30 (sinistra), 31-32 (salita),
33-34 (destra), 35-39 (salto), 40 (beep e ridisegno), 41-42 (borsa/barile sotto),
43 (`GOSUB 98` bonus vita), 52-53 (sottoprogramma del passo di caduta).

## 4.3 Prova sull'emulatore (versione a tile, con `INKEY`)

1. Lancia `lm80c/prove/p04-tastiera.bas`: premendo i tasti deve mostrare il codice
   letto da `INKEY` e l'azione associata. Attesi: SU=30, GIU'=31, SINISTRA=28,
   DESTRA=29, SPAZIO=32. Prova anche a tenere premuta una freccia: il codice deve
   ripetersi rapidamente (auto-repeat di `KEY 9,8,2`).
2. Lancia il gioco (`RUN`) e verifica: l'omino si muove a destra/sinistra sulle travi,
   scende e sale dalle scale, con SPAZIO salta di un gradino nella direzione di marcia
   e, saltando un barile, prende 1000 punti.
3. Verifica che l'omino **non** si muova premendo tasti diversi da quelli previsti
   (per esempio `1` o `RETURN`), e che **dopo la morte non faccia un passo da solo**
   quando riceve la nuova vita (step 08 §8.2c).

Per la **variante a sprite** queste prove valgono solo in parte: li' l'input e' la routine in
linguaggio macchina (§4.6), quindi si lanciano `prove/p08-matrice.bas` e il gioco, con i punti a2 e
10-12 dello step 09 §9.10.

## 4.4 Se qualcosa non torna (versione a tile, con `INKEY`)

- **L'omino non si muove**: il codice del tasto non è quello atteso -> riporta il codice
  mostrato da p04. Se la tastiera dell'emulatore non manda 28/29/30/31, si aggiungono
  come alternative le lettere `Q/A/O/P` (facile modifica nelle righe 21-25).
- **L'omino "scivola" di molte celle con una sola pressione**: auto-repeat troppo veloce
  -> alza il secondo parametro di `KEY 9,8,2` (es. `KEY 9,20,6`, come nelle prime versioni).
- **Dopo la morte l'omino fa un passo involontario**: e' il tasto rimasto in `TMPKEYBFR` 
  (step 08 §8.2c) -> alza `NB` nella riga 58 (per esempio a `5`).
- **Cade nel vuoto appena si muove**: controllo sbagliato di "cella solida"
  (righe 28/33): verifica la mappa con p03.

## 4.5 La catena completa della tastiera (dalla matrice a `K`)

Tutto quello che segue e' verificato sul firmware del repo (non e' una ricostruzione):

| # | anello | cosa fa | dove |
|---|---|---|---|
| 1 | **matrice** | 8 righe x 8 colonne, lette attraverso i **due port I/O del PSG**: port registro `$40` (64), port dati `$41` (65). Il manuale hardware: "the user can control these chips directly by reading/writing from/to the ports" | manuale hardware cap. 2; `psg-1.02.asm` |
| 2 | **lettura di una riga** | `OUT 64,15` (seleziona il registro 15 = port B), `OUT 65,mask` (bit a **0** = riga attiva), `OUT 64,14` (seleziona il registro 14 = port A), **`INP(64)`** = colonne (bit a **0** = tasto premuto) | routine `READKBLN` |
| 2b | **da quale porta si legge** | **64, non 65**: sul PSG le due porte sono i due cicli `A0=0` -> `BDIR=0, BC1=1` = *read from PSG* e `A0=1` -> `BDIR=0, BC1=0` = *inactive*. La `in A,(C)` di `READKBLN` legge da `PSG_REG` (64), non da `PSG_DAT` (65); `INP(65)` restituisce 0 | `psg-1.02.asm`; emulatore `wasm/psg.c` + `wasm/chips/ay38910.h` + `wasm/io.c` |
| 3 | **chi la esegue** | lo *sniffer* dentro l'**interrupt del CTC** (`CH3_TIMER`), ma non a ogni interrupt: l'ISR fa `ld a,(TMRCNT):rra:call nc,KEYBOARD` -> una scansione **ogni 2 tick = 20 ms (50 Hz)** | `bootloader-1.07.asm` |
| 4 | **ordine di scansione** | maschere `$7F,$BF,$DF,$EF,$F7,$FB,$FD,$FE` = righe 7,6,5,4,3,2,1,0, e si ferma alla **prima** riga che ha un tasto premuto: **un tasto solo per scansione**, quello che sta nella riga con l'indice piu' alto | `RPTKBDRD` |
| 5 | **priorita' dei tasti del gioco** | frecce SINISTRA/DESTRA ($BF) **battono** SU/GIU' ($DF) che **battono** SPAZIO ($FE riga 0): tenendo premuta una freccia laterale, SU, GIU' e SPAZIO **non vengono mai consegnati** | `KBMAP`, riga 6 = `28,...,29`, riga 5 = `31,...,30`, riga 0 = `...,' ',...` |
| 6 | **consegna** | il codice finisce in **`TMPKEYBFR`** (1 byte), in `CHR4VID`, e — se il print-on-video e' spento, come in modo grafico — anche nel buffer di input del DOS | `SENDKEY` |
| 7 | **rilascio** | quando nessuna riga ha tasti: `LASTKEYPRSD`, `STATUSKEY`, `CONTROLKEYS`, `KBDNPT` vengono azzerati, **`TMPKEYBFR` no** | `NOKEYPRSD` |
| 8 | **auto-repeat** | se il tasto e' lo stesso di `LASTKEYPRSD`: dopo `KEYDEL` (prima ripetizione) e poi ogni `AUTOKE` il codice viene **riscritto** in `TMPKEYBFR` | `CHKAUTO`/`SETNEWAUTO`, comando `KEY 9,del,rep` (in centesimi) |
| 9 | **lettura da BASIC** | `INKEY(n)`: attende il tick (max 1 cs = 10 ms), poi **legge e azzera** `TMPKEYBFR`; per n da 1 a 9 il firmware **porta l'attesa a 10 cs**, da 10 in su attende fino a n cs. E' un **evento**, non uno stato: non esiste un modo BASIC di sapere se un tasto e' ancora premuto | `INKEY`, `basic-1.14.asm` |
| 10 | **nel gioco** | **una** lettura per fotogramma (riga 20, dopo `PAUSE DL`), quindi **al massimo un passo per fotogramma** | riga 20 |

### Cosa comporta (i limiti che si sentono giocando)

- **Ritardo minimo**: 0..20 ms di scansione + fino a un fotogramma (~3-4 cs con `DL=3`) = **fino a ~60 ms**; in media ~40 ms. E' il pavimento, non dipende da `DL` ne' da `KEY`.
- **Un tasto per volta**: tenendo premuta una freccia laterale, SU/GIU'/SPAZIO non arrivano mai.
  In particolare **non si puo' saltare mentre si cammina**: il gioco pero' salta nella direzione
  dell'ultimo movimento (`DI`), quindi basta **rilasciare la freccia e premere SPAZIO**.
- **Passo fantasma**: al rilascio, l'ultima ripetizione gia' in `TMPKEYBFR` viene comunque letta
  (`NOKEYPRSD` non lo azzera) -> **un passo in piu'** dopo ogni rilascio di una direzione tenuta
  premuta abbastanza da far partire l'auto-repeat.
- **`AUTOKE` sotto 2 non serve**: la matrice e' letta ogni 20 ms, quindi il massimo utile e' una
  ripetizione per scansione.
- **Tasti "persi"**: una pressione piu' breve di 20 ms puo' cadere fra due scansioni e non essere
  vista (vale anche per SPAZIO: premuto "a colpo" e rilasciato subito, a volte non salta).

### I problemi di `INKEY` (in ordine di gravita')

| problema | effetto in gioco | si puo' aggirare? |
|---|---|---|
| **un tasto per volta** (la scansione si ferma alla prima riga con un tasto) | tenendo SINISTRA/DESTRA premuta, SU, GIU' e SPAZIO sono invisibili: **non si salta camminando**, non si sale una scala tenendo la direzione | **no**, e' nel driver: nessun rimappaggio lo risolve (anche nella stessa riga viene consegnato un solo bit). Serve leggere la matrice a parte |
| **evento, non stato** (legge e azzera) | il movimento continuo puo' venire **solo** dall'auto-repeat; il gioco non puo' sapere se il tasto e' ancora giu', quindi non puo' distinguere "nuova pressione" da "ripetizione" | no, ma si sceglie il compromesso con `KEYDEL` |
| **`TMPKEYBFR` non viene azzerato al rilascio** | **passo fantasma**: al rilascio di una direzione tenuta abbastanza da far partire l'auto-repeat, la ripetizione rimasta in coda viene letta lo stesso -> un passo in piu' | no; con `KEYDEL` alto (0,2 s) si riduce ai soli rilasci dopo una camminata lunga |
| **quantizzazione a 20 ms** (una scansione ogni 2 tick) | ritardo 20 ms + fino a un fotogramma (~40 ms in media, ~60 ms peggio); una pressione < 20 ms puo' **non essere vista affatto** | no; si puo' solo togliere il `PAUSE` in eccesso |
| **`INKEY(n)` blocca** (`n` da 1 a 9 -> 10 cs) | non si puo' usare come "aspetta un po'": 1 vorrebbe dire 100 ms | — |
| **un solo tasto per fotogramma** (il gioco legge una volta per giro) | le ripetizioni in piu' vengono scartate: il limite di velocita' resta il fotogramma | si puo' alzare `DL`, ma accelera anche i barili |

### Il rimedio strutturale (se serve)

La matrice si puo' leggere **direttamente da BASIC** con `INP()`/`OUT` sui port `$40`/`$41` (le tre
righe che servono: `$BF` sinistra/destra, `$DF` su/giu', `$FE` spazio), esattamente come l'originale
VIC-20 leggeva il joystick con `PEEK`. E' documentato: `INP (x)` e `OUT port,value` sul manuale BASIC
(port 0-255) e i due port del PSG (`$40` registro, `$41` dati) sul manuale hardware, che dice
esplicitamente che l'utente puo' pilotare i chip direttamente tramite quei port.

La sequenza di lettura e' quella del firmware, ripetuta per ogni riga:

```
OUT 64,15         ' seleziona il registro 15 (port B)
OUT 65,M          ' maschera di riga: bit a 0 = riga attiva
OUT 64,14         ' seleziona il registro 14 (port A)
R = INP(64)       ' colonne: bit a 0 = tasto premuto  (da 64, non da 65)
```

| riga | maschera | bit 0 | bit 7 | bit 4 |
|---|---|---|---|---|
| 6 | **191** ($BF) | SINISTRA (28) | DESTRA (29) | — |
| 5 | **223** ($DF) | GIU' (31) | SU (30) | — |
| 0 | **254** ($FE) | — | — | SPAZIO (32) |

A riposo le tre letture valgono **255 255 255**: quello che si legge sono le **colonne**, non la
maschera scritta in port B (il firmware riconosce la riga senza tasti con `cp $FF`; se la lettura
fosse la maschera, ogni riga risulterebbe "sempre premuta"). Ogni tasto premuto azzera il **suo** bit:
SINISTRA 254, DESTRA 127, SU 127, GIU' 254, SPAZIO 239; le lettere degli alias azzerano il bit della
**loro** riga (vedi la tabella in §4.6). Prova isolata: **`prove/p08-matrice.bas`** (mostra le otto
righe grezze e tutto quello che ne ricava la routine in linguaggio macchina, §4.6).

**Attenzione alla porta**: la lettura si fa da **64**, non da 65. Lo dice il firmware (`READKBLN` scrive
la maschera con `PSG_DAT`, ma poi legge con `in A,(C)` dove `C` e' ancora `PSG_REG` = 64) e lo conferma
l'emulatore, dove `psg_read` costruisce i segnali dal bit A0 dell'indirizzo: porta 64 = ciclo *read from
PSG*, porta 65 = *inactive* (i pin dati restano a 0, quindi `INP(65)` da' **0** sempre). Se si legge da
65, `255-INP(65)` vale 255 e sembra che **tutti** i tasti siano premuti: l'omino non risponde ai
comandi (salta una volta e poi resta fermo).

Un tasto speciale: `TMR(0)` da' i 16 bit bassi del contatore di sistema (centesimi), e la scansione
della tastiera avviene **solo negli interrupt in cui il contatore diventa pari**; quindi aspettando
che `TMR(0)` sia **dispari** si ha la garanzia che la prossima scansione e' almeno 10 ms dopo, e le
tre letture (1-2 ms) non possono incrociarla. Serve solo se si vedono glitch: costa in media 5 ms per
fotogramma. Diventerebbe uno **stato** invece di un evento: nessun
auto-repeat, nessun passo fantasma, e frecce + SPAZIO visibili **insieme** nella stessa scansione.
Due avvertenze: lo stesso sniffer usa quei registri ogni 20 ms (una lettura puo' capitare nel bel
mezzo di una scansione -> al massimo un "falso rilascio" di un fotogramma), e una `OUT` interrotta
dall'interrupt puo' finire nel registro sbagliato.

E' **questa** la via che e' stata poi presa (§4.6): una routine in **linguaggio macchina** chiamata
con `SYS indirizzo`, che legge la matrice con gli interrupt **disattivati** (`di`/`ei`) e ne ricava
direttamente il codice del comando, compresi i **tasti alternativi** (impossibili da `INKEY`: il
firmware consegna **un solo** codice per scansione, non si puo' sapere se una freccia e' ancora
premuta, e l'auto-repeat non distingue una pressione nuova da una ripetizione). Il `USR(x)` di questo
BASIC e' disabilitato (salta su `FCERR`), quindi il richiamo e' `SYS`: `SYS` puo' passare **un** byte
nel registro A, ed e' su questo che si basa il modo test della routine.

## 4.6 Applicazione: la variante a sprite usa una routine in linguaggio macchina

Il rimedio "strutturale" descritto sopra e' stato **applicato alla variante a sprite**
(`lm80c/lo_scalatore_lm80c_sprites.bas`), ma non in BASIC: la lettura della matrice e' una **routine
in linguaggio macchina** (Z80) che gira con gli **interrupt disattivati**. La versione a tile
(congelata) resta com'e', con `INKEY(0)` e `KEY 9,20,6`.

Prima di arrivare qui sono state provate due strade in BASIC, tutte e due abbandonate: `INKEY` (un
tasto per volta, evento e non stato, coda di tasti; §4.5) e la lettura diretta con `OUT`/`INP`
(esposta allo sniffer: 1,7-2,5 % di fotogrammi con `K` sbagliato, scesi a 0,6-0,75 % con la verifica
del registro 15, ma mai a zero). Il linguaggio macchina chiude il problema alla radice.

| riga | prima | ora |
|---|---|---|
| 1 | `...:DI=DO(INT(RND(1)*2)):KEY 9,8,2` | `...:DI=DO(INT(RND(1)*2))` (l'auto-repeat non serve piu') |
| 3 | `...:E3=1:Q=10000:GOTO 10` | `...:E3=1:Q=10000:GOSUB 146:GOTO 10` (carica la routine) |
| 20 | `PAUSE DL:K=INKEY(0):IF NB>0 THEN NB=NB-1:K=0` | `PAUSE DL:SYS AD:K=PEEK(SB)` |
| 58 | `...:CH=CH-1:NB=2:IF CH<0 THEN GOSUB 125:END` | `...:CH=CH-1:IF CH<0 THEN GOSUB 125:END` (via l'inibizione `NB`: serviva solo per `TMPKEYBFR`) |
| 130-143 | routine di lettura in BASIC (`OUT`/`INP`) | **tolte**: al loro posto la routine in ML |
| 145-147 | — | caricamento della routine in ML dai `DATA 1094-1111` |
| 1094-1111 | — | i **279 byte** della routine (il primo valore e' la lunghezza `LN`) |

```
145 REM input in ML: ingresso a SYS AD, blocco di stato in coda (K in PEEK(SB))
146 AD=30720:RESTORE 1094:READ LN:FOR N=0 TO LN-1:READ DT:POKE AD+N,DT:NEXT:RESTORE 101
147 SB=AD+268:RETURN
```

#### Il `RESTORE 101` in fondo alla riga 146 non e' un ornamento

Il primo collaudo di questo listato si e' fermato con **`OUT OF DATA ERROR IN LINE 110`**. Non era la
routine in ML: era il **puntatore dei `DATA`**. Il BASIC consuma i `DATA` **in ordine di numero di
riga** (non di listato), e la riga 3 chiama il caricamento **prima** che il gioco legga i suoi dati. Il
caricamento parte da `RESTORE 1094` e legge **tutti** i valori che trova da li' in poi (il `279`, poi i
279 byte: 280 valori, cioe' fino all'ultima riga del programma), quindi il puntatore resta a **fondo
elenco**: il primo `READ` del gioco (riga 110, `READ CD(N)` dentro il `GOSUB 100` della riga 10) non
trova piu' niente.

Il rimedio e' il `RESTORE 101` incatenato in coda alla riga 146: riporta il puntatore al **primo
`DATA` del gioco** (riga 101), cosi' la catena di `READ` delle righe 110-115 ritrova i suoi dati
(`101`, `102-108`, `109`, `1091`, `1092-1093`) come se il caricamento non fosse mai avvenuto. Nota che
le `DATA 1091-1093` **non** sono "protette" dal `RESTORE 1094`: e' il `RESTORE` in coda a rimettere
tutto a posto, e qualunque `READ` eseguito dopo il caricamento senza quel `RESTORE` fallisce.

Il difetto e' invisibile leggendo il listato, percio' e' finito nella prova automatica: `verifica.mjs`
simula il puntatore dei `DATA` come lo vede il BASIC (caricamento compreso: legge `LN`, legge i byte,
riavvolge, poi i cinque `READ` delle righe 110-115) e pretende che ogni gruppo prenda esattamente i
blocchi `101`-`109` e `1091`-`1093`, oltre a controllare che la riga del `POKE` chiuda con un
`RESTORE`. Provato al contrario: togliendo il `RESTORE`, spostandolo a 1094 o sfasandolo a 102 il
controllo segnala il problema.

### Il sorgente e come si compila

La routine e' in `lm80c/ml/lm80c_keys.asm` (Z80), si assembla con z88dk:

```bash
cd lm80c/ml
z80asm -b lm80c_keys.asm     # -> lm80c_keys.bin (279 byte)
node build.js                 # assembla e stampa il blocco DATA per il listato
node verifica.mjs             # controlla i listati (DATA uguali al binario, righe, salti, ingombro)
node prova_ml.mjs /percorso/di/lm80c-emu   # esegue la routine sul core dell'emulatore
```

`build.js` controlla anche che l'ingresso sia davvero al **primo byte** (cioe' che il codice non sia
stato spostato) e calcola l'indirizzo del blocco di stato, che sta **in coda** al binario: lo stampa
insieme alle righe `DATA` (16 byte per riga), che si incollano in fondo al listato; l'offset che ne
esce e' quello di `SB`, da usare nei `PEEK`. Il blocco sta **dopo** i dati del gioco (1094-1111, cioe'
oltre il 1093 dove finisce la catena di `READ` delle righe 110-115), ma il caricamento lo consuma
tutto: da qui il `RESTORE 101` in coda alla riga 146 (vedi sopra).

### Dove sta e perche' proprio li'

Il **codice** sta in testa e il **blocco di stato** in coda: l'ingresso e' il primo byte, il blocco
dipende dalla lunghezza di codice+dati (268 byte con la routine attuale), quindi il suo indirizzo si
sposta se il codice cresce. Non e' piu' un indirizzo fisso: `build.js` lo calcola e `verifica.mjs`
controlla che l'`SB` del listato sia d'accordo.

| indirizzo | cosa c'e' |
|---|---|
| **30720** (`$7800`, `AD`) | **ingresso** della routine: e' il **primo byte del binario**, quindi e' qui che salta `SYS` |
| **30988** (`AD+268`, `SB`) | blocco di stato: `K`, il codice del gioco (o 1/0 in modo test) |
| 30989 | `FLAGS`: bit0 DESTRA, bit1 SU, bit2 SINISTRA, bit3 GIU', bit4 SPAZIO |
| 30990+R (R=0..7) | immagine grezza delle 8 righe: `PEEK(SB+2+R)` |
| 30998 | stato dello SPAZIO al fotogramma precedente (serve per il fronte) |

Perche' `$7800`:

- nel firmware **64K** (quello di default dell'emulatore) la RAM bassa e' libera: il firmware viene
  copiato dalla ROM alla RAM e la ROM poi viene disattivata, quindi `$0000-$7FFF` e' tutto RAM. Il
  programma BASIC parte da `$560E` e le sue variabili stanno appena sopra: `$7800` e' oltre la fine
  del listato (che occupa meno di 6 KB) e resta comunque fuori dall'area gestita da BASIC;
- **`POKE` e `SYS` di questo BASIC non accettano indirizzi da `$8000` in su**: `DEINT` converte solo
  l'intervallo -32768..32767, quindi un indirizzo alto (per esempio `$E100`) non e' nemmeno
  esprimibile. Ecco perche' la routine sta sotto il limite dei 32767 byte;
- l'area non viene toccata da `NEW`, `CLEAR`, `RUN` ne' dallo stack (che e' a `$54E0`), e nemmeno
  dalla catena dei `DATA` letta dal livello.

Attenzione: con il firmware **32K** (ROM in basso, `?rom=314`) `$7800` e' ROM e non e' scrivibile:
l'input in ML richiede il modello 64K. In quel caso la routine va riassemblata a un indirizzo della
RAM alta (`$8241+`, vedi la mappa in step 00 §0.1), ricordandosi che li' `POKE`/`SYS` richiedono di
esprimere l'indirizzo con il segno (`$8241` = -32191).

### Perche' con gli interrupt disattivati (`di`/`ei`)

Lo sniffer del firmware gira **dentro l'interrupt del CTC** e usa **gli stessi due port** della nostra
routine ogni 20 ms: seleziona il registro 7, lo riscrive, poi fa il giro delle otto righe (per ognuna:
`OUT 64,15`, `OUT 65,mask`, `OUT 64,14`, `INP(64)`), fermandosi alla prima con un tasto. Da BASIC una
`OUT`/`INP` poteva cadere dentro una scansione e trovare la selezione dei registri e il port B
**cambiati da sotto**: la maschera finiva nel registro sbagliato e la lettura restituiva le colonne di
un'altra riga. La verifica del registro 15 (descritta nella cronologia qui sotto) riduceva il
disturbo, non lo annullava.

In linguaggio macchina basta **`di` all'inizio ed `ei` alla fine**: nessun interrupt puo' intromettersi
fra le otto letture, quindi **non esiste piu' nessuna finestra** (e non serve piu' ne' la verifica del
registro 15 ne' il contatore GLITCH di `p08`). Gli interrupt restano disattivati per la durata della
lettura: **179 istruzioni, 1627 cicli**, cioe' **441 µs** a 3,6864 MHz (numeri misurati eseguendo la
routine sul core dell'emulatore, `ml/prova_ml.mjs`). Il clock da 100 Hz del CTC non se ne accorge.

#### Cronologia: la versione in BASIC, e perche' non bastava

Restano qui sotto i numeri misurati sulla strada abbandonata (lettura con `OUT`/`INP` dalle righe
`130-143`), utili se un giorno si volesse tornare al BASIC senza routine in ML. Con un modello del PSG
identico a quello dell'emulatore (`wasm/psg.c` + `chips/ay38910.h`) e lo sniffer inserito ogni 20 ms
(piu' il conteggio dei suoni ogni 10 ms), su 800 fasi di partenza diverse:

| lettura in BASIC | fotogrammi con `K` sbagliato |
|---|---|
| senza verifica (`OUT 64,15:OUT 65,mask:OUT 64,14:K=255-INP(64)`) | 1,7-2,5 % |
| con la verifica del registro 15 dopo la maschera e dopo le colonne | 0,6-0,75 % |

Restavano le finestre di due-tre istruzioni fra il controllo e la lettura, che in BASIC non si possono
chiudere: un fotogramma sbagliato ogni qualche decina di secondi. E' il motivo per cui la lettura in
BASIC e' stata **tolta** dal gioco.

### Il protocollo (cosa fa e cosa lascia in RAM)

Il gioco fa **una chiamata per fotogramma**:

```
20 PAUSE DL:SYS AD:K=PEEK(SB)         ' una scansione, K e' il codice del gioco
```

La routine legge **tutte e otto** le righe della matrice (non solo le tre che servono) e ne ricava:

- **`PEEK(SB)`** = il codice `K` del gioco: 0 (nessun comando), 28 SINISTRA, 29 DESTRA, 30 SU,
  31 GIU', 32 SPAZIO (solo sul fronte). E' lo stesso codice che la riga 20 leggeva da `INKEY`:
  **le righe 21-34 del gioco non sono state toccate**, cambia solo chi fornisce il valore;
- **`PEEK(SB+1)`** = `FLAGS`, lo stato istantaneo dei 5 comandi (bit0 DESTRA, bit1 SU, bit2 SINISTRA,
  bit3 GIU', bit4 SPAZIO). Serve per la prova `p08` e, se un giorno servisse, per un comando che
  debba funzionare "tenuto premuto" senza passare da `K`;
- **`PEEK(SB+2+R)`** (R = 0..7) = la riga grezza come esce dal PSG: i bit a **0** sono i tasti
  premuti di quella riga (convenzione della matrice). E' il motivo per cui la lettura va fatta sui
  bit e non sui codici del firmware: le lettere dell'alias si vedono direttamente;
- **`PEEK(SB+10)`** = lo stato dello SPAZIO al fotogramma precedente, per il fronte.

La routine funziona anche in **modo test**, con il codice di un comando come parametro:
`SYS AD,28` lascia **1** in `PEEK(SB)` se il comando e' premuto (cursore **o** alias), altrimenti
**0**; con un codice fuori dall'intervallo 28..32 lascia 0. In questo modo l'omino o un eventuale
menu possono chiedere "e' premuto il comando X?" senza rifare i confronti in BASIC.

### I tasti alternativi (alias)

Il C16 non ha i cursori a T rovesciata, quindi ogni comando risponde a **due** posizioni della
matrice: il cursore e una lettera. Nella prima lettura del gioco vince il cursore, ma entrambi sono
"premuti" per il comando: si puo' giocare indifferentemente con le frecce o con `J L I K`. Le
posizioni sono prese dal `` KBMAP `` del firmware e dalla mappa della tastiera dell'emulatore
(`src/keys.ts`), e **non** dipendono dal fatto che SHIFT sia premuto: si legge la matrice, non il
codice del tasto.

| comando | codice `K` | cursore (riga/bit) | alias | alias (riga/bit) |
|---|---|---|---|---|
| SINISTRA | 28 | riga 6 (`$BF`) bit 0 | **J** | riga 4 (`$EF`) bit 2 |
| DESTRA | 29 | riga 6 (`$BF`) bit 7 | **L** | riga 5 (`$DF`) bit 2 |
| SU | 30 | riga 5 (`$DF`) bit 7 | **I** | riga 4 (`$EF`) bit 1 |
| GIU' | 31 | riga 5 (`$DF`) bit 0 | **K** | riga 4 (`$EF`) bit 5 |
| SPAZIO | 32 | riga 0 (`$FE`) bit 4 | **Z** | riga 1 (`$FD`) bit 4 |

Sono le cinque righe che la routine legge sempre (piu' le altre tre, che non servono al gioco ma
completano l'immagine della matrice e costano ~7 µs ciascuna). Nota: `L` sta nella **stessa riga** dei
cursori SU/GIU', `J I K` nella stessa riga (`$EF`), `Z` nella stessa riga di `A S E`.

### Priorita' e fronte

- **quale comando vince se ne sono premuti due** segue l'ordine di controllo della routine in
  linguaggio macchina dell'originale VIC-20 (`on peek(1) goto 35,26,28,31,33` = *fire, sotto,
  sinistra, sopra, destra*): l'ultima assegnazione vince, quindi **SPAZIO > GIU' > SINISTRA > SU >
  DESTRA**. In pratica: con GIU' e SINISTRA premuti insieme l'omino **scende** (come sull'originale),
  con SU e SINISTRA insieme **va a sinistra**;
- **lo SPAZIO ha il riconoscimento del fronte**: `K=32` scatta solo al passaggio 0 -> 1 dello spazio
  (il byte a `SB+10` tiene lo stato precedente). Serve perche' la matrice da' uno **stato** e non un
  **evento**: senza fronte, tenendo premuto SPAZIO si salterebbe a ogni fotogramma (e il salto avanza
  di due colonne, quindi l'omino "volerebbe" in avanti). Con il fronte: tenendo premuti SPAZIO e una
  freccia si salta **una volta** e poi si cammina, e tenendo premuto SPAZIO non si salta di nuovo
  finche' non lo si rilascia. Gli altri comandi sono di stato: si ripetono a ogni fotogramma, ed e'
  proprio quello che serve per camminare.

### Cosa e' cambiato in gioco

| | con `INKEY` | con la matrice in BASIC | **con la routine in ML** |
|---|---|---|---|
| salto camminando | impossibile (nello sniffer le frecce laterali battono lo SPAZIO) | possibile | **possibile** |
| passo fantasma al rilascio | si | no (la matrice e' uno stato, non una coda) | no |
| ritardo minimo | fino a 20 ms di scansione + un fotogramma | nessuna quantizzazione | nessuna quantizzazione |
| passo involontario dopo la morte | si (tasto rimasto in `TMPKEYBFR`) | no: `NB` tolto | no |
| letture disturbate dallo sniffer | n/a | 0,6-0,75 % dei fotogrammi con `K` sbagliato | **zero** (`di`/`ei`) |
| auto-repeat (`KEY 9,...`) | necessario | inutile | inutile |
| tasti non riconosciuti | diventano codice tasto | idem | **ignorati**: si legge solo la matrice |
| costo per fotogramma | 1 cs di attesa incorporata (0..10 ms, in media 5) | ~12 istruzioni `OUT`/`INP` + i test in BASIC (2-4 ms) | **179 istruzioni Z80 = 441 µs** |
| tasti alternativi | assenti | assenti | **J L I K Z** |

**Attenzione ai tempi**: `INKEY(0)` aveva 1 centesimo di attesa incorporata (0..10 ms, in media ~5 ms),
che adesso non c'e' piu'; al suo posto ci sono le otto letture e il calcolo di `K` in linguaggio
macchina, **441 µs**. Rispetto alla versione con `INKEY` il fotogramma si accorcia di ~5 ms (con `DL=3`
si passa da ~38 a ~33 ms), mentre rispetto alla versione in BASIC con `OUT`/`INP` e' praticamente
identico (441 µs contro 2-4 ms di interpretazione): **se il gioco, dopo il passaggio a questa versione,
risulta troppo rapido si sale `DL` da 3 a 4** (step 08 §8.1).

Un tasto che il gioco **non** vede piu' e' RUN/STOP: `INKEY` lo consegnava come codice 3, mentre la
matrice (riga 0 bit 3) non viene guardata. Il gioco si ferma comunque con RUN/STOP, perche' `PAUSE`
e' interrompibile; va solo tenuto premuto un attimo in piu'.

### Come e' stata verificata

- **sul core dell'emulatore, senza aprire il browser**: `lm80c-emu` espone in wasm proprio le funzioni
  che servono (`mem_write`, `keyboard_press`, `lm80c_tick`, `psg_write`, ...), quindi la routine e'
  stata eseguita davvero, con il suo PSG e la sua tastiera, partendo dal binario prodotto da `z80asm`:
  `node ml/prova_ml.mjs /percorso/di/lm80c-emu` (lo script e' nel repo). Le prove (33 controlli, tutte
  superate - il numero lo stampa lo script) coprono: matrice a riposo (`$FF` su tutte e otto
  le righe, `K=0`), i quattro cursori, i cinque alias, il fronte dello spazio (e la sua memoria in
  `SB+10`), le priorita' con due tasti premuti, il salto mentre si cammina, il modo test e la
  **conservazione dei registri e dello stack** al ritorno (indispensabile: la routine viene chiamata
  mentre il BASIC sta eseguendo una riga). Lo stesso script conta istruzioni e cicli: **179
  istruzioni, 1627 cicli, 441 µs**;
- **sull'emulatore, a mano**: `prove/p08-matrice.bas` mostra le otto righe della matrice (un `0` per
  ogni tasto premuto), `FLAGS`, `K`, lo stato dello spazio e il risultato del modo test. Serve per
  confermare che il caricamento dai `DATA` funzioni e per vedere a colpo d'occhio che riga e colonna
  corrispondono al tasto premuto;
- **nel gioco**, che e' la prova finale: `RUN` e verifica movimento, salto camminando, e che
  rilasciando un tasto l'omino si fermi subito.

Se si modifica `lm80c_keys.asm` bisogna **riassemblare e rigenerare i `DATA`** (`node build.js`, poi
`node verifica.mjs` per il confronto con i listati) in
**tutti e due** i listati che la contengono (il gioco e `prove/p08`): il primo valore dei `DATA` e' la
lunghezza, quindi il caricamento si adatta da solo, ma se i byte non sono aggiornati il gioco parte
con una routine vecchia (o, peggio, con un file troncato).

## 4.7 Report

Per la versione a tile: riporta i codici dei tasti letti, quale movimento non funziona e in che punto
della mappa. Per la variante a sprite: se `prove/p08` non mostra il tasto giusto nella riga e nella
colonna giusta, riporta **riga e colonna** dello `0` che compare e il tasto premuto (la tabella di
§4.6 dice quali valori aspettarsi); se il gioco parte ma l'omino non risponde, il primo sospetto e'
che i `DATA 1094-1111` non siano stati incollati per intero (il controllo che fa la riga 4 di `p08`:
`routine ML caricata: 279 byte`), oppure che si stia usando il firmware 32K.
