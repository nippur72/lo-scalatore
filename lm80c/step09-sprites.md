# Step 09 - Variante con gli sprite: omino e barile come sprite del TMS9918

## Obiettivo

Produrre una seconda versione del gioco, `lm80c/lo_scalatore_lm80c_sprites.bas`, in cui **l'omino e
il barile in movimento sono sprite** del TMS9918 invece che tile scritti nella name table. La
versione a tile (`lm80c/lo_scalatore_lm80c.bas`) e' **congelata**: resta la referenza stabile e non
viene piu' modificata (vedi `task.md`).

Cosa **resta a tile**: pila dei 12 barili, travi, scale, borse, deviatori, spazio. Il motivo e'
fisico: il VDP disegna **al massimo 4 sprite per riga di scansione** (il 5o sparisce), e la fila
inferiore della pila ha **6 barili sulla stessa riga**: come sprite ne resterebbero visibili solo 4.
Pila e barile "fermo" non sono oggetti in movimento, quindi restano la mappa statica del livello.

## 9.1 Idea portante

Con gli sprite la name table (**name table** = la griglia dei codici dei tile, base `$1800` = 6144)
diventa la **mappa statica del livello**, che nessun oggetto in movimento sporca o ripristina piu'.
Questo semplifica il codice: sparisce tutta la danza "salva il tile sotto l'omino / riscrivilo
quando se ne va" (`VPOKE S,T` / `VPOKE S,40`) e quella del barile (`VPOKE V,W` / `VPOKE V,24`),
perche' il barile non scrive piu' nulla nel livello.

Quello che invece **non cambia** e' la logica: l'omino vive ancora su una cella (`S`) e legge il
tile della sua cella con `T=VPEEK(S)` per capire dove si trova (scala, trave, borsa, spazio). Le
collisioni con il barile, che prima si scoprivano leggendo il tile `24` nella mappa, si fanno ora
confrontando le due celle: **`S=V`** (l'omino e' nella cella del barile), **`S+32=V`** (il barile e'
sotto l'omino), **`S+32<>V`** (il barile fa da pavimento quando si atterra dal salto).

Vantaggi collaterali:

- l'omino e il barile si disegnano con **trasparenza**: sotto di loro si vedono travi e scale (con
  i tile l'omino e il barile portavano con se' il rettangolo bianco di sfondo);
- la **borsa sparisce subito** quando la raccogli (`VPOKE S,0`), mentre nella versione a tile
  restava disegnata finche' l'omino non si spostava;
- niente piu' `VPOKE` di comodo per muovere i due oggetti: ogni fotogramma si aggiornano solo le
  coordinate degli sprite.

## 9.2 Le tabelle degli sprite in VRAM (manuale hardware, cap. 8)

| area | indirizzo VRAM in SCREEN 1 | registro VDP | come si indirizza |
|---|---|---|---|
| sprite attribute table (SAT) | `$1B00-$1B7F` = **6912-7039** | 5 (valore 54) | `54 * 128 = 6912` |
| sprite pattern table | `$3800-$3FFF` = **14336-16383** | 6 (valore 7) | `7 * 2048 = 14336` |

Nessuna collisione con quello che il gioco usa gia': pattern table `$0000-$07FF`, name table
`$1800-$1AFF` (6144-6911, dove vive la griglia del livello) e color table `$2000-$201F`
(8192-8223).

I due registri **non** vengono scritti dal gioco: li imposta `SCREEN 1` della riga 0. Verificato sul
firmware (`include/vdp/vdp-1.08.asm`): `SCREEN` chiama `initVDP`, che per il modo 1 carica la
tabella `VDPMODESET1`, dove **reg.5 = `$36`** (54: SAT a `$1B00`) e **reg.6 = `$07`** (7: pattern
degli sprite a `$3800`). Le `VREG 5,54:VREG 6,7` delle prime stesure erano quindi ridondanti: sono
state tolte (una riga in meno da digitare e un punto di rottura in meno).

Nota: `CLS` in modo 1 (riga 70) **non** tocca la SAT - manda solo il carattere "clear screen" alla
name table (firmware, `CLS:`) - quindi gli sprite vanno nascosti a mano prima di ridisegnare il
livello (vedi §9.3).

## 9.3 Layout della SAT: 4 byte per sprite

| byte | significato | come si usa nel port |
|---|---|---|
| `Y` | posizione verticale **-1**: il valore `N` mette lo sprite a partire dalla riga `N+1`; `$D0` = **208 termina la lista** | `8*R-1` dove `R` = riga del name table |
| `X` | posizione orizzontale in pixel (`0` = tutto visibile a sinistra) | `8*C` dove `C` = colonna del name table |
| pattern | numero del pattern nella sprite pattern table | 0 = omino, 1 = barile |
| colore | nibble basso: colore dello sprite (**0 = trasparente**); bit 7 = "early clock" (sposta di 32 px a sinistra) | 1 = nero (omino), 11 = giallo chiaro (barile) |

Con `R` = riga e `C` = colonna del name table, il tile di quella cella occupa i pixel
`x = 8*C ... 8*C+7` e `y = 8*R ... 8*R+7`, e lo sprite con `X = 8*C` e `Y = 8*R-1` occupa
**esattamente la stessa area**: sprite e tile sono allineati al pixel.

Per nascondere uno sprite basta scrivere **208** nel suo byte `Y` (e' il valore che termina la
lista: il VDP smette di disegnare da quell'entry in poi). Nel port:

```
51 VPOKE 6916,208:GOTO 19            (barile arrivato in fondo al campo)
59 GOSUB 96:VPOKE 6916,208:Y=Y+1     (dopo la morte)
70 CLS:VPOKE 6912,208:VPOKE 6916,208 (prima di ridisegnare il livello)
```

La lista e' terminata esplicitamente dalla riga **115** con `VPOKE 6920,208` (il terminatore sta
sull'entry 2: le entry non usate non vengono interpretate come sprite). Va notato che le entry non
inizializzate hanno colore 0 = trasparente, quindi non si vedrebbero comunque: il terminatore e' una
sicurezza in piu'.

Attenzione all'ordine: **se l'entry 0 ha `Y` = 208 la lista finisce li' e anche lo sprite 1
sparisce**. Al momento del disegno del livello (riga 70) entrambi sono nascosti apposta; l'omino
viene ripiazzato dalla riga 17 prima del primo fotogramma, quindi non si vede mai uno stato in cui
il barile resta invisibile per colpa del terminatore.

## 9.4 Colori e pattern degli sprite

In Graphics I il VDP **non** ha una color table per gli sprite: il colore e' quello scritto nel 4o
byte della SAT. Verificato sul codice dell'emulatore (`docs/tms9928a.cpp`, funzione di disegno dei
sprite: `sprcol` viene letto dalla SAT e usato in tutti i modi; `if (sprcol)` = 0 trasparente).

