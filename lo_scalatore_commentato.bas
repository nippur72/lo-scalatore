' Lo Scalatore (The Hardhat Climber)
' di Chris Lesher
' 
' First appeared on Compute's Gazette Jan 84
' Pubblicato in italia su SuperVIC n.1 giugno 1984 
' trad. e adatt. E. Comini
'
' digitato da saver71
'
' Link
' http:'www.jbrain.com/pub/cbm/mags/cg/1984/01jan/jan84-HardhatClimberA.jpg
' http:'www.jbrain.com/pub/cbm/mags/cg/1984/01jan/jan84-HardhatClimberB.jpg
' https:'www.youtube.com/watch?v=PLgV5NFaM9c&ab_channel=saver71
' https:'www.vic-20.it/lo-scalatore/ (Blog di Marco Bergomi)
' https:'www.facebook.com/groups/commodorevic20italia/posts/2570929383164987/

' commenti vari:
' - nel sorgente sono presenti "p1" e "p2" variabili del VIA
'   probabilmente pezzi rimasti prima che la lettura del joystick
'   venisse fatta in linguaggio macchina
' - non usa il carattere dello spazio ma un carattere ridefinito
'   per usare tutta la memoria possibile del VIC-20 inespanso
' - per cancellare lo schermo usa il trucco di print col buffer (?verificare)
' - contiene 1 linea morta: 69 goto 69
' - bug quando muore in cima alla scala, la scala si allunga
' - bug quando rotolano i barili dalla pila non controlla se c'è barile
' - bug quando scatta il bonus vita

' caratteri ridefiniti
' 8 trave     (56)
' 9 scala     (57)
' : omino     (58)
' ; bomba     (59)
' < barile    (60)
' = borsa     (61)
' > spazio    (62)
' ? deviatore (63) (invisibile, usato per deviare il barile)

' === variabili ===
' relativi all'omino:
'    s=locazione video omino
'    t=carattere sotto l'omino
'    di=direzione corrente omino destra/sinistra (-1,+1)
'
' relativi al barile:
'    v=posizione schermo del barile
'    w=carattere sotto del barile
'    b(11) = offset schermo dei singoli barili nella pila
'    y=0..11 numero del barile che sta rotolando
'    do=direzione corrente barile (-1,+1,22)   
'    do(0,1) = contiene i valori -1 e +1 per scegliere direzione casuale del barile a fine scala
'
' relativi al punteggio:
'    h=numero delle borse recuperate (max 16)
'    ss=score 
'    sc=livello (screen)
'    ch=numero di vite
'    q=bonus punteggio livello (10000)
'    e3=contatore bonus vite
'
' vari:
'    g=offset per andare da screen RAM a color RAM
'    d()= vettore contentente i colori dei caratteri a partire da 56 colore = d(56-i)
'    z=carattere della scala (57)
'    j=carattere della trave (56)
'    d = variabile usata per resettare il VIA a fine gioco
'    p1,p2 non usate
'
' generazione del livello:
'    e1=numero di buchi casuali sulle travi, max 8, si incremente ad ogni livello
'    e2=chance casuale deviatori dei barili sulle scale, aumenta del 5% ogni livello
'    e4=mai usata
'    e5=mai usata

   0 print "{clr}"          ' cancella schermo
   poke 51,192:poke 52,29 ' imposta la fine memoria a 7616 dove iniziano i caratteri definibili (56 ch)
   poke 55,192:poke 56,29 ' imposta la fine memoria a 7616 dove iniziano i caratteri definibili (56 ch)
   poke 36869,255         ' visualizza caratteri definibili a 7168
   poke 36878,15          ' volume del suono al massimo
   poke 36879,25          ' bordo e sfondo bianchi

 1 d=37154     ' usata per resettare il VIA a fine gioco
   p1=37151    ' mai usata
   p2=37152    ' mai usata

   do(0)=-1:do(1)=1       ' array usato per scegliere tra -1 e +1 in maniera casuale
   di=do(int(rnd(1)*2))   ' sceglie casualmente la direzione di marcia iniziale dell'omino (sx/dx)

 2 a$=">>>>>>>>>>>>>>>>>>>>>{left}{inst}>"         ' variabile usata per riempire lo schermo di "spazi"
   dim b(11)      ' dimensiona vettore b contenente le posizioni dei barili sulla pila
   g=30720        ' offset per andare da screen RAM a color RAM (38400-7680)
   3 sc=1           ' livello 1
   ch=2           ' numero di vite 2
   e1=0           ' 0 buchi sulle travi al primo livello
   d(0)=4         ' colore trave (magenta)
   d(1)=2         ' colore scala (rosso)
   d(4)=7         ' colore barile (giallo)
   z=57           ' carattere della scala
   e3=1           ' moltiplicatore bonus vite (1=primo bonus a 10000)
   q=10000        ' moltiplicatore punteggio per bonus vite
   j=56           ' carattere della trave, primo carattere ritefinito
