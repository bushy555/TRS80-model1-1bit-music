; -------------------------------
; Lyndon Sharp.  LS-ENGINE
;
; SONG : MENTAL
; ---------------------------------



	ORG	6000h




;Lyndon Sharp Beeper music engine
;Two channels of tone, no volume or timbre control, non-interrupting drums
;Originally written by Lyndon Sharp circa 1989
;Reverse-engineered from Zanthrax game and modified in 2011-12 by Shiru
;Modifications are:
; minor optimizations
; drum numbers changed
; notes shifted one semitone down
; TI modifications by utz 2012


begin

	



	ld hl,music_Data

;	ld a,%00010000			;+ set interrupts to fastest mode
;	out (4),a
	call play

	ei
;	ld a,%00010110			;+ set interrupts back to normal
;	out (4),a
	ret

play
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld (ch0ptr),de
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld (ch0loop),de
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld (ch1ptr),de
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld (ch1loop),de
	inc hl
	ld a,(hl)
	ld (speed),a

	xor a

playSong
	call playRow

;	ld a,%10111111		;7	+ new keyhandler
;	ld a,%10111111		;7
;	out (1),a		;11
;	in a,(1)		;11	read keyboard
;	nop			;4
;	bit 6,a			;8

;	ret z			;11/5 52/46+7

	jr playSong

playRow
	di
;	ld ix,$3333		;enable both tone channels (it is mask to xor with output) +
;	ld ix,$2121		;enable both tone channels (it is mask to xor with output) +
	ld ix,0202h;$2020		;enable both tone channels (it is mask to xor with output) +

	ld d,0
ch0ptr EQU $+1
	ld hl,0			;read byte from first channel pointer
	ld c,(hl)
	ld a,c
	cp 0ffh
	jr nz,noLoop

ch0loop EQU $+1
	ld hl,0
	ld (ch0ptr),hl
ch1loop EQU $+1
	ld hl,0
	ld (ch1ptr),hl
	jr playRow

noLoop
	and	03fh

	jr nz,noMute0			;if it is zero, mute the channel -> ???
	db 0DDh, 06ah			; opcode for : 	ld ixl,d

noMute0
	inc	hl			;increase pointer
	ld 	(ch0ptr),hl			;store pointer
	ld 	e,a				;read divider from note table
	ld 	hl,noteDivTable
	add 	hl,de
	ld 	a,(hl)
	ld 	(ch0div),a			;set divider
ch1ptr EQU $+1
	ld 	hl,0				;the same for second channel
	ld 	b,(hl)
	ld 	a,b
	and	03fh			; +???
	jr 	nz,noMute1
	db 	0DDh, 062h		;	opcode for ld ixh,d


noMute1
	inc	hl
	ld 	(ch1ptr),hl
	ld 	e,a
	ld 	hl,noteDivTable
	add	hl,de
	ld 	a,(hl)
	ld 	(ch1div),a
	ld 	a,b			;now use note values to get drum number, four bits, lower always 0
	rlca			;two top bits of note of second channel are top bits of the number
	rlca
	rl 	c			;and two top bits of note of first channel are lower bits
	rla
	add 	a,a
	and	0fh			;now there is drum number in A
	ld 	e,a
	ld 	hl,drumTable		;read drum parameters pointer from drum table
	add	hl,de
	ld 	a,(hl)
	inc	hl
	ld 	h,(hl)
	ld 	l,a
	ld 	(drumPtr),hl
	ld 	a,10h
	ld 	(drumParam0),a
	ld 	a,29h
	ld 	(drumParam1),a
	ld 	l,a
	xor	a
	ex 	af,af'
	xor	a
	ld 	h,2
	ld 	de, 02020h; 2020 ;$0101 ; $2121	;3333
	exx
	ld 	b,a
drumPtr EQU $+1
	ld 	hl,0
	ld 	e,01
	exx
speed EQU $+1
	ld 	c,7
loop0
	ld 	b,0
ploop1
	ex 	af,af'
	dec	l
	jr 	nz,$+3
	xor	a
	out	(255), a

	dec	d
	jr 	nz,delay0
ch0div EQU $+1
	ld 	d,0
	db 	0ddh, 0adh		; opcode for XOR IXL
drumParam0 EQU $+1
	ld 	l,0
