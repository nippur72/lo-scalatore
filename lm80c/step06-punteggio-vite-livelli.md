# Step 06 - Punteggio, vite, livelli e fine partita

## Obiettivo

Trasformare le stampe della riga di stato dell'originale (`PRINT ... TAB(...)`, `{home}`, `{rvon}`,
PETSCII) in `LOCATE` + `PRINT` del LM80C, raccogliere le quattro stampe del punteggio in una sola
subroutine, correggere il bonus vita e dare una vera schermata di fine partita.

## 6.1 La riga di stato

| originale | port |
|---|---|
| `print"{home}{rvon}"tab(8-len(str$(ss)))ss` (righe 36, 41, 65, 98) | `95 LOCATE 8-LEN(STR$(SS)),0:PRINT SS;:RETURN` |
| `print"{home}{rvon}"tab(14)ch` (righe 59, 98) | `96 LOCATE 14,0:PRINT CH;:LOCATE 17,0:PRINT SC;:RETURN` |
| `print"{rvon}"tab(8-len(str$(ss)))ss;tab(14)ch;tab(17)sc` (riga 73) | `74 GOSUB 95:GOSUB 96:...` |
| `poke7697,163` (riga 73: il `#` a riga 0 col 17) | `PRINT "#";SC;` in riga 96: il `#` precede il numero del livello |

Note:

- `TAB(n)` del VIC-20 sposta il cursore alla colonna n della riga corrente: nel port si usa
  `LOCATE col,riga`, quindi `{home}` diventa `...,0` e non serve piu'.
- `{rvon}` (video inverso) **non esiste** nel LM80C: i numeri della riga di stato sono ora in
  video normale. L'aspetto cambia, i valori no.
- `STR$` del LM80C antepone sempre il segno (spazio se positivo), esattamente come sul VIC-20
  (`STR$(12)` -> `" 12"`): l'allineamento a destra con `8-LEN(STR$(SS))` resta quindi valido.
- il `#` era a 7697 = riga 0 col 17, **sopra il numero di livello**: nell'originale era una `POKE`
  a colonna fissa e quindi, appena il livello passava a due cifre, il simbolo copriva una cifra
  (bug noto, step 05 §5.4). Nel port non e' piu' una `VPOKE` ma un carattere **stampato subito dopo
  il livello**:

  ```
  96 LOCATE 14,0:PRINT CH;:LOCATE 17,0:PRINT "#";SC;:RETURN
  ```

  Il `#` **precede** il numero del livello (`#1`, `#12`...) e resta attaccato alle sue cifre con
  qualunque numero di cifre; le due `VPOKE` che servivano prima (alla riga 74 per il primo disegno e
  alla 93 per gli altri) spariscono: la riga di stato si ridisegna sempre con `GOSUB 96`. Il carattere `#`
  (codice 35) appartiene al gruppo 4 della color table, che `COLOR 1,15,15` ha lasciato nero su
  bianco: e' quindi visibile senza `VPOKE` aggiuntive.
- le colonne sono le stesse dell'originale: punteggio 0-8, vite 14, livello 17, `#` 22.

## 6.2 Dove si assegnano i punti

| evento | originale | port |
|---|---|---|
| barile saltato: +1000 | righe 36-37 con `print ... tab(8-len(str$(ss)))ss` | riga 36: `SS=SS+1000:GOSUB 95` |
| borsa raccolta: +150 | riga 41 con la stessa print | riga 41: `SS=SS+150:GOSUB 95` |
| barili residui a fine livello: +100 per barile | riga 65 `poke7712+b(n),62` + print | riga 65: `VPOKE BA(N),0:SS=SS+100:GOSUB 95:GOSUB 98` |
| bonus vita | riga 98 | riga 98: `IF SS>=Q*E3 THEN CH=CH+1:E3=E3+1:GOSUB 96` |

Le quattro `PRINT` inline dell'originale sono ora un'unica `GOSUB 95`: il punteggio si scrive
sempre con `PRINT SS;` (punto e virgola) per **non** far avanzare il cursore oltre le cifre
stampate e non cancellare le colonne delle vite.

## 6.3 Correzione del bonus vita

Originale:

```
98 ifss=q*e3then ch=ch+1:e3=e3+1:print"{home}{rvon}"tab(14)ch
```