10 gosub 100      ' inizializza vettore b(), caratteri e LM dai DATA
   poke 36869,255 ' imposta modo video caratteri definibili (ripetuto linea 0)
   e4=0           ' mai usata
   e5=2           ' mai usata

15 gosub 70      ' disegna livello
   h=0           ' zero borse recuperate
   y=0           ' inizia con il primo barile

16 s=8143+int(rnd(1)*20)                   ' assegna casualmente posizione iniziale dell'omino sulla trave in basso
   if peek(s+22)=62 or peek(s)=59 then 16  ' se alla riga sotto c'è uno spazio o se sopra una una bomba riprova

17 t=peek(s)             ' ricorda cosa c'è sotto l'omino
   poke s,58:poke s+g,0  ' disegna omino di colore nero

' inizializza il rotolamento del barile

19 v=7712+b(y)                    ' posizione schermo del prossimo barile da far rotolare
   w=62                           ' mette un carattere spazio sotto il barile
   do=do(int(rnd(1)*2))           ' rotola a sinistra o destra in maniera casuale (-1 o +1)

' **** spostamento giocatore ****

20 sys 828                        ' chiama routine LM che legge il joystick in peek(1): 0,1,2,3,4,5
   on peek(1) goto 35,26,28,31,33 ' esegue la mossa: fire,sotto,sinistra,sopra,destra

21 for n=1 to 23:next             ' nessuna mossa, fa un ciclo di ritardo
   goto 41                        ' salta le mosse e si ricongiunge al game loop

' dir 2: sotto
26 if peek(s+22)=z then                       ' se alla riga sotto dell'omino c'e una scala
      poke s,t:poke s+g,d(t-j)                ' cancella omino dallo schermo         
      s=s+22                                  ' sposta omino in giu
      goto 40                                 ' ricongiunge al loop

27 goto 41                                    ' altrimenti se non c'è scala non fa niente

' dir 3: sinistra
28 di=-1                                      ' imposta direzione corrente a sinistra
   if peek(s+21)<62 then                      ' se c'e qualcosa sotto a SW che non sia spazio
      poke s,t:poke s+g,d(t-j)                ' cancella omino dallo schermo                  
      s=s-1                                   ' sposta omino a sinistra
      goto 40                                 ' ricongiunge al loop

29 if t<>z then                               ' altrimenti se l'omino NON è su una scala (omino nel vuoto)
      poke s,t:poke s+g,d(t-j)                ' cancella omino dallo schermo                  
      s=s+di                                  ' sposta omino nella direzione corrente
      t=peek(s)                               ' legge cosa c'è sotto omino
      goto 55                                 ' inizia il salto nel vuoto (morte)

30 goto 41                                    ' altrimenti (se omino su scala) non fa niente

' dir 4: sopra
31 if t=z then                                ' se omino su scala 
      poke s,t:poke s+g,d(t-j)                ' cancella omino dallo schermo                  
      s=s-22                                  ' sposta omino su
      goto 40                                 ' ricongiunge al loop

32 goto 41                                    ' altrimenti (se omino non su scala) non fa niente

