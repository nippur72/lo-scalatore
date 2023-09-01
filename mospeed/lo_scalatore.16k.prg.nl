SGNFAC = $DC2B
MEMARG = $DA8C
ARGADD = $D86A
ARGAND = $CFE9
ARGDIV = $DB14
FACMUL = $DA30
MEMMUL = $DA28
FACADD = $D867
FACLOG = $D9EA
FACSQR = $DF71
FACEXPCALL = $DFED
FACABS = $DC58
FACSIN = $E268
FACCOS = $E261
FACTAN = $E2B1
FACATN = $E30B
FACSIG = $DC39
FACNOT = $CED4
FACRND = $E094
XFACWORD = $D7F7
FACDIV = $DB0F
BASINT = $DCCC
FACPOW = $DF7B
FACSUB = $D853
MEMSUB = $D850
FACOR = $CFE6
FACMEM = $DBD7
ARGFAC = $DBFC
FACARG = $DC0C
FACSTR = $DDDF
FACINT = $D1AA
RNDFAC = $DC1B
REALFAC = $DBA2
INTFAC = $D391
WRITETIS = $C9E7
GETTI = $DE68
GETTIME = $CF7E
COPYTIME = $CF87
TI2FAC = $CF84
CHROUT = $FFD2
PRINTSTRS = $CB25
VALS = $D7B5
CMPFAC = $DC5B
BYTEFAC = $D3A2
CRSRPOS = $FFF0
CRSRRIGHT = $CB3B
GETIN = $FFE4
INPUT = $C560
OPENCH = $FFC0
CLOSECH = $FFC3
CHKIN = $FFC6
CHKOUT = $FFC9
CLRCH = $FFCC
LOADXX = $FFD5
SAVEXX = $FFD8
TWAIT = $FFE1
ERRALL = $C437
ERRIQ = $D248
ERREI = $CCF4
ERRSYN = $CF08
ERRFNF = $F1E2
ARGSGN=$6E
ARGLO=$6D
ARGMO=$6C
ARGMOH=$6B
ARGHO=$6A
ARGEXP=$69
FACSGN=$66
FACLO=$65
FACMO=$64
FACMOH=$63
FACHO=$62
FACEXP=$61
FACOV=$70
OLDOV=$56
ARISGN=$6F
FAC=$61
RESLO=$29
RESMO=$28
RESMOH=$27
RESHO=$26
RESOV=$2A
RESHOP=$6F
FACHOP=$56
ITERCNT=$67
IOCHANNEL=$13
BASICSTART=$2B
BASICEND=$37
STATUS=$90
VERCHK=$93
SECADDR=$B9
DEVICENUM=$BA
FILELEN=$B7
LOGICADDR=$B8
FILEADDR=$BB
LOADEND=$C3
KEYNDX=$C6
INDEX1=$22
VALTYPE=$0D
LOWDS=$5D
TIMEADDR=$A0
BASICPOINTER=$7A
LOADOK_STATUS=64
LOFBUF=$FF
LOFBUFH=$100
INPUTBUF=$200
BASICBUFFER=820
TMP_ZP = 105
TMP2_ZP = 107
TMP3_ZP = 34
;make sure that JUMP_TARGET's low can't be $ff
JUMP_TARGET = 69
TMP_REG=71
G_REG=73
X_REG=61
*=8192
TSX
STX SP_SAVE
; *** CODE ***
PROGRAMSTART:
JSR START
;
LINE_0:
;
LDY #30
STY 648
; Optimizer rule: Simple POKE/2
LDY #240
STY 36869
; Optimizer rule: Simple POKE/2
LDY #150
STY 36866
; Optimizer rule: Simple POKE/2
LDA #<CONST_3
LDY #>CONST_3
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
LDY #255
STY 36869
; Optimizer rule: Simple POKE/2
LDY #143
STY 36878
; Optimized code for POKE
;
;
;
;
;
LDY #25
STY 36879
; Optimizer rule: Simple POKE/2
;
LINE_1:
;
LDA #<CONST_7R
LDY #>CONST_7R
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<CONST_8
LDY #>CONST_8
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_DO[]
LDY #>VAR_DO[]
STA G_REG
STY G_REG+1
JSR ARRAYSTORE_REAL
LDA #<CONST_9R
LDY #>CONST_9R
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<CONST_9R
LDY #>CONST_9R
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_DO[]
LDY #>VAR_DO[]
STA G_REG
STY G_REG+1
JSR ARRAYSTORE_REAL
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = RND(FAC)
JSR FACRND
JSR FACXREG
LDY #1
STY A_REG
; Optimizer rule: Omit XREG->FAC/3
JSR SHL
; Optimizer rule: Shorter SHL/4
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = INT(FAC)
JSR BASINT
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_DO[]
LDY #>VAR_DO[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
LDX #<VAR_DI
LDY #>VAR_DI
; FAC to (X/Y)
JSR FACMEM
;
LINE_2:
;
;
LINE_3:
LDX #4
dcloop229_1:
LDA CONST_10,X
STA VAR_KK,X
LDA CONST_9R,X
STA VAR_SC,X
LDA CONST_11R,X
STA VAR_CH,X
DEX
BPL dcloop229_1
; Special rule: Aggregation of assignments (3)
; Optimizer rule: Direct copy of floats into mem/6
LDA #0
STA VAR_E1
STA VAR_E1+1
STA VAR_E1+2
STA VAR_E1+3
STA VAR_E1+4
; Optimizer rule: Simplified setting to 0/6
LDA #<CONST_7R
LDY #>CONST_7R
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<CONST_12R
LDY #>CONST_12R
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_D[]
LDY #>VAR_D[]
STA G_REG
STY G_REG+1
JSR ARRAYSTORE_REAL
LDA #<CONST_9R
LDY #>CONST_9R
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<CONST_13
LDY #>CONST_13
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_D[]
LDY #>VAR_D[]
STA G_REG
STY G_REG+1
JSR ARRAYSTORE_REAL
LDA #<CONST_12R
LDY #>CONST_12R
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<CONST_14
LDY #>CONST_14
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_D[]
LDY #>VAR_D[]
STA G_REG
STY G_REG+1
JSR ARRAYSTORE_REAL
LDX #4
dcloop229_4:
LDA CONST_15R,X
STA VAR_Z,X
LDA CONST_9R,X
STA VAR_E3,X
LDA CONST_16R,X
STA VAR_Q,X
DEX
BPL dcloop229_4
; Special rule: Aggregation of assignments (3)
; Optimizer rule: Direct copy of floats into mem/6
;
LINE_10:
;
JSR GOSUB
JSR LINE_200
JSR GOSUB
JSR LINE_100
LDY #255
STY 36869
; Optimizer rule: Simple POKE/2
;
LINE_15:
;
JSR GOSUB
JSR LINE_70
LDA #0
STA VAR_H
STA VAR_H+1
STA VAR_H+2
STA VAR_H+3
STA VAR_H+4
; Optimizer rule: Simplified setting to 0/6
STA VAR_Y
STA VAR_Y+1
STA VAR_Y+2
STA VAR_Y+3
STA VAR_Y+4
; Optimizer rule: Simplified setting to 0/6
;
LINE_16:
;
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = RND(FAC)
JSR FACRND
JSR FACXREG
LDY #4
LDA #0
STY A_REG
STA A_REG+1
JSR COPY_XREG2YREG
; Optimizer rule: FAC already populated/6
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC = FAC<<A
JSR SHL
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDY #2
LDA #0
STY A_REG
STA A_REG+1
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
; FAC = FAC<<A
JSR SHL
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = INT(FAC)
JSR BASINT
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<CONST_17R
LDY #>CONST_17R
JSR REALFAC
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_S
LDY #>VAR_S
JSR FACMEM
; Optimizer rule: Omit FAC load/4
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF8+1
STA MOVBSELF8+2
MOVBSELF8:
LDA $FFFF
CMP #59
BCC PEEKLT0
BEQ PEEKEQ0
LDA #$FF
JMP PEEKDONE0
PEEKLT0:
LDA #$01
JMP PEEKDONE0
PEEKEQ0:
LDA #0
PEEKDONE0:
; Optimized comparison for PEEK
;
;
BEQ EQ_EQ0
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP EQ_SKIP0
EQ_EQ0:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
EQ_SKIP0:
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF9+1
STA MOVBSELF9+2
MOVBSELF9:
LDA $FFFF
CMP #62
BCC PEEKLT1
BEQ PEEKEQ1
LDA #$FF
JMP PEEKDONE1
PEEKLT1:
LDA #$01
JMP PEEKDONE1
PEEKEQ1:
LDA #0
PEEKDONE1:
; Optimized comparison for PEEK
;
;
BEQ EQ_EQ1
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP EQ_SKIP1
EQ_EQ1:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
EQ_SKIP1:
; Real in (A/Y) to FAC
JSR REALFAC
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL2X
; Optimizer rule: POPREAL and load X/1
JSR FASTOR
; Optimizer rule: POP, REG0, VAR0 -> direct calc/5
; Optimizer rule: Faster logic OR/1
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA X_REG
COMP_SKP0:
BEQ LINE_SKIP35
; Simplified conditional branch
;
LINE_NSKIP35:
;
JMP LINE_16
;
LINE_SKIP35:
;
;
LINE_17:
;
LDA #<VAR_S
LDY #>VAR_S
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF10+1
STA MOVBSELF10+2
MOVBSELF10:
LDY $FFFF
LDA #0
; integer in Y/A to FAC
JSR INTFAC
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_T
LDY #>VAR_T
; FAC to (X/Y)
JSR FACMEM
LDA #<VAR_S
LDY #>VAR_S
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF11+1
STA MOVBSELF11+2
LDA #$3A
MOVBSELF11:
STA $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF12+1
STA MOVBSELF12+2
LDA #$0
MOVBSELF12:
STA $FFFF
;
LINE_19:
;
LDA #<VAR_Y
LDY #>VAR_Y
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_B[]
LDY #>VAR_B[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
LDA #<CONST_23R
LDY #>CONST_23R
JSR REALFAC
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_V
LDY #>VAR_V
; FAC to (X/Y)
JSR FACMEM
LDX #4
dcloop229_7:
LDA CONST_20R,X
STA VAR_W,X
DEX
BPL dcloop229_7
; Optimizer rule: Direct copy of floats into mem/6
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = RND(FAC)
JSR FACRND
JSR FACXREG
LDY #1
STY A_REG
; Optimizer rule: Omit XREG->FAC/3
JSR SHL
; Optimizer rule: Shorter SHL/4
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = INT(FAC)
JSR BASINT
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_DO[]
LDY #>VAR_DO[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
LDX #<VAR_DO
LDY #>VAR_DO
; FAC to (X/Y)
JSR FACMEM
;
LINE_20:
;
LDA #<828
STA TMP_ZP
LDA #>828
STA TMP_ZP+1
JSR SYSTEMCALL
LDA #<900
STA TMP_ZP
LDA #>900
STA TMP_ZP+1
JSR SYSTEMCALL
LDA #<900
STA TMP_ZP
LDA #>900
STA TMP_ZP+1
JSR SYSTEMCALL
LDY 1
LDA #0
; integer in Y/A to FAC
STY TMP_ZP
; Optimizer rule: Remove INT conversions/1
; Optimizer rule: FAC 2 X_REG(2)/1
ON1SUB0:
LDX #1
CPX TMP_ZP
COMP_SKP1:
BNE AFTER1SUB0
JMP LINE_35
AFTER1SUB0:
ON1SUB1:
INX
CPX TMP_ZP
COMP_SKP2:
BNE AFTER1SUB1
JMP LINE_26
AFTER1SUB1:
ON1SUB2:
INX
CPX TMP_ZP
COMP_SKP3:
BNE AFTER1SUB2
JMP LINE_28
AFTER1SUB2:
ON1SUB3:
INX
CPX TMP_ZP
COMP_SKP4:
BNE AFTER1SUB3
JMP LINE_31
AFTER1SUB3:
ON1SUB4:
INX
CPX TMP_ZP
COMP_SKP5:
BNE AFTER1SUB4
JMP LINE_33
AFTER1SUB4:
; Optimized code for ON XX GOYYY
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
GSKIPON1:
;
LINE_21:
;
JMP LINE_41
;
LINE_26:
;
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF14+1
STA MOVBSELF14+2
MOVBSELF14:
LDA $FFFF
CMP #57
BCC PEEKLT2
BEQ PEEKEQ2
LDA #$FF
JMP PEEKDONE2
PEEKLT2:
LDA #$01
JMP PEEKDONE2
PEEKEQ2:
LDA #0
PEEKDONE2:
; Optimized comparison for PEEK
;
BEQ EQ_EQ2
LDA #0
JMP EQ_SKIP2
EQ_EQ2:
LDA #$1
EQ_SKIP2:
COMP_SKP6:
BNE LINE_NSKIP36
; Optimizer rule: Simplified CMP redux/7
JMP LINE_SKIP36
;
LINE_NSKIP36:
;
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<Y_REG
LDY #>Y_REG
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_T
LDY #>VAR_T
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF15+1
STA MOVBSELF15+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF15:
STY $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_27
LDY #>CONST_27
JSR REALFAC
LDA #<VAR_T
LDY #>VAR_T
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_D[]
LDY #>VAR_D[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF16+1
STA MOVBSELF16+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF16:
STY $FFFF
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_S
LDY #>VAR_S
; FAC to (X/Y)
JSR FACMEM
JMP LINE_40
;
LINE_SKIP36:
;
;
LINE_27:
;
JMP LINE_41
;
LINE_28:
;
LDX #4
dcloop229_8:
LDA CONST_8,X
STA VAR_DI,X
DEX
BPL dcloop229_8
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_28R
LDY #>CONST_28R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF17+1
STA MOVBSELF17+2
MOVBSELF17:
LDA $FFFF
CMP #62
BCC PEEKLT3
BEQ PEEKEQ3
LDA #$FF
JMP PEEKDONE3
PEEKLT3:
LDA #$01
JMP PEEKDONE3
PEEKEQ3:
LDA #0
PEEKDONE3:
; Optimized comparison for PEEK
;
;
BEQ LT_LT_EQ3
ROL
BCC LT_LT3
LT_LT_EQ3:
LDA #0
JMP LT_SKIP3
LT_LT3:
LDA #$1
LT_SKIP3:
COMP_SKP7:
BNE LINE_NSKIP37
; Optimizer rule: Simplified CMP redux/7
JMP LINE_SKIP37
;
LINE_NSKIP37:
;
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<Y_REG
LDY #>Y_REG
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_T
LDY #>VAR_T
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF18+1
STA MOVBSELF18+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF18:
STY $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_27
LDY #>CONST_27
JSR REALFAC
LDA #<VAR_T
LDY #>VAR_T
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_D[]
LDY #>VAR_D[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF19+1
STA MOVBSELF19+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF19:
STY $FFFF
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_S
LDY #>VAR_S
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_S
LDY #>VAR_S
; FAC to (X/Y)
JSR FACMEM
JMP LINE_40
;
LINE_SKIP37:
;
;
LINE_29:
;
LDA #<CONST_26
LDY #>CONST_26
JSR REALFAC
LDA #<VAR_T
LDY #>VAR_T
JSR CMPFAC
; Optimizer rule: Highly simplified loading for CMP/6
BNE NEQ_NEQ4
LDA #0
JMP NEQ_SKIP4
NEQ_NEQ4:
LDA #$1
NEQ_SKIP4:
COMP_SKP8:
BNE LINE_NSKIP38
; Optimizer rule: Simplified CMP redux/7
JMP LINE_SKIP38
;
LINE_NSKIP38:
;
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<Y_REG
LDY #>Y_REG
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_T
LDY #>VAR_T
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF20+1
STA MOVBSELF20+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF20:
STY $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_27
LDY #>CONST_27
JSR REALFAC
LDA #<VAR_T
LDY #>VAR_T
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_D[]
LDY #>VAR_D[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF21+1
STA MOVBSELF21+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF21:
STY $FFFF
LDA #<VAR_DI
LDY #>VAR_DI
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_S
LDY #>VAR_S
; FAC to (X/Y)
JSR FACMEM
LDA #<VAR_S
LDY #>VAR_S
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF22+1
STA MOVBSELF22+2
MOVBSELF22:
LDY $FFFF
LDA #0
; integer in Y/A to FAC
JSR INTFAC
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_T
LDY #>VAR_T
; FAC to (X/Y)
JSR FACMEM
JMP LINE_55
;
LINE_SKIP38:
;
;
LINE_30:
;
JMP LINE_41
;
LINE_31:
;
LDA #<CONST_26
LDY #>CONST_26
JSR REALFAC
LDA #<VAR_T
LDY #>VAR_T
JSR CMPFAC
; Optimizer rule: Highly simplified loading for CMP/6
BEQ EQ_EQ5
LDA #0
JMP EQ_SKIP5
EQ_EQ5:
LDA #$1
EQ_SKIP5:
COMP_SKP9:
BNE LINE_NSKIP39
; Optimizer rule: Simplified CMP redux/7
JMP LINE_SKIP39
;
LINE_NSKIP39:
;
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<Y_REG
LDY #>Y_REG
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_T
LDY #>VAR_T
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF23+1
STA MOVBSELF23+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF23:
STY $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_27
LDY #>CONST_27
JSR REALFAC
LDA #<VAR_T
LDY #>VAR_T
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_D[]
LDY #>VAR_D[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF24+1
STA MOVBSELF24+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF24:
STY $FFFF
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_S
LDY #>VAR_S
; FAC to (X/Y)
JSR FACMEM
JMP LINE_40
;
LINE_SKIP39:
;
;
LINE_32:
;
JMP LINE_41
;
LINE_33:
;
LDX #4
dcloop389_1:
LDA CONST_9R,X
STA VAR_DI,X
DEX
BPL dcloop389_1
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_29R
LDY #>CONST_29R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF25+1
STA MOVBSELF25+2
MOVBSELF25:
LDA $FFFF
CMP #62
BCC PEEKLT4
BEQ PEEKEQ4
LDA #$FF
JMP PEEKDONE4
PEEKLT4:
LDA #$01
JMP PEEKDONE4
PEEKEQ4:
LDA #0
PEEKDONE4:
; Optimized comparison for PEEK
;
;
BEQ LT_LT_EQ6
ROL
BCC LT_LT6
LT_LT_EQ6:
LDA #0
JMP LT_SKIP6
LT_LT6:
LDA #$1
LT_SKIP6:
COMP_SKP10:
BNE LINE_NSKIP40
; Optimizer rule: Simplified CMP redux/7
JMP LINE_SKIP40
;
LINE_NSKIP40:
;
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<Y_REG
LDY #>Y_REG
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_T
LDY #>VAR_T
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF26+1
STA MOVBSELF26+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF26:
STY $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_27
LDY #>CONST_27
JSR REALFAC
LDA #<VAR_T
LDY #>VAR_T
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_D[]
LDY #>VAR_D[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF27+1
STA MOVBSELF27+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF27:
STY $FFFF
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_S
LDY #>VAR_S
; FAC to (X/Y)
JSR FACMEM
JMP LINE_40
;
LINE_SKIP40:
;
;
LINE_34:
;
JMP LINE_29
;
LINE_35:
;
LDY #240
STY 36876
; Optimizer rule: Simple POKE/2
LDA #<VAR_T
LDY #>VAR_T
JSR COPY2_XYA_XREG
LDA #<VAR_S
LDY #>VAR_S
JSR REALFAC
JSR FACWORD
; Optimizer rule: No push, direct to FAC/7
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF29+1
STA MOVBSELF29+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF29:
STY $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_27
LDY #>CONST_27
JSR REALFAC
LDA #<VAR_T
LDY #>VAR_T
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_D[]
LDY #>VAR_D[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF30+1
STA MOVBSELF30+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF30:
STY $FFFF
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_DI
LDY #>VAR_DI
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_S
LDY #>VAR_S
JSR FACMEM
; Optimizer rule: Omit FAC load/4
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF31+1
STA MOVBSELF31+2
MOVBSELF31:
LDY $FFFF
LDA #0
; integer in Y/A to FAC
JSR INTFAC
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_T
LDY #>VAR_T
; FAC to (X/Y)
JSR FACMEM
LDA #<VAR_S
LDY #>VAR_S
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF32+1
STA MOVBSELF32+2
LDA #$3A
MOVBSELF32:
STA $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF33+1
STA MOVBSELF33+2
LDA #$0
MOVBSELF33:
STA $FFFF
LDX #4
dceloop1122_1:
LDA CONST_30R,X
CMP VAR_T,X
BNE LINE_SKIP41
DEX
BPL dceloop1122_1
; Optimizer rule: Direct compare(=) of floats/7
LINE_NSKIP41:
; Optimizer rule: Simplified equal comparison/6
;
JMP LINE_55
;
LINE_SKIP41:
;
;
LINE_36:
;
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF34+1
STA MOVBSELF34+2
MOVBSELF34:
LDA $FFFF
CMP #60
BCC PEEKLT5
BEQ PEEKEQ5
LDA #$FF
JMP PEEKDONE5
PEEKLT5:
LDA #$01
JMP PEEKDONE5
PEEKEQ5:
LDA #0
PEEKDONE5:
; Optimized comparison for PEEK
;
;
BEQ EQ_EQ8
LDA #0
JMP EQ_SKIP8
EQ_EQ8:
LDA #$1
EQ_SKIP8:
COMP_SKP12:
BNE LINE_NSKIP42
; Optimizer rule: Simplified CMP redux/7
JMP LINE_SKIP42
;
LINE_NSKIP42:
;
LDA #<CONST_31R
LDY #>CONST_31R
JSR REALFAC
LDA #<VAR_SS
LDY #>VAR_SS
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(1)/1
; Optimizer rule: FAC into REG?, REG? into FAC (2)/3
LDX #<VAR_SS
LDY #>VAR_SS
; FAC to (X/Y)
JSR FACMEM
LDA #<CONST_32
LDY #>CONST_32
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
JSR COMPACTMAX
LDA #<VAR_SS
LDY #>VAR_SS
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
; ignored: CHGCTX #1
JSR STR
LDY A_REG
LDA A_REG+1
STY B_REG
STA B_REG+1
; ignored: CHGCTX #0
JSR LEN
JSR COPY_XREG2YREG
; Optimizer rule: Direct copy from X to Y/1
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Improved copy from REG0 to REG1/7
LDA #<CONST_33R
LDY #>CONST_33R
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR FACYREG
; Optimizer rule: FAC 2 Y_REG(2)/1
; ignored: CHGCTX #1
JSR TAB
LDA #<VAR_SS
LDY #>VAR_SS
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR REALOUT
JSR CHECKCMD
JSR LINEBREAK
;
LINE_SKIP42:
;
;
LINE_37:
;
LDX #4
dcloop389_2:
LDA CONST_9R,X
STA VAR_N,X
DEX
BPL dcloop389_2
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_24R
LDY #>CONST_24R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_9R
LDY #>CONST_9R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<FORLOOP0
STA JUMP_TARGET
LDA #>FORLOOP0
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP0:
LDA #<900
STA TMP_ZP
LDA #>900
STA TMP_ZP+1
JSR SYSTEMCALL
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_0
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_0:
LDA #<VAR_T
LDY #>VAR_T
JSR COPY2_XYA_XREG
LDA #<VAR_S
LDY #>VAR_S
JSR REALFAC
JSR FACWORD
; Optimizer rule: No push, direct to FAC/7
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF35+1
STA MOVBSELF35+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF35:
STY $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_27
LDY #>CONST_27
JSR REALFAC
LDA #<VAR_T
LDY #>VAR_T
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_D[]
LDY #>VAR_D[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF36+1
STA MOVBSELF36+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF36:
STY $FFFF
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_DI
LDY #>VAR_DI
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_S
LDY #>VAR_S
JSR FACMEM
; Optimizer rule: Omit FAC load/4
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF37+1
STA MOVBSELF37+2
MOVBSELF37:
LDY $FFFF
LDA #0
; integer in Y/A to FAC
JSR INTFAC
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_T
LDY #>VAR_T
; FAC to (X/Y)
JSR FACMEM
LDA #<VAR_S
LDY #>VAR_S
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF38+1
STA MOVBSELF38+2
LDA #$3A
MOVBSELF38:
STA $FFFF
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF39+1
STA MOVBSELF39+2
MOVBSELF39:
LDA $FFFF
CMP #61
BCC PEEKLT6
BEQ PEEKEQ6
LDA #$FF
JMP PEEKDONE6
PEEKLT6:
LDA #$01
JMP PEEKDONE6
PEEKEQ6:
LDA #0
PEEKDONE6:
; Optimized comparison for PEEK
;
;
ROL
BCS GT_GT9
LDA #0
JMP GT_SKIP9
GT_GT9:
LDA #$1
GT_SKIP9:
COMP_SKP14:
BEQ LINE_SKIP43
; Simplified conditional branch
;
LINE_NSKIP43:
;
JMP LINE_55
;
LINE_SKIP43:
;
;
LINE_38:
;
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF40+1
STA MOVBSELF40+2
LDA #$0
MOVBSELF40:
STA $FFFF
LDY #0
STY 36876
; Optimizer rule: Simple POKE/2
JMP LINE_41
;
LINE_40:
;
LDY #200
STY 36876
; Optimizer rule: Simple POKE/2
LDX #4
dcloop389_3:
LDA CONST_9R,X
STA VAR_N,X
DEX
BPL dcloop389_3
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_25R
LDY #>CONST_25R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_9R
LDY #>CONST_9R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<FORLOOP1
STA JUMP_TARGET
LDA #>FORLOOP1
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP1:
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_1
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_1:
LDY #0
STY 36876
; Optimizer rule: Simple POKE/2
LDA #<VAR_S
LDY #>VAR_S
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF44+1
STA MOVBSELF44+2
MOVBSELF44:
LDY $FFFF
LDA #0
; integer in Y/A to FAC
JSR INTFAC
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_T
LDY #>VAR_T
; FAC to (X/Y)
JSR FACMEM
LDA #<VAR_S
LDY #>VAR_S
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF45+1
STA MOVBSELF45+2
LDA #$3A
MOVBSELF45:
STA $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF46+1
STA MOVBSELF46+2
LDA #$0
MOVBSELF46:
STA $FFFF
LDA #<900
STA TMP_ZP
LDA #>900
STA TMP_ZP+1
JSR SYSTEMCALL
;
LINE_41:
;
LDA #<CONST_34R
LDY #>CONST_34R
JSR REALFAC
LDA #<VAR_T
LDY #>VAR_T
JSR CMPFAC
; Optimizer rule: Highly simplified loading for CMP/6
BEQ EQ_EQ10
LDA #0
JMP EQ_SKIP10
EQ_EQ10:
LDA #$1
EQ_SKIP10:
COMP_SKP16:
BNE LINE_NSKIP44
; Optimizer rule: Simplified CMP redux/7
JMP LINE_SKIP44
;
LINE_NSKIP44:
;
LDY #252
LDA #0
; Optimized code for CONST into Y/A
;
;
;
;
;
;
;
;
;
STY 36877
LDA #<CONST_2R
LDY #>CONST_2R
JSR REALFAC
LDA #<VAR_SS
LDY #>VAR_SS
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(1)/1
; Optimizer rule: FAC into REG?, REG? into FAC (2)/3
LDX #<VAR_SS
LDY #>VAR_SS
; FAC to (X/Y)
JSR FACMEM
LDA #<CONST_32
LDY #>CONST_32
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
JSR COMPACTMAX
LDA #<VAR_SS
LDY #>VAR_SS
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
; ignored: CHGCTX #1
JSR STR
LDY A_REG
LDA A_REG+1
STY B_REG
STA B_REG+1
; ignored: CHGCTX #0
JSR LEN
JSR COPY_XREG2YREG
; Optimizer rule: Direct copy from X to Y/1
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Improved copy from REG0 to REG1/7
LDA #<CONST_33R
LDY #>CONST_33R
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR FACYREG
; Optimizer rule: FAC 2 Y_REG(2)/1
; ignored: CHGCTX #1
JSR TAB
LDA #<VAR_SS
LDY #>VAR_SS
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR REALOUT
JSR CHECKCMD
JSR LINEBREAK
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_H
LDY #>VAR_H
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_H
LDY #>VAR_H
; FAC to (X/Y)
JSR FACMEM
LDX #4
dcloop549_1:
LDA CONST_20R,X
STA VAR_T,X
DEX
BPL dcloop549_1
; Optimizer rule: Direct copy of floats into mem/6
LDY #0
LDA #0
; Optimized code for CONST into Y/A
;
;
;
;
;
;
;
;
;
STY 36877
LDX #4
dceloop1122_2:
LDA CONST_37R,X
CMP VAR_H,X
BNE LINE_SKIP45
DEX
BPL dceloop1122_2
; Optimizer rule: Direct compare(=) of floats/7
LINE_NSKIP45:
; Optimizer rule: Simplified equal comparison/6
;
JMP LINE_64
;
LINE_SKIP45:
;
;
LINE_SKIP44:
;
;
LINE_42:
;
LDX #4
dceloop1122_3:
LDA CONST_30R,X
CMP VAR_T,X
BNE LINE_SKIP46
DEX
BPL dceloop1122_3
; Optimizer rule: Direct compare(=) of floats/7
LINE_NSKIP46:
; Optimizer rule: Simplified equal comparison/6
;
JMP LINE_55
;
LINE_SKIP46:
;
;
LINE_43:
;
JSR GOSUB
JSR LINE_98
;
LINE_45:
;
LDA #<900
STA TMP_ZP
LDA #>900
STA TMP_ZP+1
JSR SYSTEMCALL
LDA #<900
STA TMP_ZP
LDA #>900
STA TMP_ZP+1
JSR SYSTEMCALL
LDA #<VAR_W
LDY #>VAR_W
JSR COPY2_XYA_XREG
LDA #<VAR_V
LDY #>VAR_V
JSR REALFAC
JSR FACWORD
; Optimizer rule: No push, direct to FAC/7
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF49+1
STA MOVBSELF49+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF49:
STY $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
LDA #<VAR_V
LDY #>VAR_V
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_27
LDY #>CONST_27
JSR REALFAC
LDA #<VAR_W
LDY #>VAR_W
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_D[]
LDY #>VAR_D[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF50+1
STA MOVBSELF50+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF50:
STY $FFFF
LDA #<VAR_DO
LDY #>VAR_DO
JSR REALFAC
LDA #<VAR_V
LDY #>VAR_V
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_V
LDY #>VAR_V
JSR FACMEM
; Optimizer rule: Omit FAC load/4
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF51+1
STA MOVBSELF51+2
MOVBSELF51:
LDY $FFFF
LDA #0
; integer in Y/A to FAC
JSR INTFAC
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_W
LDY #>VAR_W
; FAC to (X/Y)
JSR FACMEM
LDA #<VAR_V
LDY #>VAR_V
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF52+1
STA MOVBSELF52+2
LDA #$3C
MOVBSELF52:
STA $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
LDA #<VAR_V
LDY #>VAR_V
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF53+1
STA MOVBSELF53+2
LDA #$6
MOVBSELF53:
STA $FFFF
;
LINE_46:
;
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_V
LDY #>VAR_V
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF54+1
STA MOVBSELF54+2
MOVBSELF54:
LDA $FFFF
CMP #56
BCC PEEKLT7
BEQ PEEKEQ7
LDA #$FF
JMP PEEKDONE7
PEEKLT7:
LDA #$01
JMP PEEKDONE7
PEEKEQ7:
LDA #0
PEEKDONE7:
; Optimized comparison for PEEK
;
;
BEQ EQ_EQ13
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP EQ_SKIP13
EQ_EQ13:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
EQ_SKIP13:
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_DO
LDY #>VAR_DO
JSR CMPFAC
; Optimizer rule: Highly simplified loading for CMP/6
BEQ EQ_EQ14
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP EQ_SKIP14
EQ_EQ14:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
EQ_SKIP14:
; Real in (A/Y) to FAC
JSR REALFAC
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL2X
; Optimizer rule: POPREAL and load X/1
JSR FASTAND
; Optimizer rule: POP, REG0, VAR0 -> direct calc/5
; Optimizer rule: Faster logic AND/1
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA X_REG
COMP_SKP19:
BNE LINE_NSKIP47
; Optimizer rule: CMP (REG) != 0(2)/3
JMP LINE_SKIP47
;
LINE_NSKIP47:
;
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = RND(FAC)
JSR FACRND
JSR FACXREG
LDY #1
STY A_REG
; Optimizer rule: Omit XREG->FAC/3
JSR SHL
; Optimizer rule: Shorter SHL/4
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = INT(FAC)
JSR BASINT
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_DO[]
LDY #>VAR_DO[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
LDX #<VAR_DO
LDY #>VAR_DO
; FAC to (X/Y)
JSR FACMEM
JMP LINE_48
;
LINE_SKIP47:
;
;
LINE_47:
;
LDX #4
dceloop1122_4:
LDA CONST_39R,X
CMP VAR_W,X
BNE LINE_SKIP48
DEX
BPL dceloop1122_4
; Optimizer rule: Direct compare(=) of floats/7
LINE_NSKIP48:
; Optimizer rule: Simplified equal comparison/6
;
LDX #4
dcloop549_2:
LDA CONST_19R,X
STA VAR_DO,X
DEX
BPL dcloop549_2
; Optimizer rule: Direct copy of floats into mem/6
;
LINE_SKIP48:
;
;
LINE_48:
;
LDX #4
dceloop1122_5:
LDA CONST_21R,X
CMP VAR_W,X
BNE LINE_SKIP49
DEX
BPL dceloop1122_5
; Optimizer rule: Direct compare(=) of floats/7
LINE_NSKIP49:
; Optimizer rule: Simplified equal comparison/6
;
JMP LINE_55
;
LINE_SKIP49:
;
;
LINE_49:
;
LDA #<CONST_40R
LDY #>CONST_40R
JSR REALFAC
LDA #<VAR_V
LDY #>VAR_V
JSR CMPFAC
; Optimizer rule: Highly simplified loading for CMP/6
BEQ LT_LT_EQ17
ROL
BCC LT_LT17
LT_LT_EQ17:
LDA #0
JMP LT_SKIP17
LT_LT17:
LDA #$1
LT_SKIP17:
COMP_SKP22:
BEQ LINE_SKIP50
; Simplified conditional branch
;
LINE_NSKIP50:
;
JMP LINE_20
;
LINE_SKIP50:
;
;
LINE_50:
;
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_Y
LDY #>VAR_Y
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_Y
LDY #>VAR_Y
; FAC to (X/Y)
JSR FACMEM
LDX #4
dceloop1122_6:
LDA CONST_41R,X
CMP VAR_Y,X
BNE LINE_SKIP51
DEX
BPL dceloop1122_6
; Optimizer rule: Direct compare(=) of floats/7
LINE_NSKIP51:
; Optimizer rule: Simplified equal comparison/6
;
JMP LINE_55
;
LINE_SKIP51:
;
;
LINE_51:
;
LDA #<VAR_V
LDY #>VAR_V
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF55+1
STA MOVBSELF55+2
LDA #$3E
MOVBSELF55:
STA $FFFF
JMP LINE_19
;
LINE_55:
;
LDY #0
STY 36876
; Optimizer rule: Simple POKE/2
LDX #4
dcloop549_3:
LDA CONST_42R,X
STA VAR_SO,X
DEX
BPL dcloop549_3
; Optimizer rule: Direct copy of floats into mem/6
LDX #4
dceloop1122_7:
LDA CONST_30R,X
CMP VAR_T,X
BNE LINE_SKIP52
DEX
BPL dceloop1122_7
; Optimizer rule: Direct compare(=) of floats/7
LINE_NSKIP52:
; Optimizer rule: Simplified equal comparison/6
;
LDX #4
dcloop549_4:
LDA VAR_W,X
STA VAR_T,X
DEX
BPL dcloop549_4
; Optimizer rule: Direct copy of floats into mem/6
;
LINE_SKIP52:
;
;
LINE_56:
;
LDA #<VAR_SO
LDY #>VAR_SO
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(2)/1
; FAC to integer in Y/A
JSR FACWORD
STY 36874
LDA #<CONST_40R
LDY #>CONST_40R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR CMPFAC
; Optimizer rule: Highly simplified loading for CMP/6
BEQ LT_LT_EQ20
ROL
BCC LT_LT20
LT_LT_EQ20:
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP LT_SKIP20
LT_LT20:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
LT_SKIP20:
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF58+1
STA MOVBSELF58+2
MOVBSELF58:
LDA $FFFF
CMP #56
BCC PEEKLT8
BEQ PEEKEQ8
LDA #$FF
JMP PEEKDONE8
PEEKLT8:
LDA #$01
JMP PEEKDONE8
PEEKEQ8:
LDA #0
PEEKDONE8:
; Optimized comparison for PEEK
;
;
BNE NEQ_NEQ21
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP NEQ_SKIP21
NEQ_NEQ21:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
NEQ_SKIP21:
; Real in (A/Y) to FAC
JSR REALFAC
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL2X
; Optimizer rule: POPREAL and load X/1
JSR FASTAND
; Optimizer rule: POP, REG0, VAR0 -> direct calc/5
; Optimizer rule: Faster logic AND/1
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA X_REG
COMP_SKP25:
BNE LINE_NSKIP53
; Optimizer rule: CMP (REG) != 0(2)/3
JMP LINE_SKIP53
;
LINE_NSKIP53:
;
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<Y_REG
LDY #>Y_REG
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_T
LDY #>VAR_T
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF59+1
STA MOVBSELF59+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF59:
STY $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_27
LDY #>CONST_27
JSR REALFAC
LDA #<VAR_T
LDY #>VAR_T
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_D[]
LDY #>VAR_D[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF60+1
STA MOVBSELF60+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF60:
STY $FFFF
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_S
LDY #>VAR_S
; FAC to (X/Y)
JSR FACMEM
LDA #<VAR_S
LDY #>VAR_S
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF61+1
STA MOVBSELF61+2
MOVBSELF61:
LDY $FFFF
LDA #0
; integer in Y/A to FAC
JSR INTFAC
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_T
LDY #>VAR_T
; FAC to (X/Y)
JSR FACMEM
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF62+1
STA MOVBSELF62+2
LDA #$3A
MOVBSELF62:
STA $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF63+1
STA MOVBSELF63+2
LDA #$0
MOVBSELF63:
STA $FFFF
;
LINE_SKIP53:
;
;
LINE_57:
;
LDX #4
dcloop549_5:
LDA CONST_9R,X
STA VAR_N,X
DEX
BPL dcloop549_5
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_24R
LDY #>CONST_24R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_9R
LDY #>CONST_9R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<FORLOOP2
STA JUMP_TARGET
LDA #>FORLOOP2
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP2:
LDA #<900
STA TMP_ZP
LDA #>900
STA TMP_ZP+1
JSR SYSTEMCALL
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_2
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_2:
LDA #<CONST_25R
LDY #>CONST_25R
JSR REALFAC
LDA #<VAR_SO
LDY #>VAR_SO
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_SO
LDY #>VAR_SO
; FAC to (X/Y)
JSR FACMEM
LDA #<CONST_2R
LDY #>CONST_2R
JSR REALFAC
LDA #<VAR_SO
LDY #>VAR_SO
JSR CMPFAC
; Optimizer rule: Highly simplified loading for CMP/6
ROL
BCS GT_GT22
LDA #0
JMP GT_SKIP22
GT_GT22:
LDA #$1
GT_SKIP22:
COMP_SKP27:
BEQ LINE_SKIP54
; Simplified conditional branch
;
LINE_NSKIP54:
;
JMP LINE_56
;
LINE_SKIP54:
;
;
LINE_58:
;
LDY #0
STY 36874
; Optimizer rule: Simple POKE/2
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_CH
LDY #>VAR_CH
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_CH
LDY #>VAR_CH
; FAC to (X/Y)
JSR FACMEM
LDX #4
dceloop1122_8:
LDA CONST_8,X
CMP VAR_CH,X
BNE LINE_SKIP55
DEX
BPL dceloop1122_8
; Optimizer rule: Direct compare(=) of floats/7
LINE_NSKIP55:
; Optimizer rule: Simplified equal comparison/6
;
JMP LINE_300
;
LINE_SKIP55:
;
;
LINE_59:
;
LDA #<CONST_32
LDY #>CONST_32
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
LDA #<CONST_43R
LDY #>CONST_43R
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
; ignored: CHGCTX #1
JSR TAB
LDA #<VAR_CH
LDY #>VAR_CH
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR REALOUT
JSR CHECKCMD
JSR LINEBREAK
LDA #<VAR_W
LDY #>VAR_W
JSR COPY2_XYA_XREG
LDA #<VAR_V
LDY #>VAR_V
JSR REALFAC
JSR FACWORD
; Optimizer rule: No push, direct to FAC/7
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF65+1
STA MOVBSELF65+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF65:
STY $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
LDA #<VAR_V
LDY #>VAR_V
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_27
LDY #>CONST_27
JSR REALFAC
LDA #<VAR_W
LDY #>VAR_W
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_D[]
LDY #>VAR_D[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF66+1
STA MOVBSELF66+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF66:
STY $FFFF
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_Y
LDY #>VAR_Y
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_Y
LDY #>VAR_Y
; FAC to (X/Y)
JSR FACMEM
LDA #<CONST_21R
LDY #>CONST_21R
JSR REALFAC
LDA #<VAR_W
LDY #>VAR_W
JSR CMPFAC
; Optimizer rule: Highly simplified loading for CMP/6
BEQ EQ_EQ24
LDA #0
JMP EQ_SKIP24
EQ_EQ24:
LDA #$1
EQ_SKIP24:
COMP_SKP29:
BNE LINE_NSKIP56
; Optimizer rule: Simplified CMP redux/7
JMP LINE_SKIP56
;
LINE_NSKIP56:
;
LDA #<VAR_V
LDY #>VAR_V
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<Y_REG
LDY #>Y_REG
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_T
LDY #>VAR_T
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF67+1
STA MOVBSELF67+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF67:
STY $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_V
LDY #>VAR_V
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_27
LDY #>CONST_27
JSR REALFAC
LDA #<VAR_T
LDY #>VAR_T
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_D[]
LDY #>VAR_D[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF68+1
STA MOVBSELF68+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF68:
STY $FFFF
;
LINE_SKIP56:
;
;
LINE_60:
;
LDA #<CONST_44R
LDY #>CONST_44R
JSR REALFAC
LDA #<VAR_Y
LDY #>VAR_Y
JSR CMPFAC
; Optimizer rule: Highly simplified loading for CMP/6
ROL
BCS GT_GT25
LDA #0
JMP GT_SKIP25
GT_GT25:
LDA #$1
GT_SKIP25:
COMP_SKP30:
BEQ LINE_SKIP57
; Simplified conditional branch
;
LINE_NSKIP57:
;
JMP LINE_15
;
LINE_SKIP57:
;
;
LINE_61:
;
LDA #<CONST_45R
LDY #>CONST_45R
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR CMPFAC
; Optimizer rule: Highly simplified loading for CMP/6
ROL
BCS GT_GT26
LDA #0
JMP GT_SKIP26
GT_GT26:
LDA #$1
GT_SKIP26:
COMP_SKP31:
BNE LINE_NSKIP58
; Optimizer rule: Simplified CMP redux/7
JMP LINE_SKIP58
;
LINE_NSKIP58:
;
LDA #<VAR_S
LDY #>VAR_S
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<Y_REG
LDY #>Y_REG
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_T
LDY #>VAR_T
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR POPREAL
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF69+1
STA MOVBSELF69+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF69:
STY $FFFF
JMP LINE_16
;
LINE_SKIP58:
;
;
LINE_62:
;
LDA #<VAR_S
LDY #>VAR_S
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF70+1
STA MOVBSELF70+2
LDA #$3A
MOVBSELF70:
STA $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
LDA #<VAR_S
LDY #>VAR_S
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF71+1
STA MOVBSELF71+2
LDA #$0
MOVBSELF71:
STA $FFFF
JMP LINE_19
;
LINE_64:
;
LDX #4
dceloop1122_9:
LDA CONST_46R,X
CMP VAR_Y,X
BNE LINE_SKIP59
DEX
BPL dceloop1122_9
; Optimizer rule: Direct compare(=) of floats/7
LINE_NSKIP59:
; Optimizer rule: Simplified equal comparison/6
;
JMP LINE_67
;
LINE_SKIP59:
;
;
LINE_65:
;
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_Y
LDY #>VAR_Y
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_N
LDY #>VAR_N
; FAC to (X/Y)
JSR FACMEM
LDA #<CONST_46R
LDY #>CONST_46R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_9R
LDY #>CONST_9R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<FORLOOP3
STA JUMP_TARGET
LDA #>FORLOOP3
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP3:
LDA #<VAR_N
LDY #>VAR_N
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_B[]
LDY #>VAR_B[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
LDA #<CONST_23R
LDY #>CONST_23R
JSR REALFAC
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF72+1
STA MOVBSELF72+2
LDA #$3E
MOVBSELF72:
STA $FFFF
LDA #<CONST_47R
LDY #>CONST_47R
JSR REALFAC
LDA #<VAR_SS
LDY #>VAR_SS
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(1)/1
; Optimizer rule: FAC into REG?, REG? into FAC (2)/3
LDX #<VAR_SS
LDY #>VAR_SS
; FAC to (X/Y)
JSR FACMEM
LDA #<CONST_32
LDY #>CONST_32
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
JSR COMPACTMAX
LDA #<VAR_SS
LDY #>VAR_SS
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
; ignored: CHGCTX #1
JSR STR
LDY A_REG
LDA A_REG+1
STY B_REG
STA B_REG+1
; ignored: CHGCTX #0
JSR LEN
JSR COPY_XREG2YREG
; Optimizer rule: Direct copy from X to Y/1
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Improved copy from REG0 to REG1/7
LDA #<CONST_33R
LDY #>CONST_33R
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR FACYREG
; Optimizer rule: FAC 2 Y_REG(2)/1
; ignored: CHGCTX #1
JSR TAB
LDA #<VAR_SS
LDY #>VAR_SS
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR REALOUT
JSR CHECKCMD
JSR LINEBREAK
JSR GOSUB
JSR LINE_98
;
LINE_66:
;
LDY #250
STY 36877
; Optimizer rule: Simple POKE/2
LDX #4
dcloop709_1:
LDA CONST_1R,X
STA VAR_M,X
DEX
BPL dcloop709_1
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_42R
LDY #>CONST_42R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_9R
LDY #>CONST_9R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_M
LDY #>VAR_M
STA A_REG
STY A_REG+1
LDA #<FORLOOP4
STA JUMP_TARGET
LDA #>FORLOOP4
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP4:
LDA #<900
STA TMP_ZP
LDA #>900
STA TMP_ZP+1
JSR SYSTEMCALL
LDA #<VAR_M
LDY #>VAR_M
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(2)/1
; FAC to integer in Y/A
JSR FACWORD
STY 36876
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_3
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_3:
LDY #0
STY 36876
; Optimizer rule: Simple POKE/2
STY 36877
; Optimizer rule: Simple POKE/2
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_4
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_4:
;
LINE_67:
;
LDA #<CONST_48
LDY #>CONST_48
JSR REALFAC
LDA #<VAR_E2
LDY #>VAR_E2
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_E2
LDY #>VAR_E2
; FAC to (X/Y)
JSR FACMEM
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_SC
LDY #>VAR_SC
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_SC
LDY #>VAR_SC
; FAC to (X/Y)
JSR FACMEM
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_E1
LDY #>VAR_E1
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_E1
LDY #>VAR_E1
; FAC to (X/Y)
JSR FACMEM
LDA #<CONST_33R
LDY #>CONST_33R
JSR REALFAC
LDA #<VAR_E1
LDY #>VAR_E1
JSR CMPFAC
; Optimizer rule: Highly simplified loading for CMP/6
ROL
BCS GT_GT28
LDA #0
JMP GT_SKIP28
GT_GT28:
LDA #$1
GT_SKIP28:
COMP_SKP35:
BEQ LINE_SKIP60
; Simplified conditional branch
;
LINE_NSKIP60:
;
LDX #4
dcloop709_2:
LDA CONST_33R,X
STA VAR_E1,X
DEX
BPL dcloop709_2
; Optimizer rule: Direct copy of floats into mem/6
;
LINE_SKIP60:
;
;
LINE_68:
;
JMP LINE_15
;
LINE_69:
;
JMP LINE_69
;
LINE_70:
;
LDA #<CONST_49
LDY #>CONST_49
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
LDX #4
dcloop709_3:
LDA CONST_9R,X
STA VAR_N,X
DEX
BPL dcloop709_3
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_28R
LDY #>CONST_28R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_9R
LDY #>CONST_9R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<FORLOOP5
STA JUMP_TARGET
LDA #>FORLOOP5
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP5:
LDA #<CONST_50
LDY #>CONST_50
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_5
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_5:
LDA #<CONST_50
LDY #>CONST_50
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
LDA #<CONST_51
LDY #>CONST_51
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_71:
;
LDA #<CONST_52
LDY #>CONST_52
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
LDA #<CONST_53R
LDY #>CONST_53R
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
; ignored: CHGCTX #1
JSR TAB
LDA #<CONST_54
LDY #>CONST_54
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
LDA #<CONST_53R
LDY #>CONST_53R
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
; ignored: CHGCTX #1
JSR TAB
LDA #<CONST_55
LDY #>CONST_55
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
LDA #<CONST_53R
LDY #>CONST_53R
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
; ignored: CHGCTX #1
JSR TAB
LDA #<CONST_56
LDY #>CONST_56
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
LDA #<CONST_53R
LDY #>CONST_53R
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
; ignored: CHGCTX #1
JSR TAB
LDA #<CONST_57
LDY #>CONST_57
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_72:
;
LDX #4
dcloop709_4:
LDA CONST_9R,X
STA VAR_N,X
DEX
BPL dcloop709_4
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_24R
LDY #>CONST_24R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_9R
LDY #>CONST_9R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<FORLOOP6
STA JUMP_TARGET
LDA #>FORLOOP6
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP6:
LDA #<CONST_58
LDY #>CONST_58
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
LDA #<CONST_59
LDY #>CONST_59
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_6
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_6:
LDA #<CONST_58
LDY #>CONST_58
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
LDA #<CONST_51
LDY #>CONST_51
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
LDY #62
STY 8185
; Optimizer rule: Simple POKE/2
;
LINE_73:
;
LDA #<CONST_60
LDY #>CONST_60
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
JSR COMPACTMAX
LDA #<VAR_SS
LDY #>VAR_SS
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
; ignored: CHGCTX #1
JSR STR
LDY A_REG
LDA A_REG+1
STY B_REG
STA B_REG+1
; ignored: CHGCTX #0
JSR LEN
JSR COPY_XREG2YREG
; Optimizer rule: Direct copy from X to Y/1
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Improved copy from REG0 to REG1/7
LDA #<CONST_33R
LDY #>CONST_33R
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR FACYREG
; Optimizer rule: FAC 2 Y_REG(2)/1
; ignored: CHGCTX #1
JSR TAB
LDA #<VAR_SS
LDY #>VAR_SS
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR REALOUT
JSR CRSRRIGHT
LDA #<CONST_43R
LDY #>CONST_43R
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
; ignored: CHGCTX #1
JSR TAB
LDA #<VAR_CH
LDY #>VAR_CH
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR REALOUT
JSR CRSRRIGHT
LDA #<CONST_61R
LDY #>CONST_61R
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
; ignored: CHGCTX #1
JSR TAB
LDA #<VAR_SC
LDY #>VAR_SC
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR REALOUT
JSR CHECKCMD
JSR LINEBREAK
LDY #163
STY 7697
; Optimizer rule: Simple POKE/2
LDA #0
STA VAR_N
STA VAR_N+1
STA VAR_N+2
STA VAR_N+3
STA VAR_N+4
; Optimizer rule: Simplified setting to 0/6
LDA #<CONST_46R
LDY #>CONST_46R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_9R
LDY #>CONST_9R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<FORLOOP7
STA JUMP_TARGET
LDA #>FORLOOP7
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP7:
LDA #<VAR_N
LDY #>VAR_N
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_B[]
LDY #>VAR_B[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
LDA #<CONST_23R
LDY #>CONST_23R
JSR REALFAC
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF79+1
STA MOVBSELF79+2
LDA #$3C
MOVBSELF79:
STA $FFFF
;
LINE_74:
;
LDA #<VAR_N
LDY #>VAR_N
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_B[]
LDY #>VAR_B[]
JSR ARRAYACCESS_REAL_S
; Optimizer rule: Memory saving array access (real)/3
LDA #<CONST_23R
LDY #>CONST_23R
JSR REALFAC
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF80+1
STA MOVBSELF80+2
LDA #$6
MOVBSELF80:
STA $FFFF
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_7
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_7:
LDX #4
dcloop869_1:
LDA CONST_63R,X
STA VAR_N,X
DEX
BPL dcloop869_1
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_40R
LDY #>CONST_40R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_64R
LDY #>CONST_64R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<FORLOOP8
STA JUMP_TARGET
LDA #>FORLOOP8
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP8:
LDX #4
dceloop1122_10:
LDA CONST_40R,X
CMP VAR_N,X
BNE LINE_SKIP61
DEX
BPL dceloop1122_10
; Optimizer rule: Direct compare(=) of floats/7
LINE_NSKIP61:
; Optimizer rule: Simplified equal comparison/6
;
JMP LINE_80
;
LINE_SKIP61:
;
;
LINE_75:
;
LDX #4
dcloop869_2:
LDA CONST_9R,X
STA VAR_O,X
DEX
BPL dcloop869_2
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_24R
LDY #>CONST_24R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_9R
LDY #>CONST_9R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_O
LDY #>VAR_O
STA A_REG
STY A_REG+1
LDA #<FORLOOP9
STA JUMP_TARGET
LDA #>FORLOOP9
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP9:
;
LINE_76:
;
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = RND(FAC)
JSR FACRND
JSR FACXREG
LDY #4
LDA #0
STY A_REG
STA A_REG+1
JSR COPY_XREG2YREG
; Optimizer rule: FAC already populated/6
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC = FAC<<A
JSR SHL
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDY #2
LDA #0
STY A_REG
STA A_REG+1
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
; FAC = FAC<<A
JSR SHL
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = INT(FAC)
JSR BASINT
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_N
LDY #>VAR_N
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL2X
; Optimizer rule: POPREAL and load X/1
JSR ARGADD
; Optimizer rule: POP, REG0, VAR0 -> direct calc/5
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_R
LDY #>VAR_R
JSR FACMEM
; Optimizer rule: Omit FAC load/4
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF81+1
STA MOVBSELF81+2
MOVBSELF81:
LDA $FFFF
CMP #56
BCC PEEKLT9
BEQ PEEKEQ9
LDA #$FF
JMP PEEKDONE9
PEEKLT9:
LDA #$01
JMP PEEKDONE9
PEEKEQ9:
LDA #0
PEEKDONE9:
; Optimized comparison for PEEK
;
;
NEQ_NEQ30:
NEQ_SKIP30:
COMP_SKP40:
BEQ LINE_SKIP62
LINE_NSKIP62:
; Optimizer rule: Simplified not equal comparison/6
;
JMP LINE_76
;
LINE_SKIP62:
;
;
LINE_77:
;
LDX #4
dcloop869_3:
LDA VAR_R,X
STA VAR_M,X
DEX
BPL dcloop869_3
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_65R
LDY #>CONST_65R
JSR REALFAC
LDA #<VAR_R
LDY #>VAR_R
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_M
LDY #>VAR_M
STA A_REG
STY A_REG+1
LDA #<FORLOOP10
STA JUMP_TARGET
LDA #>FORLOOP10
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP10:
LDA #<VAR_M
LDY #>VAR_M
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF82+1
STA MOVBSELF82+2
LDA #$39
MOVBSELF82:
STA $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
LDA #<VAR_M
LDY #>VAR_M
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF83+1
STA MOVBSELF83+2
LDA #$2
MOVBSELF83:
STA $FFFF
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_8
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_8:
LDA #<VAR_E2
LDY #>VAR_E2
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = RND(FAC)
JSR FACRND
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL
JSR FACYREG
; Optimizer rule: FAC 2 Y_REG(2)/1
; Optimizer rule: POP, REG0, VAR0/4
LDA #<X_REG
LDY #>X_REG
; CMPFAC with (A/Y)
JSR CMPFAC
BEQ LT_LT_EQ31
ROL
BCC LT_LT31
LT_LT_EQ31:
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP LT_SKIP31
LT_LT31:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
LT_SKIP31:
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_O
LDY #>VAR_O
JSR CMPFAC
; Optimizer rule: Highly simplified loading for CMP/6
ROL
BCS GT_GT32
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP GT_SKIP32
GT_GT32:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
GT_SKIP32:
; Real in (A/Y) to FAC
JSR REALFAC
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL2X
; Optimizer rule: POPREAL and load X/1
JSR FASTAND
; Optimizer rule: POP, REG0, VAR0 -> direct calc/5
; Optimizer rule: Faster logic AND/1
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA X_REG
COMP_SKP42:
BNE LINE_NSKIP63
; Optimizer rule: CMP (REG) != 0(2)/3
JMP LINE_SKIP63
;
LINE_NSKIP63:
;
LDA #<CONST_9R
LDY #>CONST_9R
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
; FAC = RND(FAC)
JSR FACRND
JSR FACXREG
LDY #1
STY A_REG
; Optimizer rule: Omit XREG->FAC/3
JSR SHL
; Optimizer rule: Shorter SHL/4
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = INT(FAC)
JSR BASINT
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<CONST_11R
LDY #>CONST_11R
JSR REALFAC
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDA #<X_REG
LDY #>X_REG
; FAC = ARG * FAC
JSR MEMMUL
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_R
LDY #>VAR_R
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF84+1
STA MOVBSELF84+2
LDA #$3F
MOVBSELF84:
STA $FFFF
;
LINE_SKIP63:
;
;
LINE_78:
;
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_R
LDY #>VAR_R
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF85+1
STA MOVBSELF85+2
MOVBSELF85:
LDA $FFFF
CMP #62
BCC PEEKLT10
BEQ PEEKEQ10
LDA #$FF
JMP PEEKDONE10
PEEKLT10:
LDA #$01
JMP PEEKDONE10
PEEKEQ10:
LDA #0
PEEKDONE10:
; Optimized comparison for PEEK
;
;
BEQ EQ_EQ33
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP EQ_SKIP33
EQ_EQ33:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
EQ_SKIP33:
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = RND(FAC)
JSR FACRND
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<CONST_66
LDY #>CONST_66
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
LDA #<X_REG
LDY #>X_REG
; CMPFAC with (A/Y)
JSR CMPFAC
BEQ LT_LT_EQ34
ROL
BCC LT_LT34
LT_LT_EQ34:
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP LT_SKIP34
LT_LT34:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
LT_SKIP34:
; Real in (A/Y) to FAC
JSR REALFAC
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL2X
; Optimizer rule: POPREAL and load X/1
JSR FASTAND
; Optimizer rule: POP, REG0, VAR0 -> direct calc/5
; Optimizer rule: Faster logic AND/1
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA X_REG
COMP_SKP43:
BNE LINE_NSKIP64
; Optimizer rule: CMP (REG) != 0(2)/3
JMP LINE_SKIP64
;
LINE_NSKIP64:
;
LDA #<CONST_19R
LDY #>CONST_19R
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
LDA #<VAR_R
LDY #>VAR_R
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF86+1
STA MOVBSELF86+2
LDA #$3F
MOVBSELF86:
STA $FFFF
;
LINE_SKIP64:
;
;
LINE_79:
;
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_9
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_9:
;
LINE_80:
;
LDX #4
dcloop869_4:
LDA CONST_9R,X
STA VAR_O,X
DEX
BPL dcloop869_4
; Optimizer rule: Direct copy of floats into mem/6
LDA #<VAR_E1
LDY #>VAR_E1
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_9R
LDY #>CONST_9R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_O
LDY #>VAR_O
STA A_REG
STY A_REG+1
LDA #<FORLOOP11
STA JUMP_TARGET
LDA #>FORLOOP11
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP11:
;
LINE_81:
;
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = RND(FAC)
JSR FACRND
JSR FACXREG
LDY #4
STY A_REG
; Optimizer rule: Omit XREG->FAC/3
JSR SHL
; Optimizer rule: Shorter SHL/4
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = INT(FAC)
JSR BASINT
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_24R
LDY #>CONST_24R
JSR REALFAC
LDA #<VAR_N
LDY #>VAR_N
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL2X
; Optimizer rule: POPREAL and load X/1
JSR ARGADD
; Optimizer rule: POP, REG0, VAR0 -> direct calc/5
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_R
LDY #>VAR_R
; FAC to (X/Y)
JSR FACMEM
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_R
LDY #>VAR_R
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF87+1
STA MOVBSELF87+2
MOVBSELF87:
LDA $FFFF
CMP #62
BCC PEEKLT11
BEQ PEEKEQ11
LDA #$FF
JMP PEEKDONE11
PEEKLT11:
LDA #$01
JMP PEEKDONE11
PEEKEQ11:
LDA #0
PEEKDONE11:
; Optimized comparison for PEEK
;
;
BEQ EQ_EQ35
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP EQ_SKIP35
EQ_EQ35:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
EQ_SKIP35:
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_R
LDY #>VAR_R
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF88+1
STA MOVBSELF88+2
MOVBSELF88:
LDA $FFFF
CMP #62
BCC PEEKLT12
BEQ PEEKEQ12
LDA #$FF
JMP PEEKDONE12
PEEKLT12:
LDA #$01
JMP PEEKDONE12
PEEKEQ12:
LDA #0
PEEKDONE12:
; Optimized comparison for PEEK
;
;
BEQ EQ_EQ36
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP EQ_SKIP36
EQ_EQ36:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
EQ_SKIP36:
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_R
LDY #>VAR_R
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF89+1
STA MOVBSELF89+2
MOVBSELF89:
LDA $FFFF
CMP #62
BCC PEEKLT13
BEQ PEEKEQ13
LDA #$FF
JMP PEEKDONE13
PEEKLT13:
LDA #$01
JMP PEEKDONE13
PEEKEQ13:
LDA #0
PEEKDONE13:
; Optimized comparison for PEEK
;
;
BNE NEQ_NEQ37
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP NEQ_SKIP37
NEQ_NEQ37:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
NEQ_SKIP37:
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_R
LDY #>VAR_R
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF90+1
STA MOVBSELF90+2
MOVBSELF90:
LDA $FFFF
CMP #56
BCC PEEKLT14
BEQ PEEKEQ14
LDA #$FF
JMP PEEKDONE14
PEEKLT14:
LDA #$01
JMP PEEKDONE14
PEEKEQ14:
LDA #0
PEEKDONE14:
; Optimized comparison for PEEK
;
;
BNE NEQ_NEQ38
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP NEQ_SKIP38
NEQ_NEQ38:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
NEQ_SKIP38:
; Real in (A/Y) to FAC
JSR REALFAC
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL2X
; Optimizer rule: POPREAL and load X/1
JSR FASTOR
; Optimizer rule: POP, REG0, VAR0 -> direct calc/5
; Optimizer rule: Faster logic OR/1
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL2X
; Optimizer rule: POPREAL and load X/1
JSR FASTOR
; Optimizer rule: POP, REG0, VAR0 -> direct calc/5
; Optimizer rule: Faster logic OR/1
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL2X
; Optimizer rule: POPREAL and load X/1
JSR FASTOR
; Optimizer rule: POP, REG0, VAR0 -> direct calc/5
; Optimizer rule: Faster logic OR/1
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA X_REG
COMP_SKP45:
BEQ LINE_SKIP65
; Simplified conditional branch
;
LINE_NSKIP65:
;
JMP LINE_85
;
LINE_SKIP65:
;
;
LINE_84:
;
LDA #<VAR_R
LDY #>VAR_R
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF91+1
STA MOVBSELF91+2
LDA #$3E
MOVBSELF91:
STA $FFFF
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_R
LDY #>VAR_R
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF92+1
STA MOVBSELF92+2
LDA #$3F
MOVBSELF92:
STA $FFFF
;
LINE_85:
;
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_10
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_10:
;
LINE_86:
;
LDX #4
dcloop1029_1:
LDA CONST_9R,X
STA VAR_O,X
DEX
BPL dcloop1029_1
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_12R
LDY #>CONST_12R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_9R
LDY #>CONST_9R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_O
LDY #>VAR_O
STA A_REG
STY A_REG+1
LDA #<FORLOOP12
STA JUMP_TARGET
LDA #>FORLOOP12
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP12:
;
LINE_87:
;
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
; Optimizer rule: Avoid INTEGER->REAL conversion/3
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = RND(FAC)
JSR FACRND
JSR FACXREG
LDY #4
LDA #0
STY A_REG
STA A_REG+1
JSR COPY_XREG2YREG
; Optimizer rule: FAC already populated/6
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC = FAC<<A
JSR SHL
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDY #2
LDA #0
STY A_REG
STA A_REG+1
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
; FAC = FAC<<A
JSR SHL
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDA #<X_REG
LDY #>X_REG
; Real in (A/Y) to ARG
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC = INT(FAC)
JSR BASINT
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR PUSHREAL
LDA #<CONST_28R
LDY #>CONST_28R
JSR REALFAC
LDA #<VAR_N
LDY #>VAR_N
JSR MEMSUB
; Optimizer rule: Combine load and sub/1
; Optimizer rule: Highly simplified loading for calculations/7
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL2X
; Optimizer rule: POPREAL and load X/1
JSR ARGADD
; Optimizer rule: POP, REG0, VAR0 -> direct calc/5
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_R
LDY #>VAR_R
; FAC to (X/Y)
JSR FACMEM
LDA #<CONST_19R
LDY #>CONST_19R
JSR REALFAC
LDA #<VAR_R
LDY #>VAR_R
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF93+1
STA MOVBSELF93+2
MOVBSELF93:
LDA $FFFF
CMP #62
BCC PEEKLT15
BEQ PEEKEQ15
LDA #$FF
JMP PEEKDONE15
PEEKLT15:
LDA #$01
JMP PEEKDONE15
PEEKEQ15:
LDA #0
PEEKDONE15:
; Optimized comparison for PEEK
;
;
BEQ EQ_EQ39
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP EQ_SKIP39
EQ_EQ39:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
EQ_SKIP39:
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_R
LDY #>VAR_R
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF94+1
STA MOVBSELF94+2
MOVBSELF94:
LDA $FFFF
CMP #62
BCC PEEKLT16
BEQ PEEKEQ16
LDA #$FF
JMP PEEKDONE16
PEEKLT16:
LDA #$01
JMP PEEKDONE16
PEEKEQ16:
LDA #0
PEEKDONE16:
; Optimized comparison for PEEK
;
;
BNE NEQ_NEQ40
LDA #<REAL_CONST_ZERO
LDY #>REAL_CONST_ZERO
JMP NEQ_SKIP40
NEQ_NEQ40:
LDA #<REAL_CONST_MINUS_ONE
LDY #>REAL_CONST_MINUS_ONE
NEQ_SKIP40:
; Real in (A/Y) to FAC
JSR REALFAC
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
JSR POPREAL2X
; Optimizer rule: POPREAL and load X/1
JSR FASTOR
; Optimizer rule: POP, REG0, VAR0 -> direct calc/5
; Optimizer rule: Faster logic OR/1
JSR FACXREG
; Optimizer rule: FAC 2 X_REG(2)/1
LDA X_REG
COMP_SKP47:
BEQ LINE_SKIP66
; Simplified conditional branch
;
LINE_NSKIP66:
;
JMP LINE_87
;
LINE_SKIP66:
;
;
LINE_88:
;
LDA #<VAR_R
LDY #>VAR_R
JSR REALFAC
; Optimizer rule: Direct loading of values into FAC/3
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF95+1
STA MOVBSELF95+2
LDA #$3D
MOVBSELF95:
STA $FFFF
LDA #<CONST_22
LDY #>CONST_22
JSR REALFAC
LDA #<VAR_R
LDY #>VAR_R
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
; Optimizer rule: FAC into REG?, REG? into FAC/0
; FAC to integer in Y/A
JSR FACWORD
STY MOVBSELF96+1
STA MOVBSELF96+2
LDA #$0
MOVBSELF96:
STA $FFFF
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_11
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_11:
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_12
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_12:
;
LINE_89:
;
LDY #63
STY 7710
; Optimizer rule: Simple POKE/2
STY 7715
; Optimizer rule: Simple POKE/2
STY 7731
; Optimizer rule: Simple POKE/2
STY 7738
; Optimizer rule: Simple POKE/2
;
LINE_90:
;
LDX #4
dcloop1029_2:
LDA CONST_67R,X
STA VAR_N,X
DEX
BPL dcloop1029_2
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_68R
LDY #>CONST_68R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_64R
LDY #>CONST_64R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<CONST_39R
LDY #>CONST_39R
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR FASTFOR
LDY #0
TYA
CPY A_REG
BNE COMP_SKP50
CMP A_REG+1
BNE COMP_SKP50
COMP_SKP50:
BNE RBEQ_13
JMP (JUMP_TARGET)
RBEQ_13:
LDX #4
dcloop1029_3:
LDA CONST_69R,X
STA VAR_N,X
DEX
BPL dcloop1029_3
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_45R
LDY #>CONST_45R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_64R
LDY #>CONST_64R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<CONST_39R
LDY #>CONST_39R
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR FASTFOR
LDY #0
TYA
CPY A_REG
BNE COMP_SKP51
CMP A_REG+1
BNE COMP_SKP51
COMP_SKP51:
BNE RBEQ_14
JMP (JUMP_TARGET)
RBEQ_14:
JMP RETURN
;
LINE_98:
;
LDA #<VAR_E3
LDY #>VAR_E3
JSR REALFAC
LDA #<CONST_70
LDY #>CONST_70
JSR MEMMUL
; Optimizer rule: Highly simplified loading for calculations (mul)/6
; Optimizer rule: FAC into REG?, REG? into FAC/0
JSR FACYREG
; Optimizer rule: FAC 2 Y_REG(2)/1
LDA #<VAR_SS
LDY #>VAR_SS
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDA #<X_REG
LDY #>X_REG
; CMPFAC with (A/Y)
JSR CMPFAC
BEQ GTEQ_GTEQ41
BCS GTEQ_GTEQ41
LDA #0
JMP GTEQ_SKIP41
GTEQ_GTEQ41:
LDA #$1
GTEQ_SKIP41:
COMP_SKP52:
BNE LINE_NSKIP67
; Optimizer rule: Simplified CMP redux/7
JMP LINE_SKIP67
;
LINE_NSKIP67:
;
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_CH
LDY #>VAR_CH
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_CH
LDY #>VAR_CH
; FAC to (X/Y)
JSR FACMEM
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
LDA #<VAR_E3
LDY #>VAR_E3
JSR FACADD
; Optimizer rule: Combine load and add/1
; Optimizer rule: Highly simplified loading for calculations/7
; Optimizer rule: FAC into REG?, REG? into FAC/0
LDX #<VAR_E3
LDY #>VAR_E3
; FAC to (X/Y)
JSR FACMEM
LDA #<CONST_32
LDY #>CONST_32
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
LDA #<CONST_43R
LDY #>CONST_43R
JSR COPY2_XYA_YREG
; Optimizer rule: MEM 2 Y_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
; ignored: CHGCTX #1
JSR TAB
LDA #<VAR_CH
LDY #>VAR_CH
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR REALOUT
JSR CHECKCMD
JSR LINEBREAK
;
LINE_SKIP67:
;
;
LINE_99:
;
JMP RETURN
;
LINE_100:
;
;
LINE_101:
;
;
LINE_102:
;
;
LINE_103:
;
;
LINE_106:
;
;
LINE_107:
;
;
LINE_108:
;
;
LINE_109:
;
LDA #0
STA VAR_N
STA VAR_N+1
STA VAR_N+2
STA VAR_N+3
STA VAR_N+4
; Optimizer rule: Simplified setting to 0/6
LDA #<CONST_46R
LDY #>CONST_46R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<CONST_9R
LDY #>CONST_9R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<FORLOOP13
STA JUMP_TARGET
LDA #>FORLOOP13
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP13:
LDA #<VAR_N
LDY #>VAR_N
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
JSR READNUMBER
JSR POPREALXREG
; Optimizer rule: POP and XREG combined/1
; Optimizer rule: FAC 2 X_REG(2)/1
LDA #<VAR_B[]
LDY #>VAR_B[]
STA G_REG
STY G_REG+1
JSR ARRAYSTORE_REAL
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_15
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_15:
LDX #4
dcloop1029_4:
LDA CONST_71R,X
STA VAR_N,X
DEX
BPL dcloop1029_4
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_72R
LDY #>CONST_72R
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
; Optimizer rule: Avoid INTEGER->REAL conversion/3
JSR FACYREG
; Optimizer rule: FAC 2 Y_REG(1)/1
LDA #<Y_REG
LDY #>Y_REG
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<FORLOOP14
STA JUMP_TARGET
LDA #>FORLOOP14
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP14:
JSR READNUMBER
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDX #<VAR_M
LDY #>VAR_M
JSR FACMEM
JSR FACXREG
LDA #<VAR_N
LDY #>VAR_N
JSR REALFAC
LDX #<X_REG
; Optimizer rule: Move variable directly in XREG/9
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF101+1
STA MOVBSELF101+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF101:
STY $FFFF
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_16
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_16:
;
LINE_110:
;
LDX #4
dcloop1029_5:
LDA CONST_73R,X
STA VAR_N,X
DEX
BPL dcloop1029_5
; Optimizer rule: Direct copy of floats into mem/6
LDA #<CONST_74
LDY #>CONST_74
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
JSR ONETOFAC
; Optimizer rule: Faster setting to 1/1
; Optimizer rule: Avoid INTEGER->REAL conversion/3
JSR FACYREG
; Optimizer rule: FAC 2 Y_REG(1)/1
LDA #<Y_REG
LDY #>Y_REG
; Real in (A/Y) to FAC
JSR REALFACPUSH
; Optimizer rule: Load and PUSH combined/1
LDA #<VAR_N
LDY #>VAR_N
STA A_REG
STY A_REG+1
LDA #<FORLOOP15
STA JUMP_TARGET
LDA #>FORLOOP15
STA JUMP_TARGET+1
JSR INITFOR
FORLOOP15:
JSR READNUMBER
JSR YREGFAC
; Optimizer rule: Y_REG 2 FAC(1)/1
LDX #<VAR_M
LDY #>VAR_M
JSR FACMEM
JSR FACXREG
LDA #<VAR_N
LDY #>VAR_N
JSR REALFAC
LDX #<X_REG
; Optimizer rule: Move variable directly in XREG/9
JSR FACWORD
; Optimizer rule: POP, REG0, VAR0 -> to WORD/2
STY MOVBSELF102+1
STA MOVBSELF102+2
JSR XREGFAC
; Optimizer rule: X_REG 2 FAC(1)/1
; FAC to integer in Y/A
JSR FACWORD
MOVBSELF102:
STY $FFFF
LDA #0
STA A_REG
STA A_REG+1
JSR NEXT
; Optimizer rule: NEXT with no variable name simplified/4
LDA A_REG
BNE RBEQ_17
JMP (JUMP_TARGET)
; Optimizer rule: NEXT check simplified/4
RBEQ_17:
JMP RETURN
;
LINE_200:
;
LDY #25
STY 36879
; Optimizer rule: Simple POKE/2
LDY #242
STY 36869
; Optimizer rule: Simple POKE/2
;
LINE_210:
;
LDA #<CONST_76
LDY #>CONST_76
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_220:
;
LDA #<CONST_77
LDY #>CONST_77
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_221:
;
JSR LINEBREAK
;
LINE_225:
;
LDA #<CONST_78
LDY #>CONST_78
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_226:
;
JSR LINEBREAK
;
LINE_227:
;
LDA #<CONST_79
LDY #>CONST_79
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_228:
;
LDA #<CONST_80
LDY #>CONST_80
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_229:
;
JSR LINEBREAK
;
LINE_230:
;
JSR LINEBREAK
JSR LINEBREAK
;
LINE_231:
;
LDA #<CONST_81
LDY #>CONST_81
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_240:
;
LDA #<CONST_82
LDY #>CONST_82
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_246:
;
JSR LINEBREAK
;
LINE_247:
;
LDA #<CONST_83
LDY #>CONST_83
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_248:
;
LDA #<CONST_84
LDY #>CONST_84
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_249:
;
JSR LINEBREAK
;
LINE_250:
;
JSR LINEBREAK
JSR LINEBREAK
;
LINE_251:
;
LDA #<CONST_85
LDY #>CONST_85
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_252:
;
LDY #0
STY 198
; Optimizer rule: Simple POKE/2
;
LINE_260:
;
JSR GETSTR
LDA A_REG
LDY A_REG+1
STA TMP_ZP
STY TMP_ZP+1
LDA #<VAR_K$
LDY #>VAR_K$
JSR COPYSTRING
LDA #<CONST_86
LDY #>CONST_86
STA B_REG
STY B_REG+1
LDA VAR_K$
LDY VAR_K$+1
STA A_REG
STY A_REG+1
; ignored: CHGCTX #0
JSR SEQ
LDA X_REG
COMP_SKP56:
BEQ LINE_SKIP68
; Simplified conditional branch
;
LINE_NSKIP68:
;
JMP LINE_260
;
LINE_SKIP68:
;
;
LINE_270:
;
JMP RETURN
;
LINE_300:
;
LDY #255
STY 37154
; Optimizer rule: Simple POKE/2
LDY #240
STY 36869
; Optimizer rule: Simple POKE/2
LDA #<CONST_87
LDY #>CONST_87
JSR STROUTWL
; Optimizer rule: Memory saving STROUT/1
LDA #<VAR_SS
LDY #>VAR_SS
JSR COPY2_XYA_XREG
; Optimizer rule: MEM 2 X_REG/3
; Optimizer rule: Memory saving copy/4
; Optimizer rule: Quick copy into REG/7
JSR REALOUT
JSR CHECKCMD
JSR LINEBREAK
;
LINE_320:
;
LDA #<CONST_88
LDY #>CONST_88
JSR STROUTBRKWL
; Optimizer rule: Memory saving STROUTBRK/1
; Optimizer rule: STROUT + LINEBRK/1
;
LINE_325:
;
LDY #0
STY 198
; Optimizer rule: Simple POKE/2
;
LINE_330:
;
JSR GETSTR
LDA A_REG
LDY A_REG+1
STA TMP_ZP
STY TMP_ZP+1
LDA #<VAR_K$
LDY #>VAR_K$
JSR COPYSTRING
LDA #<CONST_86
LDY #>CONST_86
STA B_REG
STY B_REG+1
LDA VAR_K$
LDY VAR_K$+1
STA A_REG
STY A_REG+1
; ignored: CHGCTX #0
JSR SEQ
LDA X_REG
COMP_SKP57:
BEQ LINE_SKIP69
; Simplified conditional branch
;
LINE_NSKIP69:
;
JMP LINE_330
;
LINE_SKIP69:
;
;
LINE_340:
;
JSR RUN
;
LINE_997:
;
;
LINE_998:
;
;
LINE_999:
;
JSR END
RTS
; *** SUBROUTINES ***
;###################################
END			LDX SP_SAVE
TXS
<IF BIGRAM>
JSR ENABLEROM
</IF>
<IF BOOST>
JSR BOOSTDIASBLE
</IF>
RTS
;###################################
;###################################
SYSTEMCALL
LDA TMP_ZP
STA SCDO+1
LDA TMP_ZP+1
STA SCDO+2
LDA $030F
PHA
LDA $030C
LDX $030D
LDY $030E
PLP
<IF BIGRAM>
JSR ENABLEROM
</IF>
SCDO		JSR $FFFF
<IF BIGRAM>
JSR DISABLEROM
</IF>
PHP
STA $030C
STX $030D
STY $030E
PLA
STA $030F
RTS
;###################################
;###################################
START		LDA ENDSTRBUF+1
BNE ENDGIVEN
LDA BASICEND
STA ENDSTRBUF
LDA BASICEND+1
STA ENDSTRBUF+1
ENDGIVEN	LDA #<FPSTACK
LDY #>FPSTACK
STA FPSTACKP
STY FPSTACKP+1
LDA #<FORSTACK
LDY #>FORSTACK
STA FORSTACKP
STY FORSTACKP+1
LDA #<STRBUF
LDY #>STRBUF
STA STRBUFP
STY STRBUFP+1
STA HIGHP
STY HIGHP+1
LDA #0
STA CHLOCKFLAG
STA LASTVAR
STA LASTVAR+1
JSR INITVARS
LDA #0
STA CMD_NUM
STA CHANNEL
TAY
TAX
<IF X16>
JSR VARBANKON
</IF>
STA KEYNDX
<IF X16>
JSR VARBANKOFF
LDA #DEFAULT_BANK
STA RAMSELECT
</IF>
JSR RESTORE
CLC
<IF BOOST>
JSR BOOSTENABLE
</IF>
RTS
;###################################
;###################################
INITNARRAY
STA TMP_ZP
STY TMP_ZP+1
LDY #0
TYA
NINITLOOP	STA (TMP_ZP),Y
INC TMP_ZP
BNE NLOOPNOV
INC TMP_ZP+1
NLOOPNOV	LDX TMP2_ZP
BNE NLOOPNOV2
DEC TMP2_ZP+1
NLOOPNOV2	DEC TMP2_ZP
BNE NINITLOOP
LDX TMP2_ZP+1
BNE NINITLOOP
RTS
;###################################
;###################################
INITSTRARRAY
STA TMP_ZP
STY TMP_ZP+1
SINITLOOP	LDY #0
LDA #<EMPTYSTR
STA (TMP_ZP),Y
LDA #>EMPTYSTR
INY
STA (TMP_ZP),Y
CLC
LDA TMP_ZP
ADC #2
STA TMP_ZP
BCC SLOOPNOV1
INC TMP_ZP+1
SLOOPNOV1	SEC
LDA TMP2_ZP
SBC #2
STA TMP2_ZP
BCS SLOOPNOV2
DEC TMP2_ZP+1
SLOOPNOV2	LDA TMP2_ZP
BNE SINITLOOP
LDA TMP2_ZP+1
BNE SINITLOOP
RTS
;###################################
;###################################
INITSPARAMS	STA TMP3_ZP
STY TMP3_ZP+1
SEC
SBC #2
STA TMP_ZP
TYA
SBC #0
STA TMP_ZP+1
LDY #0
LDA (TMP_ZP),Y
STA TMP2_ZP
INY
LDA (TMP_ZP),Y
STA TMP2_ZP+1
LDA TMP3_ZP
LDY TMP3_ZP+1
RTS
;##################################
;##################################
INITSTRVARS	LDA #<STRINGVARS_START		; Reset all string variables...
LDY #>STRINGVARS_START
CMP #<STRINGVARS_END
BNE INITIT1
CPY #>STRINGVARS_END
BNE INITIT1
JMP INITSA2					; No string variables at all
INITIT1		STA TMP_ZP
STY TMP_ZP+1
LDY #0
INITSTRLOOP	LDA #<EMPTYSTR
STA (TMP_ZP),Y
INY
LDA #>EMPTYSTR
STA (TMP_ZP),Y
DEY
LDA TMP_ZP
CLC
ADC #2
STA TMP_ZP
LDA TMP_ZP+1
ADC #0
STA TMP_ZP+1
CMP #>STRINGVARS_END
BNE INITSTRLOOP
LDA TMP_ZP
CMP #<STRINGVARS_END
BNE INITSTRLOOP
INITSA2		LDA #<STRINGARRAYS_START	; ...and all string arrays
LDY #>STRINGARRAYS_START
CMP #<STRINGARRAYS_END
BNE ARRAYLOOP
CPY #>STRINGARRAYS_END
BNE ARRAYLOOP
RTS							;...no string array at all
ARRAYLOOP	CLC
ADC #3
BCC ARRAYSKIP1
INY
ARRAYSKIP1	CPY #>STRINGARRAYS_END
BEQ ARRAYSC
BCC ARRAYSKIP2
JMP ARRAYQUIT
ARRAYSC		CMP #<STRINGARRAYS_END
BCS ARRAYQUIT
ARRAYSKIP2	STA TMP_REG
STY TMP_REG+1
JSR INITSPARAMS
LDA TMP_REG
LDY TMP_REG+1
JSR INITSTRARRAY
LDA TMP_ZP
LDY TMP_ZP+1
JMP ARRAYLOOP
ARRAYQUIT	RTS
;###################################
;###################################
RUN			LDX SP_SAVE
TXS
JMP PROGRAMSTART
;###################################
;###################################
RESTORE		LDA #<DATAS
LDY #>DATAS
STA DATASP
STY DATASP+1
RTS
;###################################
;###################################
; Special loop to handle the common for-poke-next-case
; used to clear the screen and such...
FASTFOR		JSR POPREAL
JSR SGNFAC
STA TMP_REG		; store sign
BCC FFPOSSTEP
LDA #<REAL_CONST_MINUS_ONE	; negative...negate it
LDY #>REAL_CONST_MINUS_ONE
JSR MEMARG	; to ARG
JSR FACMUL	; MUL
FFPOSSTEP	JSR FACWORD	; to WORD
STY TMP2_ZP
STA TMP2_ZP+1	; step
LDA A_REG
LDY A_REG+1
JSR REALFAC
JSR FACWORD
STY TMP_ZP
STA TMP_ZP+1	; from
JSR POPREAL
JSR FACWORD
STY TMP2_ZP+2
STA TMP2_ZP+3	; end
JSR XREGFAC
JSR FACINT
STY TMP3_ZP		; value
LDA TMP2_ZP+1
BNE STEPNOTONE
LDA TMP2_ZP
CMP #$1
BNE STEPNOTONE
JMP STEPONE
STEPNOTONE	LDA TMP_REG
BEQ FFSTEPZERO
ROL
FFSTEPZERO	BCC FFSTEPPOS
FFSTEPNEG	LDY #0
LDA TMP3_ZP
TAX
FFNEGLOOP	TXA
STA (TMP_ZP),Y
LDA TMP_ZP
SEC
SBC TMP2_ZP
STA TMP_ZP
LDA TMP_ZP+1
BCS	FFNEGSKIP
SBC TMP2_ZP+1
STA TMP_ZP+1
FFNEGSKIP	CMP TMP2_ZP+3
BEQ FFNEGCHECK2
BCS FFNEGLOOP
JMP FFDONE
FFNEGCHECK2	LDA TMP_ZP
CMP TMP2_ZP+2
BCS FFNEGLOOP
JMP FFDONE
FFSTEPPOS	LDY #0
LDA TMP3_ZP
TAX
FFPOSLOOP	TXA
STA (TMP_ZP),Y
LDA TMP_ZP
CLC
ADC TMP2_ZP
STA TMP_ZP
LDA TMP_ZP+1
BCC	FFPOSSKIP
ADC TMP2_ZP+1
STA TMP_ZP+1
FFPOSSKIP	CMP TMP2_ZP+3
BCC FFPOSLOOP
BEQ FFPOSCHECK2
JMP FFDONE
FFPOSCHECK2	LDA TMP_ZP
CMP TMP2_ZP+2
BCC FFPOSLOOP
BEQ FFPOSLOOP
FFDONE		LDY TMP_ZP
LDA TMP_ZP+1
JSR INTFAC
LDX A_REG
LDY A_REG+1
LDA #1
STA A_REG
JMP FACMEM		; Store end value in loop variable
; Special routine for step=1/-1
STEPONE	LDA TMP_REG
BEQ OFFSTEPZERO
ROL
OFFSTEPZERO	BCC OFFSTEPPOS
OFFSTEPNEG	LDY #0
LDA TMP3_ZP
TAX
OFFNEGLOOP	TXA
STA (TMP_ZP),Y
LDA TMP_ZP
BNE ONOOVERFLOW
DEC TMP_ZP+1
ONOOVERFLOW	DEC TMP_ZP
LDA TMP_ZP+1
OFFNEGSKIP	CMP TMP2_ZP+3
BEQ OFFNEGCHECK2
BCS OFFNEGLOOP
JMP FFDONE
OFFNEGCHECK2
LDA TMP_ZP
CMP TMP2_ZP+2
BCS OFFNEGLOOP
JMP FFDONE
OFFSTEPPOS	LDY #0
LDA TMP3_ZP
TAX
OFFPOSLOOP	TXA
STA (TMP_ZP),Y
INC TMP_ZP
BNE ONOOVERFLOW2
INC TMP_ZP+1
ONOOVERFLOW2
LDA TMP_ZP+1
OFFPOSSKIP	CMP TMP2_ZP+3
BCC OFFPOSLOOP
BEQ OFFPOSCHECK2
JMP FFDONE
OFFPOSCHECK2
LDA TMP_ZP
CMP TMP2_ZP+2
BCC OFFPOSLOOP
BEQ OFFPOSLOOP
JMP FFDONE
;###################################
;###################################
STR			JSR YREGFAC
STRINT		LDY #1
JSR FACSTR
LDY #0
STY TMP_ZP+1
LDA #LOFBUF
STA TMP_ZP
DEY
STRLOOP		INY
LDA LOFBUFH,Y
BNE STRLOOP
STY LOFBUF
TYA
TAX			; Length in X
LDA #<A_REG
LDY #>A_REG
STA TMP2_ZP
STY TMP2_ZP+1
JMP COPYONLY
;###################################
;###################################
TAB			JSR TABSPCINIT
JSR REROUTE
LDA CMD_NUM
BEQ NORMALTAB		; No reroute? Normal TAB
CMP #3
BEQ NORMALTAB2		; To screen? Normal TAB
JMP TABCHANNEL2
NORMALTAB2	JSR CLRCHNEW
NORMALTAB	SEC
JMP TABSPC
;###################################
;###################################
TABSPCINIT	SEC
JSR CRSRPOS
STY $09
JSR YREGFAC
JSR FACWORD
TYA
TAX
RTS
;###################################
;###################################
TABSPC	    BCC DOSPC
TXA
SBC $09
BCC TABSPCQUIT
TAX
DOSPC		INX
TABSPCLOOP  DEX
BNE TABSPCRIGHT
TABSPCQUIT	RTS
TABSPCRIGHT	JSR CRSRRIGHT
JMP TABSPCLOOP
;###################################
;###################################
LEN			LDA B_REG
STA TMP_ZP
LDA B_REG+1
STA TMP_ZP+1
LDY #0
LDA (TMP_ZP),Y
STA TMP2_ZP		;For use in a later optimization
BEQ ZEROLEN
TAY
LDA #0
JSR INTFAC
JMP FACXREG	;RTS is implicit
ZEROLEN		JMP ZEROSET
;###################################
;###################################
SAVEPOINTERS
LDA TMP_ZP			; ...save the pointers
STA STORE1
LDA TMP_ZP+1
STA STORE1+1
LDA TMP2_ZP
STA STORE2
LDA TMP2_ZP+1
STA STORE2+1
LDA TMP3_ZP
STA STORE3
LDA TMP3_ZP+1
STA STORE3+1
RTS
;###################################
;###################################
RESTOREPOINTERS
LDA STORE3+1		; ...restore the pointers
STA TMP3_ZP+1
LDA STORE3
STA TMP3_ZP
LDA STORE2+1
STA TMP2_ZP+1
LDA STORE2
STA TMP2_ZP
LDA STORE1+1
STA TMP_ZP+1
LDA STORE1
STA TMP_ZP
RTS
;###################################
;###################################
; This check is called in places, where the actual source's length is unknown.
; So we compact assuming the maximum string length of 255. It's not ideal this way
; but it's better than what we did before: Read some random length out of whatever
; memory location TMP_ZP/TMP_ZP+1 was pointing to...
COMPACTMAX
LDA #$FF
LDY #$0
JMP COMPACTF
;###################################
;###################################
COMPACT
LDY #0
GCBUFNE		LDA (TMP_ZP),Y		; Get the source's length
COMPACTF	STA TMP4_REG		; ...and store it
LDY STRBUFP+1		; First, check if the new string would fit into memory...
STY TMP4_REG+1		; For that, we have to calculate the new strbufp after adding the string
INY					; add 1 to the high byte to check, if at least 256 bytes are free (fast path)
BEQ ENDMEM			; actually, if this happens, all went wrong anyway...whatever...
CPY ENDSTRBUF+1		; check, if there are at least 256 bytes free. If there are, no detailed check is needed...
BCC RGCEXIT			; there are? We are out then.
ENDMEM		LDA STRBUFP
CLC
ADC TMP4_REG
STA TMP4_REG
BCC	RGCNOOV1
INC TMP4_REG+1
RGCNOOV1	CLC
LDA TMP4_REG
ADC #3
STA TMP4_REG
BCC	RGCNOOV2
INC TMP4_REG+1
RGCNOOV2	LDA TMP4_REG+1		; Now do the actual check
CMP ENDSTRBUF+1
BEQ RGCLOW1
BCS GCEXECOMP		; Doesn't fit, run GC!
JMP RGCEXIT
RGCLOW1		LDA TMP4_REG
CMP ENDSTRBUF
BCS	GCEXECOMP		; This also triggers if it would fit exactly...but anyway...
RGCEXIT		RTS					; It fits? Then exit without GC
GCEXECOMP	LDA STRBUFP
STA STORE4
LDA STRBUFP+1
STA STORE4+1
JSR GCEXE
JMP CHECKMEMORY
;###################################
;###################################
GCEXE		JSR SAVEPOINTERS
LDA #0
STA LASTVAR
STA LASTVAR+1		; reset the last variable pointer to 0
LDA #<STRBUF
STA TMP_ZP
STA GCSTART
LDA #>STRBUF
STA TMP_ZP+1		; Pointer into the string memory, initialized to point at the start...
STA GCSTART+1
GCLOOP		LDY #0
LDA TMP_ZP
STA GCWORK
LDA TMP_ZP+1
STA GCWORK+1		; store the pointer for later use...
LDA (TMP_ZP),Y
STA GCLEN			; store the length
INC TMP_ZP
BNE GCLOOPNOOV
INC TMP_ZP+1
GCLOOPNOOV	LDA TMP_ZP
CLC
ADC GCLEN
STA TMP_ZP
BCC GCLOOPNOOV2
INC TMP_ZP+1		; TMP_ZP now points to the reference to the string variable that used this chunk once
GCLOOPNOOV2 LDY #0
LDA (TMP_ZP),Y
STA TMP2_ZP
INY
LDA (TMP_ZP),Y
STA TMP2_ZP+1		; Store the variable reference in TMP2_ZP
LDA TMP_ZP
CLC
ADC #2
STA TMP_ZP
BCC GCLOOPNOOV3
INC TMP_ZP+1		; adjust the pointer to point to the next entry
GCLOOPNOOV3 LDY #0
LDA (TMP2_ZP),Y
CMP GCWORK
BNE GCKLOOP
INY
LDA (TMP2_ZP),Y
CMP GCWORK+1
BEQ MEMFREE
GCKLOOP		LDA TMP_ZP+1		; Check if we have processed all of the string memory...
CMP HIGHP+1
BEQ GCHECKLOW
BCC GCLOOP
JMP GCDONE
GCHECKLOW	LDA TMP_ZP
CMP HIGHP
BCS GCDONE
JMP GCLOOP
MEMFREE		LDA GCSTART			; found a variable that points to this chunk...
CMP GCWORK			; ...then check if the can be copied down. This is the case if GCSTART!=GCWORK
BNE COPYDOWN
LDA GCSTART+1
CMP GCWORK+1
BNE COPYDOWN
LDA TMP_ZP			; GCSTART==GCWORK...adjust GCSTART and continue
STA GCSTART
LDA TMP_ZP+1
STA GCSTART+1
JMP	GCKLOOP			; continue if needed...
COPYDOWN	LDA GCSTART			; There's a gap in memory, so copy the found variable down to GCSTART and adjust GCSTART accordingly
STA TMP_REG
LDA GCSTART+1
STA TMP_REG+1		; set the target location...
LDA GCWORK
STA TMP2_REG
LDA GCWORK+1
STA TMP2_REG+1		; set the source location...
LDA TMP_ZP
SEC
SBC GCWORK
STA TMP3_REG
LDA TMP_ZP+1
SBC GCWORK+1
STA TMP3_REG+1		; set the length
LDA GCSTART
CLC
ADC TMP3_REG
STA GCSTART
LDA GCSTART+1
ADC TMP3_REG+1
STA GCSTART+1		; update GCSTART to point to the next free chunk
JSR QUICKCOPY		; copy the chunk down to (former, now stored in TMP_REG) GCSTART
LDY #0
LDA TMP_REG
STA (TMP2_ZP),Y
INY
LDA TMP_REG+1
STA (TMP2_ZP),Y		; ...and adjust the pointer to the memory in the variable to that new location
JMP GCKLOOP
GCDONE		LDA GCSTART
STA HIGHP
STA STRBUFP
LDA GCSTART+1
STA HIGHP+1
STA STRBUFP+1		; Update the string pointers to the new, hopefully lower position
GCSKIP		JSR RESTOREPOINTERS
RTS					; Remember: GC has to adjust highp as well!
;###################################
;###################################
CHECKMEMORY
LDA STRBUFP+1		; Check if we are out of memory even after a garbage collection.
CMP STORE4+1		; This is indicated by the string pointer being still equal or higher
BCC STILLFITSCM		; than before the GC. We are not checking against the actual memory limit,
; because the GC stops before reaching it, leaving all unhandled variables
; untouched. That's because we can't free anything more if we've already reached
; the limit. But there's no direct indicator of this, so we use this indirect one.
BEQ CHECKMEMLOWCM
JMP OUTOFMEMORY		; STRBUFP>last value? OOM!
CHECKMEMLOWCM
LDA STRBUFP			; High bytes are equal? Check low bytes
CMP STORE4
BCC	STILLFITSCM
JMP OUTOFMEMORY		; No? OOM
STILLFITSCM RTS
;###################################
;###################################
QUICKCOPY	LDA TMP_REG		; a self modifying copy routine
STA TMEM+1
LDA TMP_REG+1
STA TMEM+2
LDA TMP2_REG
STA SMEM+1
LDA TMP2_REG+1
STA SMEM+2
LDY #$0
LDX TMP3_REG
BNE QCLOOP
LDA TMP3_REG+1
BEQ QCEXIT		; length is null, nothing to copy
QCLOOP
SMEM		LDA $0000,Y
TMEM		STA $0000,Y
INY
BNE YNOOV
INC TMEM+2
INC SMEM+2
YNOOV		DEX
BNE QCLOOP
LDA TMP3_REG+1
BEQ QCEXIT
DEC TMP3_REG+1
JMP QCLOOP
QCEXIT		RTS
;###################################
;###################################
COPYSTRING	STA TMP2_ZP
STY TMP2_ZP+1
CPY TMP_ZP+1
BNE CONTCOPY
LDA TMP2_ZP
CMP TMP_ZP
BNE CONTCOPY
RTS					; A copy from a variable into the same instance is pointless an will be ignored.
CONTCOPY	JSR COMPACT			; Do a GC if needed
LDY #0
STY TMP_FLAG
LDA (TMP_ZP),Y
BNE NOTEMPTYSTR
LDA #<EMPTYSTR		; The source is empty? Then assign the empty string constant instead
STA TMP_ZP
LDA #>EMPTYSTR
STA TMP_ZP+1
JMP ISCONST
NOTEMPTYSTR	TAX					; Store the length of the source in X...this is valid until right to the end, where it's not longer used anyway
LDA (TMP2_ZP),Y
STA TMP3_ZP
INY
LDA (TMP2_ZP),Y
STA TMP3_ZP+1
DEY
LDA TMP_ZP+1		; Check if the source is a constant (upper bound). If so, don't copy it but just point to it
CMP #>CONSTANTS_END
BEQ CHECKLOW1
BCS INVAR
JMP CHECKNEXT
CHECKLOW1	LDA TMP_ZP
CMP #<CONSTANTS_END
BCS INVAR
CHECKNEXT	LDA TMP_ZP+1		; Check if the source is a constant (lower bound). If so, don't copy it but just point to it
CMP #>CONSTANTS
BEQ CHECKLOW3
BCC INVAR
JMP ISCONST
CHECKLOW3	LDA TMP_ZP
CMP #<CONSTANTS
BCC INVAR			; No, it's not a constant. It's something from lower memory...
ISCONST		JSR CHECKLASTVAR	; Reclaim formerly used memory if possible
LDA TMP_ZP
STA (TMP2_ZP),Y		; Yes, it's a constant...
INY
LDA TMP_ZP+1
STA (TMP2_ZP),Y
LDA HIGHP			; Reset the memory pointer to the last assigned one. Everything that came later has to be temp. data
STA STRBUFP
LDA HIGHP+1
STA STRBUFP+1
RTS
INVAR		INY
LDA (TMP2_ZP),Y		; Check if the target is currently pointing into the constant pool. If so, don't update that memory by accident
CMP #>CONSTANTS_END
BEQ CHECKLOW2
BCS INVAR2
JMP PUPDATEPTR
CHECKLOW2	DEY
LDA (TMP2_ZP),Y
CMP #<CONSTANTS_END
BCS INVAR2
JMP PUPDATEPTR
INVAR2		LDY #0			; The target is somewhere in var memory (i.e. not in constant memory)
LDA (TMP3_ZP),Y
STA TMP_REG
TXA
CMP TMP_REG		; Compare the string-to-copy's length (in A) with the variable's current one (in TMP_REG)
BEQ UPDATEHP2	; does the new string fit into the old memory location (i.e. is it the same length)?
; Shorter strings would fit as well, but aren't stored this way or otherwise, the result would
; be some stray memory chunk that none could identify properly when doing a GC
PUPDATEPTR	JSR CHECKLASTVAR
LDY #1			; No? Then new memory has to be used. Update the "highest memory position" in the process
STY TMP_FLAG	; to regain temp. memory used for non-assigned strings like for printing and such...
JMP UPDATEPTR	; ...we set a flag here to handle this case later
UPDATEHP2	LDA HIGHP		; Update the memory pointer to the last assigned position, reclaim some memory this way
STA STRBUFP
LDA HIGHP+1
STA STRBUFP+1
JMP STRFITS
COPYONLY	LDY #0
STY TMP_FLAG
JMP CHECKMEM
ALTCOPY		JMP COPYSTRING2
UPDATEPTR	LDA TMP_ZP+1	; Check if the new string comes after or equals highp, which indicates that it can be
CMP HIGHP+1		; "copied down". This is another routine, because of...reasons...
BEQ CHECKXT1
BCS ALTCOPY
JMP CHECKMEM
CHECKXT1	LDA TMP_ZP
CMP HIGHP
BCS ALTCOPY
CHECKMEM
MEMOK		LDY #0
LDA STRBUFP		; no, then copy it into string memory later...
STA (TMP2_ZP),Y	; ...but update the string memory pointer now
STA TMP3_ZP
LDA STRBUFP+1
INY
STA (TMP2_ZP),Y
STA TMP3_ZP+1
TXA
CLC
ADC STRBUFP
PHP
CLC
ADC #3
STA STRBUFP
BCC NOCS1
INC STRBUFP+1
NOCS1		PLP
BCC STRFITS
INC STRBUFP+1
STRFITS		LDY TMP_FLAG	; Check if the pointer to the highest mem addr is used by an actual string
BEQ NOHPUPDATE	; has to be updated and do that...
LDA HIGHP+1
CMP STRBUFP+1
BCC UPDATEHIGHP
BEQ CHECKNEXTHP
JMP NOHPUPDATE
CHECKNEXTHP	LDA HIGHP
CMP	STRBUFP
BCC UPDATEHIGHP
JMP NOHPUPDATE
UPDATEHIGHP	LDA STRBUFP
STA HIGHP
LDA STRBUFP+1
STA HIGHP+1		; set new pointer
JSR REMEMBERLASTVAR
JSR STOREVARREF
NOHPUPDATE	LDY #0
LDA (TMP_ZP),Y	; Set the new length...
STA (TMP3_ZP),Y
TAY				; Copy length to Y
BEQ	EXITCOPY	; Length 0? nothing to copy then...
LOOP		LDA (TMP_ZP),Y	; Copy the actual string
STA (TMP3_ZP),Y
DEY
BNE LOOP
EXITCOPY	RTS
;###################################
;###################################
; Special copy routine that handles the case that a string is >highp but might interleave with the temp data that has to be copied into it.
; Therefor, this routine copies from lower to higher addresses and not vice versa like the simpler one above.
COPYSTRING2	LDY #0
LDA (TMP_ZP),Y
STA TMP_REG
TAX
LDA HIGHP
STA TMP3_ZP
STA (TMP2_ZP),Y
LDA HIGHP+1
STA TMP3_ZP+1
INY
STA (TMP2_ZP),Y
JSR REMEMBERLASTVAR
; Do a quick test, if a real copy is needed or if the memory addrs are equal anyway?
; This introduces some overhead but according to my tests, its actually faster this way.
LDA TMP_ZP
CMP TMP3_ZP
BNE DOLOOP
LDA TMP_ZP+1
CMP TMP3_ZP+1
BEQ SKIPCP2
DOLOOP		DEY
TXA
STA (TMP3_ZP),Y
INY
ASLOOP		LDA (TMP_ZP),Y
STA (TMP3_ZP),Y
INY
DEX
BNE	ASLOOP
SKIPCP2		LDA HIGHP
CLC
ADC TMP_REG
PHP
CLC
ADC #3
STA HIGHP
STA STRBUFP
BCC SKIPLOWAS1
INC HIGHP+1
SKIPLOWAS1	PLP
BCC SKIPLOWAS2
INC HIGHP+1
SKIPLOWAS2	LDA HIGHP+1
STA STRBUFP+1
JSR STOREVARREF
RTS
;###################################
;###################################
; Checks if this variable is the same one that has been stored last. If so, we can reclaim its memory first.
CHECKLASTVAR
LDA TMP2_ZP
CMP LASTVAR
BNE NOTSAMEVAR
LDA TMP2_ZP+1
CMP LASTVAR+1
BNE NOTSAMEVAR
LDA LASTVARP			; The target is the last string that has been added. We can free it's currently used memory then.
STA HIGHP
STA STRBUFP
LDA LASTVARP+1
STA HIGHP+1
STA STRBUFP+1
NOTSAMEVAR	RTS
;###################################
;###################################
; Stores the last variable reference that has been stored in string memory.
REMEMBERLASTVAR
LDA TMP2_ZP
STA LASTVAR
LDA TMP2_ZP+1
STA LASTVAR+1
LDA TMP3_ZP
STA LASTVARP
LDA TMP3_ZP+1
STA LASTVARP+1	; Remember this variable as the last written one
RTS
;###################################
;###################################
; Appends a reference to the variable at the end of the string in memory for
; easier GC later...
STOREVARREF
TYA
PHA				; Save Y reg
LDA TMP_ZP
PHA
LDA TMP_ZP+1
PHA
LDA HIGHP+1
STA TMP_ZP+1
LDA HIGHP
SEC
SBC #2
STA TMP_ZP
BCS RLVNOOV
DEC TMP_ZP+1
RLVNOOV		LDA TMP2_ZP
LDY #0
STA (TMP_ZP),Y
LDA TMP2_ZP+1
INY
STA (TMP_ZP),Y	; Store the reference to the variable that uses this chunk of memory at the end of the string
PLA
STA TMP_ZP+1
PLA
STA TMP_ZP		; ...restore TMP_ZP
PLA
TAY				; ...restore Y reg
RTS
;###################################
;###################################
REROUTE		LDA CMD_NUM		; if CMD mode, enable channel output
BEQ REROUTECMD
TAX
STA CHANNEL
JMP CHKOUT
REROUTECMD	RTS
;###################################
;###################################
RESETROUTE	LDA CMD_NUM		; if CMD mode, disable channel output
BEQ RESETROUTECMD
JMP CLRCHNEW
RESETROUTECMD
RTS
;###################################
;###################################
INTOUTFASTZ	LDX #32				; SPACE
LDA TMP_ZP+1
BPL INTISPOS
CLC
LDA TMP_ZP
EOR #$FF
ADC #1
STA TMP_ZP
LDA TMP_ZP+1
EOR #$FF
ADC #0
STA TMP_ZP+1
LDX #45				; MINUS
INTISPOS
TXA
JSR CHROUT
JSR CONVPOSINT
LDA NUMFLAG
BNE ALLINTOUTDONE
LDA #48
JSR CHROUT
ALLINTOUTDONE
RTS
;###################################
;###################################
NUMBEROUT
BEQ NUMZERO
ORA #$30
STA NUMFLAG
JMP CHROUT
NUMZERO
LDX NUMFLAG
BEQ STILLZERO
ORA #$30
JMP CHROUT
STILLZERO
RTS
;###################################
;###################################
CONVPOSINT
JSR INT2BCD
LDX #0
STX NUMFLAG
AND #$0F
JSR NUMBEROUT
LDA BCD+1
LSR
LSR
LSR
LSR
JSR NUMBEROUT
LDA BCD+1
AND #$0F
TAY
JSR NUMBEROUT
LDA BCD
LSR
LSR
LSR
LSR
JSR NUMBEROUT
LDA BCD
AND #$0F
JSR NUMBEROUT
RTS
;###################################
;###################################
INT2BCD
SED
LDA #0
STA BCD
STA BCD+1
STA BCD+2
ASL TMP_ZP
ROL TMP_ZP+1
LDA BCD
ADC BCD
STA BCD
ASL TMP_ZP
ROL TMP_ZP+1
ADC BCD
STA BCD
ASL TMP_ZP
ROL TMP_ZP+1
ADC BCD
STA BCD
ASL TMP_ZP
ROL TMP_ZP+1
ADC BCD
STA BCD
ASL TMP_ZP
ROL TMP_ZP+1
ADC BCD
STA BCD
ASL TMP_ZP
ROL TMP_ZP+1
ADC BCD
STA BCD
LDX #7
BCDBIT1
ASL TMP_ZP
ROL TMP_ZP+1
LDA BCD
ADC BCD
STA BCD
LDA BCD+1
ADC BCD+1
STA BCD+1
DEX
BNE BCDBIT1
LDX #3
BCDBIT2
ASL TMP_ZP
ROL TMP_ZP+1
LDA BCD
ADC BCD
STA BCD
LDA BCD+1
ADC BCD+1
STA BCD+1
LDA BCD+2
ADC BCD+2
STA BCD+2
DEX
BNE BCDBIT2
CLD
RTS
BCD
.WORD 0 0
NUMFLAG
.BYTE 0
;###################################
;###################################
REALOUTFAST	JSR FACINT
STA TMP_ZP+1
STY TMP_ZP
JMP INTOUTFASTZ
;###################################
;###################################
CHECKFORFASTOUT
JSR REROUTE
JSR XREGFAC
LDA FACEXP
CMP #$90
BCS REALOUTINT
CMP #$81
BCC REALOUTINT
MAYBEREALOUTFAST
LDA FACEXP+3
BNE REALOUTINT
LDA FACEXP+4
BNE REALOUTINT
LDA FACEXP
SEC
SBC #129
ASL
TAX
LDA FACEXP+1
AND MANTMASK,X
BNE	REALOUTINT
INX
LDA FACEXP+2
AND MANTMASK,X
BNE	REALOUTINT
JMP REALOUTFAST
REALOUTINT	LDY #0
JSR FACSTR
LDY #0
LDA LOFBUF,Y
STRLOOPRO	JSR CHROUT
INY
LDA LOFBUF,Y
BNE STRLOOPRO
RTS
MANTMASK
.BYTE 127 255 63 255 31 255 15 255 7 255 3 255 1 255 0 255 0 127 0 63 0 31 0 15 0 7 0 3 0 1
;###################################
;###################################
REALOUT		LDA X_REG
BNE RNOTNULL
JMP PRINTNULL
RNOTNULL	JSR CHECKFORFASTOUT
JMP RESETROUTE
;###################################
;###################################
LINEBREAK	JSR REROUTE
LDA #$0D
JSR CHROUT
JMP RESETROUTE
;###################################
;###################################
PRINTNULL	JSR REROUTE
LDA #$20
JSR CHROUT
LDA #$30
JSR CHROUT
JMP RESETROUTE
;###################################
;###################################
STROUTWL	STA A_REG
STY A_REG+1
STROUT		JSR REROUTE
LDA A_REG
STA INDEX1
LDA A_REG+1
STA INDEX1+1
LDY #0
LDA (INDEX1),Y
TAX
INC INDEX1
BNE PRINTSTR
INC INDEX1+1
PRINTSTR	JSR PRINTSTRS
LDA HIGHP			; Update the memory pointer to the last actually assigned one
STA STRBUFP
LDA HIGHP+1
STA STRBUFP+1
JSR RESETROUTE
RTS
;###################################
;###################################
STROUTBRKWL	STA A_REG
STY A_REG+1
STROUTBRK	JSR REROUTE
LDA A_REG
STA INDEX1
LDA A_REG+1
STA INDEX1+1
LDY #0
LDA (INDEX1),Y
TAX
INC INDEX1
BNE PRINTSTR2
INC INDEX1+1
PRINTSTR2	JSR PRINTSTRS
LDA HIGHP			; Update the memory pointer to the last actually assigned one
STA STRBUFP
LDA HIGHP+1
STA STRBUFP+1
LDA #$0D
JSR CHROUT
JMP RESETROUTE 	;RTS is implicit
;###################################
;###################################
ARRAYACCESS_REAL_S
STA G_REG
STY G_REG+1
ARRAYACCESS_REAL
JSR XREGFAC
JSR FACINT
ARRAYACCESS_REAL_INT
LDX G_REG
STX TMP_ZP
LDX G_REG+1
STX TMP_ZP+1
STY TMP3_ZP
STA TMP3_ZP+1
TAX
TYA
ASL
TAY
TXA
ROL
TAX
TYA
ASL
STA TMP2_ZP
TXA
ROL
STA TMP2_ZP+1
LDA TMP_ZP
CLC
ADC TMP3_ZP
STA TMP_ZP
LDA TMP_ZP+1
ADC TMP3_ZP+1
STA TMP_ZP+1
LDA TMP_ZP
CLC
ADC TMP2_ZP
STA TMP3_ZP
LDA TMP_ZP+1
ADC TMP2_ZP+1
STA TMP3_ZP+1
JMP COPY2_XY_XREG
;###################################
;###################################
ARRAYSTORE_REAL
JSR XREGFAC
JSR FACINT
ARRAYSTORE_REAL_INT
LDX G_REG
STX TMP_ZP
LDX G_REG+1
STX TMP_ZP+1
STY TMP3_ZP
STA TMP3_ZP+1
TAX
TYA
ASL
TAY
TXA
ROL
TAX
TYA
ASL
STA TMP2_ZP
TXA
ROL
STA TMP2_ZP+1
LDA TMP_ZP
CLC
ADC TMP3_ZP
STA TMP_ZP
LDA TMP_ZP+1
ADC TMP3_ZP+1
STA TMP_ZP+1
LDA TMP_ZP
CLC
ADC TMP2_ZP
STA TMP_ZP
LDA TMP_ZP+1
ADC TMP2_ZP+1
STA TMP_ZP+1
JMP COPY2_YREG_XYA	;RTS is implicit
;###################################
;###################################
ADJUSTSTACK LDA FORSTACKP	; Adjust the FORSTACK in case a new loop uses an unclosed old one (i.e. the code jumped out of that loop with goto)
STA TMP_ZP
LDA FORSTACKP+1
STA TMP_ZP+1
ADSEARCHFOR	LDA TMP_ZP
CMP #<FORSTACK
BNE ADJUST2
LDA TMP_ZP+1
CMP #>FORSTACK
BNE ADJUST2
RTS				; Start of Stack reached? Return
ADJUST2		LDA TMP_ZP
SEC
SBC #2
STA TMP_ZP
BCS ADNOPV1N1
DEC TMP_ZP+1
ADNOPV1N1	LDY #0
LDA (TMP_ZP),Y
BNE ADNOGOSUB
RTS				; Encountered a GOSUB on the way? Then return (is this correct?)
ADNOGOSUB
INY
LDA TMP_ZP
SEC
SBC (TMP_ZP),Y
STA TMP_ZP
BCS ADNOPV1N2
DEC TMP_ZP+1
ADNOPV1N2	DEY
LDA A_REG
ADCMPFOR	CMP (TMP_ZP),Y
BNE ADSEARCHFOR
LDA A_REG+1
INY
CMP (TMP_ZP),Y
BEQ ADFOUNDFOR
JMP ADSEARCHFOR
ADLOW0		LDX A_REG+1
BEQ ADFOUNDFOR
BNE ADCMPFOR
ADFOUNDFOR	LDA TMP_ZP		; Adjust the stack so that it points onto the last entry for the "new" loop variable
STA FORSTACKP
LDA TMP_ZP+1
STA FORSTACKP+1
RTS
;###################################
;###################################
INITFOR		JSR ADJUSTSTACK
LDA FORSTACKP
STA TMP_ZP
LDA FORSTACKP+1
STA TMP_ZP+1
LDY #0
LDA A_REG
STA (TMP_ZP),Y
INY
LDA A_REG+1
STA (TMP_ZP),Y
INY
LDA JUMP_TARGET
STA (TMP_ZP),Y
INY
LDA JUMP_TARGET+1
STA (TMP_ZP),Y
INY
STY TMP3_ZP
JSR INCTMPZP
JSR POPREAL
LDX TMP_ZP
LDY TMP_ZP+1
; FAC to (X/Y)
JSR FACMEM
JSR SGNFAC
STA TMP_FLAG
LDY #5
STY TMP3_ZP
JSR INCTMPZP
JSR POPREAL
LDX TMP_ZP
LDY TMP_ZP+1
; FAC to (X/Y)
JSR FACMEM
LDY #5
STY TMP3_ZP
JSR INCTMPZP
LDY #0
LDA TMP_FLAG
STA (TMP_ZP),Y
INY
LDA #1
STA (TMP_ZP),Y
INY
LDA #15
STA (TMP_ZP),Y
LDY #3
STY TMP3_ZP
JSR INCTMPZP
LDA TMP_ZP
STA FORSTACKP
LDA TMP_ZP+1
STA FORSTACKP+1
RTS
;###################################
;###################################
NEXT		LDA FORSTACKP
STA TMP_ZP
LDA FORSTACKP+1
STA TMP_ZP+1
SEARCHFOR	LDA TMP_ZP+1
STA TMP3_REG+1
LDA TMP_ZP
STA TMP3_REG
SEC
SBC #2
STA TMP_ZP
BCS NOPV1N1
DEC TMP_ZP+1
NOPV1N1		LDY #0
LDA (TMP_ZP),Y
BNE NOGOSUB
JMP NEXTWOFOR
NOGOSUB
INY
LDA TMP_ZP
SEC
SBC (TMP_ZP),Y
STA TMP_ZP
BCS NOPV1N2
DEC TMP_ZP+1
NOPV1N2		DEY
LDA A_REG
BEQ LOW0
CMPFOR		CMP (TMP_ZP),Y
BNE SEARCHFOR
LDA A_REG+1
INY
CMP (TMP_ZP),Y
BEQ FOUNDFOR
JMP SEARCHFOR
LOW0		LDX A_REG+1
BEQ FOUNDFOR
BNE CMPFOR
FOUNDFOR	LDA TMP_ZP
STA TMP2_REG
LDA TMP_ZP+1
STA TMP2_REG+1
VARREAL
LDY #0
STY A_REG+1 ; Has to be done anyway...so we can do it here as well
LDA (TMP_ZP),Y
TAX
INY
LDA (TMP_ZP),Y
TAY
TXA
JSR REALFAC
CALCNEXT	LDA TMP_ZP
CLC
ADC #4
STA TMP_ZP
BCC NOPV2IN
INC TMP_ZP+1
NOPV2IN		STA TMP_REG
LDY TMP_ZP+1
STY TMP_REG+1
JSR FACADD
LDA TMP2_REG
STA TMP_ZP
LDA TMP2_REG+1
STA TMP_ZP+1
STOREREAL
LDY #0
LDA (TMP_ZP),Y
TAX
INY
LDA (TMP_ZP),Y
TAY
JSR FACMEM	;FAC TO (X/Y)
CMPFOR		LDA #5
STA TMP3_ZP
LDA TMP_REG
CLC
ADC #5
STA TMP_REG
BCC NOPV3
INC TMP_REG+1
NOPV3		LDY TMP_REG+1
JSR CMPFAC 	;CMPFAC
BEQ LOOPING
PHA
LDY #14
LDA (TMP_ZP),Y
BEQ STEPZERO
ROL
BCC STEPPOS
STEPNEG		PLA
ROL
BCC LOOPING
BCS EXITLOOP
STEPPOS		PLA
ROL
BCC EXITLOOP
LOOPING		LDA TMP3_REG
STA FORSTACKP
LDA TMP3_REG+1
STA FORSTACKP+1
LDA TMP2_REG
CLC
ADC #2
STA TMP2_REG
BCC NOPV4IN
INC TMP2_REG+1
NOPV4IN		LDY #0
STY A_REG
STA TMP_ZP
LDA TMP2_REG+1
STA TMP_ZP+1
LDA (TMP_ZP),Y
STA JUMP_TARGET
INY
LDA (TMP_ZP),Y
STA JUMP_TARGET+1
RTS
STEPZERO	PLA
JMP LOOPING
EXITLOOP	LDA TMP2_REG
STA FORSTACKP
LDA TMP2_REG+1
STA FORSTACKP+1
LDA #1
STA A_REG
RTS
;###################################
;###################################
RETURN		LDA FORSTACKP
STA TMP_ZP
LDA FORSTACKP+1
STA TMP_ZP+1
SEARCHGOSUB	LDA TMP_ZP
SEC
SBC #2
STA TMP_ZP
BCS NOPV1SG
DEC TMP_ZP+1
NOPV1SG		LDY #0
LDA (TMP_ZP),Y
BEQ FOUNDGOSUB
INY
LDA (TMP_ZP),Y
STA TMP3_ZP
LDA TMP_ZP
SEC
SBC (TMP_ZP),Y
STA TMP_ZP
BCS NOPV1GS
DEC TMP_ZP+1
NOPV1GS		JMP SEARCHGOSUB
FOUNDGOSUB
LDA TMP_ZP
STA FORSTACKP
LDA TMP_ZP+1
STA FORSTACKP+1
RTS
;###################################
;###################################
GOSUB		LDA FORSTACKP
STA TMP_ZP
LDA FORSTACKP+1
STA TMP_ZP+1
LDY #0
TYA
STA (TMP_ZP),Y
INY
STA (TMP_ZP),Y
INY
TYA
CLC
ADC TMP_ZP
STA FORSTACKP
BCC GOSUBNOOV
INC FORSTACKP+1
GOSUBNOOV	RTS
;###################################
;###################################
READINIT	LDA DATASP
STA TMP3_ZP
LDA DATASP+1
STA TMP3_ZP+1
LDY #$0
LDA (TMP3_ZP),Y
INC TMP3_ZP
BNE READNOOV
INC TMP3_ZP+1
READNOOV	CMP #$FF
BNE MOREDATA
JMP OUTOFDATA
MOREDATA	RTS
;###################################
;###################################
READADDPTR	STX TMP_REG+1
LDA TMP3_ZP
CLC
ADC TMP_REG+1
STA TMP3_ZP
BCC READADDPTRX
INC TMP3_ZP+1
READADDPTRX	RTS
;###################################
;###################################
READNUMBER	JSR READINIT
MORENUMDATA CMP #$2				; Strings are not allowed here
BNE NUMNUM
LDA (TMP3_ZP),Y		; ...unless they are empty, which makes them count as 0
BEQ RNESTR
CMP #1				; or a "." or "e", which is 0 as well...so length has to be 1..
BEQ STRGNUMCHK
JMP SYNTAXERROR
STRGNUMCHK 	INY
LDA (TMP3_ZP),Y
CMP #46				; ...and really a "."?
BEQ RNESTR2
CMP #69				; ...or really an "e"?
BEQ RNESTR2
JMP SYNTAXERROR
RNESTR2		LDA #0
LDY #0
JSR INTFAC
LDX #2
JSR READADDPTR
JMP NUMREAD
RNESTR		LDA #0
LDY #0
JSR INTFAC
LDX #1
JSR READADDPTR
JMP NUMREAD
NUMNUM		CMP #$1
BEQ NUMREADREAL
CMP #$0
BEQ NUMREADINT
CMP #$4
BCS READNOTYPE
LDA (TMP3_ZP),Y
TAY
JSR BYTEFAC
LDX #1
JSR READADDPTR
JMP NUMREAD			; It's a byte
READNOTYPE	TAY					; It's a byte >3, which mean it has no typing stored to save memory
JSR BYTEFAC
JMP NUMREAD
NUMREADINT	LDA (TMP3_ZP),Y		; It's an integer
STA TMP_REG
INY
LDA (TMP3_ZP),Y
LDY TMP_REG
JSR INTFAC
LDX #2
JSR READADDPTR
JMP NUMREAD
NUMREADREAL	LDA TMP3_ZP
LDY TMP3_ZP+1
JSR REALFAC
LDX #5
JSR READADDPTR
NUMREAD		JSR NEXTDATA
JMP FACYREG		; ...and return
;###################################
;###################################
NEXTDATA	LDA TMP3_ZP			; Adjust pointer to the next element
STA DATASP
LDA TMP3_ZP+1
STA DATASP+1
RTS
;###################################
;###################################
GETSTR		LDA #8
LDY #0
JSR COMPACTF
LDY #0
STY CMD_NUM		; Reset CMD target
JSR GETIN
CMP #0			; Without this compare, it works for disk and keyboard GETs...but not for those from the RS232 port...DOH!
BNE SOMEKEY
NOKEY		LDA #<EMPTYSTR
STA A_REG
LDA #>EMPTYSTR
STA A_REG+1
RTS
SOMEKEY		TAX
LDA STRBUFP
STA TMP_ZP
STA A_REG
LDA STRBUFP+1
STA TMP_ZP+1
STA A_REG+1
LDA #1
LDY #0
STA (TMP_ZP),Y
TXA
LDY #1
STA (TMP_ZP),Y
LDA STRBUFP
CLC
ADC #2
STA STRBUFP
BCC GETSTR1
INC STRBUFP+1
GETSTR1		RTS
;###################################
;###################################
ZEROSET		LDA #0
STA X_REG
STA X_REG+1
STA X_REG+2
STA X_REG+3
STA X_REG+4
RTS
;###################################
;###################################
SEQ			JSR CMPSTR
LDA TMP3_ZP
BNE NOTSEQ
LDA #<REAL_CONST_MINUS_ONE
STA TMP3_ZP
LDA #>REAL_CONST_MINUS_ONE
STA TMP3_ZP+1
JMP COPY2_XY_XREG
NOTSEQ		JMP ZEROSET
;###################################
;###################################
CMPSTR		LDY #0			;Returns 0 if strings are equal, something else otherwise
LDX #1
LDA A_REG
STA TMP_ZP
LDA A_REG+1
STA TMP_ZP+1
LDA B_REG
STA TMP2_ZP
LDA B_REG+1
STA TMP2_ZP+1
CMP TMP_ZP+1
BNE CMPSTRSK1
LDA TMP2_ZP
CMP TMP_ZP
BNE CMPSTRSK1
LDX #0
JMP STRCMPRES
CMPSTRSK1	LDA (TMP_ZP),Y
CMP (TMP2_ZP),Y
BNE STRCMPRES
TAX
BNE NOTZCTR
LDX #0
JMP STRCMPRES
NOTZCTR		INC TMP_ZP
BNE SCSKP1
INC TMP_ZP+1
SCSKP1		INC TMP2_ZP
BNE CMPSTRLOOP
INC TMP2_ZP+1
CMPSTRLOOP	LDA (TMP_ZP),Y
CMP (TMP2_ZP),Y
BNE STRCMPRES
INY
DEX
BNE CMPSTRLOOP
STRCMPRES	STX TMP3_ZP
RTS
;###################################
;##################################
REALFACPUSH	STA TMP_ZP
STY	TMP_ZP+1
LDX FPSTACKP
LDY FPSTACKP+1
STX TMP2_ZP
STY TMP2_ZP+1
LDY #0
LDA (TMP_ZP),Y
STA (TMP2_ZP),Y
INY
LDA (TMP_ZP),Y
STA (TMP2_ZP),Y
INY
LDA (TMP_ZP),Y
STA (TMP2_ZP),Y
INY
LDA (TMP_ZP),Y
STA (TMP2_ZP),Y
INY
LDA (TMP_ZP),Y
STA (TMP2_ZP),Y
TXA				;LDA FPSTACKP
CLC
ADC #5
STA FPSTACKP
BCC NOPVRFPXX
INC FPSTACKP+1
NOPVRFPXX	RTS
;###################################
;###################################
PUSHREAL	LDX FPSTACKP
LDY FPSTACKP+1
JSR FACMEM
LDA FPSTACKP
CLC
ADC #5
STA FPSTACKP
BCC NOPVPUR
INC FPSTACKP+1
NOPVPUR		RTS
;###################################
;###################################
POPREAL2X	LDA FPSTACKP
SEC
SBC #5
STA FPSTACKP
BCS NOPVPR2X
DEC FPSTACKP+1
NOPVPR2X	LDA FPSTACKP
LDY FPSTACKP+1
JSR REALFAC
JSR XREGARG
RTS
;###################################
;###################################
POPREAL		LDA FPSTACKP
SEC
SBC #5
STA FPSTACKP
BCS NOPVPR
DEC FPSTACKP+1
NOPVPR		LDA FPSTACKP
LDY FPSTACKP+1
JMP REALFAC
;###################################
;###################################
POPREALXREG LDA FPSTACKP
SEC
SBC #5
STA FPSTACKP
BCS NOPVPRXR
DEC FPSTACKP+1
NOPVPRXR	LDA FPSTACKP
LDY FPSTACKP+1
STA TMP_ZP
STY TMP_ZP+1
LDY #$4
LDA (TMP_ZP),Y
STA X_REG+4
STA FACLO
DEY
LDA (TMP_ZP),Y
STA X_REG+3
STA FACMO
DEY
LDA (TMP_ZP),Y
STA X_REG+2
STA FACMOH
DEY
LDA (TMP_ZP),Y
STA X_REG+1
STA FACSGN
ORA #$80
STA FACHO
DEY
LDA (TMP_ZP),Y
STA X_REG
STA FACEXP
STY FACOV
RTS
;###################################
;###################################
SHL			LDA FACEXP
BEQ SHLOK
CLC
ADC A_REG
BCC SHLOK
LDA #0
STA FACSGN
STA FACLO
STA FACMO
STA FACMOH
STA FACHO
LDA #$FF
SHLOK		STA FACEXP
RTS
;###################################
;###################################
INCTMPZP	LDA TMP_ZP
CLC
ADC TMP3_ZP
STA TMP_ZP
BCC NOPV2
INC TMP_ZP+1
NOPV2		RTS
;###################################
;###################################
COPY2_YREG_XYA
LDY #0
LDA Y_REG
STA (TMP_ZP),Y
INY
LDA Y_REG+1
STA (TMP_ZP),Y
INY
LDA Y_REG+2
STA (TMP_ZP),Y
INY
LDA Y_REG+3
STA (TMP_ZP),Y
INY
LDA Y_REG+4
STA (TMP_ZP),Y
RTS
;###################################
;###################################
COPY2_XYA_XREG
STA TMP3_ZP
STY TMP3_ZP+1
COPY2_XY_XREG
LDX #<X_REG		; the pointer to X_REG has to be in X, because the "value already in X"-optimization might expect it to be there! YIKES!
LDY #0
LDA (TMP3_ZP),Y
STA X_REG
INY
LDA (TMP3_ZP),Y
STA X_REG+1
INY
LDA (TMP3_ZP),Y
STA X_REG+2
INY
LDA (TMP3_ZP),Y
STA X_REG+3
INY
LDA (TMP3_ZP),Y
STA X_REG+4
RTS
;###################################
;###################################
COPY2_XYA_YREG
STA TMP3_ZP
STY TMP3_ZP+1
COPY2_XY_YREG
LDX #<Y_REG		; the pointer to Y_REG has to be in X, because the "value already in X"-optimization might expect it to be there! YIKES!
LDY #0
LDA (TMP3_ZP),Y
STA Y_REG
INY
LDA (TMP3_ZP),Y
STA Y_REG+1
INY
LDA (TMP3_ZP),Y
STA Y_REG+2
INY
LDA (TMP3_ZP),Y
STA Y_REG+3
INY
LDA (TMP3_ZP),Y
STA Y_REG+4
RTS
;###################################
;###################################
COPY_XREG2YREG
LDA X_REG
STA Y_REG
LDA X_REG+1
STA Y_REG+1
LDA X_REG+2
STA Y_REG+2
LDA X_REG+3
STA Y_REG+3
LDA X_REG+4
STA Y_REG+4
RTS
;###################################
;###################################
<IF !BIGRAM>
FACWORD
LDA FACEXP			; Check if there's a -0 in FAC1
BNE DOFACWORD
STA FACSGN			; make sure that it's not -0
DOFACWORD:
JMP XFACWORD
</IF>
;###################################
;###################################
ONETOFAC    LDX #129
STX FAC
DEX
STX FAC+1
LDX #0
STX FAC+2
STX FAC+3
STX FAC+4
STX FAC+5
STX FAC+6
RTS
;###################################
;###################################
FASTAND		LDA ARGEXP			; Check ARG for 0
BNE CHECKFAC
STA FACSGN			; if so, set FAC to 0 and exit
STA FACLO
STA FACMO
STA FACMOH
STA FACHO
STA FACEXP
RTS
CHECKFAC	LDA FACEXP			; Check if there's a -1 in FAC1
BNE FACNOTNULL
STA FACSGN			; make sure that it's not -0
RTS				; FAC is 0, then exit
FACNOTNULL	CMP #$81
BNE NORMALAND
LDA FACHO
CMP #$80
BNE NORMALAND
LDA FACMOH
BNE NORMALAND
LDA FACMO
BNE NORMALAND
LDA FACLO
BNE NORMALAND
LDA FACSGN
ROL
BCC NORMALAND
LDA ARGEXP			; Check if there's a -1 in ARG
CMP #$81
BNE NORMALAND
LDA ARGHO
CMP #$80
BNE NORMALAND
LDA ARGMOH
BNE NORMALAND
LDA ARGMO
BNE NORMALAND
LDA ARGLO
BNE NORMALAND
LDA ARGSGN
ROL
BCC NORMALAND
RTS				; both, FAC1 and ARG contain -1...then we leave FAC1 untouched and return
NORMALAND	JMP ARGAND
;###################################
;###################################
FASTOR		LDA FACEXP			; Check FAC for 0
BNE CHECKFACOR
LDA ARGEXP			; if so, is ARG = 0 as well?
BNE CHECKARGOR	; no, continue with ARG (FAC is still 0 here)
LDA #0
STA FACSGN			; make sure that the negative flag is deleted in this case...
RTS				; yes? Then we leave FAC untouched
CHECKFACOR	LDA FACEXP			; Check if there's a -1 in FAC1
CMP #$81
BNE NORMALOR
LDA FACHO
CMP #$80
BNE NORMALOR
LDA FACMOH
BNE NORMALOR
LDA FACMO
BNE NORMALOR
LDA FACLO
BNE NORMALOR
LDA FACSGN
ROL
BCC NORMALOR
CHECKARGOR	LDA ARGEXP			; Check if there's a -1 in ARG
BNE CHECKARGOR2
RTS 			; ARG is actually 0? Then the value of FAC doesn't change. We can exit here
CHECKARGOR2	CMP #$81
BNE NORMALOR
LDA ARGHO
CMP #$80
BNE NORMALOR
LDA ARGMOH
BNE NORMALOR
LDA ARGMO
BNE NORMALOR
LDA ARGLO
BNE NORMALOR
LDA ARGSGN
AND #$80
CMP #$80
BNE NORMALOR
JMP ARGFAC		; ARG is 1, so just copy it to FAC and exit (implicit)
NORMALOR	JMP FACOR
;###################################
;###################################
INITOUTCHANNEL
LDA CHLOCKFLAG
BEQ INITOUT2
CMP #$FF
BNE SKIPINITCH
INITOUT2
LDA #<C_REG
LDY #>C_REG
JSR REALFAC
JSR FACWORD
TYA
TAX
CPX CMD_NUM
BNE CMDNEQUAL
LDY #0
STY CMD_NUM			; Reset CMD channel
CMDNEQUAL	STA CHANNEL
STA CHLOCKFLAG
JMP CHKOUT
SKIPINITCH
RTS
;###################################
;###################################
CLRCHNEW
LDA CHLOCKFLAG
BNE SKIPCLRCH
JMP CLRCH
SKIPCLRCH
RTS
;###################################
;###################################
TABCHANNEL
JSR INITOUTCHANNEL
TABCHANNELINT
LDA CHANNEL
CMP #3		; To the screen?
BEQ TABSCREEN
TABCHANNEL2	LDA IOCHANNEL
STA STORE1
LDA #1
STA IOCHANNEL		; Something that's not the screen...that's enough for the check the CRSRRIGHT does...
JSR YREGFAC
JSR FACWORD
TYA
TAX
JMP EXITCHANNEL
TABSCREEN
JSR CLRCHNEW
JMP TAB
;###################################
;###################################
EXITCHANNEL	CLC
JSR TABSPC
JSR CLRCHNEW
LDA STORE1
STA IOCHANNEL
RTS
;###################################
;###################################
CHECKCMD	LDA CMD_NUM		; if CMD mode, then print an additional space
BEQ NOCMD
JSR REROUTE
LDA #$20
JMP CHROUT
JSR RESETROUTE
NOCMD		RTS
;###################################
;###################################
NEXTWOFOR
<IF BOOST>
JSR BOOSTDIASBLE
</IF>
LDX #$0A
JMP ERRALL
;###################################
;###################################
OUTOFDATA
<IF BOOST>
JSR BOOSTDIASBLE
</IF>
LDX #$0D
JMP ERRALL
;###################################
;###################################
OUTOFMEMORY
<IF BOOST>
JSR BOOSTDIASBLE
</IF>
LDX #$10
JMP ERRALL
;###################################
;###################################
SYNTAXERROR
<IF BOOST>
JSR BOOSTDIASBLE
</IF>
JMP ERRSYN
;###################################
;###################################
FACXREG		LDA FACLO
STA X_REG+4
LDA FACMO
STA X_REG+3
LDA FACMOH
STA X_REG+2
LDA FACSGN
ORA #$7F
AND FACHO
STA X_REG+1
LDA FACEXP
STA X_REG
LDA #0			; Why? Don't know...the ROM does this as well...
STA FACOV
RTS
;###################################
;###################################
FACYREG		LDA FACLO
STA Y_REG+4
LDA FACMO
STA Y_REG+3
LDA FACMOH
STA Y_REG+2
LDA FACSGN
ORA #$7F
AND FACHO
STA Y_REG+1
LDA FACEXP
STA Y_REG
LDA #0			; Why? Don't know...the ROM does this as well...
STA FACOV
RTS
;###################################
;###################################
XREGFAC		LDA X_REG+4
STA FACLO
LDA X_REG+3
STA FACMO
LDA X_REG+2
STA FACMOH
LDA X_REG+1
STA FACSGN
ORA #$80
STA FACHO
LDA X_REG
STA FACEXP
LDA #0
STA FACOV
RTS
;###################################
;###################################
XREGARG		LDA X_REG+4
STA ARGLO
LDA X_REG+3
STA ARGMO
LDA X_REG+2
STA ARGMOH
LDA X_REG+1
STA ARGSGN
EOR FACSGN
STA ARISGN
LDA ARGSGN
ORA #$80
STA ARGHO
LDA X_REG
STA ARGEXP
LDA FACEXP
RTS
;###################################
;###################################
YREGFAC		LDA Y_REG+4
STA FACLO
LDA Y_REG+3
STA FACMO
LDA Y_REG+2
STA FACMOH
LDA Y_REG+1
STA FACSGN
ORA #$80
STA FACHO
LDA Y_REG
STA FACEXP
LDA #0
STA FACOV
RTS
;###################################
;###################################
<IF BOOST>
BOOSTENABLE
LDA $D030
CMP #$FF
BNE C128
RTS
C128
LDA #1
STA BOOSTFLAG
LDA #0
STA BOOSTCNT
LDA $0314
STA IRQROUT
LDA $0315
STA IRQROUT+1
SEI
LDA #<MYRASTER
STA $0314
LDA #>MYRASTER
STA $0315
LDA #46
STA $D012
LDA $D011
AND #127
STA $D011
LDA $D01A
ORA #1
STA $D01A
CLI
RTS
MYRASTER
LDA $D019
BMI RASTER
LDA $DC0D
CLI
JMP $EA31
RASTER
STA $D019
LDA $D012
CMP #254
BCS SETSTART
LDA #0
STA $D030
LDA #254
STA $D012
JMP EXIT
SETSTART
LDA #1
STA $D030
LDA #46
STA $D012
EXIT
PLA
TAY
PLA
TAX
PLA
RTI
BOOSTFLAG
.BYTE 0
BOOSTCNT
.BYTE 0
IRQROUT
.WORD 0
NOBOOST
RTS
BOOSTOFF
LDA BOOSTFLAG
BEQ NOBOOST
SEI
LDA $D01A
AND #14
STA $D01A
LDA #0
STA $D030
INC BOOSTCNT
CLI
RTS
BOOSTON
LDA BOOSTFLAG
BEQ NOBOOST
LDA BOOSTCNT
BEQ BOOSTZERO	; Zero? Then just enable boost
BPL BOOSTNOV
LDA #0			; Counter >128, then reset it anyway (should not occur)
STA BOOSTCNT
JMP BOOSTZERO
BOOSTNOV
DEC BOOSTCNT
BNE NOBOOST
BOOSTZERO
SEI
LDA $D01A
ORA #1
STA $D01A
CLI
RTS
BOOSTDIASBLE
LDA BOOSTFLAG
BEQ NOBOOST
JSR BOOSTOFF
SEI
LDA IRQROUT
STA $0314
LDA IRQROUT+1
STA $0315
CLI
RTS
</IF>
;###################################
;###############################
INITVARS
JSR INITSTRVARS
LDA #0
LDY #4
REALINITLOOP0:
STA VAR_DI,Y
STA VAR_KK,Y
STA VAR_SC,Y
STA VAR_CH,Y
STA VAR_E1,Y
STA VAR_Z,Y
STA VAR_E3,Y
STA VAR_Q,Y
STA VAR_H,Y
STA VAR_Y,Y
STA VAR_S,Y
STA VAR_T,Y
STA VAR_V,Y
STA VAR_W,Y
STA VAR_DO,Y
STA VAR_SS,Y
STA VAR_N,Y
STA VAR_SO,Y
STA VAR_M,Y
STA VAR_E2,Y
STA VAR_O,Y
STA VAR_R,Y
DEY
BMI REALLOOPEXIT0
JMP REALINITLOOP0
REALLOOPEXIT0:
LDA #<VAR_DO[]
LDY #>VAR_DO[]
JSR INITSPARAMS
JSR INITNARRAY
LDA #<VAR_D[]
LDY #>VAR_D[]
JSR INITSPARAMS
JSR INITNARRAY
LDA #<VAR_B[]
LDY #>VAR_B[]
JSR INITSPARAMS
JSR INITNARRAY
LDA #0
RTS
;###############################
; *** SUBROUTINES END ***
; *** CONSTANTS ***
CONSTANTS
; CONST: #30