Il confronto e' esatto, ma il punteggio cresce a blocchi di 150 (borse), 100 (barili residui) e
1000 (barili saltati): partendo da 0 il totale e' sempre multiplo di 50, quindi `ss = 10000`
riesce solo per caso (per esempio 9950 + 150 = 10100 salta il valore esatto) e il bonus non
scatta quasi mai. Nel port:

```
98 IF SS>=Q*E3 THEN CH=CH+1:E3=E3+1:GOSUB 96
```

- `>=` premia il superamento della soglia, qualunque sia il punteggio esatto;
- `Q=10000` e `E3` parte da 1 e cresce a ogni bonus, quindi i bonus successivi sono a 20000,
  30000...;
- la routine e' richiamata a ogni evento che assegna punti (borse, barili saltati, fine livello)
  e aiuta a recuperare anche i casi di salto doppio di soglia (per esempio 19900 -> 20900).

## 6.4 Progressione dei livelli

| originale | port | nota |
|---|---|---|
| `67 e2=e2+.05:sc=sc+1:e1=e1+1:ife1>8thene1=8` | `67 E2=E2+.05:SC=SC+1:E1=E1+1:IF E1>8 THEN E1=8` | `SC` = livello (col 17), `E1` = buchi per trave (max 8), `E2` = probabilita' di scala interrotta |
| `68 goto15` | `68 GOTO 15` | nuova partita con un livello piu' difficile |
| righe 15-16 | `15 GOSUB 70:H=0:Y=0` + `16 ...` | riga 0 ridisegnata, omino ripiazzato, pila ricaricata (riga 74) |

Ogni livello aggiunge quindi il 5% di probabilita' di trovare una scala interrotta e un buco in
piu' per trave (fino a 8): e' l'unico aumento di difficolta' dell'originale e va verificato
passando piu' volte di livello.

## 6.5 Fine partita

Originale:

```
58 ...ch=ch-1:ifch=-1then poked,255:poke36869,240:print"{clr}{blk}"ss:end
```

(`poked,255` rimetteva la direzione del joystick via VIA, `poke36869,240` risistemava il charset).

Port:

```
58 SOUND 0:CH=CH-1:IF CH<0 THEN GOSUB 120:END
...
120 CLS:LOCATE 8,10:PRINT "GAME OVER"
121 LOCATE 5,12:PRINT "PUNTEGGIO ";SS
122 RETURN
```

- le ultime due `POKE` non servono (VIA e charset non esistono sul LM80C) e `ch<0` sostituisce
  `ch=-1` (equivalente: `ch` scende di 1 alla volta a partire da 2);
- `CLS` pulisce lo schermo senza scorrere, quindi la vecchia `print"{clr}"` + `poke36869` sparisce;
- `GAME OVER` a riga 10 e punteggio finale a riga 12: il punteggio **resta a video** dopo l'`END`,
  prima l'originale lo stampava da solo, in alto a sinistra;
- con `RUN` da direct mode si riparte da capo, oppure si ricarica il listato.

## 6.6 Prova sull'emulatore

1. Lancia `lm80c/prove/p05-punteggio.bas`: deve far salire il punteggio di 150 punti per volta
   (con il conteggio a destra sempre allineato), e con SPAZIO far passare il livello da 1 a 2, 3...
   Il `#` deve stare a riga 0 **dopo** l'area di gioco, senza coprire il livello.
2. Nel gioco, verifica:
   - il punteggio si aggiorna immediatamente dopo ogni borsa (+150) e ogni barile saltato (+1000);
   - a fine livello arrivano i 100 punti per ogni barile rimasto nella pila;
   - a 10000 punti compare una vita in piu' a colonna 14 (bonus corretto);
   - perdendo tutte le vite compare `GAME OVER` con il punteggio finale.
3. Passa almeno 2-3 livelli e controlla che il numero a col 17 avanzi e che i buchi/scale rotte
   aumentino (prova indiretta di `E1`/`E2`, riga 67).

## 6.7 Report

Riporta: cosa mostra la riga di stato (valori e posizioni), se il bonus vita scatta a 10000,
e cosa succede esattamente alla fine della partita (schermata e comportamento dopo `END`).
