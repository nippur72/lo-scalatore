

   PROCESSOR 6502

   ORG 900

WAITRASTER:
   LDA $9004
	CMP #110
	BNE WAITRASTER
WAITRASTER1:
   LDA $9004
	CMP #110
	BEQ WAITRASTER1
   RTS

