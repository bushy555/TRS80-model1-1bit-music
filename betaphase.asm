;BetaPhase - ZX Spectrum beeper engine - r0.4
;experimental pulse-interleaving synthesis without duty threshold comparison
;by utz 2016-2017, based on an original concept by Shiru


endPtn		  equ   40h

noUpd1		  equ   1h
noUpd2		  equ   4h
noUpd3		  equ   80h

phaseReset	  equ   1
dutyModOn	  equ   40h

scaleDown	  equ   0fh		;rrca
scaleUp		  equ   07h		;rlca
dMod		  equ   57h		;ld d,a

mXor		  equ   0ac00h		;xor (iy)h
mAnd		  equ   0a400h		;and (iy)h
mOr		  equ   0b400h		;or (iy)h
mNone		  equ   0b700h		;or a

slideUp		  equ   08000h

rest		  equ   0h

ckick		  equ   4
chat		  equ   80h


a0	   equ   1ch
ais0	   equ   1eh
b0	   equ   20h
c1	   equ   22h
cis1	   equ   24h
d1	   equ   26h
dis1	   equ   28h
e1	   equ   2bh
f1	   equ   2dh
fis1	   equ   30h
g1	   equ   33h
gis1	   equ   36h
a1	   equ   39h
ais1	   equ   3ch
b1	   equ   40h
c2	   equ   44h
cis2	   equ   48h
d2	   equ   4ch
dis2	   equ   50h
e2	   equ   55h
f2	   equ   5ah
fis2	   equ   60h
g2	   equ   65h
gis2	   equ   6bh
a2	   equ   72h
ais2	   equ   79h
b2	   equ   80h
c3	   equ   87h
cis3	   equ   8fh
d3	   equ   98h
dis3	   equ   0a1h
e3	   equ   0abh
f3	   equ   0b5h
fis3	   equ   0bfh
g3	   equ   0cbh
gis3	   equ   0d7h
a3	   equ   0e4h
ais3	   equ   0f1h
b3	   equ   100h
c4	   equ   10fh
cis4	   equ   11fh
d4	   equ   130h
dis4	   equ   142h
e4	   equ   155h
f4	   equ   169h
fis4	   equ   17fh
g4	   equ   196h
gis4	   equ   1aeh
a4	   equ   1c7h
ais4	   equ   1e2h
b4	   equ   1ffh
c5	   equ   21dh
cis5	   equ   23eh
d5	   equ   260h
dis5	   equ   284h
e5	   equ   2aah
f5	   equ   2d3h
fis5	   equ   2feh
g5	   equ   32bh
gis5	   equ   35bh
a5	   equ   38fh
ais5	   equ   3c5h
b5	   equ   3feh
c6	   equ   43bh
cis6	   equ   47bh
d6	   equ   4bfh
dis6	   equ   508h
e6	   equ   554h
f6	   equ   5a5h
fis6	   equ   5fbh
g6	   equ   656h
gis6	   equ   6b7h
a6	   equ   71dh
ais6	   equ   789h
b6	   equ   7fch
c7	   equ   876h
cis7	   equ   8f6h
d7	   equ   97fh
dis7	   equ   0a0fh
e7	   equ   0aa9h
f7	   equ   0b4bh
fis7	   equ   0bf7h
g7	   equ   0cadh
gis7	   equ   0d6eh
a7	   equ   0e3ah



	org 6000h
	

begin:	di	
	exx
	push hl			;preserve HL' for return to BASIC
	push ix
	push iy
	ld (oldSP),sp
	ld hl,musicData
	ld (seqpntr),hl

;*******************************************************************************
rdseq
	exx
seqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (seqpntr),sp
	jr nz,rdptn0

;	jp exit		;uncomment to disable looping
	ld sp,mloop		;get loop point
	jr rdseq+3

;*******************************************************************************
rdptn0
	ld (ptnpntr),de
	ld e,0			;reset timer lo-byte
	
rdptn
	exx
