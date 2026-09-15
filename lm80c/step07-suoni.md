# Step 07 - Suoni: da POKE sul VIC-20 a SOUND/VOLUME sul PSG

## Obiettivo

Convertire i suoni che l'originale produce con `POKE 36878/36876/36874/36877/36876` (volume,
voce 1, voce 2 del VIC-20) nei comandi del PSG del LM80C: `VOLUME chn,val` e `SOUND ch[,tone[,dur]]`.

## 7.1 Tabella di conversione

| suono | originale | port | frequenza/tone |
|---|---|---|---|
| volume generale | `poke36878,15` (riga 0) | `VOLUME 0,15` (riga 0) | massimo su tutti i canali (logaritmico) |
| salto dell'omino | `poke36876,240` (riga 35) | `SOUND 1,3996,5` (riga 35) | 1152 Hz (VIC 1154,4 Hz = D6) per 0,05 s |
| passo dell'omino | `poke36876,200:poke36876,0` (riga 40) | `SOUND 1,3730,1` (riga 40) | 314,8 Hz (VIC 314,8 Hz = D#4) per 0,01 s: **durata minima utile** (1 = 10 ms; **0 = suono infinito**, da non usare) |
| morte (tono che cala) | `poke36876,0:so=250 ... poke36874,so:...:so=so-5:ifso>150then56` (righe 55-57) | `SOUND 1,0,0:SO=255 ... SO=SO-5:SOUND 1,4096-INT(26.6112*(255-SO)),0:...:IF SO>155 THEN 56` (righe 55-57) | da 865,8 Hz (A5) a 43,3 Hz (F1) in 20 passi, come sul VIC-20: vedi §7.3 |
| bonus di fine livello (rumore + rampa) | `poke36877,250:form=240to250:poke36876,m:next:poke36876,0:poke36877,0` (riga 66) | `SOUND 4,17` (fine riga 65) + `FOR I=0 TO 10:SOUND 1,DN(I),1:NEXT:SOUND 0:VOLUME 0,15` (riga 66), con `DN()` letta dai `DATA` 1091 | rumore a 6776 Hz (VIC 6928 Hz) + rampa **in salita** da 1152 a 3491 Hz (VIC 1154 -> 3464 Hz) |
| silenzio | `poke36874,0` / `poke36876,0` / `poke36877,0` (righe 55, 57, 58) | `SOUND 1,0,0` (canale 1) e `SOUND 0:VOLUME 0,15` (tutti i canali) | `tone=0` interrompe subito |

## 7.2 Sintassi di `SOUND`: tre forme diverse

Verificata sul manuale BASIC (capitolo `SOUND`, pag. 73-74) e sul firmware `basic-1.14.asm`
(routine `SOUND`, `NOISUP`, `CTSNDC`):

| forma | sintassi | parametri | note |
|---|---|---|---|
| tono | `SOUND ch,tone,dur` | **3, tutti obbligatori** | il parser esige una `,` dopo il tono e legge la durata (`CHKSYN ','` + `GETNUM`), quindi `SOUND 1,0` da' errore di sintassi: va scritto `SOUND 1,0,0` |
| rumore | `SOUND ch,tone` | **2, e la riga deve finire li'** | i canali 4-6 sono il rumore dei canali PSG 1-3; dopo la frequenza il parser pretende la fine della riga (`call GETCHR` + `jp NZ,SNERR`), quindi `SOUND 4,10,0` da' errore (troppi parametri) e anche `SOUND 4,10:...` da' errore (c'e' altro dopo); la durata non esiste per il rumore |
| reset | `SOUND 0` | **1** | caso speciale (`CLRPSGREGS`): spegne toni, rumori ed envelope e **azzera il volume di tutti i canali** |

Conseguenza importante per il port: l'originale spegneva i suoni con `poke36874,0` (una voce alla
volta, senza toccare il volume), mentre `SOUND 0` **azzera anche i volumi**. Nel port ogni
`SOUND 0` e' quindi seguito da `VOLUME 0,15`, altrimenti dal primo silenzio in poi (prima morte o
primo bonus di livello) non si sentirebbe piu' nulla:

```
39 VPOKE S,40:SOUND 1,0,0:GOTO 41     <- dopo un tono si puo' continuare la riga
55 SOUND 1,0,0:...                    <- era poke36874,0 / poke36876,0
58 SOUND 0:VOLUME 0,15:CH=CH-1:...    <- fine del suono della morte: azzera e rimette il volume
65 FOR N=Y+1 TO 11:...:GOSUB 98:SOUND 4,10   <- il rumore chiude la riga (niente dopo)
66 FOR M=3800 TO 3900 STEP 10:SOUND 1,M,1:NEXT:SOUND 0:VOLUME 0,15:NEXT
```

