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


musicData7
                DEFW  $500               ; Initial tempo
                DEFW  PATTDATA7 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $09
                DEFB  $02
                DEFB  $0A
                DEFB  $0B
                DEFB  $10
                DEFB  $0F
                DEFB  $11
                DEFB  $12
                DEFB  $13
                DEFB  $02
                DEFB  $14
                DEFB  $04
                DEFB  $15
                DEFB  $06
                DEFB  $16
                DEFB  $08
                DEFB  $13
                DEFB  $02
                DEFB  $14
                DEFB  $04
                DEFB  $15
                DEFB  $06
                DEFB  $17
                DEFB  $08
                DEFB  $18
                DEFB  $02
                DEFB  $19
                DEFB  $0B
                DEFB  $1A
                DEFB  $0D
                DEFB  $1B
                DEFB  $0F
                DEFB  $18
                DEFB  $02
                DEFB  $19
                DEFB  $0B
                DEFB  $1C
                DEFB  $0F
                DEFB  $1D
                DEFB  $12
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $1E
                DEFB  $22
                DEFB  $20
                DEFB  $23
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $1E
                DEFB  $24
                DEFB  $20
                DEFB  $25
                DEFB  $26
                DEFB  $27
                DEFB  $28
                DEFB  $21
                DEFB  $26
                DEFB  $29
                DEFB  $28
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2B
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $1E
                DEFB  $22
                DEFB  $20
                DEFB  $23
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $1E
                DEFB  $24
                DEFB  $20
                DEFB  $25
                DEFB  $26
                DEFB  $27
                DEFB  $28
                DEFB  $21
                DEFB  $26
                DEFB  $29
                DEFB  $28
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3C
                DEFB  $3D
                DEFB  $3E
                DEFB  $3F
                DEFB  $40
                DEFB  $41
                DEFB  $42
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3C
                DEFB  $3D
                DEFB  $3E
                DEFB  $43
                DEFB  $40
                DEFB  $44
                DEFB  $45
                DEFB  $13
                DEFB  $02
                DEFB  $14
                DEFB  $04
                DEFB  $15
                DEFB  $06
                DEFB  $16
                DEFB  $08
                DEFB  $13
                DEFB  $02
                DEFB  $14
                DEFB  $04
                DEFB  $15
                DEFB  $06
                DEFB  $17
                DEFB  $08
                DEFB  $18
                DEFB  $02
                DEFB  $19
                DEFB  $0B
                DEFB  $1A
                DEFB  $0D
                DEFB  $1B
                DEFB  $0F
                DEFB  $46
                DEFB  $02
                DEFB  $47
                DEFB  $0B
                DEFB  $48
                DEFB  $0F
                DEFB  $49
                DEFB  $4A
                DEFB  $13
                DEFB  $02
                DEFB  $14
                DEFB  $04
                DEFB  $15
                DEFB  $06
                DEFB  $16
                DEFB  $08
                DEFB  $13
                DEFB  $02
                DEFB  $14
                DEFB  $04
                DEFB  $15
                DEFB  $06
                DEFB  $17
                DEFB  $08
                DEFB  $18
                DEFB  $02
                DEFB  $19
                DEFB  $0B
                DEFB  $1A
                DEFB  $0D
                DEFB  $1B
                DEFB  $0F
                DEFB  $18
                DEFB  $02
                DEFB  $19
                DEFB  $0B
                DEFB  $1C
                DEFB  $0F
                DEFB  $1D
                DEFB  $12
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $1E
                DEFB  $22
                DEFB  $20
                DEFB  $23
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $1E
                DEFB  $24
                DEFB  $20
                DEFB  $25
                DEFB  $26
                DEFB  $27
                DEFB  $28
                DEFB  $21
                DEFB  $26
                DEFB  $29
                DEFB  $28
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2B
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $1E
                DEFB  $22
                DEFB  $20
                DEFB  $23
                DEFB  $1E
                DEFB  $1F
                DEFB  $20
                DEFB  $21
                DEFB  $1E
                DEFB  $24
                DEFB  $20
                DEFB  $25
                DEFB  $26
                DEFB  $27
                DEFB  $28
                DEFB  $21
                DEFB  $26
                DEFB  $29
                DEFB  $28
                DEFB  $2A
                DEFB  $2B
                DEFB  $2C
                DEFB  $2D
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $35
                DEFB  $36
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3C
                DEFB  $3D
                DEFB  $3E
                DEFB  $3F
                DEFB  $40
                DEFB  $41
                DEFB  $42
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $37
                DEFB  $38
                DEFB  $39
                DEFB  $3A
                DEFB  $3B
                DEFB  $3C
                DEFB  $3D
                DEFB  $3E
                DEFB  $3F
                DEFB  $40
                DEFB  $4B
                DEFB  $4C
                DEFB  $4D
                DEFB  $4E
                DEFB  $00                 ; End of song

