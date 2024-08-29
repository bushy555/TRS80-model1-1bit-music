; -------------------------
; 	TRS80 - model 1.
; -------------------------

	ORG	6000h


OP_INCL:        EQU   2Ch

BEGIN:          LD    HL,  MUSICDATA1	; 	(Not included here)
                CALL  HUBY_PLAY
                RET

HUBY_PLAY:      LD    C, (HL)              ; Read the tempo word
                INC   HL
                LD    B, (HL)
                INC   HL
                LD    E, (HL)              ; Offset to pattern data is 
                INC   HL                  ; kept in DE always. 
                LD    D, (HL)              ; And HL = current position in song layout.

READPOS:        INC   HL
                LD    A, (HL)              ; Read the pattern number for channel 1
                INC   HL
                OR    A
                RET   Z                   ; Zero signifies the end of the song

                CP    0FFh                 ; $FF signifies SET TEMPO
                JR    NZ, NOT_TEMPO
                LD    C, (HL)
                INC   HL
                LD    B, (HL)
                JR    READPOS

NOT_TEMPO:      PUSH  HL                  ; Store the layout pointer
                PUSH  DE                  ; Store the pattern offset pointer
                PUSH  BC                  ; Store current tempo
                LD    L, (HL)              ; Read the pattern number for channel 2
                LD    B, 2                 ; DJNZ through following code twice (1x for each channel)
CALC_ADR:       LD    H, 0                 ; Multiply pattern number by 8...
                ADD   HL, HL               ; x2
                ADD   HL, HL               ; x4
                ADD   HL, HL               ; x8
                ADD   HL, DE               ; Add the offset to the pattern data
                PUSH  HL                  ; Store the address of pattern data
                LD    L, A
                DJNZ  CALC_ADR            ; Do the same thing for channel 2
                EXX
                POP   HL
                POP   DE

                LD    B, 8                 ; Fixed pattern length = 8 rows
READ_ROW:       LD    A, (DE)              ; Read note for channel 1
                INC   DE                  ; inc channel 1 row pointer
                EXX
                LD    H, A
                LD    D, A
                EXX
                LD    A, (HL)              ; Read note for channel 2
                INC   HL                  ; inc channel 2 row pointer
                EXX
                LD    L, A
                LD    E, A
                CP    OP_INCL             ; If channel 1 note == $2C then play drum
                JR    Z, SET_DRUMSLIDE
                XOR   A
SET_DRUMSLIDE:  LD    (SND_SLIDE), A
                POP   BC                  ; Retrieve tempo
                PUSH  BC
                DI

SOUND_LOOP:     XOR   A
                DEC   E
                JR    NZ, SND_LOOP1
                LD    E, L
                SUB   L
SND_SLIDE:      NOP                       ; This is set to INC L for the drum sound
SND_LOOP1:      DEC   D
                JR    NZ, SND_LOOP2
                LD    D, H
                SUB   H
SND_LOOP2:      SBC   A, A


	AND   3
	jp 	nz,HP1	;[10]

	ld	a, 0
	out	(255), a
	jp 	LP1 	;[10]

HP1:	ld	a, 2
	out 	(255),a	;[11]
	jp 	LP1 	;[10]
LP1:



                DEC   BC
                LD    A, B
                OR    C
                JR    NZ, SOUND_LOOP       ; 113/123 Ts

SND_LOOP3:      EXX   
                EI
                JR    NZ, PATTERN_END
                DJNZ  READ_ROW
PATTERN_END:    POP   BC
                POP   DE
                POP   HL
                JR    Z, READPOS           ; No key pressed,  goto next pattern
                RET                       ; Otherwise return



; ************************************************************************
; * Song data...
; ************************************************************************