Per avere gli stessi colori delle due versioni si usano gli stessi valori dei gruppi colori dei
tile:

| oggetto | tile (versione congelata) | gruppo colori | sprite (variante) |
|---|---|---|---|
| omino | tile 40, gruppo 5 -> `VPOKE 8197,31` = `$1F` = nero su bianco | 5 | colore **1** (nero) |
| barile | tile 24, gruppo 3 -> `VPOKE 8195,191` = `$BF` = giallo chiaro su bianco | 3 | colore **11** (giallo chiaro) |

I **bitmap** degli sprite hanno gli stessi valori dei tile corrispondenti, scritti in due `DATA`
dedicati e caricati a `14336` dalle righe **115** (omino -> pattern 0) e seguenti (barile ->
pattern 1):

```
1092 DATA 60,60,25,255,188,60,36,231   -- omino  (= tile 40, DATA 107)
1093 DATA 60,66,165,153,153,165,66,60   -- barile (= tile 24, DATA 106)
115 FOR M=0 TO 15:READ DT:VPOKE 14336+M,DT:NEXT:VPOKE 6912,208:VPOKE 6920,208
```

Le prime stesure copiavano i pattern dalla pattern table con `VPOKE 14336+M,VPEEK(320+M)`: la
sintassi e' lecita, ma era un costrutto mai usato altrove nel gioco e la duplicazione dei due
pattern in `DATA` e' piu' facile da verificare a occhio (16 numeri) e non dipende dall'ordine in cui
il firmware carica il charset. Le due coppie di `DATA` vanno tenute allineate: se si cambia il
disegno del barile vanno cambiate **entrambe** (106 e 1093).

## 9.5 La causa dell'invisibilita' degli sprite (e la lezione sulle righe)

La prima stesura caricava i pattern e inizializzava la SAT nelle righe `1121`, `1122` e `1141`, e
aveva le routine in `115`-`1171`. Gli sprite non comparivano **mai**, in nessun fotogramma, e il
motivo non era il VDP: era la **numerazione delle righe**.

Il BASIC, come tutti i Microsoft BASIC, tiene il programma **ordinato per numero di riga** ed
esegue la riga successiva *in quell'ordine*: una subroutine e' quindi un **intervallo contiguo di
numeri di riga**, che finisce al primo `RETURN` incontrato. Nel sorgente precedente l'ordine reale
di esecuzione era:

```
110  DIM CD(6)...            (inizio del corpo di GOSUB 100)
...
114  DIM DN(10)...:NEXT      (ultima lettura DATA fatta per davvero)
115  GOSUB 116:GOSUB 117:RETURN   <-- RETURN: il corpo di GOSUB 100 finisce QUI
116  ...
117  ...
120  CLS:LOCATE 8,10:PRINT "GAME OVER"
...
1121 VPOKE 6912,208:...      }  numeri piu' alti: mai raggiunti dal GOSUB 100
1122 VPOKE 6914,0:...        }
1141 FOR M=0 TO 15:READ DT:VPOKE 14336+M,DT:NEXT:RETURN   }
```

I numeri `1121`, `1122`, `1141` sono **maggiori di 115**, quindi vengono dopo il `RETURN`: non
eseguiti mai. Il risultato era una VRAM con i pattern degli sprite tutti a zero (**sprite
trasparenti**: invisibili per definizione) e la SAT tutta a zero. Il gioco funzionava lo stesso
perche' la logica degli sprite usava `S`/`V` e non aveva bisogno ne' della SAT ne' dei pattern per
decidere cosa fare.

Nello stesso blocco c'era un secondo errore latente, nella riga

```
116 R=(S-6144)#32:IF R<0 THEN R=0:IF R>23 THEN R=23:C=S-6144-32*R
```

In BASIC **tutto cio' che segue `THEN` fino a fine riga e' parte del `THEN`** (verificato sul
firmware: su condizione falsa il gestore `IF1` scandisce la riga fino al fine-riga o a un `ELSE`).
Quindi con `R >= 0` (il caso normale) la parte `:IF R>23 THEN R=23:C=...` **non veniva eseguita** e
`C` restava 0. Il port non usava il `%` (modulo) proprio per evitare quel tipo di costrutti: e' lo
stesso motivo per cui nella versione a tile le righe delicate sono spezzate su piu' righe di
continuazione (`1161`, `1162`).

**Regole che ne derivano, valide per tutto il progetto:**

1. il corpo di una subroutine deve stare in un **intervallo contiguo di numeri di riga** che
   termina con il suo `RETURN`: nessuna riga di quel corpo puo' avere un numero maggiore di una
   riga intermedia che contiene `RETURN`;
2. le righe di continuazione (`1161`, `1151`, ...) devono stare **fra** la riga base e la riga
   successiva *in ordine numerico*, non solo nel file;