; CONST: #240

CONST_1R	.REAL 240.0
; CONST: #150

CONST_2R	.REAL 150.0
; CONST: ${clr}
CONST_3	.BYTE 5
.STRG "{clr}"
; CONST: #255


; CONST: #143.0


; CONST: #25


; CONST: #0

CONST_7R	.REAL 0.0
; CONST: #-1.0

CONST_8	.REAL -1.0
; CONST: #1

CONST_9R	.REAL 1.0
; CONST: #0.1

CONST_10	.REAL 0.1
; CONST: #2

CONST_11R	.REAL 2.0
; CONST: #4

CONST_12R	.REAL 4.0
; CONST: #2.0

CONST_13	.REAL 2.0
; CONST: #6.0

CONST_14	.REAL 6.0
; CONST: #57

CONST_15R	.REAL 57.0
; CONST: #10000

CONST_16R	.REAL 10000.0
; CONST: #8143

CONST_17R	.REAL 8143.0
; CONST: #59


; CONST: #22

CONST_19R	.REAL 22.0
; CONST: #62

CONST_20R	.REAL 62.0
; CONST: #58

CONST_21R	.REAL 58.0
; CONST: #30720.0

CONST_22	.REAL 30720.0
; CONST: #7712

CONST_23R	.REAL 7712.0
; CONST: #3