; *** DATA ***
MUSICDATA1:


	dw 00500h
	dw ptn-8
	db 001h,002h
	db 003h,004h
	db 005h,006h
	db 007h,008h
	db 009h,00ah
	db 00bh,00ch
	db 001h,00dh
	db 00eh,00fh
	db 001h,002h
	db 003h,004h
	db 005h,006h
	db 007h,010h
	db 009h,011h
	db 00bh,012h
	db 005h,013h
	db 014h,015h
	db 016h,017h
	db 018h,019h
	db 01ah,017h
	db 01bh,01ch
	db 01dh,01eh
	db 01fh,020h
	db 01dh,01eh
	db 021h,020h
	db 016h,017h
	db 018h,01ch
	db 01ah,017h
	db 01bh,022h
	db 023h,024h
	db 025h,024h
	db 023h,026h
	db 027h,028h
	db 016h,017h
	db 018h,019h
	db 01ah,017h
	db 01bh,01ch
	db 01dh,01eh
	db 01fh,020h
	db 01dh,01eh
	db 021h,020h
	db 016h,017h
	db 018h,01ch
	db 01ah,017h
	db 01bh,022h
	db 029h,028h
	db 02ah,028h
	db 029h,02bh
	db 02ch,02dh
	db 02eh,02eh
	db 000h
ptn
	db 0e2h,000h,0e2h,000h,0e2h,000h,0e2h,000h
	db 000h,000h,038h,038h,032h,032h,02dh,02dh
	db 02ch,000h,0e2h,000h,0e2h,000h,0e2h,000h
	db 038h,038h,038h,038h,03ch,03ch,038h,038h
	db 097h,000h,097h,000h,097h,000h,097h,000h
	db 038h,038h,03ch,03ch,000h,000h,000h,000h
	db 02ch,000h,097h,000h,097h,000h,097h,000h
	db 043h,043h,03ch,03ch,000h,000h,04bh,04bh
	db 0a9h,000h,0a9h,000h,0a9h,000h,0a9h,000h
	db 04bh,04bh,054h,054h,04bh,04bh,043h,043h
	db 02ch,000h,0a9h,000h,0a9h,000h,0a9h,000h
	db 04bh,04bh,04bh,04bh,054h,054h,04bh,04bh
	db 04bh,04bh,059h,000h,059h,000h,059h,000h
	db 02ch,000h,0cah,000h,0b3h,000h,0b3h,000h
	db 054h,000h,054h,000h,04bh,000h,04bh,000h
	db 038h,038h,032h,032h,000h,000h,03ch,03ch
	db 03ch,03ch,043h,043h,04bh,04bh,054h,054h
	db 065h,065h,059h,059h,000h,000h,04bh,04bh
	db 04bh,04bh,04bh,04bh,04bh,04bh,04bh,04bh
	db 02ch,000h,097h,000h,02ch,000h,02ch,000h
	db 04bh,04bh,04bh,04bh,000h,000h,000h,000h
	db 0a9h,000h,0a9h,0a9h,054h,000h,054h,054h
	db 043h,043h,038h,038h,032h,032h,043h,043h
	db 02ch,000h,0a9h,0a9h,054h,000h,054h,054h
	db 038h,038h,032h,032h,038h,038h,032h,032h
	db 097h,000h,097h,097h,04bh,000h,04bh,04bh
	db 02ch,000h,097h,097h,02ch,000h,02ch,04bh
	db 038h,038h,032h,032h,043h,043h,038h,038h
	db 086h,000h,086h,086h,043h,000h,043h,043h
	db 03ch,03ch,038h,038h,032h,032h,03ch,03ch
	db 02ch,000h,086h,086h,043h,000h,043h,043h
	db 038h,038h,032h,032h,03ch,03ch,038h,038h
	db 02ch,000h,086h,086h,02ch,000h,02ch,043h
	db 038h,038h,032h,032h,043h,043h,03ch,03ch
	db 0cah,000h,0cah,0cah,065h,000h,065h,065h
	db 043h,000h,043h,000h,043h,000h,043h,000h
	db 02ch,000h,0cah,0cah,065h,000h,065h,065h
	db 03ch,000h,03ch,000h,03ch,000h,03ch,000h
	db 02ch,000h,02ch,0cah,02ch,000h,02ch,065h
	db 038h,000h,038h,000h,038h,000h,038h,000h
	db 0e2h,000h,0e2h,0e2h,071h,000h,071h,071h
	db 02ch,000h,0e2h,0e2h,071h,000h,071h,071h
	db 038h,038h,038h,038h,038h,038h,038h,038h
	db 02ch,0e2h,0e2h,0e2h,0e2h,0e2h,000h,000h
	db 038h,038h,038h,038h,038h,038h,000h,000h
	db 000h,000h,000h,000h,000h,000h,000h,000h


 	END 	BEGIN