' dir 5: destra
33 di=1                                       ' imposta direzione corrente a destra
   if peek(s+23)<62 then                      ' se c'e qualcosa sotto a SE che non sia spazio 
      poke s,t:poke s+g,d(t-j)                ' cancella omino dallo schermo                  
      s=s+1                                   ' sposta omino a destra
      goto 40                                 ' ricongiunge al loop

34 goto29                                     ' prosegue come left per vedere se è su scala

' dir 1: salto
35 poke 36876,240                             ' emette il suono del salto
   poke s,t:poke s+g,d(t-j)                   ' cancella omino dallo schermo
   s=s-22+di                                  ' calcola la posizione salendo di una riga nella direzione del salto
   t=peek(s)                                  ' vede cosa c'è sotto la posizione del salto
   poke s,58                                  ' disegna l'omino (ma non il colore)
   if t=60 then 55                            ' se ha crashato con un barile vai alla morte

36 if peek(s+22)=60 then                          ' se alla riga sotto c'è un barile (ha saltato un barile)
      ss=ss+1000                                  ' assegna 1000 punti
      print "{home}{rvon}"tab(8-len(str$(ss)))ss  ' aggiorna il punteggio a video

37 for n=1 to 5:next                              ' ciclo di ritardo in modo che l'omino che salta sia visibile
   poke s,t:poke s+g,d(t-j)                       ' cancella omino dalla posizione di salto
   s=s+22+di                                      ' sposta omino una riga sotto di nuovo sulla linea di base
   t=peek(s)                                      ' vede cosa c'è sotto omino
   poke s,58                                      ' disegna omino nella nuova posizione
   if peek(s+22)>61 then 55                       ' se saltato su un barile o su uno spazio vai alla morte    

38 poke s+g,0                                     ' colora omino di nero
   poke 36876,0                                   ' smette di suonare
   goto 41                                        ' si ricongiunge al loop

' ricongiunzione dopo spostamento

40 poke 36876,200:poke 36876,0                    ' emette breve beep di spostamento
   t=peek(s)                                      ' vede cosa c'è sotto omino
   poke s,58:poke s+g,0                           ' ridisegna omino nella nuova posizione

41 if t=61 then                                    ' se trovato borsa
      ss=ss+150                                    ' assegna 150 punti
      print "{home}{rvon}"tab(8-len(str$(ss)))ss   ' aggiorna il punteggio a video
      h=h+1                                        ' aumenta il numero di borse trovate
      t=62                                         ' toglie la borsa da sotto omino
      if h=16 then 64                              ' se omino ha preso 16 borse => fine livello

42 if t=60 then 55    ' se trovato barile vai alla morte

43 gosub 98           ' controlla se per caso è scattato il bonus vita

' *** spostamento barile ***

45 poke v,w:poke v+g,d(w-j)               ' cancella barile dallo schermo
   v=v+do                                 ' sposta barile nella direzione di marcia
   w=peek(v)                              ' vede cosa c'è sotto il barile
   poke v,60:poke v+g,7                   ' disegna il barile

46 if do=22 and peek(v+22)=56 then        ' se il barile sta cadendo (do=22) e sotto c'è una trave
   do=do(int(rnd(1)*2))                   ' si ferma sulla trave e va a destra o sinistra in maniera casuale
   goto 48                                ' 

47 if w=63 then do=22                     ' altrimenti, se barile incontra un deviatore, inizia a scendere

48 if w=58 then 55                        ' se barile crasha su omino vai alla morte

49 if v<8164 then 20                      ' se il barile è ancora dentro lo schermo ritorna al game loop

50 y=y+1                                  ' barile fuori schermo. aumenta il numero di barili
   if y=12 then 55                        ' se è arrivato a 12 barili => morte

51 poke v,62                              ' cancella il barile che è andato fuori schermo
   goto 19                                ' chiude il game loop dal punto in cui inizia il rotolamento barile

' *** morte ***   
55 poke 36876,0       ' spegne altri suoni
   so=250             ' parte da un suono alto
   if t=60 then t=w   ' se sotto omino c'era il barile allora imposta cosa c'era sotto del barile