CONST_24R	.REAL 3.0
; CONST: #5

CONST_25R	.REAL 5.0
; CONST: #57.0

CONST_26	.REAL 57.0
; CONST: #56.0

CONST_27	.REAL 56.0
; CONST: #21

CONST_28R	.REAL 21.0
; CONST: #23

CONST_29R	.REAL 23.0
; CONST: #60

CONST_30R	.REAL 60.0
; CONST: #1000

CONST_31R	.REAL 1000.0
; CONST: ${home}{rvon}
CONST_32	.BYTE 12
.STRG "{home}{rvon}"
; CONST: #8

CONST_33R	.REAL 8.0
; CONST: #61

CONST_34R	.REAL 61.0
; CONST: #200


; CONST: #252


; CONST: #16

CONST_37R	.REAL 16.0
; CONST: #56


; CONST: #63

CONST_39R	.REAL 63.0
; CONST: #8164

CONST_40R	.REAL 8164.0
; CONST: #12

CONST_41R	.REAL 12.0
; CONST: #250

CONST_42R	.REAL 250.0
; CONST: #14

CONST_43R	.REAL 14.0
; CONST: #10

CONST_44R	.REAL 10.0
; CONST: #8163

CONST_45R	.REAL 8163.0
; CONST: #11

CONST_46R	.REAL 11.0
; CONST: #100

