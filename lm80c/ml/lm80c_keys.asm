; ============================================================================
;  lm80c_keys.asm - LM80C - "LO SCALATORE" - input da tastiera in linguaggio
;                   macchina (Z80), al posto di INKEY e di INP/OUT da BASIC
; ----------------------------------------------------------------------------
;  La routine legge direttamente la matrice 8x8 della tastiera attraverso i
;  due port del PSG, con gli interrupt DISATTIVATI (di/ei): lo sniffer del
;  firmware gira nell'ISR del CTC ogni 20 ms e usa gli stessi port, quindi in
;  BASIC una OUT/INP poteva capitare in mezzo a una sua scansione. Qui non
;  puo' succedere: la lettura e' un blocco unico di ~60 us.
;
;  Non serve piu' nemmeno la sequenza a 4 passi da BASIC: il gioco fa una
;  chiamata per fotogramma e legge il risultato con PEEK.
;
;  TASTI (con gli alias, comodi perche' il C16 non ha i cursori a T rovesciata):
;      SINISTRA = cursore sinistra  oppure J
;      DESTRA   = cursore destra    oppure L
;      SU       = cursore su        oppure I
;      GIU'     = cursore giu'      oppure K
;      SPAZIO   = barra spaziatrice oppure Z
;
;  USO DA BASIC (AD = 30720 = $7800, base del blocco caricata con POKE dai DATA)
;      SYS AD              -> scansione completa; il codice K del gioco e' in
;                             PEEK(AD)  (0 = niente, 28/29/30/31/32)
;      SYS AD,codice       -> PEEK(AD) = 1 se il comando e' premuto, 0 se no
;                             (codice = 28 sinistra, 29 destra, 30 su, 31 giu',
;                              32 spazio; con gli alias compresi)
;
;  BLOCCO DI STATO (in testa al binario, quindi a partire da 30720):
;      AD+0   K       codice del gioco (28/29/30/31/32) o 1/0 in modo test
;      AD+1   FLAGS   bit0 DESTRA bit1 SU bit2 SINISTRA bit3 GIU' bit4 SPAZIO
;      AD+2   riga 0  ($FE) bit4 = SPAZIO   bit3 = RUN/STOP   bit0 = '1'
;      AD+3   riga 1  ($FD) bit4 = Z
;      AD+4   riga 2  ($FB)
;      AD+5   riga 3  ($F7)
;      AD+6   riga 4  ($EF) bit1 = I   bit2 = J   bit5 = K
;      AD+7   riga 5  ($DF) bit0 = GIU' bit2 = L  bit7 = SU
;      AD+8   riga 6  ($BF) bit0 = SINISTRA       bit7 = DESTRA
;      AD+9   riga 7  ($7F)
;      AD+10  SPAZIO  stato del fotogramma precedente (serve per il fronte)
;      AD+16  INGRESSO della routine (SYS AD+16, oppure SYS AD+16,codice)
;  In tutte le righe il bit vale 1 quando il tasto NON e' premuto (convenzione
;  della matrice); FLAGS e K invece hanno il bit a 1 quando il tasto E' premuto.
;
;  COMPILAZIONE (z88dk, assemblatore z80asm):
;      z80asm -b lm80c_keys.asm          ->  lm80c_keys.bin
;  oppure (assembla e stampa il blocco DATA pronto per il listato):
;      node build.js
; ============================================================================