56 poke 36874,so      ' emette suono che descresce

   ' fa cadere l'omino fino ad incotrare una trave o la fine schermo
   
   if peek(s+22)<>56 and s<8164 then      ' se riga sotto non è trave ed è ancora dentro schermo
      poke s,t:poke s+g,d(t-j)            ' cancella omino dallo schermo
      s=s+22                              ' scende giù omino di una riga
      t=peek(s)                           ' salva cosa sotto omino
      poke s,58:poke s+g,0                ' disegna omino

57 for n=1 to 17:next ' ciclo di ritardo
   so=so-5            ' suono che scende
   if so>150 then 56  ' ripete la discesa finche il suono arriva al tono più basso

58 poke 36874,0      ' spegne suono
   ch=ch-1           ' toglie una vita
   if ch=-1 then     ' se le vite sono finite allora fine gioco 
      poke d,255                ' ripristina il VIA causa lettura joystick
      poke 36869,240            ' ritorna ai caratteri normali 
      print "{clr}{blk}"ss      ' stampa score
      end                       ' ritorna al BASIC

59 print "{home}{rvon}"tab(14)ch        ' aggiorna conteggio su schermo vite

   poke v,w:poke v+g,d(w-j)             ' cancella barile che stava rotolando quando l'omino è morto
   y=y+1                                ' aumenta il numero dei barili usati
   if w=58 then pokev,t:pokev+g,d(t-j)  ' se barile aveva crashato con l'omino, disegna cosa c'era sotto l'omino

60 if y>10 then 15                      ' se è morto perchè sono caduti tutti i barili ricomincia il livello da zero con 12 barili

61 if s>8163 then                       ' se l'omino è morto perché andato fuori schermo
      poke s,t                          ' cancella l'omino
      goto 16                           ' riparte riposizionando l'omino sulla piattaforma

62 poke s,58:poke s+g,0                 ' disegna omino nel punto dove era morto
   goto 19                              ' chiude il game loop

' nuovo livello

64 if y=11 then 67                      ' se fine barili, va a nuovo livello

' animazione di fine livello che conta i barili rimasti e aumenta i punti

65 for n=y+1 to 11                                ' cicla sui barili rimasti
      poke 7712+b(n),62                           ' cancella il barile dalla pila
      ss=ss+100                                   ' aggiunge 100 punti
      print "{home}{rvon}"tab(8-len(str$(ss)))ss  ' aggiorna il punteggio
      gosub 98                                    ' controlla se bonus vita

66    poke 36877,250                              ' emette suono fisso
      for m=240 to 250:poke 36876,m:next          ' emette suono crescente         
      poke 36876,0:poke 36877,0                   ' ammutolisce i suoni
   next

67 e2=e2+.05                                      ' aumenta del 5% chance deviatori sulle scale
   sc=sc+1                                        ' aumenta numero livello
   e1=e1+1                                        ' aumenta numero di buchi sulle travi
   if e1>8 then e1=8                              ' max 8 buchi 

68 goto 15                             ' vai al game loop

69 goto 69                             ' non fa niente, non arriva mai qui

' subroutine disegna livello in maniera completa

70 print "{clr}{pur}";             ' cancella schermo e imposta colore porpora (per punteggio,liv,vite)
   for n=1 to 21:print a$:next     ' stampa stringa con tutti spazi ridefiniti (pulisce schermo)
   print a$"{home}"                ' stampa l'ultima linea portando il cursore home
   b$=">88888888888888888888"      ' crea stringa per la trave (spazio iniziale e carattere trave)

71 print "{down}{down}"tab(6)"?>>>>>>>>?{red}"    ' cancella con spazio il punteggio, score, livello
   printtab(6)"9{pur}88888888{red}9"              ' stampa trave che sorregge la pila di barili
   printtab(6)"9>>>>>>>>9"                        ' e le relative scale
   printtab(6)"9>>>>>>>>9{pur}"                   ' 

72 for n=1 to3                                    ' stampa 3 travi distanziate di 4 righe ciascuna
      print b$"{down}{down}{down}{down}"
   next
   printb$"{home}";                               ' stampa la quarta trave in fondo allo schermo 
   poke 8185,62                                   ' spazio in angolo basso destra, per evitare omino fuori

