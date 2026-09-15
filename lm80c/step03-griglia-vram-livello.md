# Step 03 - Griglia VRAM e disegno del livello

## Obiettivo

Convertire tutto lo strato "schermo" del gioco da `POKE`/`PEEK` su RAM video del VIC-20
(base 7680, 22 colonne) a `VPOKE`/`VPEEK` sulla name table del TMS9918
(base 6144 = `$1800`, 32 colonne), e disegnare il livello come fa la routine 70 dell'originale.

## 3.1 Il modello di indirizzamento

```
addr(riga,col) = 6144 + 32*riga + 5 + col = 6149 + 32*riga + col
```
- riga 0 = riga di stato (punteggio, vite, livello, `#`);
- righe 1..22 = campo di gioco, **22 colonne centrate** (colonne 0..21 -> indirizzi 5..26);
- le colonne 27..31 restano vuote (tile 0) e fanno da cornice;
- righe delle travi: **7, 12, 17, 22**; pavimenti su cui cammina l'omino: 6, 11, 16, 21.

Lettura e scrittura di una cella sono una `VPEEK(addr)` e una `VPOKE addr,codice`:
esattamente l'equivalente di `PEEK`/`POKE` dell'originale (che faceva 2 POKE, schermo+colore;
nel port il colore è implicito nel codice del tile).

## 3.2 Conversione delle stringhe PETSCII (righe 70-73 originali)

L'originale disegnava tutto il livello stampando stringhe (`a$`, `b$`) che contenevano i tile
ridefiniti (`>` = 62 spazio, `8` = 56 trave, `9` = 57 scala, `?` = 63 deviatore). Nel port sono
`VPOKE`:

```
70 CLS                                   <- era PRINT "{clr}{pur}"; + 22 righe di a$
71 VPOKE 6251,1:VPOKE 6260,1              <- deviatori a fianco della pila (riga 3, col 6 e 15)
72 VPOKE 6283,16:FOR N=6284 TO 6291:VPOKE N,8:NEXT:VPOKE 6292,16   <- ripiano (riga 4 col 6..15)
73 VPOKE 6315,16:VPOKE 6324,16:VPOKE 6347,16:VPOKE 6356,16          <- scale laterali (righe 5-6)
74 GOSUB 95:GOSUB 96:FOR N=0 TO 11:VPOKE BA(N),24:NEXT
75 FOR N=6373 TO 6853 STEP 160:FOR C=1 TO 20:VPOKE N+C,J:NEXT:...   <- le 4 travi (era PRINT b$)
```

Due note importanti:

- `b$` era `">88888888888888888888"` = **1 spazio + 20 travi** (21 caratteri): le travi coprono le
  colonne **1..20**, mentre le colonne 0 e 21 restano celle su cui il gioco mette i deviatori di
  fine trave (righe 94 e 97). Le travi sono sulle righe **7, 12, 17, 22** (una riga sotto le
  superfici calpestabili 6, 11, 16, 21 dove camminano omino, barili e borse).
- il disegno delle travi **deve** precedere la ricerca della cella per le scale (riga 77:
  `IF VPEEK(R)<>J THEN 77`): senza le travi quella ricerca non trova mai una trave e il programma
  resta in ciclo infinito. E' esattamente l'errore che si e' visto alla prima prova;
- il simbolo `#` non e' piu' una `VPOKE` a colonna fissa: `GOSUB 96` lo stampa con
  `PRINT "#";SC;` **subito prima** del numero del livello (vedi step 06 §6.1), cosi' resta attaccato
  alle cifre anche quando il livello passa a due cifre. Il trucco anti-scroll
  `a$` + `POKE 8185` non serve piu': `CLS` pulisce lo schermo senza scorrere (e riempie tutto di
tile 0 = spazio calpestabile, come faceva `a$`).

## 3.3 Pila dei barili (era `b()` con `7712+b(n)`)

`DATA 109` conserva gli offset originali `0,1,21,22,23,24,42,43,44,45,46,47`; la conversione
in indirizzi VRAM avviene una volta sola:

```
113 FOR N=0 TO 11:READ B(N):OF=B(N)+32:BA(N)=6149+32*(OF#22)+(OF%22):NEXT
```
`32 = 7712-7680` è l'offset del primo barile della pila nel sistema a 22 colonne;
`#` e `%` sono la divisione intera e il resto del LM80C BASIC. Risultato:
riga 1 col 10-11, riga 2 col 9-12, riga 3 col 8-13 (12 barili).

## 3.4 Generazione del livello (righe 75-94 del port, erano 74-90)

- travi: `FOR N=6373 TO 6853 STEP 160` (righe 7,12,17,22) con salto a 82 per l'ultima
  (sotto la trave piu' bassa non si disegnano scale); ogni trave e' disegnata su **20 celle**
  (colonne 1..20) con `FOR C=1 TO 20:VPOKE N+C,J:NEXT`, come il vecchio `PRINT b$`;
- 3 scale per trave: `R=N+1+INT(RND(1)*20)`, disegnate con `FOR M=R TO R+128 STEP 32`
  (5 celle verso il basso, 4 righe: era `r+88 step 22`);
- scala interrotta (`IF O>1 AND RND(1)<E2`) con deviatore a `R+(INT(RND(1)*2)+2)*32`;
- deviatore in cima alla scala (`IF RND(1)<.5 AND VPEEK(R-32)=0`);
- buchi nelle travi (`E1` per trave) con deviatore nella cella sopra: `VPOKE R,0:VPOKE R-32,1`;
- 4 borse per trave a `R=N-32+INT(RND(1)*20)` con trave sotto (`VPEEK(R+32)<>0`);
- deviatori ai lati della pila (`6189, 6194, 6220, 6227`);
- deviatori a fine trave: righe 6,11,16,21 col 0 (`6341..6821 step 160`) e col 21
  (`6362..6842 step 160`).

## 3.5 Prova sull'emulatore

1. Lancia `lm80c/prove/p03-livello.bas`: dopo il disegno premi **SPAZIO**.
2. Atteso: campo bianco con 4 righe di **travi magenta** interrotte da **scale rosse**,
   12 **barili gialli** impilati in alto al centro con il ripiano, **borse nere** sopra le
   travi, e il `#` in riga 0 attaccato davanti al numero del livello.
3. Dopo SPAZIO: conti per tipo di tile. Attesi (indicativi, la generazione è casuale):
   `BARILI 24 -> 12`, `OMINO 40 -> 0`, `SCALE 16 -> circa 60` (3 scale x 5 celle x 4 travi,
   meno quelle "rotte"), `TRAVI 8 -> circa 80` (4 x 21 meno scale, buchi e deviatori),
   `BORSE 41 -> 16`, `DEVIATORI 1` presenti.
4. Poi lancia il gioco con `RUN`: il livello disegnato dal gioco deve avere lo stesso aspetto.

## 3.6 Report

Riporta: aspetto del campo (posizione di travi, scale, pila, borse) e i conteggi stampati,
segnalando quale tipo di tile è assente o fuori posto.