;	in a,($fe)		;read kbd
;	cpl
;	and $1f
;	jp nz,exit

	nop
	nop
	nop
	nop


ptnpntr equ $+1
	ld sp,0
	
	pop af			;
	jr z,rdseq
	
	jr c,skipUpdate1	;***ch1***
	ex af,af'

	pop af
	ld (preScale1A),a	;preScale1A|phase reset enable
	jr nc,_skipPhaseRese0
	
	pop de			;pop phase offset
	ld hl,0
	
_skipPhaseRese0
	ld a,$7a		;ld a,d
	jr nz,_setDutyMod
	
	ld a,$82		;add a,d
_setDutyMod
	ld (dutyMod),a
	

	pop bc			;mixMethod + preScale1B
	ld (preScale1B),bc
	
	pop bc			;freq divider
	
	ld a,b			;disable output on rests
	or c
 	jr nz,_skipPhaseRese2

	ld a,0afh		;$af = xor a
	ld (mix1),a

_skipPhaseRese2
	
	ex af,af'

skipUpdate1			;***ch2***
	jp pe,skipUpdate2
	
	ld (_restoreHL),hl
	ex af,af'
	
	pop af			;mix2|phase reset enable
	ld (mix2),a	
	jr nc,_skipPhaseRese3	;phase reset yes/no
	
	pop iy
	ld ix,0

_skipPhaseRese3
	jr nz,_noDutyMod2
	
	pop af
	ld (dutyMod2),a
_noDutyMod2

	pop hl			;preScale2A/B
	ld (preScale2A),hl
				
	pop hl			;freq div
	ld (noteDiv2),hl
	
	ld a,h
	or l
	jr nz,_skipPhaseRese4	;disable output on rests
	
	ld a,0afh		;$af = xor a
	ld (mix2),a
_skipPhaseRese4
	
	ex af,af'
_restoreHL equ $+1
	ld hl,0	

skipUpdate2			;***ch3***
	exx
	jp m,skipUpdate3
	ex af,af'
	
	pop hl			;postscale + slide amount
	ld a,h
	ld (postScale3),a
	ld a,l
	ld (slideAmount),a
	
	pop bc			;freq divider ch3 + slide dir
	
	ld hl,0809fh		;sbc a,a \ add a,b
	ld a,0d6h		;sub n
	sla b			;bit 7 set = slide up
	jr nc,_slideDown
	
	ld hl,09188h		;adc a,b \ sub c
	ld a,0ceh		;add a,n

_slideDown
	ld (slideDirectionA),a
	ld (slideDirectionB),hl
	sra b			;restore freqdiv hi-byte
	
	ld hl,0			;phase reset
	ex af,af'
	
skipUpdate3
	ld d,a			;timer
	ld (ptnpntr),sp

noteDiv2 equ $+1
	ld sp,0	
	
;*******************************************************************************	
playNote
	exx			;4

	add hl,bc		;11		;ch1 (phaser/sid/noise)
	ex de,hl		;4
	add hl,bc		;11

	sbc a,a			;4		;sync for duty modulation
dutyMod	
	ld a,d			;4		;ld a,d = $7a (disable), add a,d = $82 (enable)
preScale1A
	nop			;4		;switch rrca/rlca/... *2 | ld d,a = $57 (enable sweep) | rlc d = $cb(02) for noise
preScale1B
	nop			;4		;also for rlc h... osc 2 off = noise? rlc l & prescale? or move it down | $(cb)02 for noise
mix1
	xor h			;4		;switch xor|or|and|or a|xor a (disable output)
	ret c			;5		;timing TODO: careful, this will fail if mix op doesn't reset carry

	and 2
	out (255),a		;11___80 (ch3)
	
	ex de,hl		;4	
	ld a,0			;7		;timing

	
	add ix,sp		;15		;ch2 (phaser/noise)					
	add iy,sp		;15
	ld a,ixh		;8

preScale2A
	nop			;4
preScale2B
	nop			;4