73 print "{rvon}"tab(8-len(str$(ss)))ss;tab(14)ch;tab(17)sc   ' stampa punteggio, vite, livello
   poke 7697,163                                              ' simbolo del # (in reverse)
   for n=0 to 11                                              ' disegna i 12 barili
      poke 7712+b(n),60                                       ' carattere del barile nella pila  
74    poke 7712+b(n)+g,7                                      ' colore barile
   next
      
   for n=7834 to 8164 step 110                                ' cicla sulle 4 travi (110=8 righe di 22)
         if n=8164 then 80                                      ' ?? non necessario?

         ' per ogni trave disegna 3 scale
75     for o=1 to 3                                           ' disegna tre scale per trave
76        r=n+1+int(rnd(1)*20)                                ' trova una posizione casuale sulla trave
            if peek(r)<>56 then 76                              ' se non è trave, ripeti

77        for m=r to r+88 step 22                             ' dalla trave corrente fino a quella appena più in basso
               poke m,57:poke m+g,2                             ' disegna scala rossa
            next                                                '

            if o>1 and rnd(1)<e2 then                           ' (buco sulla scala) se dalla seconda scala in 
               poker+(int(rnd(1)*2)+2)*22,63                    ' poi e chance casuale, buca la scala ad altezza casuale (63??)
                                                               ' il buco può cadere a +2 o +3 righe da inizio scala

78        if rnd(1)<.5 and peek(r-22)=62 then                 ' (deviatore su scala) se 50% chance e sopra la scala c'è spazio
               poker-22,63                                      ' mette un deviatore in cima alla scala
79     next

         ' disegna buchi sulle travi
80     for o=1 to e1                                          ' crea un numero di buchi sulla rampa pari a e1
81        r=n+3+int(rnd(1)*16)                                ' posizione casuale all'interno della rampa
            if peek(r)<>56                                      ' se non è trave 
               or peek(r-22)<>62                                ' oppure il carattere di sopra non è spazio
               or peek(r+1)=62 or peek(r-1)=62                  ' oppure i caratteri a sx/dx non sono spazio
            then 85                                             ' allora non fa niente
84        poke r,62:poke r-22,63                              ' trave libera: crea buco e deviazione
85     next

         ' disegna borse     
86     for o=1 to 4                                          ' disegna 4 borse per trave
87        r=n-21+int(rnd(1)*20)                              ' posizione casuale della borsa sulla riga sopra la trave
            if peek(r)<>62 or peek(r+22)=62 then 87            ' se non è spazio vuoto o non c'è trave sotto, ripeti
88        poke r,61:poke r+g,0                               ' disegna borsa nera
         next

   next                                                      ' chiude il ciclo delle 4 travi

89 poke 7710,63                                              ' mette deviatori ai lati della pila di barili
   poke 7715,63                                              ' mette deviatori ai lati della pila di barili
   poke 7731,63                                              ' mette deviatori ai lati della pila di barili
   poke 7738,63                                              ' mette deviatori ai lati della pila di barili

90 for n=7812 to 8142 step 110:poke n,63:next                ' mette deviatori a fine trave a sinistra
   for n=7833 to 8163 step 110:poke n,63:next                ' mette deviatori a fine trave a destra
   return

' subroutine bonus vita
98 if ss=q*e3 then                    ' se il punteggio ha raggiunto il valore del bonus
      ch=ch+1                         ' assegna una vita in più
      e3=e3+1                         ' incrementa valore del prossimo bonus
      print "{home}{rvon}"tab(14)ch   ' aggiorna il numero di vite
99 return                             ' ritorna alla routine chiamante

' posizioni dei 12 barili nella pila (vettore b) a partire dal barile più in alto a sinistra
100 data,1,21,22,23,24,42,43,44,45,46,47

' 8 caratteri ridefiniti
101 data255,255,153,102,102,153,255,255,195,255,255,195,195,255,255,195,60,60,25,255,188
102 data60,36,231,3,4,24,24,60,126,126,60,60,66,165,153,153,165,66,60,,24,36,126,126,126
103 data126,,,,,,,,,,,,,,,,,