CONST_47R	.REAL 100.0
; CONST: #0.05

CONST_48	.REAL 0.05
; CONST: ${clr}{pur}
CONST_49	.BYTE 10
.STRG "{clr}{pur}"
; CONST: $>>>>>>>>>>>>>>>>>>>>>{left}{inst}>
CONST_50	.BYTE 34
.STRG ">>>>>>>>>>>>>>>>>>>>>{left}{inst}>"
; CONST: ${home}
CONST_51	.BYTE 6
.STRG "{home}"
; CONST: ${down}{down}
CONST_52	.BYTE 12
.STRG "{down}{down}"
; CONST: #6

CONST_53R	.REAL 6.0
; CONST: $?>>>>>>>>?{red}
CONST_54	.BYTE 15
.STRG "?>>>>>>>>?{red}"
; CONST: $9{pur}88888888{red}9
CONST_55	.BYTE 20
.STRG "9{pur}88888888{red}9"
; CONST: $9>>>>>>>>9
CONST_56	.BYTE 10
.STRG "9>>>>>>>>9"
; CONST: $9>>>>>>>>9{pur}
CONST_57	.BYTE 15
.STRG "9>>>>>>>>9{pur}"
; CONST: $>88888888888888888888
CONST_58	.BYTE 21
.STRG ">88888888888888888888"
; CONST: ${down}{down}{down}{down}
CONST_59	.BYTE 24
.STRG "{down}{down}{down}{down}"
; CONST: ${rvon}
CONST_60	.BYTE 6
.STRG "{rvon}"
; CONST: #17