mix2 equ $+1
	xor iyh			;8

	exx			;4
	and 2

	out (255),a		;11___80 (ch3)


	
	add hl,bc		;11		;ch3 (slide)
	jr nc,noSlideUpdate	;7/12
	
	ld a,c			;4
slideDirectionA
slideAmount equ $+1
	add a,0			;7		;add a,n = $ce, sub n = $d6
	ld c,a			;4
	
slideDirectionB
	adc a,b			;4		;sbc a,a	;adc a,b; sub c = $9188 | sbc a,a; add a,b = $809f
	sub c			;4		;add a,d
	ld b,a			;4
		
slideReturn
	ld a,h			;4
postScale3
	nop			;4		;switch
	and 2
	out (255),a		;11___80 (ch3)

	
	dec e			;4
	jp nz,playNote		;10
				;224

	ld a,ixl				;duty modulator ch2
dutyMod2 equ $+1
	add a,0
	ld ixl,a
	
	ld a,ixh
	adc a,0
	ld ixh,a
			
	dec d
	jp nz,playNote
	
	ld (noteDiv2),sp
	jp rdptn

;*******************************************************************************	
noSlideUpdate
	jr _aa			;12
_aa	jp slideReturn		;10+12+12=34

;*******************************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop iy
	pop ix
	pop hl
	exx
	ei
	ret
;*******************************************************************************
musicData
;	include "music.asm";sequence

	dw mdb_Patterns_ptn0
	dw mdb_Patterns_ptn1
	dw mdb_Patterns_ptn0
	dw mdb_Patterns_ptn1a
	dw mdb_Patterns_ptn0
	dw mdb_Patterns_ptn1
	dw mdb_Patterns_ptn0
	dw mdb_Patterns_ptn1b
mloop
	dw mdb_Patterns_ptn2
	dw mdb_Patterns_ptn3
	dw mdb_Patterns_ptn4
	dw mdb_Patterns_ptn5
	dw mdb_Patterns_ptn2
	dw mdb_Patterns_ptn3
	dw mdb_Patterns_ptn4a
	dw mdb_Patterns_ptn5a
	dw mdb_Patterns_ptn2
	dw mdb_Patterns_ptn3
	dw mdb_Patterns_ptn4
	dw mdb_Patterns_ptn5
	dw mdb_Patterns_ptn2
	dw mdb_Patterns_ptn3
	dw mdb_Patterns_ptn4a
	dw mdb_Patterns_ptn5a
	dw mdb_Patterns_ptn2
	dw mdb_Patterns_ptn3
	dw mdb_Patterns_ptn4
	dw mdb_Patterns_ptn5
	dw mdb_Patterns_ptn2
	dw mdb_Patterns_ptn3
	dw mdb_Patterns_ptn4a
	dw mdb_Patterns_ptn5a
	dw mdb_Patterns_ptn0
	dw mdb_Patterns_ptn0
	dw mdb_Patterns_ptn0
	dw mdb_Patterns_ptn1a
	dw mdb_Patterns_ptn0
	dw mdb_Patterns_ptn0
	dw mdb_Patterns_ptn0
	dw mdb_Patterns_ptn1b
	dw 0


mdb_Patterns_ptn0

	dw 0500h, 0f01h, 0800h, 0ac00h, a1, 0b441h, 0h, 0h, 0h, 0h, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, a2, 0f00h, rest
	dw 0504h, 0f00h, 0ac00h, a3, 0f00h, a1
	dw 0584h, 0f00h, 0ac00h, a2
	dw 0504h, 0f00h, 0ac00h, a1, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, a2, 0f00h, rest
	dw 0504h, 0f00h, 0ac00h, a3, 0f00h, a1
	dw 0584h, 0f00h, 0ac00h, a2
	dw 0504h, 0f00h, 0ac00h, a1, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, a2, 0f00h, rest
	dw 0504h, 0f00h, 0ac00h, a3, 0f00h, a1
	dw 0584h, 0f00h, 0ac00h, a2
	dw 0504h, 0f00h, 0ac00h, c2, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, c3, 0f00h, rest
	dw 0504h, 0f00h, 0ac00h, c4, 0f00h, c2
	dw 0584h, 0f00h, 0ac00h, c3
	db 040h