PATTDATA7:
                DEFB  $51, $51, $00, $00, $22, $1E, $51, $51
                DEFB  $00, $00, $22, $1E, $1B, $1B, $1E, $1B
                DEFB  $1E, $51, $51, $1B, $51, $00, $1B, $00
                DEFB  $00, $1B, $1E, $00, $1B, $00, $1B, $1E
                DEFB  $79, $79, $22, $22, $24, $22, $79, $6C
                DEFB  $22, $22, $24, $22, $00, $22, $00, $24
                DEFB  $00, $6C, $6C, $1E, $6C, $00, $00, $1E
                DEFB  $1E, $1E, $24, $1E, $00, $1E, $24, $00
                DEFB  $66, $66, $00, $00, $22, $1E, $66, $66
                DEFB  $1E, $66, $66, $1B, $66, $00, $00, $1B
                DEFB  $00, $1B, $1E, $1B, $00, $1B, $1E, $00
                DEFB  $5B, $5B, $1E, $1E, $22, $1E, $5B, $5B
                DEFB  $1E, $1E, $22, $1E, $00, $1E, $00, $22
                DEFB  $00, $5B, $5B, $1E, $5B, $00, $00, $1E
                DEFB  $1E, $1E, $22, $1E, $00, $1E, $22, $00
                DEFB  $5B, $5B, $1E, $1E, $22, $1E, $5B, $00
                DEFB  $5B, $00, $00, $00, $66, $00, $5B, $00
                DEFB  $1E, $00, $00, $00, $00, $00, $00, $00
                DEFB  $2C, $51, $00, $2C, $51, $1E, $2C, $51
                DEFB  $2C, $51, $51, $2C, $51, $00, $2C, $00
                DEFB  $2C, $79, $22, $2C, $79, $22, $2C, $6C
                DEFB  $2C, $6C, $6C, $2C, $6C, $00, $2C, $1E
                DEFB  $2C, $6C, $6C, $2C, $6C, $00, $00, $1E
                DEFB  $2C, $66, $00, $2C, $66, $1E, $2C, $66
                DEFB  $2C, $66, $66, $2C, $66, $66, $2C, $1B
                DEFB  $2C, $5B, $1E, $2C, $5B, $1E, $2C, $5B
                DEFB  $2C, $5B, $5B, $2C, $5B, $00, $2C, $1E
                DEFB  $2C, $5B, $1E, $2C, $5B, $1E, $2C, $1E
                DEFB  $5B, $1E, $22, $00, $1E, $00, $00, $00
                DEFB  $2C, $51, $00, $51, $44, $00, $51, $51
                DEFB  $36, $36, $00, $00, $00, $00, $36, $36
                DEFB  $2C, $44, $2C, $51, $44, $00, $5B, $00
                DEFB  $00, $00, $00, $00, $24, $22, $00, $22
                DEFB  $24, $24, $2D, $00, $00, $00, $3D, $00
                DEFB  $36, $00, $00, $00, $00, $00, $00, $00
                DEFB  $24, $00, $2D, $00, $00, $2D, $24, $00
                DEFB  $2D, $00, $00, $00, $36, $00, $3D, $00
                DEFB  $2C, $79, $00, $79, $66, $00, $79, $79
                DEFB  $33, $33, $00, $00, $00, $00, $33, $33
                DEFB  $2C, $66, $2C, $79, $66, $00, $88, $00
                DEFB  $24, $00, $2D, $00, $00, $00, $24, $00
                DEFB  $2D, $00, $00, $00, $2D, $00, $28, $00
                DEFB  $2C, $6C, $00, $6C, $5B, $00, $6C, $6C
                DEFB  $24, $24, $00, $00, $00, $00, $24, $24
                DEFB  $2C, $5B, $2C, $6C, $5B, $00, $79, $00
                DEFB  $00, $00, $00, $00, $1E, $1B, $00, $1B
                DEFB  $1E, $00, $22, $00, $00, $00, $24, $00
                DEFB  $2C, $5B, $2C, $6C, $5B, $00, $51, $00
                DEFB  $22, $00, $00, $00, $44, $00, $3D, $00
                DEFB  $00, $00, $00, $00, $1E, $1B, $00, $1E
                DEFB  $2C, $6C, $2C, $6C, $5B, $2C, $6C, $6C
                DEFB  $1B, $00, $00, $00, $00, $00, $00, $00
                DEFB  $00, $5B, $00, $2C, $66, $00, $5B, $00
                DEFB  $00, $00, $00, $00, $44, $00, $3D, $00
                DEFB  $2C, $2C, $44, $2C, $51, $2C, $51, $2C
                DEFB  $36, $36, $22, $36, $36, $1E, $36, $36
                DEFB  $2C, $2C, $51, $2C, $51, $2C, $44, $2C
                DEFB  $22, $36, $36, $1E, $36, $1E, $22, $1E
                DEFB  $2C, $2C, $33, $2C, $79, $2C, $79, $2C
                DEFB  $28, $28, $19, $28, $28, $17, $28, $28
                DEFB  $2C, $2C, $79, $2C, $79, $2C, $36, $2C
                DEFB  $19, $28, $28, $17, $28, $19, $1B, $19
                DEFB  $2C, $2C, $5B, $2C, $6C, $2C, $6C, $6C
                DEFB  $24, $24, $2D, $24, $24, $28, $24, $24
                DEFB  $2C, $6C, $6C, $2C, $6C, $5B, $6C, $5B
                DEFB  $2D, $24, $24, $28, $24, $2D, $36, $2D
                DEFB  $2C, $2C, $5B, $2C, $6C, $2C, $6C, $2C
                DEFB  $5B, $6C, $6C, $51, $00, $6C, $66, $5B
                DEFB  $2D, $24, $24, $28, $00, $00, $00, $00
                DEFB  $2C, $66, $00, $2C, $22, $1E, $2C, $66
                DEFB  $2C, $66, $66, $2C, $66, $00, $2C, $1B
                DEFB  $2C, $5B, $1E, $2C, $22, $1E, $2C, $00
                DEFB  $2C, $00, $1E, $2C, $66, $00, $5B, $00
                DEFB  $1E, $00, $00, $00, $33, $00, $2D, $00
                DEFB  $2C, $6C, $2C, $51, $00, $6C, $66, $5B
                DEFB  $2D, $24, $24, $28, $00, $36, $33, $2D
                DEFB  $51, $00, $00, $00, $00, $00, $00, $00
                DEFB  $28, $00, $00, $00, $00, $00, $00, $00

 	END 	BEGIN