CONST_61R	.REAL 17.0
; CONST: #163


; CONST: #7834

CONST_63R	.REAL 7834.0
; CONST: #110

CONST_64R	.REAL 110.0
; CONST: #88

CONST_65R	.REAL 88.0
; CONST: #0.5

CONST_66	.REAL 0.5
; CONST: #7812

CONST_67R	.REAL 7812.0
; CONST: #8142

CONST_68R	.REAL 8142.0
; CONST: #7833

CONST_69R	.REAL 7833.0
; CONST: #10000.0

CONST_70	.REAL 10000.0
; CONST: #7616

CONST_71R	.REAL 7616.0
; CONST: #7679

CONST_72R	.REAL 7679.0
; CONST: #828

CONST_73R	.REAL 828.0
; CONST: #914.0

CONST_74	.REAL 914.0
; CONST: #242


; CONST: ${clr}{blue}{down}{down}{rvson} THE HARDHAT CLIMBER {rvsoff}{down}
CONST_76	.BYTE 65
.STRG "{clr}{blue}{down}{down}{rvson} THE HARDHAT CLIMBER {rvsoff}{down}"
; CONST: $      written by
CONST_77	.BYTE 16
.STRG "      written by"
; CONST: $     {black}Chris Lesher{blue}
CONST_78	.BYTE 30
.STRG "     {black}Chris Lesher{blue}"
; CONST: $  Compute!'s Gazette
CONST_79	.BYTE 20
.STRG "  Compute!'s Gazette"
; CONST: $      Jan, 1984
CONST_80	.BYTE 15
.STRG "      Jan, 1984"
; CONST: $  2023 turbo edition
CONST_81	.BYTE 20
.STRG "  2023 turbo edition"
; CONST: $ by Antonino Porcino
CONST_82	.BYTE 20
.STRG " by Antonino Porcino"
; CONST: ${green}github.com/nippur72
CONST_83	.BYTE 26
.STRG "{green}github.com/nippur72"
; CONST: $/lo-scalatore{blue}
CONST_84	.BYTE 19
.STRG "/lo-scalatore{blue}"
; CONST: $    press any key
CONST_85	.BYTE 17
.STRG "    press any key"
; CONST: $
CONST_86	.BYTE 0
.STRG ""
; CONST: ${clr}{blk}your score:
CONST_87	.BYTE 22
.STRG "{clr}{blk}your score: "
; CONST: ${down}{down}{down}{down}press any key
CONST_88	.BYTE 37
.STRG "{down}{down}{down}{down}press any key"
;###############################
; ******** DATA ********
DATAS
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 3
.BYTE 1
.BYTE 21
.BYTE 22
.BYTE 23
.BYTE 24
.BYTE 42
.BYTE 43
.BYTE 44
.BYTE 45
.BYTE 46
.BYTE 47
.BYTE 3
.BYTE 255
.BYTE 3
.BYTE 255
.BYTE 153
.BYTE 102
.BYTE 102
.BYTE 153
.BYTE 3
.BYTE 255
.BYTE 3
.BYTE 255
.BYTE 195
.BYTE 3
.BYTE 255
.BYTE 3
.BYTE 255
.BYTE 195
.BYTE 195
.BYTE 3
.BYTE 255
.BYTE 3
.BYTE 255
.BYTE 195
.BYTE 60
.BYTE 60
.BYTE 25
.BYTE 3
.BYTE 255
.BYTE 188
.BYTE 60
.BYTE 36
.BYTE 231
.BYTE 3
.BYTE 3
.BYTE 4
.BYTE 24
.BYTE 24
.BYTE 60
.BYTE 126
.BYTE 126
.BYTE 60
.BYTE 60
.BYTE 66
.BYTE 165
.BYTE 153
.BYTE 153
.BYTE 165
.BYTE 66
.BYTE 60
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 24
.BYTE 36
.BYTE 126
.BYTE 126
.BYTE 126
.BYTE 126
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 169
.BYTE 2
.BYTE 0
.STRG ""
.BYTE 133
.BYTE 3
.BYTE 1
.BYTE 169
.BYTE 3
.BYTE 255
.BYTE 141
.BYTE 34
.BYTE 145
.BYTE 169
.BYTE 32
.BYTE 44
.BYTE 31
.BYTE 145
.BYTE 208
.BYTE 5
.BYTE 169
.BYTE 3
.BYTE 1
.BYTE 133
.BYTE 3
.BYTE 1
.BYTE 96
.BYTE 169
.BYTE 8
.BYTE 44
.BYTE 31
.BYTE 145
.BYTE 208
.BYTE 5
.BYTE 169
.BYTE 3
.BYTE 2
.BYTE 133
.BYTE 3
.BYTE 1
.BYTE 96
.BYTE 169
.BYTE 16
.BYTE 44
.BYTE 31
.BYTE 145
.BYTE 208
.BYTE 5
.BYTE 169
.BYTE 3
.BYTE 3
.BYTE 133
.BYTE 3
.BYTE 1
.BYTE 96
.BYTE 169
.BYTE 4
.BYTE 44
.BYTE 31
.BYTE 145
.BYTE 208
.BYTE 3
.BYTE 3
.BYTE 133
.BYTE 3
.BYTE 1
.BYTE 96
.BYTE 169
.BYTE 127
.BYTE 141
.BYTE 34
.BYTE 145
.BYTE 169
.BYTE 128
.BYTE 44
.BYTE 32
.BYTE 145
.BYTE 208
.BYTE 4
.BYTE 169
.BYTE 5
.BYTE 133
.BYTE 3
.BYTE 1
.BYTE 96
.BYTE 173
.BYTE 4
.BYTE 144
.BYTE 201
.BYTE 110
.BYTE 208
.BYTE 249
.BYTE 173
.BYTE 4
.BYTE 144
.BYTE 201
.BYTE 111
.BYTE 208
.BYTE 249
.BYTE 96
.BYTE $FF
; ******** DATA END ********
CONSTANTS_END
;###############################
; *** VARIABLES ***
VARIABLES
; VAR: DO[]
.BYTE 1
.WORD 55
VAR_DO[]	.ARRAY 55
; VAR: DI
VAR_DI	.REAL 0.0
; VAR: KK
VAR_KK	.REAL 0.0
; VAR: SC
VAR_SC	.REAL 0.0
; VAR: CH
VAR_CH	.REAL 0.0
; VAR: E1
VAR_E1	.REAL 0.0
; VAR: D[]
.BYTE 1
.WORD 55
VAR_D[]	.ARRAY 55
; VAR: Z
VAR_Z	.REAL 0.0
; VAR: E3
VAR_E3	.REAL 0.0
; VAR: Q
VAR_Q	.REAL 0.0
; VAR: H
VAR_H	.REAL 0.0
; VAR: Y
VAR_Y	.REAL 0.0
; VAR: S
VAR_S	.REAL 0.0
; VAR: T
VAR_T	.REAL 0.0
; VAR: B[]
.BYTE 1
.WORD 60
VAR_B[]	.ARRAY 60
; VAR: V
VAR_V	.REAL 0.0
; VAR: W
VAR_W	.REAL 0.0
; VAR: DO
VAR_DO	.REAL 0.0
; VAR: SS
VAR_SS	.REAL 0.0
; VAR: N
VAR_N	.REAL 0.0
; VAR: SO
VAR_SO	.REAL 0.0
; VAR: M
VAR_M	.REAL 0.0
; VAR: E2
VAR_E2	.REAL 0.0
; VAR: O
VAR_O	.REAL 0.0
; VAR: R
VAR_R	.REAL 0.0
STRINGVARS_START
; VAR: K$
VAR_K$	.WORD EMPTYSTR
; VAR: TI$
VAR_TI$ .WORD EMPTYSTR
STRINGVARS_END
STRINGARRAYS_START
STRINGARRAYS_END
VARIABLES_END
; *** INTERNAL ***
Y_REG	.REAL 0.0
C_REG	.REAL 0.0
D_REG	.REAL 0.0
E_REG	.REAL 0.0
F_REG	.REAL 0.0
A_REG	.WORD 0
B_REG	.WORD 0
CMD_NUM	.BYTE 0
CHANNEL	.BYTE 0
SP_SAVE	.BYTE 0
TMP2_REG	.WORD 0
TMP3_REG	.WORD 0
TMP4_REG	.WORD 0
AS_TMP	.WORD 0
BPOINTER_TMP	.WORD 0
BASICTEXTP	.BYTE 0
STORE1	.WORD 0
STORE2	.WORD 0
STORE3	.WORD 0
STORE4	.WORD 0
GCSTART	.WORD 0
GCLEN	.WORD 0
GCWORK	.WORD 0
TMP_FREG	.REAL 0
TMP2_FREG	.REAL 0
TMP_FLAG	.BYTE 0
REAL_CONST_ONE	.REAL 1.0
REAL_CONST_ZERO	.REAL 0.0
REAL_CONST_MINUS_ONE	.REAL -1.0
CHLOCKFLAG	.BYTE 0
EMPTYSTR	.BYTE 0
FPSTACKP	.WORD FPSTACK
FORSTACKP	.WORD FORSTACK
DATASP	.WORD DATAS
LASTVAR	.WORD 0
LASTVARP	.WORD 0
HIGHP	.WORD STRBUF
STRBUFP	.WORD STRBUF
ENDSTRBUF	.WORD 0
INPUTQUEUEP	.BYTE 0
PROGRAMEND
INPUTQUEUE	.ARRAY $0F
FPSTACK .ARRAY 50
FORSTACK .ARRAY 170
STRBUF	.BYTE 0