mdb_Patterns_ptn1

	dw 0504h, 0f01h, 0800h, 0ac00h, a1, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, a1, 0f00h, rest
	dw 0504h, 0f00h, 0ac00h, a3, 0f00h, a1
	dw 0584h, 0f00h, 0ac00h, a2
	dw 0504h, 0f00h, 0ac00h, a1, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, a2, 0f00h, rest
	dw 0504h, 0f00h, 0ac00h, a3, 0f00h, a1
	dw 0584h, 0f00h, 0ac00h, a2
	dw 0504h, 0f00h, 0ac00h, a1, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, a2, 0f00h, rest
	dw 0504h, 0f00h, 0ac00h, a3, 0f00h, a1
	dw 0584h, 0f00h, 0ac00h, a2
	dw 0504h, 0f00h, 0ac00h, gis1, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, gis2, 0f00h, rest
	dw 0504h, 0f00h, 0ac00h, gis3, 0f00h, gis1
	dw 0584h, 0f00h, 0ac00h, gis2
	db 040h



mdb_Patterns_ptn1a

	dw 0504h, 0f01h, 0800h, 0ac00h, a1, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, a2, 0f00h, rest
	dw 0504h, 0f00h, 0ac00h, a3, 0f00h, a1
	dw 0584h, 0f00h, 0ac00h, a2
	dw 0504h, 0f00h, 0ac00h, a1, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, a2, 0f00h, rest
	dw 0504h, 0f00h, 0ac00h, a3, 0f00h, a1
	dw 0584h, 0f00h, 0ac00h, a2
	dw 0504h, 0f00h, 0ac00h, gis1, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, gis2, 0f00h, rest
	dw 0504h, 0f00h, 0ac00h, gis3, 0f00h, gis1
	dw 0584h, 0f00h, 0ac00h, gis2
	dw 0504h, 0f00h, 0ac00h, gis1, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, gis2, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, gis3, 0f30h, c4
	dw 0504h, 0f00h, 0ac00h, gis2, 0f30h, c4
	db 040h



mdb_Patterns_ptn1b

	dw 0504h, 0f01h, 0800h, 0ac00h, a1, 0f30h, c4
	dw 0504h 
	dw 0f01h, 0h, 0ac00h, rest, 0f00h, rest
	dw 0585
	dw 0585
	dw 0585
	dw 0585
	dw 0585
	dw 0585
	dw 0505h, 0f02h, 08072
	dw 0585
	dw 0585
	dw 0585
	dw 0585
	dw 0585
	dw 0585
	dw 0585
	db 040h



mdb_Patterns_ptn2

	dw 0200h, 0f01h, 0800h, 0ac00h, a1, 0b441h, 0, 01000h, 07, e4, 0f30h, c4
	dw 0281h, 0b400h, 07, e3
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, e4, 0f00h, rest
	dw 0281h, 0b400h, 07, e3
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, e4, 0f00h, a1
	dw 0281h, 0b400h, 07, e3
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, e4
	dw 0281h, 0b400h, 07, e3
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, e4, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, a1, 0b400h, 07, e3
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, e4, 0f00h, rest
	dw 0281h, 0b400h, 07, e3
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, e4, 0f00h, a1
	dw 0281h, 0b400h, 07, e3
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, e4
	dw 0281h, 0b400h, 07, e3
	dw 0200h, 0f00h, 0ac00h, a1, 0b400h, 07, e4, 0f30h, c4
	dw 0281h, 0b400h, 07, e3
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, e4, 0f00h, rest
	dw 0281h, 0b400h, 07, e3
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, e4, 0f00h, a1
	dw 0281h, 0b400h, 07, e3
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, e4
	dw 0281h, 0b400h, 07, e3
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, e4, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, c2, 0b400h, 07, e3
	dw 0200h, 0f00h, 0ac00h, c3, 0b400h, 07, e4, 0f00h, rest
	dw 0281h, 0b400h, 07, e3
	dw 0200h, 0f00h, 0ac00h, c4, 0b400h, 07, e4, 0f00h, c2
	dw 0281h, 0b400h, 07, e3
	dw 0280h, 0f00h, 0ac00h, c3, 0b400h, 07, e4
	dw 0281h, 0b400h, 07, e3
	db 040h


