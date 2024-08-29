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


musicData5
                DEFW  $500               ; Initial tempo
                DEFW  PATTDATA5 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $01
                DEFB  $04
                DEFB  $05
                DEFB  $04
                DEFB  $01
                DEFB  $06
                DEFB  $03
                DEFB  $06
                DEFB  $01
                DEFB  $07
                DEFB  $03
                DEFB  $07
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $02
                DEFB  $01
                DEFB  $04
                DEFB  $05
                DEFB  $04
                DEFB  $01
                DEFB  $06
                DEFB  $03
                DEFB  $06
                DEFB  $01
                DEFB  $07
                DEFB  $03
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $14
                DEFB  $0D
                DEFB  $15
                DEFB  $16
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $14
                DEFB  $0D
                DEFB  $15
                DEFB  $17
                DEFB  $08
                DEFB  $18
                DEFB  $0A
                DEFB  $16
                DEFB  $0C
                DEFB  $19
                DEFB  $0E
                DEFB  $1A
                DEFB  $10
                DEFB  $1B
                DEFB  $12
                DEFB  $16
                DEFB  $14
                DEFB  $1C
                DEFB  $15
                DEFB  $1D
                DEFB  $08
                DEFB  $18
                DEFB  $0A
                DEFB  $16
                DEFB  $0C
                DEFB  $19
                DEFB  $0E
                DEFB  $1A
                DEFB  $10
                DEFB  $1B
                DEFB  $12
                DEFB  $16
                DEFB  $14
                DEFB  $1C
                DEFB  $1E
                DEFB  $1D
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $14
                DEFB  $0D
                DEFB  $15
                DEFB  $16
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $10
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $14
                DEFB  $0D
                DEFB  $15
                DEFB  $17
                DEFB  $08
                DEFB  $18
                DEFB  $0A
                DEFB  $16
                DEFB  $0C
                DEFB  $19
                DEFB  $0E
                DEFB  $1A
                DEFB  $10
                DEFB  $1B
                DEFB  $12
                DEFB  $16
                DEFB  $14
                DEFB  $1C
                DEFB  $15
                DEFB  $1D
                DEFB  $08
                DEFB  $18
                DEFB  $0A
                DEFB  $16
                DEFB  $0C
                DEFB  $19
                DEFB  $0E
                DEFB  $1A
                DEFB  $10
                DEFB  $1B
                DEFB  $12
                DEFB  $16
                DEFB  $14
                DEFB  $1C
                DEFB  $1E
                DEFB  $1D
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $22
                DEFB  $23
                DEFB  $24
                DEFB  $01
                DEFB  $16
                DEFB  $00                 ; End of song

PATTDATA5:
                DEFB  $2C, $00, $00, $00, $00, $00, $00, $00
                DEFB  $79, $79, $3D, $3D, $79, $79, $3D, $3D
                DEFB  $2C, $00, $2C, $00, $00, $00, $00, $00
                DEFB  $97, $97, $4C, $4C, $97, $97, $4C, $4C
                DEFB  $2C, $00, $2C, $00, $00, $00, $2C, $00
                DEFB  $88, $88, $44, $44, $88, $88, $44, $44
                DEFB  $B4, $B4, $5B, $5B, $B4, $B4, $5B, $5B
                DEFB  $2C, $79, $3D, $3D, $79, $79, $3D, $3D
                DEFB  $00, $00, $3D, $00, $00, $00, $36, $00
                DEFB  $2C, $79, $2C, $3D, $79, $79, $3D, $3D
                DEFB  $00, $00, $33, $00, $00, $00, $00, $00
                DEFB  $2C, $97, $4C, $4C, $97, $97, $4C, $4C
                DEFB  $44, $00, $00, $00, $44, $00, $3D, $00
                DEFB  $2C, $97, $2C, $4C, $97, $97, $2C, $4C
                DEFB  $00, $00, $36, $00, $00, $00, $00, $00
                DEFB  $2C, $88, $44, $44, $88, $88, $44, $44
                DEFB  $00, $00, $00, $00, $3D, $00, $00, $00
                DEFB  $2C, $88, $2C, $44, $88, $88, $44, $44
                DEFB  $36, $00, $00, $00, $33, $00, $00, $00
                DEFB  $2C, $B4, $5B, $5B, $B4, $B4, $5B, $5B
                DEFB  $2C, $B4, $2C, $5B, $B4, $B4, $5B, $5B
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $00, $00, $00, $00, $48, $00, $00, $00
                DEFB  $3D, $00, $00, $00, $00, $00, $00, $00
                DEFB  $4C, $00, $00, $00, $00, $00, $51, $00
                DEFB  $00, $00, $00, $00, $4C, $00, $00, $00
                DEFB  $44, $00, $00, $00, $00, $00, $00, $00
                DEFB  $5B, $00, $00, $00, $5B, $00, $51, $00
                DEFB  $00, $00, $00, $00, $5B, $00, $00, $00
                DEFB  $2C, $2C, $2C, $2C, $B4, $B4, $5B, $5B
                DEFB  $2C, $00, $79, $2C, $79, $00, $2C, $00
                DEFB  $00, $00, $79, $00, $00, $00, $79, $00
                DEFB  $2C, $00, $79, $00, $3D, $00, $3D, $00
                DEFB  $00, $00, $79, $00, $00, $00, $3D, $00
                DEFB  $2C, $00, $00, $2C, $00, $00, $2C, $00
                DEFB  $79, $00, $00, $00, $00, $00, $00, $00

 	END 	BEGIN
