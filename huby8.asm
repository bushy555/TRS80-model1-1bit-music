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

           
musicData8:
                DEFW  $500               ; Initial tempo
                DEFW  PATTDATA8 - 8        ; Ptr to start of pattern data - 8
                DEFB  $01
                DEFB  $02
                DEFB  $03
                DEFB  $04
                DEFB  $01
                DEFB  $05
                DEFB  $06
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
                DEFB  $10
                DEFB  $11
                DEFB  $10
                DEFB  $11
                DEFB  $10
                DEFB  $12
                DEFB  $13
                DEFB  $14
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $14
                DEFB  $15
                DEFB  $16
                DEFB  $17
                DEFB  $0E
                DEFB  $17
                DEFB  $18
                DEFB  $19
                DEFB  $1A
                DEFB  $1B
                DEFB  $11
                DEFB  $13
                DEFB  $14
                DEFB  $13
                DEFB  $14
                DEFB  $15
                DEFB  $14
                DEFB  $15
                DEFB  $16
                DEFB  $17
                DEFB  $0E
                DEFB  $17
                DEFB  $1C
                DEFB  $13
                DEFB  $1D
                DEFB  $13
                DEFB  $11
                DEFB  $13
                DEFB  $1E
                DEFB  $13
                DEFB  $1F
                DEFB  $13
                DEFB  $20
                DEFB  $21
                DEFB  $0F
                DEFB  $22
                DEFB  $23
                DEFB  $22
                DEFB  $24
                DEFB  $22
                DEFB  $20
                DEFB  $25
                DEFB  $0F
                DEFB  $26
                DEFB  $27
                DEFB  $26
                DEFB  $27
                DEFB  $FF                 ; Tempo change
                DEFW  $1338               ; New tempo value
                DEFB  $28
                DEFB  $27
                DEFB  $0E
                DEFB  $29
                DEFB  $FF                 ; Tempo change
                DEFW  $1A6A               ; New tempo value
                DEFB  $0E
                DEFB  $2A
                DEFB  $2B
                DEFB  $0E
                DEFB  $FF                 ; Tempo change
                DEFW  $10D2               ; New tempo value
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $31
                DEFB  $34
                DEFB  $35
                DEFB  $36
                DEFB  $0E
                DEFB  $2C
                DEFB  $37
                DEFB  $2C
                DEFB  $2D
                DEFB  $2E
                DEFB  $2F
                DEFB  $30
                DEFB  $31
                DEFB  $32
                DEFB  $33
                DEFB  $34
                DEFB  $31
                DEFB  $38
                DEFB  $35
                DEFB  $2C
                DEFB  $0E
                DEFB  $2C
                DEFB  $39
                DEFB  $3A
                DEFB  $0E
                DEFB  $3B
                DEFB  $3C
                DEFB  $3D
                DEFB  $3E
                DEFB  $3F
                DEFB  $40
                DEFB  $2C
                DEFB  $41
                DEFB  $42
                DEFB  $43
                DEFB  $3A
                DEFB  $0E
                DEFB  $44
                DEFB  $45
                DEFB  $2C
                DEFB  $46
                DEFB  $2E
                DEFB  $47
                DEFB  $48
                DEFB  $31
                DEFB  $38
                DEFB  $35
                DEFB  $49
                DEFB  $4A
                DEFB  $03
                DEFB  $04
                DEFB  $01
                DEFB  $05
                DEFB  $06
                DEFB  $07
                DEFB  $08
                DEFB  $09
                DEFB  $0A
                DEFB  $0B
                DEFB  $0C
                DEFB  $0D
                DEFB  $0E
                DEFB  $0F
                DEFB  $00                 ; End of song