delay0ret
	exx
	ld 	c,a
	ld 	a,b

	out	(255), a


	dec	e
	jr 	nz,delay1
	ld 	a,(hl)
	or 	a
	jp 	z,delay2
	ld 	e,a
	ld 	a,b
	xor	2		; +
	inc	hl
delay2ret
	ld 	b,a
	ld 	a,c
	exx
	ex 	af,af'
	dec	h
	jr 	nz,$+3		; +
	xor	a


	out	(255), a

	dec	e

	jr 	nz,delay3
ch1div EQU $+1
	ld 	e,9dh

	db 	0ddh, 0ach		; opcode for  xor ixh



drumParam1 EQU $+1
	ld	h,017H
delay3ret
	djnz 	ploop1
	push 	af
	ld 	a,(drumParam0)
	dec	a
	ld 	(drumParam0),a
	ld 	a,(drumParam1)
	sub	3
	ld 	(drumParam1),a
	pop	af
	dec	c
	jp 	nz,loop0

	exx
	ei
	ret

delay0	xor	0
	jp	delay0ret

delay1	ld 	(0),hl
delay2	ld 	r,a
	jr 	delay2ret

delay3	xor	0
	jp 	delay3ret




drumTable
	dw drum0
	dw drum1
	dw drum2
	dw drum3
	dw drum4
	dw drum5
	dw drum6
	dw drum7

drum0
	db 000
drum1
	db 005h,005h,00eh,00eh,017h,017h,02ah,017h
	db 02ah,017h,02ah,017h,02ah,017h,017h,00eh
	db 00eh,004h,004h,000
drum2
	db 011h,008h,018h,006h,020h,009h,025h,00ch
	db 02ah,00ah,02eh,008h,032h,00ah,037h,00dh
	db 03dh,00bh,042h,009h,04ch,00bh,052h,00eh
	db 05ah,00ch,062h,00ah,069h,00ch,070h,00eh
	db 07bh,010h,089h,011h,096h,013h,09ch,015h
	db 070h,012h,012h,072h,072h,00ch,055h,00ch
	db 07ah,00bh,06dh,00bh,071h,00ah,074h,00ah
	db 077h,009h,07ch,006h
drum3
	db 005h,00ah,00fh,014h,01bh,020h,01bh,01eh
	db 010h,014h,017h,01ah,01dh,020h,02ah,036h
	db 042h,04fh,05ch,04fh
drum4
	db 047h,041h,00fh,00fh,009h,00ch,001h,00dh
	db 003h,005h,00eh,00ch,009h,006h,009h,00ah
	db 00eh,00fh,001h,00ch,004h,00eh,008h,009h
	db 006h,00bh,002h,002h,005h,006h,00ch,00bh
	db 000
drum5
	db 00bh,006h,00dh,00ah,00fh,00eh,011h,012h
	db 013h,016h,015h,01ah,017h,01eh,019h,022h
	db 01bh,026h,01dh,000h
drum6
	db 011h,005h,017h,005h,020h,005h,023h,005h
	db 02ah,005h,02dh,005h,030h,005h,034h,005h
	db 03fh,005h,042h,005h,04ch,005h,052h,005h
	db 05fh,005h,065h,005h,069h,005h,06eh,005h
	db 07bh,005h,07fh,005h,084h,005h,09fh,005h
	db 065h,00fh,067h,019h,069h,023h,06bh,02dh
	db 06dh,037h,06fh,041h,071h,04bh,073h,055h
	db 075h,05fh,077h
drum7
	db 000

noteDivTable
	db 000	;no div for mute, shifts all the notes one semitone down compared to the original
	db 0fah,0ebh,0deh,0d2h,0c6h,0bbh,0b0h,0a6h
	db 09dh,094h,08ch,084h,07ch,075h,06fh,069h
	db 063h,05dh,058h,053h,04eh,04ah,046h,042h
	db 03eh,03bh,037h,034h,031h,02eh,02ch,029h
	db 027h,025h,023h,021h,01fh,01dh,01ch,01ah
	db 019h,017h,016h,015h,014h,012h

music_Data

	dw ptr1,loop1
	dw ptr2,loop2
	db 003				; speed
