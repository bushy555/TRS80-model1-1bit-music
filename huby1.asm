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
                DEFW  03e0h               ; Initial tempo
                DEFW  PATTDATA1 - 8        ; Ptr to start of pattern data - 8
                DEFB  01h
                DEFB  02h
                DEFB  01h
                DEFB  03h
                DEFB  01h
                DEFB  04h
                DEFB  01h
                DEFB  05h
                DEFB  06h
                DEFB  07h
                DEFB  08h
                DEFB  09h
                DEFB  0Ah
                DEFB  01h
                DEFB  0Bh
                DEFB  01h
                DEFB  0Ch
                DEFB  0Dh
                DEFB  0Eh
                DEFB  0Fh
                DEFB  10h
                DEFB  11h
                DEFB  12h
                DEFB  13h
                DEFB  06h
                DEFB  07h
                DEFB  08h
                DEFB  09h
                DEFB  0Ah
                DEFB  01h
                DEFB  0Bh
                DEFB  01h
                DEFB  0Ch
                DEFB  0Dh
                DEFB  0Eh
                DEFB  0Fh
                DEFB  10h
                DEFB  11h
                DEFB  12h
                DEFB  13h
                DEFB  06h
                DEFB  14h
                DEFB  15h
                DEFB  01h
                DEFB  06h
                DEFB  01h
                DEFB  15h
                DEFB  01h
                DEFB  16h
                DEFB  17h
                DEFB  16h
                DEFB  18h
                DEFB  19h
                DEFB  1Ah
                DEFB  19h
                DEFB  01h
                DEFB  1Bh
                DEFB  1Ch
                DEFB  1Bh
                DEFB  1Dh
                DEFB  16h
                DEFB  14h
                DEFB  16h
                DEFB  01h
                DEFB  1Eh
                DEFB  1Fh
                DEFB  1Eh
                DEFB  20h
                DEFB  19h
                DEFB  1Fh
                DEFB  19h
                DEFB  01h
                DEFB  21h
                DEFB  22h
                DEFB  21h
                DEFB  23h
                DEFB  24h
                DEFB  25h
                DEFB  26h
                DEFB  01h
                DEFB  16h
                DEFB  17h
                DEFB  16h
                DEFB  18h
                DEFB  19h
                DEFB  1Ah
                DEFB  19h
                DEFB  01h
                DEFB  1Bh
                DEFB  1Ch
                DEFB  1Bh
                DEFB  1Dh
                DEFB  16h
                DEFB  14h
                DEFB  16h
                DEFB  01h
                DEFB  1Eh
                DEFB  1Fh
                DEFB  1Eh
                DEFB  20h
                DEFB  19h
                DEFB  1Fh
                DEFB  19h
                DEFB  01h
                DEFB  21h
                DEFB  22h
                DEFB  21h
                DEFB  27h
                DEFB  16h
                DEFB  25h
                DEFB  28h
                DEFB  01h
                DEFB  29h
                DEFB  01h
                DEFB  06h
                DEFB  01h
                DEFB  06h
                DEFB  07h
                DEFB  08h
                DEFB  09h
                DEFB  0Ah
                DEFB  01h
                DEFB  0Bh
                DEFB  01h
                DEFB  0Ch
                DEFB  0Dh
                DEFB  0Eh
                DEFB  0Fh
                DEFB  10h
                DEFB  11h
                DEFB  12h
                DEFB  13h
                DEFB  06h
                DEFB  07h
                DEFB  08h
                DEFB  2Ah
                DEFB  0Ah
                DEFB  01h
                DEFB  0Bh
                DEFB  01h
                DEFB  0Ch
                DEFB  07h
                DEFB  0Ch
                DEFB  2Bh
                DEFB  10h
                DEFB  2Ch
                DEFB  2Dh
                DEFB  2Eh
                DEFB  06h
                DEFB  14h
                DEFB  15h
                DEFB  01h
                DEFB  06h
                DEFB  01h
                DEFB  15h
                DEFB  01h
                DEFB  16h
                DEFB  17h
                DEFB  16h
                DEFB  18h
                DEFB  19h
                DEFB  1Ah
                DEFB  19h
                DEFB  01h
                DEFB  1Bh
                DEFB  1Ch
                DEFB  1Bh
                DEFB  1Dh
                DEFB  16h
                DEFB  14h
                DEFB  16h
                DEFB  01h
                DEFB  1Eh
                DEFB  1Fh
                DEFB  1Eh
                DEFB  20h
                DEFB  19h
                DEFB  1Fh
                DEFB  19h
                DEFB  01h
                DEFB  21h
                DEFB  22h
                DEFB  21h
                DEFB  23h
                DEFB  24h
                DEFB  25h
                DEFB  26h
                DEFB  01h
                DEFB  16h
                DEFB  17h
                DEFB  16h
                DEFB  18h
                DEFB  19h
                DEFB  1Ah
                DEFB  19h
                DEFB  01h
                DEFB  1Bh
                DEFB  1Ch
                DEFB  1Bh
                DEFB  1Dh
                DEFB  16h
                DEFB  14h
                DEFB  16h
                DEFB  01h
                DEFB  1Eh
                DEFB  1Fh
                DEFB  1Eh
                DEFB  20h
                DEFB  19h
                DEFB  1Fh
                DEFB  19h
                DEFB  01h
                DEFB  21h
                DEFB  22h
                DEFB  21h
                DEFB  27h
                DEFB  16h
                DEFB  25h
                DEFB  28h
                DEFB  01h
                DEFB  29h
                DEFB  01h
                DEFB  06h
                DEFB  01h
                DEFB  00h                ; End of song