PATTDATA8:
                DEFB  $22, $00, $22, $00, $22, $00, $22, $00
                DEFB  $1B, $00, $1B, $00, $1B, $00, $1B, $00
                DEFB  $22, $00, $22, $00, $36, $28, $22, $1B
                DEFB  $1B, $00, $1B, $00, $00, $00, $00, $00
                DEFB  $1C, $00, $1C, $00, $1C, $00, $1C, $00
                DEFB  $22, $00, $22, $00, $33, $28, $22, $1C
                DEFB  $1C, $00, $1C, $00, $00, $00, $00, $00
                DEFB  $79, $00, $00, $00, $00, $00, $00, $00
                DEFB  $1E, $00, $00, $00, $22, $00, $28, $00
                DEFB  $6C, $00, $00, $00, $00, $00, $00, $00
                DEFB  $22, $00, $22, $00, $00, $00, $28, $00
                DEFB  $A1, $00, $00, $00, $00, $00, $00, $00
                DEFB  $00, $00, $00, $00, $00, $28, $22, $1B
                DEFB  $00, $00, $00, $00, $00, $00, $00, $00
                DEFB  $14, $00, $00, $00, $00, $00, $00, $00
                DEFB  $A1, $00, $A1, $00, $A1, $00, $A1, $00
                DEFB  $14, $12, $11, $0D, $14, $12, $11, $0D
                DEFB  $14, $12, $11, $0D, $14, $12, $1B, $0D
                DEFB  $51, $00, $51, $00, $51, $00, $51, $00
                DEFB  $1B, $00, $19, $00, $19, $00, $1B, $00
                DEFB  $56, $00, $56, $00, $56, $00, $56, $00
                DEFB  $1B, $00, $14, $00, $14, $00, $15, $00
                DEFB  $6C, $00, $6C, $00, $6C, $00, $6C, $00
                DEFB  $1E, $00, $1E, $00, $00, $00, $1E, $00
                DEFB  $A1, $00, $A1, $00, $51, $00, $51, $00
                DEFB  $22, $00, $00, $0D, $14, $12, $11, $0D
                DEFB  $51, $00, $51, $00, $51, $00, $1B, $00
                DEFB  $19, $00, $19, $00, $00, $00, $19, $00
                DEFB  $1B, $00, $00, $0D, $14, $12, $11, $0D
                DEFB  $0F, $00, $0F, $00, $00, $00, $11, $00
                DEFB  $00, $00, $00, $00, $11, $00, $00, $00
                DEFB  $12, $00, $12, $00, $00, $00, $11, $12
                DEFB  $51, $00, $51, $00, $5B, $00, $5B, $00
                DEFB  $66, $00, $66, $00, $66, $00, $66, $00
                DEFB  $00, $00, $0F, $00, $0F, $00, $00, $00
                DEFB  $11, $00, $11, $00, $00, $00, $11, $00
                DEFB  $66, $00, $66, $00, $6C, $00, $6C, $00
                DEFB  $79, $00, $79, $00, $79, $00, $79, $00
                DEFB  $14, $00, $12, $00, $12, $00, $14, $00
                DEFB  $E3, $00, $00, $00, $00, $00, $00, $00
                DEFB  $14, $00, $11, $00, $11, $00, $12, $00
                DEFB  $1B, $19, $1E, $1B, $22, $1E, $24, $1B
                DEFB  $6C, $66, $79, $6C, $88, $79, $90, $88
                DEFB  $2C, $00, $A1, $00, $A1, $00, $A1, $00
                DEFB  $14, $00, $12, $00, $11, $00, $14, $00
                DEFB  $2C, $00, $A1, $00, $44, $00, $2C, $00
                DEFB  $12, $00, $11, $00, $36, $00, $39, $00
                DEFB  $2C, $00, $90, $00, $90, $00, $90, $00
                DEFB  $00, $00, $00, $00, $12, $00, $14, $00
                DEFB  $2C, $00, $90, $00, $28, $00, $2C, $00
                DEFB  $12, $00, $11, $00, $39, $00, $3D, $00
                DEFB  $2C, $00, $D7, $00, $D7, $00, $D7, $00
                DEFB  $11, $00, $11, $00, $00, $00, $14, $00
                DEFB  $2C, $00, $A1, $00, $A1, $00, $2C, $00
                DEFB  $0D, $0F, $11, $14, $11, $12, $14, $00
                DEFB  $2C, $00, $D7, $00, $D7, $00, $2C, $00
                DEFB  $0D, $0F, $11, $14, $11, $00, $0C, $00
                DEFB  $2C, $00, $79, $00, $79, $00, $79, $00
                DEFB  $2C, $00, $79, $00, $79, $00, $2C, $00
                DEFB  $00, $00, $00, $0C, $0F, $00, $0D, $00
                DEFB  $2C, $00, $6C, $00, $6C, $00, $6C, $00
                DEFB  $00, $00, $00, $00, $1B, $00, $1E, $00
                DEFB  $2C, $00, $6C, $00, $6C, $00, $2C, $00
                DEFB  $1B, $00, $19, $00, $00, $00, $20, $00
                DEFB  $00, $00, $00, $00, $19, $00, $1B, $00
                DEFB  $2C, $00, $A1, $00, $A1, $00, $79, $00
                DEFB  $19, $00, $1B, $00, $28, $00, $1E, $00
                DEFB  $2C, $00, $66, $00, $6C, $00, $6C, $00
                DEFB  $22, $00, $00, $00, $24, $00, $00, $00
                DEFB  $28, $00, $24, $00, $22, $00, $28, $00
                DEFB  $24, $00, $22, $00, $36, $00, $33, $00
                DEFB  $2C, $00, $F0, $00, $F0, $00, $F0, $00
                DEFB  $A1, $00, $00, $00, $22, $00, $22, $00
                DEFB  $00, $00, $1B, $00, $1B, $00, $1B, $00

 	END 	BEGIN