ptr1
loop1
	db 021h
	db 02dh
	db 01eh
	db 02ah
	db 020h
	db 02ch
	db 01ch
	db 028h
	db 02ah
	db 01eh
	db 026h
	db 01ah
	db 028h
	db 01ch
	db 025h
	db 019h
	db 02dh
	db 02dh
	db 02ah
	db 02ah
	db 02ch
	db 02ch
	db 028h
	db 028h
	db 02ah
	db 02ah
	db 026h
	db 026h
	db 028h
	db 028h
	db 025h
	db 025h
	db 021h
	db 02dh
	db 01eh
	db 02ah
	db 020h
	db 02ch
	db 01ch
	db 028h
	db 02ah
	db 01eh
	db 026h
	db 01ah
	db 028h
	db 01ch
	db 025h
	db 019h
	db 02dh
	db 02dh
	db 02ah
	db 02ah
	db 02ch
	db 02ch
	db 028h
	db 028h
	db 02ah
	db 02ah
	db 026h
	db 026h
	db 028h
	db 028h
	db 025h
	db 025h
	db 021h
	db 02dh
	db 01eh
	db 02ah
	db 020h
	db 02ch
	db 01ch
	db 028h
	db 02ah
	db 01eh
	db 026h
	db 01ah
	db 028h
	db 01ch
	db 025h
	db 019h
	db 02dh
	db 02dh
	db 02ah
	db 02ah
	db 02ch
	db 02ch
	db 028h
	db 028h
	db 02ah
	db 02ah
	db 026h
	db 026h
	db 028h
	db 028h
	db 025h
	db 025h
	db 02dh
	db 02ah
	db 02ch
	db 028h
	db 02ah
	db 026h
	db 028h
	db 025h
	db 02dh
	db 02ah
	db 02ch
	db 028h
	db 02ah
	db 026h
	db 028h
	db 025h
	db 02dh
	db 02ah
	db 02ch
	db 028h
	db 02ah
	db 026h
	db 028h
	db 025h
	db 019h
	db 019h
	db 019h
	db 019h
	db 019h
	db 019h
	db 000h
	db 000h
	db 021h
	db 02dh
	db 01eh
	db 02ah
	db 020h
	db 02ch
	db 01ch
	db 028h
	db 02ah
	db 01eh
	db 026h
	db 01ah
	db 028h
	db 01ch
	db 025h
	db 019h
	db 02dh
	db 02dh
	db 02ah
	db 02ah
	db 02ch
	db 02ch
	db 028h
	db 028h
	db 02ah
	db 02ah
	db 026h
	db 026h
	db 028h
	db 028h
	db 025h
	db 025h
	db 021h
	db 02dh
	db 01eh
	db 02ah
	db 020h
	db 02ch
	db 01ch
	db 028h
	db 02ah
	db 01eh
	db 026h
	db 01ah
	db 028h
	db 01ch
	db 025h
	db 019h
	db 02dh
	db 02dh
	db 02ah
	db 02ah
	db 02ch
	db 02ch
	db 028h
	db 028h
	db 02ah
	db 02ah
	db 026h
	db 026h
	db 028h
	db 028h
	db 025h
	db 025h
	db 021h
	db 02dh
	db 01eh
	db 02ah
	db 020h
	db 02ch
	db 01ch
	db 028h
	db 02ah
	db 01eh
	db 026h
	db 01ah
	db 028h
	db 01ch
	db 025h
	db 019h
	db 02dh
	db 02dh
	db 02ah
	db 02ah
	db 02ch
	db 02ch
	db 028h
	db 028h
	db 02ah
	db 02ah
	db 026h
	db 026h
	db 028h
	db 028h
	db 025h
	db 025h
	db 02dh
	db 02ah
	db 02ch
	db 028h
	db 02ah
	db 026h
	db 028h
	db 025h
	db 02dh
	db 02ah
	db 02ch
	db 028h
	db 02ah
	db 026h
	db 028h
	db 025h
	db 0adh
	db 0aah
	db 0ach
	db 0a8h
	db 0aah
	db 0a6h
	db 0a8h
	db 0a5h
	db 02dh
	db 02ah
	db 02ch
	db 028h
	db 02ah
	db 026h
	db 028h
	db 025h
	db 021h
	db 02dh
	db 01eh
	db 02ah
	db 020h
	db 02ch
	db 01ch
	db 028h
	db 02ah
	db 01eh
	db 026h
	db 01ah
	db 028h
	db 01ch
	db 025h
	db 019h
	db 02dh
	db 02dh
	db 02ah
	db 02ah
	db 02ch
	db 02ch
	db 028h
	db 028h
	db 02ah
	db 02ah
	db 026h
	db 026h
	db 028h
	db 028h
	db 025h
	db 025h
	db 021h
	db 02dh
	db 01eh
	db 02ah
	db 020h
	db 02ch
	db 01ch
	db 028h
	db 02ah
	db 01eh
	db 026h
	db 01ah
	db 028h
	db 01ch
	db 025h
	db 019h
	db 02dh
	db 02dh
	db 02ah
	db 02ah
	db 02ch
	db 02ch
	db 028h
	db 028h
	db 02ah
	db 02ah
	db 026h
	db 026h
	db 028h
	db 028h
	db 025h
	db 025h
	db 021h
	db 02dh
	db 01eh
	db 02ah
	db 020h
	db 02ch
	db 01ch
	db 028h
	db 02ah
	db 01eh
	db 026h
	db 01ah
	db 028h
	db 01ch
	db 025h
	db 019h
	db 02dh
	db 02dh
	db 02ah
	db 02ah
	db 02ch
	db 02ch
	db 028h
	db 028h
	db 02ah
	db 02ah
	db 026h
	db 026h
	db 028h
	db 028h
	db 025h
	db 025h
	db 02dh
	db 02ah
	db 02ch
	db 028h
	db 02ah
	db 026h
	db 028h
	db 025h
	db 02dh
	db 02ah
	db 02ch
	db 028h
	db 02ah
	db 026h
	db 028h
	db 025h
	db 0adh
	db 0aah
	db 0ach
	db 0a8h
	db 0aah
	db 0a6h
	db 0a8h
	db 0a5h
	db 02dh
	db 02ah
	db 02ch
	db 028h
	db 02ah
	db 026h
	db 028h
	db 025h
	db 0ffh