; --- dove vive la routine ---------------------------------------------------
; 30720 = $7800: la variante 64K (il firmware di default dell'emulatore) gira
; in RAM, quindi la memoria bassa e' libera; il programma BASIC parte da $560E
; e le sue variabili stanno appena sopra, percio' $7800 e' ben oltre la fine del
; listato. E' anche sotto il limite di POKE/SYS di questo BASIC, che rifiuta gli
; indirizzi da $8000 in su (DEINT accetta solo -32768..32767). Non viene toccata
; da CLEAR, NEW o RUN: e' fuori dall'area gestita da BASIC.
            org   $7800

; --- port del PSG e registri usati ------------------------------------------
PSGREG      equ   64            ; $40: latch del registro da leggere/scrivere
PSGDAT      equ   65            ; $41: scrittura del dato nel registro latched
REG15       equ   15            ; port B = righe della matrice (uscita)
REG14       equ   14            ; port A = colonne della matrice (ingresso)
NROWS       equ   8
ENTRY       equ   $7810         ; indirizzo dell'ingresso (SYS): +16 dalla base

; ============================================================================
;  BLOCCO DI STATO - deve restare all'inizio: e' la parte che BASIC legge con
;  PEEK, quindi il suo indirizzo non cambia mai ($7800 = 30720).
; ============================================================================
RESULT:     defb  0             ; +0  K (o 1/0 in modo test)      <- PEEK(AD)
FLAGS:      defb  0             ; +1  stato dei 5 comandi         <- PEEK(AD+1)
IMG:        defs  8,0           ; +2..+9 righe 0..7 come lette dal PSG
SPZP:       defb  0             ; +10 SPAZIO al fotogramma precedente
            defs  5,0           ; +11..+15 riserva (l'ingresso sta a +16)

; ============================================================================
;  ENTRY POINT (qui salta SYS: AD+16 = 30736)
;  A = parametro: 0 = scansione e calcolo di K, altro = prova di un comando
;  (niente "org" qui: z80asm vuole un solo org, il riempimento qui sopra mette
;   il codice esattamente a ENTRY; build.js lo verifica)
; ============================================================================
KEYIN:      push  af
            push  bc
            push  de
            push  hl
            push  ix
            push  iy
            ld    (PRM),a           ; salva il parametro di SYS
            di                      ; nessuna scansione del firmware in mezzo
            call  ROWREAD           ; legge le 8 righe della matrice
            ei
            call  KFLAGS            ; flag dei 5 comandi (alias compresi)
            ld    a,(PRM)
            or    a
            jr    z,KSCAN
            call  KTST              ; modo test: "il comando X e' premuto?"
            jr    KEXIT
KSCAN:      call  KCALC             ; modo gioco: codice K con il fronte
KEXIT:      pop   iy
            pop   ix
            pop   hl
            pop   de
            pop   bc
            pop   af
            ret

; ============================================================================
;  ROWREAD - legge le 8 righe della matrice in IMG[0..7]
;  Sequenza del firmware (READKBLN): si seleziona il registro 15 (port B), si
;  scrive la maschera (un bit a 0 = riga attiva), si seleziona il registro 14
;  (port A) e si legge: bit a 0 = tasto premuto. La lettura si fa dalla porta
;  64 ($40 = "read from PSG"): la 65 e' il ciclo "inactive" e restituisce 0.
; ============================================================================
ROWREAD:    ld    hl,IMG
            ld    de,ROWMASKS
            ld    b,NROWS
RR01:       ld    a,REG15
            out   (PSGREG),a
            ld    a,(de)
            out   (PSGDAT),a
            ld    a,REG14
            out   (PSGREG),a
            in    a,(PSGREG)
            ld    (hl),a
            inc   hl
            inc   de
            djnz  RR01
            ret

; ============================================================================
;  KFLAGS - riempie FLAGS con lo stato dei 5 comandi (bit a 1 = premuto).
;  Ogni comando ha due posizioni: il cursore e il tasto alternativo (alias).
; ============================================================================
KFLAGS:     ld    c,0
; --- DESTRA: cursore destra (riga 6 bit 7) oppure L (riga 5 bit 2)
            ld    a,(IMG+6)
            and   $80
            jr    nz,KF01
            set   0,c
KF01:       ld    a,(IMG+5)
            and   $04
            jr    nz,KF02
            set   0,c
KF02:
; --- SU: cursore su (riga 5 bit 7) oppure I (riga 4 bit 1)
            ld    a,(IMG+5)
            and   $80
            jr    nz,KF03
            set   1,c
KF03:       ld    a,(IMG+4)
            and   $02
            jr    nz,KF04
            set   1,c
KF04:
; --- SINISTRA: cursore sinistra (riga 6 bit 0) oppure J (riga 4 bit 2)
            ld    a,(IMG+6)
            and   $01
            jr    nz,KF05
            set   2,c
KF05:       ld    a,(IMG+4)
            and   $04
            jr    nz,KF06
            set   2,c
KF06:
; --- GIU': cursore giu' (riga 5 bit 0) oppure K (riga 4 bit 5)
            ld    a,(IMG+5)
            and   $01
            jr    nz,KF07
            set   3,c
KF07:       ld    a,(IMG+4)
            and   $20
            jr    nz,KF08
            set   3,c
KF08:
; --- SPAZIO: barra (riga 0 bit 4) oppure Z (riga 1 bit 4)
            ld    a,(IMG+0)
            and   $10
            jr    nz,KF09
            set   4,c
KF09:       ld    a,(IMG+1)
            and   $10
            jr    nz,KF10
            set   4,c
KF10:       ld    a,c
            ld    (FLAGS),a
            ret

; ============================================================================
;  KCALC - dal byte FLAGS ricava il codice K del gioco.
;  Priorita' (vince l'ultimo controllo, come l'"on peek(1) goto" dell'originale):
;  SPAZIO > GIU' > SINISTRA > SU > DESTRA.
;  Lo SPAZIO viene dato solo sul FRONTE (0 -> 1): la matrice e' uno stato, non
;  un evento, quindi senza fronte si salterebbe a ogni fotogramma.
; ============================================================================
KCALC:      ld    a,(FLAGS)
            ld    b,a
            ld    c,0
            bit   0,a
            jr    z,KC01
            ld    c,29              ; DESTRA
KC01:       bit   1,a
            jr    z,KC02
            ld    c,30              ; SU
KC02:       bit   2,a
            jr    z,KC03
            ld    c,28              ; SINISTRA
KC03:       bit   3,a
            jr    z,KC04
            ld    c,31              ; GIU'
KC04:       ld    a,b
            and   $10               ; SPAZIO premuto adesso?
            ld    d,a               ; D = 0 oppure 16
            ld    a,(SPZP)          ; SPAZIO nel fotogramma precedente
            or    a
            jr    nz,KC06           ; era gia' premuto: nessun fronte
            ld    a,d
            or    a
            jr    z,KC06            ; adesso non e' premuto
            ld    c,32              ; fronte di salita: salto
KC06:       ld    a,d
            ld    (SPZP),a
            ld    a,c
            ld    (RESULT),a
            ret

; ============================================================================
;  KTST - modo test: A (passato da SYS) e' il codice di un comando (28..32);
;  lascia 1 in RESULT se il comando e' premuto, 0 se no o se il codice e' fuori
;  intervallo. Usa lo stato istantaneo (senza fronte), utile per le prove.
; ============================================================================
KTST:       ld    a,(PRM)
            sub   28
            cp    5
            jr    nc,KTNO           ; codice fuori intervallo
            ld    hl,BITTAB         ; bit dei FLAGS per i codici 28..32
            ld    e,a
            ld    d,0
            add   hl,de
            ld    a,(hl)
            ld    d,a
            ld    a,(FLAGS)
            and   d
            jr    z,KTNO
            ld    a,1
            jr    KTSV
KTNO:       xor   a
KTSV:       ld    (RESULT),a
            ret

; ============================================================================
;  DATI della routine (dopo il codice, non letti da BASIC)
; ============================================================================
ROWMASKS:   defb  $FE,$FD,$FB,$F7,$EF,$DF,$BF,$7F   ; righe 0..7 (bit a 0)
BITTAB:     defb  4,1,2,8,16    ; codici 28,29,30,31,32 -> bit di FLAGS
PRM:        defb  0             ; parametro di SYS (0 = scansione)