' routine in linguaggio macchina per leggere il joystick
106 data169,,133,1,169,255,141,34,145,169,32,44,31,145,208,5,169,1,133,1,96,169,8,44
107 data31,145,208,5,169,2,133,1,96,169,16,44,31,145,208,5,169,3,133,1,96,169,4,44,31
108 data145,208,3,133,1,96,169,127,141,34,145,169,128,44,32,145,208,4,169,5,133,1,96

109 for n=0 to 11:read b(n):next           ' legge le posizioni della pila di barili      
    for n=7616 to 7679:readm:poken,m:next  ' ridefinisce gli 8 caratteri      
110 for n=828 to 899:readm:poken,m:next    ' scrive la routine LM joystick nel buffer tape
    return                                 ' ritorna al chiamante

111 rem lo scalatore per vic-20 digitato da saver71 18/11/2014


' 828 cassette buffer
033c  A9 00       LDA #$00
033e  85 01       STA $01       
0340  A9 FF       LDA #$FF
0342  8D 22 91    STA $9122    
0345  A9 20       LDA #$20
0347  2C 1F 91    BIT $911F
034a  D0 05       BNE $0351
034c  A9 01       LDA #$01
034e  85 01       STA $01
0350  60          RTS
0351  A9 08       LDA #$08
0353  2C 1F 91    BIT $911F
0356  D0 05       BNE $035D
0358  A9 02       LDA #$02
035a  85 01       STA $01
035c  60          RTS
035d  A9 10       LDA #$10
035f  2C 1F 91    BIT $911F
0362  D0 05       BNE $0369
0364  A9 03       LDA #$03
0366  85 01       STA $01
0368  60          RTS
0369  A9 04       LDA #$04
036b  2C 1F 91    BIT $911F
036e  D0 03       BNE $0373
0370  85 01       STA $01
0372  60          RTS
0373  A9 7F       LDA #$7F
0375  8D 22 91    STA $9122
0378  A9 80       LDA #$80
037a  2C 20 91    BIT $9120
037d  D0 04       BNE $0383
037f  A9 05       LDA #$05
0381  85 01       STA $01
0383  60          RTS


' routine di lettura del Joystick.
' Imposta la locazione $01 con la lettura del joystick:
' 0 - joystick non premuto
' 1 - fire
' 2 - sotto
' 3 - sinistra
' 4 - sopra
' 5 - destra

033c  LDA #$00 : STA $01          ' pulisce la cella $01 dove c'è il risultato 
      LDA #$FF : STA $9122        ' imposta i bit della porta B del VIA #1 tutti in lettura
      LDA #$20 : BIT $911F        ' testa il bit 5
      BNE $0351                   ' se alto (non premuto) prosegue
      LDA #$01 : STA $01          ' altrimenti imposta $01 come valore di ritorno in $01
      RTS                         ' ritorna al BASIC

0351  LDA #$08 : BIT $911F        ' testa il bit 3
      BNE $035D                   ' se alto (non premuto) prosegue 
      LDA #$02 : STA $01          ' altrimenti imposta $02 come valore di ritorno in $01
      RTS                         ' ritorna al BASIC

035d  LDA #$10 : BIT $911F        ' testa il bit 4
      BNE $0369                   ' se alto (non premuto) prosegue 
      LDA #$03 : STA $01          ' altrimenti imposta $03 come valore di ritorno in $01
      RTS

0369  LDA #$04 : BIT $911F        ' testa il bit 2
      BNE $0373                   ' se alto (non premuto) prosegue 
      STA $01                     ' altrimenti imposta $04 (gia presente in A) come valore di ritorno in $01
      RTS                         ' ritorna al BASIC

0373  LDA #$7F : STA $9122        ' imposta i bit della porta B del VIA #1 tutti in lettura
      LDA #$80 : BIT $9120        ' testa il bit 7
      BNE $0383                   ' se alto (non premuto) prosegue 
      LDA #$05 : STA $01          ' altrimenti imposta $05 come valore di ritorno in $01
0383  RTS                         ' ritorna al BASIC