ptr2
loop2
	db 061h
	db 055h
	db 061h
	db 052h
	db 0deh
	db 014h
	db 020h
	db 010h
	db 01ch
	db 01eh
	db 012h
	db 01ah
	db 00eh
	db 01ch
	db 010h
	db 019h
	db 00dh
	db 021h
	db 021h
	db 01eh
	db 01eh
	db 020h
	db 020h
	db 01ch
	db 05ch
	db 05eh
	db 01eh
	db 01ah
	db 05ah
	db 05ch
	db 01ch
	db 019h
	db 059h
	db 055h
	db 061h
	db 052h
	db 05eh
	db 054h
	db 0e0h
	db 010h
	db 01ch
	db 01eh
	db 012h
	db 01ah
	db 00eh
	db 01ch
	db 010h
	db 019h
	db 00dh
	db 021h
	db 021h
	db 01eh
	db 01eh
	db 020h
	db 020h
	db 01ch
	db 01ch
	db 01eh
	db 01eh
	db 01ah
	db 01ah
	db 01ch
	db 01ch
	db 019h
	db 059h
	db 055h
	db 061h
	db 052h
	db 0deh
	db 054h
	db 060h
	db 050h
	db 05ch
	db 05eh
	db 052h
	db 05ah
	db 0ceh
	db 01ch
	db 050h
	db 019h
	db 00dh
	db 021h
	db 021h
	db 01eh
	db 01eh
	db 020h
	db 020h
	db 01ch
	db 01ch
	db 01eh
	db 01eh
	db 01ah
	db 01ah
	db 01ch
	db 01ch
	db 019h
	db 059h
	db 061h
	db 05eh
	db 060h
	db 05ch
	db 05eh
	db 0dah
	db 01ch
	db 059h
	db 021h
	db 05eh
	db 020h
	db 05ch
	db 05eh
	db 05ah
	db 05ch
	db 059h
	db 061h
	db 05eh
	db 060h
	db 05ch
	db 05eh
	db 05ah
	db 05ch
	db 0d2h
	db 0d2h
	db 0d2h
	db 0d2h
	db 0d2h
	db 012h
	db 0c0h
	db 0c0h
	db 046h
	db 046h
	db 052h
	db 046h
	db 0c6h
	db 046h
	db 052h
	db 046h
	db 046h
	db 046h
	db 0d2h
	db 046h
	db 0c6h
	db 046h
	db 052h
	db 046h
	db 046h
	db 046h
	db 052h
	db 046h
	db 0c6h
	db 046h
	db 052h
	db 046h
	db 046h
	db 046h
	db 052h
	db 046h
	db 0c6h
	db 046h
	db 0d2h
	db 046h
	db 044h
	db 044h
	db 0d0h
	db 044h
	db 0c4h
	db 044h
	db 050h
	db 044h
	db 044h
	db 044h
	db 050h
	db 044h
	db 044h
	db 0c4h
	db 0d0h
	db 0c4h
	db 044h
	db 044h
	db 050h
	db 044h
	db 0c4h
	db 044h
	db 050h
	db 044h
	db 044h
	db 044h
	db 050h
	db 044h
	db 0c4h
	db 044h
	db 0d0h
	db 0c4h
	db 042h
	db 042h
	db 04eh
	db 042h
	db 0c2h
	db 042h
	db 04eh
	db 042h
	db 042h
	db 042h
	db 04eh
	db 042h
	db 0c2h
	db 002h
	db 04eh
	db 002h
	db 042h
	db 042h
	db 04eh
	db 042h
	db 0c2h
	db 042h
	db 04eh
	db 042h
	db 042h
	db 042h
	db 04eh
	db 042h
	db 0c2h
	db 0c2h
	db 0ceh
	db 0c2h
	db 04bh
	db 04bh
	db 057h
	db 04bh
	db 0cbh
	db 00bh
	db 0d7h
	db 0cbh
	db 04bh
	db 04bh
	db 057h
	db 04bh
	db 0cbh
	db 00bh
	db 0d7h
	db 00bh
	db 009h
	db 009h
	db 015h
	db 009h
	db 089h
	db 089h
	db 095h
	db 089h
	db 0c2h
	db 0c2h
	db 0ceh
	db 0c2h
	db 044h
	db 044h
	db 050h
	db 044h
	db 046h
	db 046h
	db 052h
	db 046h
	db 0c6h
	db 046h
	db 052h
	db 046h
	db 046h
	db 046h
	db 0d2h
	db 046h
	db 0c6h
	db 046h
	db 052h
	db 046h
	db 046h
	db 046h
	db 052h
	db 046h
	db 0c6h
	db 046h
	db 052h
	db 046h
	db 046h
	db 046h
	db 052h
	db 046h
	db 0c6h
	db 046h
	db 0d2h
	db 046h
	db 050h
	db 050h
	db 0dch
	db 050h
	db 0d0h
	db 050h
	db 05ch
	db 050h
	db 050h
	db 050h
	db 05ch
	db 050h
	db 050h
	db 0d0h
	db 0dch
	db 0d0h
	db 050h
	db 050h
	db 05ch
	db 050h
	db 0d0h
	db 050h
	db 05ch
	db 050h
	db 050h
	db 050h
	db 05ch
	db 050h
	db 0d0h
	db 050h
	db 0dch
	db 0d0h
	db 04eh
	db 04eh
	db 05ah
	db 04eh
	db 0ceh
	db 04eh
	db 05ah
	db 04eh
	db 04eh
	db 04eh
	db 05ah
	db 04eh
	db 0ceh
	db 00eh
	db 05ah
	db 00eh
	db 04eh
	db 04eh
	db 065h
	db 04eh
	db 0ceh
	db 04eh
	db 065h
	db 04eh
	db 04eh
	db 04eh
	db 065h
	db 04eh
	db 0ceh
	db 0ceh
	db 0e5h
	db 0ceh
	db 04bh
	db 04bh
	db 057h
	db 04bh
	db 0cbh
	db 00bh
	db 0d7h
	db 0cbh
	db 04bh
	db 04bh
	db 057h
	db 04bh
	db 0cbh
	db 00bh
	db 0d7h
	db 00bh
	db 00dh
	db 00dh
	db 019h
	db 00dh
	db 08dh
	db 08dh
	db 099h
	db 08dh
	db 0ceh
	db 0ceh
	db 0dah
	db 0ceh
	db 050h
	db 050h
	db 05ch
	db 050h
	db 0ffh
 end begin