PATTDATA1:
                DEFB  000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                DEFB  066h, 000h, 000h, 000h, 060h, 000h, 000h, 000h
                DEFB  05Bh, 000h, 000h, 000h, 056h, 000h, 000h, 000h
                DEFB  051h, 000h, 000h, 000h, 04Ch, 000h, 000h, 000h
                DEFB  048h, 000h, 000h, 000h, 044h, 000h, 000h, 000h
                DEFB  080h, 000h, 080h, 000h, 080h, 000h, 080h, 000h
                DEFB  020h, 000h, 000h, 000h, 020h, 000h, 000h, 000h
                DEFB  02Ch, 000h, 080h, 000h, 02Ch, 000h, 080h, 000h
                DEFB  000h, 000h, 024h, 000h, 020h, 000h, 024h, 000h
                DEFB  090h, 000h, 090h, 000h, 090h, 000h, 090h, 000h
                DEFB  02Ch, 000h, 090h, 000h, 02Ch, 000h, 090h, 000h
                DEFB  0A1h, 000h, 0A1h, 000h, 0A1h, 000h, 0A1h, 000h
                DEFB  028h, 000h, 000h, 000h, 028h, 000h, 000h, 000h
                DEFB  02Ch, 000h, 0A1h, 000h, 02Ch, 000h, 0A1h, 000h
                DEFB  000h, 000h, 028h, 000h, 030h, 000h, 036h, 000h
                DEFB  097h, 000h, 097h, 000h, 097h, 000h, 097h, 000h
                DEFB  039h, 000h, 000h, 040h, 000h, 000h, 039h, 000h
                DEFB  02Ch, 000h, 088h, 000h, 088h, 000h, 088h, 000h
                DEFB  039h, 000h, 000h, 044h, 000h, 000h, 039h, 000h
                DEFB  019h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                DEFB  080h, 000h, 080h, 000h, 080h, 000h, 090h, 088h
                DEFB  040h, 000h, 080h, 000h, 080h, 000h, 040h, 080h
                DEFB  033h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                DEFB  000h, 000h, 000h, 000h, 030h, 000h, 02Dh, 000h
                DEFB  044h, 000h, 088h, 000h, 088h, 000h, 044h, 088h
                DEFB  02Bh, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                DEFB  04Ch, 000h, 097h, 000h, 097h, 000h, 04Ch, 097h
                DEFB  026h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                DEFB  000h, 000h, 022h, 000h, 020h, 000h, 01Ch, 000h
                DEFB  039h, 000h, 072h, 000h, 072h, 000h, 039h, 072h
                DEFB  018h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                DEFB  000h, 000h, 013h, 000h, 000h, 000h, 015h, 000h
                DEFB  056h, 000h, 0ABh, 000h, 0ABh, 000h, 056h, 0ABh
                DEFB  01Ch, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                DEFB  000h, 000h, 018h, 000h, 000h, 000h, 019h, 000h
                DEFB  080h, 000h, 080h, 040h, 088h, 000h, 080h, 040h
                DEFB  020h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                DEFB  097h, 000h, 080h, 040h, 0ABh, 000h, 080h, 040h
                DEFB  02Bh, 000h, 000h, 000h, 01Ch, 000h, 000h, 000h
                DEFB  040h, 000h, 080h, 000h, 040h, 000h, 040h, 080h
                DEFB  080h, 0FFh, 080h, 0FFh, 080h, 0FFh, 080h, 0FFh
                DEFB  01Bh, 000h, 01Ch, 000h, 020h, 000h, 024h, 000h
                DEFB  01Bh, 000h, 01Ch, 000h, 020h, 000h, 01Bh, 000h
                DEFB  018h, 000h, 000h, 020h, 000h, 000h, 018h, 000h
                DEFB  088h, 000h, 088h, 000h, 088h, 000h, 088h, 000h
                DEFB  015h, 000h, 000h, 01Ch, 000h, 000h, 015h, 000h

 	END 	BEGIN
