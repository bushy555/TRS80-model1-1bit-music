

; *****************************************************************************
; * The Music Studio Player Engine
; *
; * Based on code written by Sa�a Pu�ica for the utility, YU The Music Box.
; * Modified for Beepola by Chris Cowley
; * 
; * Modified for Z80 TI calcs by utz
; *****************************************************************************
	org $6000

START			LD    HL,MUSICDATA			;  <- Pointer to Music Data. Change
								;     this to play a different song
			LD   A,(HL)				; Get the loop start pointer
			LD   (PATTERN_LOOP_BEGIN),A
			INC  HL
			LD   A,(HL)				; Get the song end pointer
			LD   (PATTERN_LOOP_END),A
			INC  HL
			LD   (PATTERNDATA1),HL
			LD   (PATTERNDATA2),HL
			LD   A,254
			LD   (PATTERN_PTR),A			; Set the pattern pointer to zero
			DI
			EXX
			PUSH  HL
			CALL  NEXT_PATTERN

NEXTNOTE		CALL  PLAYNOTE
			XOR   A

;			ld a,%10111111				;+ new keyhandler
;			out (1),a
;			in a,(1)				;read keyboard
;			cpl
;			bit 6,a
;
;			JR    Z,NEXTNOTE			; Play next note if no key pressed
	jp NEXTNOTE			

PATTERN_PTR		DEFB 0
NOTE_PTR		DEFB 0