3. niente `IF cond THEN a=...:b=...`: se il secondo pezzo deve essere eseguito comunque, va su una
   riga sua (o l'`IF` va messo per ultimo);
4. verificare sempre **l'ordine numerico** delle righe, non la sequenza del file: nel sorgente le
   `DATA` possono stare "fuori posto" (il `READ` le cerca in ordine di programma e le legge tutte),
   ma il codice no.

Il file ora contiene una nota in testa alla zona dati (riga `1004`) che ricorda la regola 1, e la
numerazione e' stata riorganizzata come segue:

| vecchia riga | nuova riga | contenuto |
|---|---|---|
| `1121` + `1122` + `1141` | **115** + **116** | dentro `GOSUB 100`: carica i 16 byte dei pattern degli sprite, nasconde i due sprite e termina la lista (115), scrive pattern e colori (116), `RETURN` |
| `115` | **117** | `GOSUB 118:GOSUB 120:RETURN`, aggiorna entrambi gli sprite |
| `116` + `1161` + `1162` | **118** + **119** | posizione dello sprite 0 (omino) |
| `117` + `1171` | **120** + **121** | posizione dello sprite 1 (barile) |
| `120`-`122` (GAME OVER) | **125**-`127` | spostate in alto per liberare `120`/`121` agli sprite (aggiornata la chiamata della riga 58: `GOSUB 125`) |
| — | `1092`, `1093` | `DATA` dei due pattern degli sprite |
| — | `1004` | promemoria sulla contiguita' del corpo di `GOSUB 100` |

## 9.6 Righe cambiate rispetto alla versione congelata

| riga | versione a tile (congelata) | variante a sprite |
|---|---|---|
| 0 | `SCREEN 1:COLOR 1,15,15:VOLUME 0,15` | `SCREEN 1:COLOR 1,15,15:VOLUME 0,15` (identica: gli sprite 8x8 non ingranditi sono il default di SCREEN 1) |
| 1 | `DO(0)=-1:DO(1)=1:DI=DO(INT(RND(1)*2)):KEY 9,20,6` | `DO(0)=-1:DO(1)=1:DI=DO(INT(RND(1)*2))` (senza `KEY`: l'auto-repeat serviva solo a `INKEY`, §9.14) |
| 3 | `SC=1:CH=2:E1=0:E2=0:Z=16:J=8:E3=1:Q=10000:GOTO 10` | `...:GOSUB 146:GOTO 10` (carica la routine in linguaggio macchina dai `DATA`) |
| 17 | `T=VPEEK(S):VPOKE S,40` | `T=VPEEK(S):GOSUB 118` |
| 19 | `GOSUB 4:V=BA(Y):W=0:DO=DO(INT(RND(1)*2))` | `GOSUB 4:V=BA(Y):VPOKE V,0:W=0:DO=DO(INT(RND(1)*2)):GOSUB 117` (§9.13: non basta la `120`) |
| 20 | `PAUSE DL:K=INKEY(0):IF K=0 THEN 41` | `SYS AD:K=PEEK(SB)` (routine in ML: legge la matrice e non ha nessuna attesa, il `PAUSE DL` e' stato tolto, §9.14) |
| 26 | `IF VPEEK(S+32)=Z THEN VPOKE S,T:S=S+32:GOTO 40` | `IF VPEEK(S+32)=Z THEN S=S+32:GOTO 40` |
| 28 | `DI=-1:IF VPEEK(S+31)>1 THEN VPOKE S,T:S=S-1:GOTO 40` | `DI=-1:IF VPEEK(S+31)>1 THEN S=S-1:GOTO 40` |
| 29 | `IF T<>Z THEN VPOKE S,T:S=S+DI:T=VPEEK(S):GOTO 55` | `IF T<>Z THEN S=S+DI:T=VPEEK(S):GOTO 55` |
| 31 | `IF T=Z THEN VPOKE S,T:S=S-32:GOTO 40` | `IF T=Z THEN S=S-32:GOTO 40` |
| 33 | `DI=1:IF VPEEK(S+33)>1 THEN VPOKE S,T:S=S+1:GOTO 40` | `DI=1:IF VPEEK(S+33)>1 THEN S=S+1:GOTO 40` |
| 35 | `...:VPOKE S,T:S=S-32+DI:T=VPEEK(S):VPOKE S,40:IF T=24 THEN 55` | `SOUND 1,3996,5:S=S-32+DI:T=VPEEK(S):GOSUB 118:IF S=V THEN 55` (la `118` disegna l'omino nel **vertice del salto**) |
| 36 | `IF VPEEK(S+32)=24 THEN SS=SS+1000:GOSUB 95` | `IF S+32=V THEN SS=SS+1000:GOSUB 95` |
| 37 | `FOR N=1 TO 5:NEXT:VPOKE S,T:S=S+32+DI:T=VPEEK(S):VPOKE S,40` | `FOR N=1 TO 5:NEXT:S=S+32+DI:T=VPEEK(S):GOSUB 118` |
| 38 | `IF VPEEK(S+32)<2 THEN 55` | `IF VPEEK(S+32)<2 AND S+32<>V THEN 55` |
| 39 | `VPOKE S,40:SOUND 1,0,0:GOTO 41` | `SOUND 1,0,0:GOTO 41` |
| 40 | `SOUND 1,3730,1:T=VPEEK(S):VPOKE S,40` | `SOUND 1,3730,1:T=VPEEK(S)` |
| 41 | `IF T=41 THEN SS=SS+150:GOSUB 95:H=H+1:T=0:IF H=16 THEN 64` | `IF T=41 THEN SS=SS+150:VPOKE S,0:GOSUB 95:H=H+1:T=0:IF H=16 THEN 64` |
| 42 | `IF T=24 THEN 55` | `IF T=24 OR S=V THEN 55` (24 = pila, `S=V` = barile in movimento) |
| 45 | `VPOKE V,W:V=V+DO:W=VPEEK(V):VPOKE V,24` | `V=V+DO:W=VPEEK(V):GOSUB 117` |
| 48 | `IF W=40 THEN 55` | `IF V=S THEN 55` |
| 51 | `VPOKE V,0:GOTO 19` | `VPOKE 6916,208:GOTO 19` |
| 52 | `... THEN VPOKE S,T:S=S+32:T=VPEEK(S):VPOKE S,40` | `... THEN S=S+32:T=VPEEK(S):GOSUB 118` (la `118` fa **vedere la caduta** durante il suono di morte) |
| 55 | `SOUND 1,0,0:SO=255:IF T=24 THEN T=0` | `SOUND 1,0,0:SO=255:T=0` |
| 58 | `...CH=CH-1:IF CH<0 THEN GOSUB 120:END` | `...CH=CH-1:IF CH<0 THEN GOSUB 125:END` (GAME OVER spostata; il `NB=2` della quarta stesura e' stato tolto insieme a `INKEY`, §9.14) |
| 59 | `GOSUB 96:VPOKE V,W:Y=Y+1:IF W=40 THEN VPOKE V,T` | `GOSUB 96:VPOKE 6916,208:Y=Y+1` |
| 61 | `IF S>6842 THEN VPOKE S,T:GOTO 16` | `IF S>6842 THEN GOTO 16` |
| 62 | `VPOKE S,40:GOTO 19` | `GOTO 19` (il ridisegno e' passato alla riga `19`, ora `GOSUB 117`) |
| 70 | `CLS` | `CLS:VPOKE 6912,208:VPOKE 6916,208` |
| 125 | `CLS:LOCATE 8,10:PRINT "GAME OVER"` | `VPOKE 6912,208:VPOKE 6916,208:CLS:LOCATE 8,10:PRINT "GAME OVER"` (§9.13: il `CLS` cancella la name table, **non** gli sprite) |
| — | — | **`145`-`147`** (nuove): caricamento della routine in linguaggio macchina a `AD=30720` dai `DATA 1094-1111` (§9.14) |
| — | — | **`1094`-`1111`** (nuove): i 279 byte della routine di input, 16 per riga |

Tutte le altre righe sono identiche alla versione congelata (in particolare quelle della pila:
`4-7`, `74`, e il `VPOKE BA(N),24` che la ridisegna).

Il significato di `W` (riga 45) e' l'unico cambio di semantica: nella versione a tile era il tile
"salvato" sotto il barile, ora e' semplicemente **il tile della cella in cui il barile si trova**
(serve al deviatore, riga 47: `IF W=1 THEN DO=32`), che per la mappa statica e' lo stesso valore.

## 9.7 Le routine nuove (117-121)

```
117 GOSUB 118:GOSUB 120:RETURN
118 R=(S-6144)#32:C=S-6144-32*R:P=8*R-1:IF P<0 THEN P=0
119 VPOKE 6912,P:VPOKE 6913,8*C:VPOKE 6914,0:VPOKE 6915,1:RETURN
120 R=(V-6144)#32:C=V-6144-32*R:P=8*R-1:IF P<0 THEN P=0
121 VPOKE 6916,P:VPOKE 6917,8*C:VPOKE 6918,1:VPOKE 6919,11:RETURN
```

- `117` aggiorna **entrambi** gli sprite ed e' chiamata una volta per fotogramma dalla riga 45 e
  dalla riga 19 (nuovo barile);
- `118`/`119` piazzano l'omino: chiamata dal piazzamento (riga 17), dal **vertice del salto**
  (riga 35), dall'atterraggio (riga 37) e da ogni passo della **caduta** (riga 52);
  `120`/`121` piazzano il barile (righe 19, 45, 51);
- `#` e' la **divisione intera** (manuale BASIC, cap. 2.9-2.10); il modulo `%` non serve piu':
  nel calcolo del byte `Y` non compaiono piu' espressioni con `%`;
- ogni riga che puo' essere scartata da un `IF` **finisce** con l'istruzione condizionale
  (`118`/`120`: `...:IF P<0 THEN P=0`) e le `VPOKE` stanno su righe separate (`119`, `121`), cosi'
  la trappola del "tutto cio' che segue `THEN` e' condizionale" non puo' mordere;
- `IF P<0 THEN P=0` copre l'unico caso in cui il byte `Y` sarebbe negativo: l'omino sulla riga 0
  (ci arriva solo con i salti). Il valore `0` mette lo sprite una riga piu' in alto del tile e ne
  taglia una: e' un glitch di un pixel in un fotogramma raro, ed evita l'errore di `VPOKE` con
  argomento negativo;
- il barile non ha bisogno di limiti: si muove solo dentro il campo (righe 1..22, colonne 5..31).

## 9.8 Inizializzazione (dentro la subroutine 100)

```
114  DIM DN(10):FOR N=0 TO 10:READ DN(N):NEXT
115  FOR M=0 TO 15:READ DT:VPOKE 14336+M,DT:NEXT:VPOKE 6912,208:VPOKE 6920,208
116  VPOKE 6914,0:VPOKE 6915,1:VPOKE 6918,1:VPOKE 6919,11:RETURN
```

- `115` carica i 16 byte dei pattern degli sprite (prima gli 8 dell'omino da `DATA 1092`, poi gli 8
  del barile da `DATA 1093`), nasconde lo sprite 0 (`6912 = 208`) e mette il terminatore di lista
  (`6920 = 208`, entry 2);
- `116` scrive pattern (0 = omino, 1 = barile) e colori (1 = nero, 11 = giallo chiaro) e chiude la
  subroutine con `RETURN`;
- **l'ordine di lettura dei `DATA` va rispettato**: `110` legge 7 valori (`DATA 101`), `111` ne
  legge 56 (`DATA 102`-`108`), `113` ne legge 12 (`DATA 109`), `114` ne legge 11 (`DATA 1091`),
  `115` ne legge 16 (`DATA 1092`+`1093`). Le `DATA` sono "fuori posto" nel listato (i numeri
  `1091`-`1093` stanno fisicamente prima di `110`) ma questo non conta: il `READ` le scandisce in
  ordine di numero di riga, ed e' per questo che l'ordine dei valori e' corretto;
- non serve nessun `VREG`: i registri 5 e 6 li ha gia' messi `SCREEN 1` (§9.2).

## 9.9 Limiti noti e differenze visibili

| aspetto | versione a tile | variante a sprite |
|---|---|---|
| pila dei barili | tile | tile (identica) |
| barile in movimento | tile scritto nella name table | sprite 1, disegnato **sopra** i tile |
| omino | tile | sprite 0, disegnato sopra i tile |
| trasparenza | l'omino/barile coprono la cella con lo sfondo bianco | sotto gli sprite si vedono travi e scale (i pixel a 0 sono trasparenti) |
| borsa raccolta | sparisce quando l'omino si sposta | sparisce **subito** |
| barile che passa sopra la pila | il tile 24 viene riscritto (nessun effetto visibile) | lo sprite passa sopra i tile della pila: visivamente identico, perche' il disegno e' lo stesso |
| limite di 4 sprite per riga | non esiste (i tile non hanno limiti) | **rilevante**: con 2 soli sprite (omino e barile) non si tocca mai, ed e' il motivo per cui la pila resta a tile |
| `VPOKE` per fotogramma | 1-3 per l'omino + 1-2 per il barile | 3 per l'omino (`119`), 3 per il barile (`121`): stesso ordine di grandezza |
| riga 0 (barra di stato) | l'omino puo' scriverci un tile (glitch) | lo sprite ci finisce sopra, nessun glitch nella mappa |
| **input da tastiera** | `INKEY(0)`: un tasto per volta, con coda, auto-repeat e 1 cs di attesa (step 04 §4.5) | **routine in linguaggio macchina** a `30720` (`lm80c/ml/lm80c_keys.asm`, 441 µs per fotogramma), richiamata con `SYS AD`: matrice letta con `di`/`ei`, stato invece di evento, frecce e SPAZIO insieme, niente `KEY` ne' `NB`, tasti alternativi `J L I K Z` (§9.14) |

## 9.10 Procedura di prova sull'emulatore

### a) `prove/p07-sprites.bas`

Caricalo e lancialo. Prepara due riferimenti nella griglia dei tile: la **sagoma dell'omino (tile
40) sulla riga 10 dello schermo, colonna 5** e una **riga di travi (riga 12, colonne 5-25)** con il
**tile del barile (tile 24) in colonna 8**. Poi mette lo **sprite 0 sopra il tile dell'omino** e fa
scorrere lo **sprite 1 (il barile) sulla trave**, da colonna 5 a 25, una cella ogni 0,2 s.

Risultato atteso:

1. sulla riga 10 si vede **una sola figura nera**, non due figure spostate o sdoppiate: se lo sprite
   fosse disallineato si vedrebbe la sagoma del tile e quella dello sprite sfalsate di qualche pixel;
2. la sagoma che scorre sulla trave e' **giallo chiaro** (colore 11 = `$B`), lo stesso giallo del tile
   del barile: e' il colore corretto, preso dal 4o byte della SAT;
3. la riga 21 dello schermo mostra `X = ... COLONNA = ... TILE SOTTO = ...`:
   **`X` deve essere sempre `8 * COLONNA`** e `TILE SOTTO` deve essere **8** (trave) per tutte le
   colonne tranne la 8, dove deve valere **24** (il tile del barile): in quel momento lo sprite del
   barile passa **esattamente sopra** il tile del barile e i due disegni devono coincidere. E' la
   dimostrazione che sprite e griglia dei tile sono allineati al pixel;
4. la riga 22 mostra la SAT: il primo numero e' il byte `Y` dell'omino (**79**), il secondo la sua
   `X` (**40**), poi pattern (**0**) e colore (**1**); poi il barile: `Y` (**95**), `X` (che cambia
   mentre scorre), pattern (**1**), colore (**11**). All'avvio la riga deve leggere
   `79 40 0 1 95 40 1 11`;
5. premendo **H** il barile sparisce e nella riga 22 il suo byte `Y` (il 5o numero) diventa
   **208**; ripremendo **H** torna **95**;
6. premendo **SPAZIO** lo sprite 0 (omino) si sposta di 8 pixel a destra.

Se p07 funziona, il meccanismo (SAT, pattern, colori, allineamento) e' dimostrato: qualunque
problema residuo nel gioco e' nella logica, non nel VDP.

### a2) `prove/p08-matrice.bas` (input)

E' la prova dell'input in linguaggio macchina: carica la routine dai suoi `DATA` (la prima riga dello
schermo deve dire `routine ML caricata: 279 byte`) e poi mostra, aggiornandosi da sola:

- le **otto righe** della matrice come le legge la routine, con un `0` per ogni tasto premuto
  (`.` = non premuto, convenzione della matrice);
- `FLAGS`, `K` e lo stato dello SPAZIO del fotogramma precedente;
- il risultato del **modo test** (`SYS AD,codice` dei cinque comandi) e la legenda di
  riga/colonna dei tasti interessati.

Risultato atteso:

1. a riposo: le otto righe sono tutte `........`, `FLAG 0` e `K 0`; premendo SINISTRA compare uno `0`
   nella **riga 6** in **prima colonna**, con DESTRA in riga 6 **ultima colonna**, SU in riga 5 ultima
   colonna, GIU' in riga 5 prima colonna, SPAZIO in riga 0 **quinta colonna**;
2. **il punto della modifica**: tenendo premuta SINISTRA (riga 6, prima colonna) e premendo anche
   SPAZIO (riga 0, quinta colonna) **le due righe cambiano insieme** e `K` diventa **32**: e' la cosa
   che con `INKEY` non si poteva fare (lo sniffer si fermava alla prima riga con un tasto);
3. tenendo premuto SPAZIO, `K` vale 32 **solo al primo fotogramma** (fronte) e poi torna 0; con la
   freccia premuta insieme a SPAZIO ritorna il codice della freccia: si cammina mentre SPAZIO e'
   ancora giu';
4. in fondo allo schermo ci sono il **modo test** (`TEST 28:1 29:0 30:0 31:0 32:0`) e la legenda
   riga/colonna: un tasto che non risponde si riconosce subito perche' il suo `0` non compare in
   nessuna delle otto righe. Se invece **tutte** le righe mostrano `0` (e il gioco salta al primo
   fotogramma per poi inchiodarsi su GIU'), il sospetto e' l'ordine delle istruzioni di lettura: la
   porta e' **64**, non 65 (step 04 §4.5).

Se p08 torna, la lettura e' corretta: qualunque problema residuo nel gioco sta nella logica.

### b) il gioco `lo_scalatore_lm80c_sprites.bas`

Poi lancia il gioco con `RUN`. Risultato atteso: identico alla versione congelata (pila, travi,
scale, borse, punteggio, suoni, movimento, morte, livelli), con l'omino e il barile che si muovono
**come sprite**: si vedono travi e scale attraverso i pixel "vuoti" delle due sagome, e il barile che
esce dalla pila fa **sparire il tile** della cella di partenza (riga 19) e compare come sprite.

Punti da guardare con attenzione:

1. all'avvio l'omino compare in basso nella stessa posizione di prima (nessuno sprite "orfano" in
   alto a sinistra durante il disegno del livello: la riga 70 nasconde i due sprite prima del `CLS`);
2. il primo barile esce dalla pila e rotola come prima, con il suo sprite che copre via via le celle;
3. raccogliendo una borsa il simbolo sparisce immediatamente;
4. saltando sopra il barile si sente il bonus e si vedono i 1000 punti; toccandolo si muore;
5. morendo, il barile sparisce (compare il punteggio aggiornato) e ne esce uno nuovo dalla pila;
6. arrivando al livello successivo il livello si ridisegna e i due sprite ricompaiono al loro posto;
7. **saltando** si devono vedere *tre* posizioni distinte: partenza, vertice (una riga sopra e una
   colonna di lato) e atterraggio due colonne piu' in la' — se ne vedi solo due, la `GOSUB 118`
   della riga 35 non e' stata digitata (o la 37);
8. **morendo** l'omino deve **scendere di riga in riga** insieme al suono che cala (20 gradini), non
   restare fermo dove e' morto: e' la `GOSUB 118` della riga 52;
9. a **GAME OVER** su schermo devono restare solo la scritta e il punteggio: nessun omino ne' barile
   sopra la scritta (riga 125 che scrive `208` nei due byte `Y`);
10. **salto camminando** (il guadagno della matrice): tieni premuto SINISTRA (l'omino cammina) e
    premi SPAZIO -> deve **saltare verso sinistra** senza fermarsi; con `INKEY` era impossibile;
11. **niente salto infinito**: tenendo premuto SPAZIO l'omino salta **una volta**, non a ogni
    fotogramma (fronte dello SPAZIO, §9.14);
12. dopo la morte, se il giocatore tiene premuta una freccia, alla nuova vita l'omino **riparte
    subito** in quella direzione: e' voluto (e' quello che faceva il joystick dell'originale, lettura
    di stato) e non e' piu' il passo fantasma della quarta stesura.

### Esito (15/09/2026)

**Il gioco e' collaudato e funziona**: lanciata sul gioco la variante a sprite con l'input in
linguaggio macchina, la partita gira corretta dall'inizio alla fine (movimento e salto dell'omino,
barili, collisioni e morte, punteggio, vite, passaggio di livello, suoni, GAME OVER). La variante a
sprite e' quindi **giocabile**, non solo "da collaudare"; lo stato del port e' aggiornato in `task.md`
(prova **22** del report).

Con questo il **port e' completo**: la versione a tile resta congelata come referenza, la variante a
sprite e' la versione con gli sprite e la lettura della matrice in ML. Le due prove preparatorie
(`prove/p07-sprites.bas`, `prove/p08-matrice.bas`) non sono state rilanciate: restano nel repo come
diagnosi, utili se un giorno si tocca la SAT (§9.11) o la routine (§9.14), non come passi obbligatori
del collaudo.

Resta aperto solo il capitolo **taratura facoltativa** (step 08 §8.1-8.2): il ritmo del ciclo non e'
piu' tarabile (il `PAUSE DL` della variante a sprite e' stato tolto: contano il costo del giro e il
`SOUND` del passo), `tone` dei suoni se il timbro non convince, ordine di priorita' con due tasti
premuti, tasti accumulati nel buffer del DOS a fine partita.

## 9.11 Piano B (se gli sprite non si vedono o sono spostati)

1. **Non compaiono affatto**: lancia `prove/p07-sprites.bas`. Se li' gli sprite si vedono, il
   problema e' nel gioco e va cercato **nell'ordine numerico delle righe** (§9.5): un blocco di
   inizializzazione che finisce dopo il `RETURN` di `GOSUB 100` non viene mai eseguito. Se non si
   vedono nemmeno in `p07`, allora la strada e' il VDP: controlla con `PRINT VSTAT` se il VDP e' in
   modo grafico 1 e verifica i due registri con `SCREEN 1` ripetuto prima delle `VPOKE`.
2. **Compaiono ma spostati di una riga**: e' l'offset `-1` del byte `Y`: il port scrive `8*R-1`; per
   correggere senza toccare il resto basta cambiare in `8*R` nella riga `119` (omino) e `121`
   (barile).
3. **Compaiono neri/invisibili**: colore 0 = trasparente: controlla i byte 6915 (omino) e 6919
   (barile) = `1` e `11`.
4. **Il barile "lascia" il tile della pila**: e' voluto (riga 19 `VPOKE V,0`): senza quella scrittura
   si vedrebbero due barili, il tile e lo sprite.
5. **Il barile sparisce e non torna**: il terminatore della lista e' sullo sprite 0: se `6912 = 208`
   (riga 70 o riga 51/59) la lista si ferma prima dello sprite 1. Verifica che la riga 17
   (`GOSUB 118`) venga eseguita prima del primo fotogramma.

## 9.12 Verifiche fatte sul sorgente

- tutte le righe entro **88 caratteri** (limite del buffer d'ingresso del BASIC, manuale cap. 14);
- nessun numero di riga duplicato e nessuna riga del gioco a tile persa (confronto automatico riga
  per riga: le uniche differenze sono quelle della tabella §9.6, piu' le righe nuove `1092`, `1093`,
  `115`, `116`, `117`-`121`, `1004`);
- **ordine numerico verificato con uno script** (`lm80c/ml/verifica.mjs`: numeri di riga, lunghezze,
  target dei salti, `DATA` identici al binario, ingombro del listato sotto `$7800`): il corpo di
  `GOSUB 100` va da `100` a `116` senza buchi, le coppie
  `118`-`119` e `120`-`121` sono contigue, `125`-`127` (GAME OVER) sono dopo e non vengono
  attraversate da nessun percorso;
- tutti i target di `GOSUB`/`GOTO`/`THEN <numero>` esistono (controllo automatico);
- nessun `IF ... THEN <istruzioni multiple>` che dipenda dall'esecuzione della coda della riga;
- nessun residuo di gestione a tile dei due oggetti: non restano `VPOKE S,40` ne' `VPOKE V,24`
  (il solo `VPOKE V,0` della riga 19 e il `VPOKE S,0` della riga 41 sono voluti);
- `#` (divisione intera) verificato sul manuale BASIC cap. 2.9-2.10; il modulo `%` non e' piu' usato
  nelle routine degli sprite;
- **input in linguaggio macchina** (§9.14): le righe `145`-`147` stanno dopo il `RETURN` della
  schermata di GAME OVER (`127`) e non vengono attraversate da nessun percorso; il `GOSUB 146` e' nella
  riga `3`, prima di `GOTO 10`, quindi la routine e' caricata prima della prima lettura (riga 20);
  i `DATA 1094-1111` sono in fondo, dopo l'ultima `DATA` letta dal livello (`1093`), e i due listati
  che li contengono (gioco e `prove/p08`) sono stati confrontati **byte per byte** con
  `lm80c/ml/lm80c_keys.bin`; il caricamento li consuma **tutti**, quindi la riga `146` chiude con
  `RESTORE 101` (`prove/p08` con `RESTORE 1000`), altrimenti i `READ` delle righe 110-115 finiscono
  con `OUT OF DATA ERROR` (la storia del difetto e' in step 08 §8.2e, il controllo automatico che lo
  sorveglia in `lm80c/ml/verifica.mjs`); non resta nessun `INKEY`, nessun `KEY`, nessun `INP` e
  nessun `NB` nel listato del gioco;
- la `K` prodotta dalla routine e' stata verificata **eseguendola sul core dell'emulatore** (33
  controlli, tutti superati: cursori, alias `J L I K Z`, fronte dello spazio, priorita', modo test,
  registri e stack conservati) e poggia sugli stessi casi utili controllati a tavolino: SINISTRA 28,
  DESTRA 29, SU 30, GIU' 31, SPAZIO (fronte) 32, SINISTRA+GIU' 31, SINISTRA+SU 28,
  SINISTRA+SPAZIO 32 (fronte) e poi 28 (tenuto), SPAZIO tenuto da solo 0.

## 9.13 Seconda lezione: il disegno "dentro la riga" (salto, caduta, GAME OVER)

Prima prova sull'emulatore: il gioco gira, ma

1. del **salto** si vedono solo la cella di partenza e quella d'arrivo, mai il vertice;
2. la **caduta** dell'omino (l'animazione che accompagna il suono di morte che scende) non si vede:
   l'omino resta immobile dove e' morto;
3. a **fine gioco** gli sprite dell'omino e del barile restano sullo schermo sopra la scritta.

**Causa unica delle 1 e 2** (terza regola di §9.5 applicata al contrario): nella conversione a sprite
ho tolto le scritture di tile che disegnavano l'omino *dentro* una riga — la `VPOKE S,40` del vertice
del salto (riga 35), quella dell'atterraggio (37) e quella di ogni gradino della caduta (52) —
**senza mettere un `GOSUB 118` al loro posto**. Nel port a sprite l'omino viene ridisegnato una volta
sola per fotogramma, alla fine (riga 45 → `GOSUB 117`); tutte le posizioni intermedie di un fotogramma
non venivano quindi mai mostrate. E' la differenza strutturale fra le due versioni: con i tile una
`VPOKE` disegna **subito**, con gli sprite serve una chiamata esplicita.

Errore di conversione, non di progetto: nella riga 17 (piazzamento al primo fotogramma) la
`VPOKE S,40` era stata sostituita bene con `GOSUB 118`, mentre nelle righe 35, 37 e 52 — le tre
"cancella e ridisegna" del movimento — sono sparite **entrambe** le scritture, tanto che anche il
confronto automatico riga per riga di §9.12 le ha date per buone: guardava che non restassero
`VPOKE S,40`, non che al loro posto ci fosse un disegno dello sprite.

**La correzione** (una chiamata per ogni punto in cui l'omino cambia cella e deve essere visto li'):

```
35 SOUND 1,3996,5:S=S-32+DI:T=VPEEK(S):GOSUB 118:IF S=V THEN 55
37 FOR N=1 TO 5:NEXT:S=S+32+DI:T=VPEEK(S):GOSUB 118
52 IF VPEEK(S+32)<>J AND S<6853 THEN S=S+32:T=VPEEK(S):GOSUB 118
19 GOSUB 4:V=BA(Y):VPOKE V,0:W=0:DO=DO(INT(RND(1)*2)):GOSUB 117
125 VPOKE 6912,208:VPOKE 6916,208:CLS:LOCATE 8,10:PRINT "GAME OVER"
```

Dettaglio per dettaglio:

- **riga 35** (vertice del salto): e' il fotogramma che mancava del tutto. Il ciclo di ritardo
  `FOR N=1 TO 5:NEXT` che lo tiene a schermo e' nella riga **37**: per questo la `GOSUB 118` va messa
  *prima* della `IF S=V THEN 55`, cioe' subito dopo lo spostamento, e non alla fine del salto;
- **riga 37** (atterraggio) e **riga 52** (caduta): stessa cosa. La 52 non e' un caso a parte, e' il
  cuore dell'animazione di morte: l'originale fa scendere l'omino di una riga per ogni gradino del
  suono, e ogni gradino e' un fotogramma da disegnare (§7.3, righe 55-57);
- **riga 62 → 19**: dopo la caduta il gioco riprende da 19, che piazzava **solo** il barile
  (`GOSUB 120`). Con i tile ci pensava la `VPOKE S,40` della riga 62; con gli sprite serviva un
  ridisegno dell'omino, e la soluzione piu' corta e' `GOSUB 117` (entrambi) nella 19, che copre sia
  il risveglio dopo la morte sia il barile uscito dallo schermo (riga 51);
- **riga 125**: `CLS` cancella la **name table**, non gli sprite: la SAT e' indipendente e i due
  sprite continuano a essere disegnati dal VDP. Vanno nascosti scrivendo `208` ($D0, terminatore)
  nel byte `Y` dei due sprite, esattamente come fanno la riga 70 (nuovo livello) e le righe 51/59
  (barile/omino "sparito"), ora anche all'inizio della schermata di GAME OVER.

Nota di metodo: **un `GOSUB` che disegna va messo nella posizione in cui il disegno deve comparire,
non alla fine del fotogramma.** La versione a tile non aveva questo problema solo perche' la `POKE`
disegnava nel punto esatto in cui stava scritta.

Verifica dopo la correzione: il salto mostra tre posizioni (partenza, vertice, atterraggio, in due
fotogrammi distinti); la morte mostra l'omino che scende di riga in riga insieme al suono; a GAME OVER
restano solo la scritta e il punteggio su schermo pulito.

## 9.14 L'input passa a una routine in linguaggio macchina: niente piu' `INKEY`

Ultima differenza rispetto alla versione a tile: **la variante a sprite non usa piu' `INKEY`**, e non
lo fa nemmeno in BASIC. La lettura della matrice e' una **routine in linguaggio macchina** (Z80),
scritta in `lm80c/ml/lm80c_keys.asm`, assemblata con z88dk (`z80asm -b`) e caricata dai `DATA`:

```
3 ...:Q=10000:GOSUB 146:GOTO 10
20 SYS AD:K=PEEK(SB)
145 REM input in ML: ingresso a SYS AD, blocco di stato in coda (K in PEEK(SB))
146 AD=30720:RESTORE 1094:READ LN:FOR N=0 TO LN-1:READ DT:POKE AD+N,DT:NEXT:RESTORE 101
147 SB=AD+268:RETURN
1094-1111 DATA della routine (279 byte, il primo valore e' la lunghezza)
```

La catena completa della tastiera sul firmware (sniffer, `KBMAP`, `TMPKEYBFR`, limiti di `INKEY`) e' in
**step 04 §4.5**; il protocollo della routine (blocco di stato, alias, priorita', fronte dello spazio,
modo test, tempi e verifica) in **step 04 §4.6**. Qui ci sono solo le scelte specifiche della variante
a sprite.

Perche' in linguaggio macchina e non in BASIC: la sequenza di lettura di una riga e' quella del
firmware (`READKBLN` di `include/psg/psg-1.02.asm`, ripresa in step 04 §4.5) — `OUT 64,15` seleziona
il registro 15 (port B), `OUT 65,mask` attiva la riga (bit a 0 = riga attiva), `OUT 64,14` seleziona il
registro 14 (port A) e **`INP(64)`** legge le colonne (bit a 0 = tasto premuto; **si legge da 64, non
da 65**, che e' il ciclo *inactive*) — ma da BASIC lo sniffer del firmware, che usa **gli stessi port**
ogni 20 ms, puo' intromettersi nella scansione. Con `di`/`ei` attorno alle otto letture la finestra non
esiste piu': e' il motivo per cui questa parte e' **uscita dal listato BASIC**. Le righe `130`-`143`
(la precedente versione in `OUT`/`INP`, con la sua verifica del registro 15 e i ritentativi) sono state
**tolte**: restano descritte in step 04 §4.6 come cronologia.

Cosa risolve rispetto a `INKEY` (i problemi sono elencati in step 04 §4.5 e step 08 §8.2b-8.2c):

| problema di `INKEY` | qui |
|---|---|
| un tasto per volta (la scansione dello sniffer si ferma alla prima riga con un tasto, e le frecce laterali battono SU/GIU'/SPAZIO) | **risolto**: le otto righe si leggono nella stessa scansione, quindi si puo' **saltare mentre si cammina** |
| evento invece di stato (legge e azzera) | **risolto**: la lettura e' uno stato; l'omino fa un passo a ogni fotogramma in cui il tasto e' premuto |
| passo fantasma al rilascio (`TMPKEYBFR` non azzerato) | **risolto**: non c'e' coda; `NB` e' stato tolto dalla riga 58 (e dalla 20) |
| quantizzazione a 20 ms + 1 cs di attesa incorporata | **risolto**: si legge al momento, senza attesa |
| `KEY 9,8,2` da tarare | **non serve piu'**: la riga 1 non lo ha piu' |
| letture disturbate dallo sniffer | **risolto alla radice**: `di`/`ei` (in BASIC restava 0,6-0,75 % di fotogrammi con `K` sbagliato) |
| tasti scomodi da raggiungere (niente cursori a T rovesciata sul C16) | **tasti alternativi**: ogni comando risponde anche a `J L I K Z` (tabella in step 04 §4.6) |

Le due scelte da conoscere (si cambiano nel sorgente assembly, `KFLAGS`/`KCALC`, e poi va ricompilata):

- **priorita' fra due tasti premuti**: l'ultimo test vince, quindi
  **SPAZIO > GIU' > SINISTRA > SU > DESTRA**. E' lo stesso ordine di controllo della routine in
  linguaggio macchina dell'originale (`on peek(1) goto 35,26,28,31,33` = *fire, sotto, sinistra,
  sopra, destra*): con GIU' e SINISTRA premuti insieme l'omino **scende** (come sul VIC), con SU e
  SINISTRA insieme **va a sinistra**. Per far vincere le laterali sulle verticali basta scambiare
  l'ordine dei `bit` in `KCALC`;
- **fronte dello SPAZIO** (`SB+10` tiene lo stato precedente): `K=32` scatta solo al passaggio 0 -> 1.
  Serve perche' lo **stato** non ha un "momento"; senza fronte, tenendo premuto SPAZIO l'omino
  salterebbe a ogni fotogramma e il salto avanza di **due colonne**, quindi volerebbe. Con il fronte:
  tenendo SPAZIO e una freccia si salta una volta e poi si cammina (e SPAZIO, tornando a 0, si riarma
  da solo). Lo stato di questo fronte sopravvive alla sequenza di morte (la routine non viene
  richiamata mentre l'omino muore), quindi **non** c'e' il rischio di un salto involontario alla nuova
  vita: se lo spazio era premuto, resta "premuto" e il fronte e' gia' stato consumato.

Dettagli:

- **`K`** resta lo **stesso codice** di prima (28 SINISTRA, 29 DESTRA, 30 SU, 31 GIU', 32 SPAZIO):
  le righe `21`-`34` del gioco non sono state toccate, cambia solo chi fornisce il valore. Il gioco
  **non** ha bisogno di sapere nulla della matrice: legge `K` e basta;
- le righe **145-147** caricano la routine con `POKE` dai `DATA 1094-1111` e stanno dopo il `RETURN`
  della schermata di GAME OVER (`127`): nessun percorso le attraversa (regola 1 di §9.5), e la `GOSUB`
  che le chiama e' nella riga `3`, prima di `GOTO 10`;
- i `DATA` stanno **in fondo** (dopo la `1093`, l'ultima letta dal livello), cosi' `verifica.mjs` puo'
  riconoscere il blocco della routine come coda dell'elenco: ma il caricamento se li legge **tutti**,
  percio' la riga `146` chiude con `RESTORE 101` che rimette il puntatore sul primo `DATA` del gioco
  (riga `101`) prima del `GOSUB 100` della riga 10. Senza, il primo `READ` del gioco muore con
  `OUT OF DATA ERROR IN LINE 110`: e' il **primo difetto trovato al collaudo**, raccontato in
  step 08 §8.2e. Il puntatore dei `DATA` e' l'unico pezzo di questo listato che dipende dall'**ordine
di esecuzione** e non dal testo, quindi ora e' simulato da `lm80c/ml/verifica.mjs`;
- il nome `AD` (e `LN`, `DT`, `N` usati dal caricatore) non collide con niente: nessuno dei tre e' un
  nome usato dal gioco, e `AD` non e' una parola riservata (regola dei nomi di step 01 §1.1);
- la routine non viene mai toccata da `NEW`, `CLEAR` o `RUN`: sta fuori dall'area di BASIC. Se si
  modifica il sorgente assembly **vanno rigenerati i `DATA` in tutti e due i listati** che li
  contengono (il gioco e `prove/p08`).

**Tempi**: `INKEY(0)` aveva 1 centesimo di attesa incorporata che ora non c'e' piu'; al suo posto ci
sono le otto letture della matrice e il calcolo di `K`, in tutto **179 istruzioni Z80 = 441 µs**
(misurati sul core dell'emulatore). Nella variante a sprite e' stato tolto anche il `PAUSE DL` della
riga 20 (`DL` non esiste piu'): il ciclo gira alla **massima velocita'** consentita dall'interprete,
senza nessuna attesa per fotogramma. Il ritmo lo decidono ora il costo del giro e il `SOUND` del passo
(10 ms, riga 40), che resta il tetto della velocita' dell'omino mentre i barili, che non hanno suono,
vanno piu' svelto (step 08 §8.1 e §8.2d). Resta un'avvertenza, annotata in step 08 §8.6: i tasti
premuti finiscono comunque nel buffer di input del DOS (lo faceva anche `INKEY`), quindi dopo una
partita lunga il prompt BASIC puo' mostrare i codici accumulati. Il disturbo dello sniffer invece
**non** e' piu' possibile.
