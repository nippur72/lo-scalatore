# Step 05 - Barili, collisioni, morte e correzioni

## Obiettivo

Convertire la logica di gioco dell'originale (righe 17-21, 35-53 e 55-68: generazione dei barili,
passi, salto, borsa, morte, conteggio dei barili a fine livello) e applicare le correzioni ai bug
noti del listato VIC-20. Input e movimento dell'omino sono nello step 04, punteggio/vite/livelli
nello step 06, suoni nello step 07.

## 5.1 Generazione e movimento del barile

| originale | port | nota |
|---|---|---|
| `19 v=7712+b(y):w=62:do=do(int(rnd(1)*2))` | `19 GOSUB 4:V=BA(Y):W=0:DO=DO(INT(RND(1)*2))` | `W=0` = "sotto il barile c'e' spazio" (era 62) |
| `45 pokev,w:...:v=v+do:w=peek(v):pokev,60` | `45 VPOKE V,W:V=V+DO:W=VPEEK(V):VPOKE V,24` | `VPOKE V,W` rimette a posto il tile lasciato |
| `46 ifdo=22andpeek(v+22)=56then...` | `46 IF DO=32 AND VPEEK(V+32)=J THEN ...` | a fine trave il barile scende e cambia direzione |
| `47 ifw=63thendo=22` | `47 IF W=1 THEN DO=32` | il deviatore invisibile (1) fa cadere il barile |
| `48 ifw=58then55` | `48 IF W=40 THEN 55` | il tile sotto e' l'omino: barile addosso = morte |
| `49 ifv<8164then20` | `49 IF V<6853 THEN 20` | `6853` = inizio riga 22 (bordo basso del campo) |
| `51 pokev,62:goto19` | `51 VPOKE V,0:GOTO 19` | il barile esce dal campo: nuovo barile dalla pila |
| `59 print"{home}{rvon}"tab(14)ch:pokev,w:...` | `59 GOSUB 96:VPOKE V,W:Y=Y+1:IF W=40 THEN VPOKE V,T` | dopo la morte ridisegna vite e livello (`GOSUB 96`, step 06) e rimette a posto il tile sotto il barile (che era l'omino) |
| `60 ify>10then15` | `60 IF Y>10 THEN 15` | 11 barili passati = nuovo round |

Il barile e' il tile 24: `J` (8) e' la trave, `Z` (16) la scala, `W` il tile che il barile trovava
sotto di se'.

## 5.2 Collisioni dell'omino

| originale | port | nota |
|---|---|---|
| `ifpeek(s+22)=z` | `IF VPEEK(S+32)=Z` | sotto c'e' una scala: si puo' scendere |
| `ifpeek(s+21)<62` | `IF VPEEK(S+31)>1` | in VIC `<62` escludeva spazio (62) e deviatore (63); qui i codici sono 0 e 1, quindi `>1` = cella solida |
| `ifpeek(s+23)<62` | `IF VPEEK(S+33)>1` | idem verso destra |
| `ifpeek(s+22)=60` | `IF VPEEK(S+32)=24` | sotto c'e' un barile: saltandolo si prendono 1000 punti |
| `ifpeek(s+22)>61` | `IF VPEEK(S+32)<2` | atterrando su spazio (0) o deviatore (1) si muore |
| `ift=61then ss=ss+150:...:h=h+1:t=62` | `IF T=41 THEN SS=SS+150:GOSUB 95:H=H+1:T=0` | borsa raccolta: 150 punti, `T` torna spazio |
| `ift=60then55` | `IF T=24 THEN 55` | il tile sotto l'omino e' un barile: morte |
| `gosub98` | `43 GOSUB 98` | controllo del bonus vita (step 06) |

Il salto (righe 35-39 del port) e' la sequenza dell'originale con gli stessi spostamenti
(`S-32+DI` prima, `S+32+DI` dopo) e i suoni sostituiti (step 07): sale di un gradino nella
direzione di marcia, raccoglie il barile saltato, ricade e muore se sotto trova spazio.

## 5.3 Correzione: i barili non devono uscire dalla pila se il barile non c'e' piu'

Nell'originale la riga 19 fa `v=7712+b(y)` **senza verificare** che il barile in quella posizione
della pila sia ancora presente: dopo che i 12 barili sono rotolati via, un nuovo barile compariva
dal nulla (a volte sopra l'omino). Il port aggiunge la routine 4-9, chiamata con `GOSUB 4`:

```
3 ...:Q=10000:GOTO 10      <- la 3 non deve "cadere" nella routine 4-9
4 IF Y>11 THEN 64
5 IF VPEEK(BA(Y))=24 THEN 9
6 Y=Y+1
7 GOTO 4
9 RETURN
...
19 GOSUB 4:V=BA(Y):...     <- chiamata prima di generare il barile
...
64 IF Y>10 THEN 67         <- era IF Y=11 (vedi sotto)
```

- `Y` e' l'indice del barile della pila da cui parte il nuovo barile;
- se il tile in `BA(Y)` non e' piu' un barile (24) si passa al successivo, fino a trovarne uno ancora presente;
- se nessuno dei 12 e' presente (`Y>11`) il round e' finito: si va a 64 come quando si superano 11 barili.

Due dettagli indispensabili perche' la routine funzioni (erano fonti di `BAD SUBSCRIPT ERROR`):

1. **linea 3 -> `GOTO 10`**: nell'originale dopo la riga 3 si eseguiva la 10; inserendo le righe 4-9
   subito dopo la 3, il programma al via entrava nella routine **prima** che la subroutine 100 avesse
   riempito `BA()` con gli indirizzi della pila. Con `BA()` vuoto tutti i valori sono 0, la ricerca
   arrivava a `Y=12` e la riga 64 portava alla 65 con `FOR N=13 TO 11`: `BA(13)` non esiste ->
   `?BAD SUBSCRIPT ERROR IN LINE 65`. La routine 4-9 va percorsa **solo** con `GOSUB 4`;
2. **linea 64 con `IF Y>10 THEN 67`** (invece di `IF Y=11`): quando la pila si esaurisce `Y` vale 12,
   e il ciclo della riga 65 partirebbe da 13. Ora con `Y>10` (cio' comprende 11 e 12) si salta
   direttamente al cambio livello, senza contare i barili rimasti (che non ci sono piu').

## 5.4 Bug noti del listato originale: stato nel port

Elenco preso dal commento in testa a `lo_scalatore_commentato.bas`:

| bug | stato nel port | dove |
|---|---|---|
| riga morta `69 goto 69` | rimossa | non esiste nel port |
| barili che rotolano dalla pila senza controllare se c'e' il barile | **corretto** | righe 4-9 + `GOSUB 4` alla riga 19 |
| bonus vita che non scatta quasi mai (punteggio a blocchi di 150/100/1000) | **corretto** | riga 98, vedi step 06 §6.3 |
| morendo in cima alla scala la scala si allunga | **non corretto**: la discesa di morte e' identica all'originale | righe 52-53 e 55-57 |
| `#` a 7697 che copriva il numero di livello | **corretto**: il `#` e' ora stampato con `PRINT "#";SC;` subito **prima** del numero del livello | riga 96 |

Sul bug della scala, la correzione pronta e' di una riga: in riga 55, dopo `IF T=24 THEN T=0`,
aggiungere `IF T=16 THEN T=0` (16 = scala), cosi' la discesa di morte non ridisegna la scala
dietro l'omino. Applicarla **solo se** in emulazione il difetto si vede (vedi §5.5 punto 4).

## 5.5 Prova sull'emulatore

1. Lancia `lm80c/prove/p03-livello.bas` e verifica la mappa (come step 03).
2. Lancia il gioco. Percorso di collaudo:
   - **passi**: destra/sinistra sulle travi, discesa e risalita delle scale (cursori);
   - **salto**: SPAZIO davanti a un barile -> il barile viene saltato e il punteggio aumenta di
     **1000**;
   - **borsa**: passando sopra una borsa nera il punteggio aumenta di **150**;
   - **morte**: farsi colpire da un barile -> l'omino "scende" con un suono che cala, perde una
     vita e riparte (il numero a colonna 14 diminuisce di 1);
   - **vite**: dopo la morte il numero a riga 0 col 14 diminuisce di 1 (`Y` conta i barili passati
     o "giocati": arrivato a 11 si passa al livello successivo, riga 60 del port);
   - **pila esaurita**: se i barili della pila finiscono, il round termina (righe 4-9) senza
     barili che appaiono dal nulla.
3. Verifica che **non** compaiano mai due omini o barili agganciati fuori dal campo
   (righe 49 e 61 sono i limiti del campo).
4. **pila esaurita** (verifica dei punti §5.3): quando i 12 barili sono rotolati via, l'omino non deve
   piu' respawnare un barile dal nulla e il gioco deve passare al livello successivo senza errori
   (`BAD SUBSCRIPT` in riga 65 = la riga 3 o la riga 64 non sono come in §5.3).
5. Caso specifico del bug della scala: fai morire l'omino **mentre e' sulla scala** (in cima o a
   meta'), poi guarda il tratto di scala percorso dalla discesa di morte. Se appare un gradino
   in piu' (o un gradino mancante), riportalo: si applica la correzione di una riga di §5.4.

## 5.6 Report

Riporta per ogni punto di §5.5 cosa hai visto e cosa non torna, con il numero di riga del port
che sospetti (per esempio: "morendo sulla scala compare un gradino in piu' alla riga 8 col 12").