djm

mdb_Patterns_ptn3

	dw 0200h, 0f01h, 0800h, 0ac00h, a1, 0b400h, 07, dis4, 0f30h, c4
	dw 0281h, 0b400h, 07, dis3
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, dis4, 0f00h, rest
	dw 0281h, 0b400h, 07, dis3
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, dis4, 0f00h, a1
	dw 0281h, 0b400h, 07, dis3
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, dis4
	dw 0281h, 0b400h, 07, dis3
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, dis4, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, a1, 0b400h, 07, dis3
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, dis4, 0f00h, rest
	dw 0281h, 0b400h, 07, dis3
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, dis4, 0f00h, a1
	dw 0281h, 0b400h, 07, dis3
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, dis4
	dw 0281h, 0b400h, 07, dis3
	dw 0200h, 0f00h, 0ac00h, a1, 0b400h, 07, dis4, 0f30h, c4
	dw 0281h, 0b400h, 07, dis3
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, dis4, 0f00h, rest
	dw 0281h, 0b400h, 07, dis3
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, dis4, 0f00h, a1
	dw 0281h, 0b400h, 07, dis3
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, dis4
	dw 0281h, 0b400h, 07, dis3
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, dis4, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, gis1, 0b400h, 07, dis3
	dw 0200h, 0f00h, 0ac00h, gis2, 0b400h, 07, dis4, 0f00h, rest
	dw 0281h, 0b400h, 07, d3
	dw 0200h, 0f00h, 0ac00h, gis3, 0b400h, 07, cis4, 0f00h, gis1
	dw 0281h, 0b400h, 07, c3
	dw 0280h, 0f00h, 0ac00h, gis2, 0b400h, 07, b3
	dw 0281h, 0b400h, 07, ais2
	db 040h



mdb_Patterns_ptn4

	dw 0200h, 0f01h, 0800h, 0ac00h, a1, 0b400h, 07, a3, 0f30h, c4
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, a3, 0f00h, rest
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, a3, 0f00h, a1
	dw 0281h, 0b400h, 07, a2
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, a3
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, a3, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, a1, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, a3, 0f00h, rest
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, a3, 0f00h, a1
	dw 0281h, 0b400h, 07, a2
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, a3
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a1, 0b400h, 07, a3, 0f30h, c4
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, a3, 0f00h, rest
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, a3, 0f00h, a1
	dw 0281h, 0b400h, 07, a2
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, a3
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, a3, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, c2, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, c3, 0b400h, 07, a3, 0f00h, rest
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, c4, 0b400h, 07, a3, 0f00h, c2
	dw 0281h, 0b400h, 07, a2
	dw 0280h, 0f00h, 0ac00h, c3, 0b400h, 07, ais3
	dw 0281h, 0b400h, 07, b2
	db 040h



