# Modifiche rispetto all'originale

sposta i puntatori dello schermo per compatibilità con 16K
0 poke648,30:poke36869,240:poke36866,150

tolti puntatori delle variabili BASIC (inutili con il BASIC compilato)
0 ... poke51,192:poke52,29:poke55,192 ...

introdotti colore barile e colore scala variabili
3 cb=6:cs=2:

variabile a casaccio per rallentare nel loop del suono
3 kk=0.1

ritardo prima dello spostamento omino
20 sys828:sys900:sys900:onpeek(1)goto35,26,28,31,33

disabilitato ciclo di ritardo quando non c'è mossa
21 goto41:rem forn=1to23*5:next:goto41

aggiunto colore omino nel salto
35 ... pokes+g,0 ...

rimodulato ciclo di ritardo nel salto
37 forn=1to3:sys900:next:

ciclo di ritardo per suono spostamento
40 poke36876,200:forn=1to5:kk=kk+1:next:poke36876,0 ...

suono cattura borsa attrezzi
41 ift=61thenpoke36877,252:ss=ss+150:print"{home}{rvon}"tab(8-len(str$(ss)))ss:h=h+1:t=62:poke36877,0:ifh=16then64

ritardo prima dello spostamento barile
45 sys900:sys900:

//sistemato bug barile a fine schermo
//49 ifv<8164+22then20

rimodulato ritardo del suono della morte
57 forn=1to3:sys900:next:so=so-5:ifso>150then56

ritardo suono conteggio barili a fine livello
66 poke36877,250:form=240to250:sys900:poke36876,m:next:poke36876,0:poke36877,0:next

corretto bug bonus vite
98 ifss>=q*e3thench=ch+1:e3=e3+1:print"{home}{rvon}"tab(14)ch

aggiunta routine LM all'indirizzo 900
108 ... , 173,4,144,201,110,208,249, 173,4,144,201,111,208,249, 96
110 ... to899+15 ...