(`SOUND 1,0,0`: tono 0 con durata 0 = canale 1 azzerato e silenzioso, cioe' l'equivalente del
`poke36874,0` dell'originale.)

## 7.3 Il suono della morte: nota di partenza e nota di arrivo sul VIC-20

L'originale spegne la voce 3 (`poke36876,0`) e fa scendere il tono **sulla voce 1**, cioe' il
registro **36874** (`$900A`), che e' la voce *bass* del VIC 6560/6561:

```
55 poke36876,0:so=250
56 poke36874,so:...            <- voce 1 = 36874
57 forn=1to17:next:so=so-5:ifso>150then56
```

Valori usati: `so` = **250, 245, 240 ... 155** (20 valori, passo -5; il ciclo si ferma quando
`so<=150`), quindi con l'incremento di +5 il port usa `SO=255` come punto di partenza.

**Formula del VIC-20.** Il valore scritto nel registro e' `128 + X` (il bit 7 accende la voce) e la
frequenza e' `freq = clock / (127 - X)`, cioe'

```
freq = C / (255 - valore)
```

con `C` costante per voce e sistema (VIC-20 PRG pag. 216-217): **voce 1 = 4329 (PAL) / 3995 (NTSC)**,
voce 2 = 8658/7990, voce 3 (36876, usata da passo e salto) = 17316/15980.

| valore registro (voce 1) | frequenza PAL | nota |
|---|---|---|
| 250 (inizio) | 4329/5 = **865,8 Hz** | **A5** (880 Hz) |
| 225 | 4329/30 = 144,3 Hz | D3 (146,8 Hz) |
| 200 | 4329/55 = 78,7 Hz | D#2 (77,8 Hz) |
| 175 | 4329/80 = 54,1 Hz | A1 (55 Hz) |
| 155 (fine) | 4329/100 = **43,3 Hz** | **F1** (43,65 Hz) |

**Conversione sul PSG.** Da `tone = 4096 - 115200/freq` e da `freq = 4329/(255-v)` segue
`tone = 4096 - (115200/4329)*(255-v) = 4096 - 26,6112*(255-v)`, che e' esattamente quello che fa la
riga 56 del port:

```
55 SOUND 1,0,0:SO=255:IF T=24 THEN T=0
56 SO=SO-5:SOUND 1,4096-INT(26.6112*(255-SO)),0:GOSUB 52
57 FOR N=1 TO 17:NEXT:IF SO>155 THEN 56
```

Il codice ricalca quindi l'originale riga per riga (`so=250 ... so=so-5 ... ifso>150`), con la sola
trasformazione della frequenza: 250 -> `tone` 3963 (866,2 Hz) e 155 -> `tone` 1435 (43,3 Hz).

**Il rumore del bonus.** Il registro `36877` (`$900D`) e' la voce 4 e vale la stessa formula
`freq = C / (127 - X)`, ma con un clock **doppio** rispetto al soprano:

| canale VIC | clock NTSC | clock PAL |
|---|---|---|
| bass (`36874`) | 3995 | 4329 |
| alto (`36875`) | 7990 | 8659 |
| soprano (`36876`) | 15980 | 17320 |
| **noise (`36877`)** | **31960** | **34640** |

Con `poke36877,250` (X = 122) si ha `34640/5` = **6928 Hz**; sul PSG la frequenza del rumore e'
`115200/tone`, quindi il valore corrispondente e' `tone = 115200/6928 = 16,6` -> **17** (6776 Hz).
Il primo tentativo usava `SOUND 4,10`, cioe' 11520 Hz: un sibilo molto piu' acuto e sottile, ed e'
la differenza che si sente di piu' in questo suono, perche' il rumore resta acceso per tutta la
rampa.

La prima stesura del port usava 4050 -> 3550, cioe' 2504 Hz -> 211 Hz: era **~18 semitoni troppo
alto all'inizio e ~27 alla fine** (il PSG arrivava a un fischio, il VIC a un tonfo grave). Anche il
numero di passi era sbagliato (34 invece di 20), percio' l'animazione di morte durava troppo.

## 7.4 Tabella delle frequenze reali del VIC-20 e dei `tone` del port

Tutte le frequenze sono calcolate con `freq = C / (255 - valore)` e convertite in `tone` con
`tone = 4096 - 115200/freq` (arrotondato). PAL: C = 4329 per la voce 1, 17316 per la voce 3.

| suono | registro VIC | valore | frequenza VIC | nota | `tone` del port | frequenza effettiva PSG |
|---|---|---|---|---|---|---|
| passo dell'omino | `36876` (voce 3) | 200 | 17316/55 = 314,8 Hz | D#4 | **3730** | 314,8 Hz |
| salto dell'omino | `36876` (voce 3) | 240 | 17316/15 = 1154,4 Hz | ~D6 | **3996** | 1152 Hz |
| bonus: rumore | `36877` (voce 4) | 250 | 34640/5 = 6928,0 Hz | sibilo | **17** | 6776 Hz |
| bonus: inizio rampa | `36876` (voce 3) | 240 | 17320/15 = 1154,7 Hz | ~D6 | **3996** | 1152 Hz |
| bonus: fine rampa | `36876` (voce 3) | 250 | 17320/5 = 3464,0 Hz | ~A7 | **4063** | 3490,9 Hz |
| morte: inizio | `36874` (voce 1) | 250 | 4329/5 = 865,8 Hz | A5 | **3963** | 866,2 Hz |
| morte: passo intermedio | `36874` (voce 1) | 200 | 4329/55 = 78,7 Hz | D#2 | 2633 | 78,7 Hz |
| morte: fine | `36874` (voce 1) | 155 | 4329/100 = 43,3 Hz | F1 | **1435** | 43,3 Hz |

Le due voci non usate dal gioco: `36875` (voce 2) e, come tono, `36877` (voce 4 = rumore, usata
solo per il bonus di fine livello).

## 7.5 Perche' i valori sono diversi

- VIC-20: `36874` (voce 1), `36876` (voce 3) e `36877` (voce 4 = rumore) sono i registri dei
  suoni, `36878` il volume. La scala delle frequenze **non e' lineare**: `freq = C / (255 - valore)`
  con `C` costante per voce (PAL: 4329 per la voce 1, 17316 per la voce 3) e i valori utili in
  pratica 128..255, con 0/128 che fermano la voce (bit 7 = voce accesa).
- LM80C: `SOUND ch,tone,dur` con `freq = 1843200 / 16 / (4096 - tone)`: scala **lineare** di 4096
  passi, `dur` in centesimi di secondo (0 = infinita) e `tone = 0` = stop immediato.
  La formula inversa e' `tone = 4096 - 115200/freq`, con cui i valori del VIC si convertono uno per
  uno (vedi la tabella di §7.4): e' esattamente cosi' che sono stati tarati i suoni del port.

Tabella dei `tone` usati dal port (tutti sul canale 1 del PSG, tranne il rumore):

| `tone` | frequenza | suono |
|---|---|---|
| 3730 | 314,8 Hz | passo dell'omino (durata 1 = 10 ms) |
| 3996 | 1152 Hz | salto dell'omino (durata 5 = 50 ms) |
| 3963 -> 1435 | 866 Hz -> 43,3 Hz | morte, 20 passi (tabella di §7.4) |
| 3996 -> 4063 | 1152 Hz -> 3491 Hz | rampa in salita del bonus di fine livello (11 valori, `DATA` 1091, registro VIC 240 -> 250) |
| `SOUND 4,17` (rumore) | 6776 Hz (`Fnoise = 115200/tone`) | bonus di fine livello (VIC `36877,250` = 6928 Hz) |

Due dettagli che valgono per tutti i suoni:

- `VOLUME` deve essere invocato **prima** di `SOUND`, altrimenti non si sente nulla: il port lo fa
  una sola volta nella riga 0, e non lo azzera mai.
- `SOUND 1,SO,0` (durata 0 = infinita) viene rimpiazzato a ogni iterazione del ciclo della morte
  dal `SOUND` successivo: e' cosi' che si ottiene la discesa continua, come il VIC con il suo
  `poke36874,so` ripetuto.

## 7.6 Ritmo del suono della morte

L'originale cala di 5 unita' ogni `forn=1to17:next` a partire da 250 e si ferma a 150 (21 passi).
Il port cala di 15 ogni `FOR N=1 TO 17:NEXT` da 4050 a 3550 (34 passi): il suono e' quindi piu'
lungo. Se risulta troppo lungo o troppo corto, si cambiano il passo (`SO=SO-15`) e/o il numero di
iterazioni del ciclo di ritardo (riga 57): sono gli stessi numeri da ritoccare per tarare la
durata dell'animazione di morte (step 08).

## 7.7 Prova sull'emulatore

1. Lancia `lm80c/prove/p06-suoni.bas` e premi 1..5: deve far sentire i cinque suoni del gioco
   (passo, salto, morte, bonus, scala). Se non senti nulla, controlla di aver lanciato lo step 02
   (il `VOLUME` sta nella riga 0 del gioco) e il volume dell'emulatore.
2. Nel gioco verifica: beep a ogni passo, tono piu' acuto e breve al salto, discesa continua alla
   morte, rumore + rampa quando si completa un livello.
3. Verifica che il suono della morte **finisca** e non resti appeso dopo la perdita della vita
   (riga 58: `SOUND 0`) e che il bonus di fine livello non lasci il rumore acceso (riga 66 termina
   con `SOUND 0`).

## 7.8 Report

Riporta per ogni suono: se si sente, se dura troppo/troppo poco e se il timbro e' accettabile
(per esempio "il salto e' troppo acuto", "la morte e' troppo lunga"). Con queste indicazioni si
ritoccano i `tone` e i cicli di ritardo.