mdb_Patterns_ptn5

	dw 0200h, 0f01h, 0800h, 0ac00h, a1, 0b400h, 07, c4, 0f30h, c4
	dw 0281h, 0b400h, 07, c3
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, c4, 0f00h, rest
	dw 0281h, 0b400h, 07, c3
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, c4, 0f00h, a1
	dw 0281h, 0b400h, 07, c3
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, c4
	dw 0281h, 0b400h, 07, c3
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, c4, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, a1, 0b400h, 07, c3
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, c4, 0f00h, rest
	dw 0281h, 0b400h, 07, c3
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, c4, 0f00h, a1
	dw 0281h, 0b400h, 07, c3
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, c4
	dw 0281h, 0b400h, 07, c3
	dw 0200h, 0f00h, 0ac00h, gis1, 0b400h, 07, c4, 0f30h, c4
	dw 0281h, 0b400h, 07, c3
	dw 0200h, 0f00h, 0ac00h, gis2, 0b400h, 07, c4, 0f00h, rest
	dw 0281h, 0b400h, 07, c3
	dw 0200h, 0f00h, 0ac00h, gis3, 0b400h, 07, c4, 0f00h, gis1
	dw 0281h, 0b400h, 07, c3
	dw 0280h, 0f00h, 0ac00h, gis2, 0b400h, 07, c4
	dw 0281h, 0b400h, 07, c3
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, c4, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, gis1, 0b400h, 07, c3
	dw 0200h, 0f00h, 0ac00h, gis2, 0b400h, 07, c4, 0f30h, c4
	dw 0281h, 0b400h, 07, c3
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, c4, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, gis3, 0b400h, 07, c3
	dw 0200h, 0f00h, 0ac00h, gis2, 0b400h, 07, c4, 0f30h, c4
	dw 0281h, 0b400h, 07, c3
	db 040h



mdb_Patterns_ptn4a

	dw 0200h, 0f01h, 0800h, 0ac00h, a1, 0b400h, 07, a3, 0f30h, c4
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, a3, 0f00h, rest
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, a3, 0f00h, a1
	dw 0281h, 0b400h, 07, a2
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, a3
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, a3, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, a1, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, a3, 0f00h, rest
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, a3, 0f00h, a1
	dw 0281h, 0b400h, 07, a2
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, a3
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a1, 0b400h, 07, a3, 0f30h, c4
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, a3, 0f00h, rest
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, a3, 0f00h, a1
	dw 0281h, 0b400h, 07, a2
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, a3
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, a3, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, c2, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, c3, 0b400h, 07, a3, 0f00h, rest
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, c4, 0b400h, 07, a3, 0f00h, c2
	dw 0281h, 0b400h, 07, a2
	dw 0280h, 0f00h, 0ac00h, c3, 0b400h, 07, a3
	dw 0281h, 0b400h, 07, a2
	db 040h



mdb_Patterns_ptn5a

	dw 0200h, 0f01h, 0800h, 0ac00h, a1, 0b400h, 07, a3, 0f30h, c4
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, a3, 0f00h, rest
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, a3, 0f00h, a1
	dw 0281h, 0b400h, 07, a2
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, a3
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, a3, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, a1, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a2, 0b400h, 07, a3, 0f00h, rest
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, a3, 0b400h, 07, a3, 0f00h, a1
	dw 0281h, 0b400h, 07, a2
	dw 0280h, 0f00h, 0ac00h, a2, 0b400h, 07, a3
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, gis1, 0b400h, 07, a3, 0f30h, c4
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, gis2, 0b400h, 07, a3, 0f00h, rest
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0f00h, 0ac00h, gis3, 0b400h, 07, a3, 0f00h, gis1
	dw 0281h, 0b400h, 07, a2
	dw 0280h, 0f00h, 0ac00h, gis2, 0b400h, 07, a3
	dw 0281h, 0b400h, 07, a2
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, a3, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, gis1, 0b400h, 07, ais2
	dw 0200h, 0f00h, 0ac00h, gis2, 0b400h, 07, b3, 0f30h, c4
	dw 0281h, 0b400h, 07, b2
	dw 0200h, 0cb00h, 0ac02h, 0235h, 0b400h, 07, c4, 0f30h, c4
	dw 0280h, 0f01h, 0800h, 0ac00h, gis3, 0b400h, 07, cis3
	dw 0200h, 0f00h, 0ac00h, gis2, 0b400h, 07, d4, 0f30h, c4
	dw 0281h, 0b400h, 07, dis3
	db 040h




	end begin