; ********************************************************************************************************
; * NEXT_PATTERN
; *
; * Select the next pattern in sequence (and handle looping if we've reached PATTERN_LOOP_END
; * Execution falls through to PLAYNOTE to play the first note from our next pattern
; ********************************************************************************************************

NEXT_PATTERN		LD   A,(PATTERN_PTR)
			INC  A
			INC  A
			DEFB $FE				; CP n
PATTERN_LOOP_END	DEFB 0
			JR   NZ,NO_PATTERN_LOOP
			DEFB $3E				; LD A,n
PATTERN_LOOP_BEGIN	DEFB 0
NO_PATTERN_LOOP		LD   (PATTERN_PTR),A

			DEFB $21				; LD HL,nn
PATTERNDATA1		DEFW $0000
			LD   E,A				; (this is the first byte of the pattern)
			LD   D,0				; and store it at TEMPO
			ADD  HL,DE
			LD   E,(HL)
			INC  HL
			LD   D,(HL)
			LD   A,(DE)				; Pattern Tempo -> A
			LD   (TEMPO),A				; Store it at TEMPO

			LD   A,1
			LD   (NOTE_PTR),A

PLAYNOTE		DEFB $21				; LD HL,nn
PATTERNDATA2		DEFW $0000
			LD   A,(PATTERN_PTR)
			LD   E,A
			LD   D,0
			ADD  HL,DE
			LD   E,(HL)
			INC  HL
			LD   D,(HL)				; Now DE = Start of Pattern data
			LD   A,(NOTE_PTR)
			LD   L,A
			LD   H,0
			ADD  HL,DE				; Now HL = address of note data
			LD   D,(HL)
			LD   E,1

; IF D = $0 then were at the end of the pattern so increment PATTERN_PTR by 2 and set NOTE_PTR=0
			LD   A,D
			CP   $FE				; $FE indicates end of pattern
			JR   Z,NEXT_PATTERN

CONTINUE0		PUSH DE
			INC  HL
			LD   D,(HL)
			LD   E,1
			
			LD   A,(NOTE_PTR)
			INC  A
			INC  A
			LD   (NOTE_PTR),A			; Increment the note pointer by 2 (one note per chan)

			EXX
			POP  DE					; Now CH1 freq is in DE, and CH2 freq is in DE'

			LD   A,(TEMPO)
			LD   C,A
			LD   B,0
			LD   A,0
			EX   AF,AF'
			LD   A,0			; So now BC = TEMPO, A and A' = BORDER_COL
			EXX

OUTPUT_NOTE		LD   IXH,D				; Put note frequency for chan 1 into IXH
			LD   H,D
			LD   L,H
			DEC  L
			LD   E,L
			JR   Z,CONTINUE1
			LD   E,2

CONTINUE1		EXX
			LD   IXL,D				; Put note frequency for chan 2 into IXL
			LD   H,D
			LD   L,H
			DEC  L
			LD   E,L
			JR   Z,CONTINUE2
			LD   E,2

CONTINUE2		EXX
			EX   AF,AF'
			push af					;11
;			xor %11111100				;7
;			out (0),a				;(11)

	out	(255), a
			nop					;4
			pop af
			DEC  H					; Dec H, which also holds the frequency value
			JR   NZ,L8055
			XOR  E
			LD   H,D
			PUSH AF
			LD   A,IXH
			CP   $20
			JR   NC,L8054		; if A > $20 then this is not a drum effect, skip the INC D
			INC  D			; create the "fast falling pitch" percussion effect
L8054			POP  AF
L8055			DEC  L
			JR   NZ,L805B
			XOR  E
			LD   L,D
			DEC  L
L805B			EXX
			EX   AF,AF'
			push af					;11
;			xor %11111100				;7
;			out (0),a				;(11)
	out	(255), a
			nop					;4
			pop af
			DEC  H
			JR   NZ,L806D
			XOR  E
			LD   H,D
			PUSH AF
			LD   A,IXL
			CP   $20
			JR   NC,L806C		; if A > $20 then this is not a drum effect, skip the INC D
			INC  D		; create the "fast falling pitch" percussion effect
L806C			POP  AF
L806D			DEC  L
			JR   NZ,L8073
			XOR  E
			LD   L,D
			DEC  L
L8073			DJNZ CONTINUE2
			DEC  C
			JR   NZ,CONTINUE2
			RET


TEMPO			DEFB 186

MUSICDATA		DEFB 8   ; Loop start point * 2
                    DEFB 16   ; Song Length * 2
PATTERNDATA         DEFW      PAT0
                    DEFW      PAT0
                    DEFW      PAT1
                    DEFW      PAT1
                    DEFW      PAT2
                    DEFW      PAT2
                    DEFW      PAT3
                    DEFW      PAT3

; *** Pattern data consists of pairs of frequency values CH1,CH2 with a single $FE to
; *** Mark the end of the pattern, and $01 for a rest
PAT0
         DEFB 7  ; Pattern tempo
             DEFB 215,108
             DEFB 215,1
             DEFB 215,17
             DEFB 215,1
             DEFB 215,108
             DEFB 215,1
             DEFB 215,17
             DEFB 215,1
             DEFB 215,108
             DEFB 215,1
             DEFB 215,17
             DEFB 215,1
             DEFB 161,108
             DEFB 161,1
             DEFB 180,108
             DEFB 180,1
             DEFB 215,91
             DEFB 215,91
             DEFB 215,108
             DEFB 215,108
             DEFB 215,81
             DEFB 215,81
             DEFB 215,81
             DEFB 215,81
             DEFB 215,108
             DEFB 215,108
             DEFB 215,108
             DEFB 215,17
             DEFB 240,17
             DEFB 240,17
             DEFB 227,121
             DEFB 227,114
             DEFB 215,108
             DEFB 215,1
             DEFB 215,17
             DEFB 215,1
             DEFB 215,108
             DEFB 215,1
             DEFB 215,17
             DEFB 215,1
             DEFB 215,108
             DEFB 215,1
             DEFB 215,17
             DEFB 215,1
             DEFB 161,108
             DEFB 161,1
             DEFB 180,108
             DEFB 180,1
             DEFB 215,91
             DEFB 215,91
             DEFB 215,17
             DEFB 215,91
             DEFB 215,91
             DEFB 215,91
             DEFB 215,17
             DEFB 215,108
             DEFB 227,81
             DEFB 227,81
             DEFB 227,17
             DEFB 227,17
             DEFB 227,81
             DEFB 227,17
             DEFB 227,81
             DEFB 227,17
         DEFB 0xFE
PAT1
         DEFB 7  ; Pattern tempo
             DEFB 161,81
             DEFB 161,1
             DEFB 161,16
             DEFB 161,1
             DEFB 161,81
             DEFB 161,1
             DEFB 161,16
             DEFB 161,1
             DEFB 161,81
             DEFB 161,1
             DEFB 161,16
             DEFB 161,1
             DEFB 121,81
             DEFB 121,1
             DEFB 136,81
             DEFB 136,1
             DEFB 161,68
             DEFB 161,68
             DEFB 161,16
             DEFB 161,81
             DEFB 161,61
             DEFB 161,61
             DEFB 161,16
             DEFB 161,61
             DEFB 161,81
             DEFB 161,81
             DEFB 161,81
             DEFB 161,16
             DEFB 180,16
             DEFB 180,16
             DEFB 171,91
             DEFB 171,86
             DEFB 161,81
             DEFB 161,1
             DEFB 161,16
             DEFB 161,1
             DEFB 161,81
             DEFB 161,1
             DEFB 161,16
             DEFB 161,1
             DEFB 161,81
             DEFB 161,1
             DEFB 161,16
             DEFB 161,1
             DEFB 121,81
             DEFB 121,1
             DEFB 136,16
             DEFB 136,1
             DEFB 161,68
             DEFB 161,68
             DEFB 161,16
             DEFB 161,68
             DEFB 161,68
             DEFB 161,68
             DEFB 161,16
             DEFB 161,81
             DEFB 171,61
             DEFB 171,61
             DEFB 171,16
             DEFB 171,61
             DEFB 171,61
             DEFB 171,61
             DEFB 171,16
             DEFB 171,61
         DEFB 0xFE
PAT2
         DEFB 7  ; Pattern tempo
             DEFB 114,57
             DEFB 227,151
             DEFB 227,17
             DEFB 227,151
             DEFB 114,57
             DEFB 227,151
             DEFB 227,17
             DEFB 227,151
             DEFB 114,57
             DEFB 227,151
             DEFB 227,17
             DEFB 227,151
             DEFB 171,57
             DEFB 171,151
             DEFB 192,17
             DEFB 192,151
             DEFB 227,48
             DEFB 227,96
             DEFB 227,57
             DEFB 227,114
             DEFB 227,43
             DEFB 227,86
             DEFB 227,17
             DEFB 227,86
             DEFB 227,57
             DEFB 227,114
             DEFB 227,57
             DEFB 227,17
             DEFB 255,17
             DEFB 255,17
             DEFB 240,64
             DEFB 121,61
             DEFB 114,57
             DEFB 227,151
             DEFB 227,17
             DEFB 227,151
             DEFB 114,57
             DEFB 227,151
             DEFB 227,17
             DEFB 227,151
             DEFB 114,57
             DEFB 227,151
             DEFB 227,17
             DEFB 227,151
             DEFB 171,57
             DEFB 171,151
             DEFB 192,57
             DEFB 192,151
             DEFB 227,48
             DEFB 227,96
             DEFB 227,17
             DEFB 227,96
             DEFB 227,48
             DEFB 227,96
             DEFB 227,17
             DEFB 227,57
             DEFB 240,43
             DEFB 240,86
             DEFB 240,17
             DEFB 240,17
             DEFB 240,43
             DEFB 240,17
             DEFB 240,43
             DEFB 240,17
         DEFB 0xFE
PAT3
         DEFB 7  ; Pattern tempo
             DEFB 86,43
             DEFB 171,114
             DEFB 171,17
             DEFB 171,114
             DEFB 86,43
             DEFB 171,114
             DEFB 171,17
             DEFB 171,114
             DEFB 86,43
             DEFB 171,114
             DEFB 171,17
             DEFB 171,114
             DEFB 128,43
             DEFB 128,114
             DEFB 144,17
             DEFB 144,114
             DEFB 171,36
             DEFB 171,72
             DEFB 171,43
             DEFB 171,86
             DEFB 171,32
             DEFB 171,64
             DEFB 171,17
             DEFB 171,64
             DEFB 171,43
             DEFB 171,86
             DEFB 171,43
             DEFB 171,17
             DEFB 192,17
             DEFB 192,17
             DEFB 180,48
             DEFB 91,45
             DEFB 86,43
             DEFB 171,114
             DEFB 171,17
             DEFB 171,114
             DEFB 86,43
             DEFB 171,114
             DEFB 171,17
             DEFB 171,114
             DEFB 86,43
             DEFB 171,114
             DEFB 171,17
             DEFB 171,114
             DEFB 128,43
             DEFB 128,114
             DEFB 144,43
             DEFB 144,114
             DEFB 171,36
             DEFB 171,72
             DEFB 171,17
             DEFB 171,72
             DEFB 171,36
             DEFB 171,72
             DEFB 171,17
             DEFB 171,43
             DEFB 180,32
             DEFB 180,64
             DEFB 180,17
             DEFB 180,17
             DEFB 180,32
             DEFB 180,17
             DEFB 180,32
             DEFB 180,17
         DEFB 0xFE
end
