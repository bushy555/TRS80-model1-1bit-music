	org	6000h

	
start:	di
	exx
	push hl
	ld hl,  music_data
	call play
	pop hl
	exx
	ei
	ret
	

;Music Synth 48K engine by Simon C. Tillson,   1989
;reversed and adapted for 1tracker by Shiru 01'2018
;the code mostly remained intact,  just a header added

play:

;        di
	
	ld a, (hl)
	ld (song_speed), a
	inc hl
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld   (ch1_song_ptr), de
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld   (ch2_song_ptr), de
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld   (ch3_song_ptr), de
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld   (ch1_loop_ptr), de
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld   (ch2_loop_ptr), de
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld   (ch3_loop_ptr), de
	
	ld (envelope_data_ptr), hl

	call ch1_read_note
	call ch2_read_note
	call ch3_read_note
	
	ld e, 0
	
	call play_loop
        ei
	ret

play_loop:
	ld   a, (song_speed)
	ld   (sound_loop_cnt), a
sound_loop:
sound_loop_ch1:
	ld   a, h			;process first tone channel
	and  a
	jr   z, sound_loop_ch2		;check if channel is muted (zero period)
	dec  h
	jr   nz, sound_loop_ch2
	ld   a, (ch1_volume)
	ld   c, a
	and  a
	jr   z, sound_loop_ch2
	ld   b, a
	xor  a

	and 2
       OUT   (255), A
	djnz $
	ld   a, 2
        out  (255), a
	sub  c
	ld   b, a
	djnz $
	ld   a, (ch1_period)
	ld   h, a
sound_loop_ch2:
	ld   a, l			;process second tone channel
	and  a
	jr   z, sound_loop_ch3
	dec  l
	jr   nz, sound_loop_ch3
	ld   a, (ch2_volume)
	and  a
	jr   z, sound_loop_ch3
	ld   c, a
	ld   b, a
	xor  a
       OUT   (255), A

	djnz $
	
	ld   a, 2
	out	(255), a 		; Cassette Output becomes High

	sub  c
	ld   b, a

	djnz $
	
	ld   a, (ch2_period)
	ld   l, a

sound_loop_ch3:

	ld   a, d			;process noise channel
	
	and  a
	jr   z, sound_loop_next
	dec  d
	jr   nz, sound_loop_next
	ld   a, (ix)			;read noise from ROM

	and 2
        out  (255), a


	jr   nz, hidc1
	and 2
        out  (255), a

	jr   nxdc
hidc1: 
	and 2
	out	(255), a 		; Cassette Output becomes High

nxdc:	xor  2
        out  (255), a


	jr   nz,  hidc2
	and 2
        out  (255), a
	jr   loop
hidc2: 	
	and 2
        out  (255), a
loop:	ld   a, (ch3_period)
	ld   d, a
sound_loop_next:
	inc  ix 			;advance noise pointer,  gets modified to mute noise
	ld   a, ixh			;keep it in $0fff range
	cp   0Fh
	jr   nz, no_noise_overflow
	ld   ix, 0
no_noise_overflow:
	ld   a, (sound_loop_cnt)
	dec  a
	ld   (sound_loop_cnt), a
	jp   nz, sound_loop
	call ch1_advance_envelope
	call ch2_advance_envelope
	call ch3_advance_envelope
	
	bit  6, e
	call nz, loop_playing
	res  6, e

;        xor  a
;        in   a, ($FE)
;        cpl
;        and  $1F
;        jp   z, play_loop

	ld   a, h
	or   l
	or   d
	jp   nz, play_loop
	ret
ch1_advance_envelope:
	exx
	dec  e
	exx
	ret  nz
	ld   a, (ch1_counter)
	exx
	ld   e, a
	exx
	ld   bc, (ch1_env_play_ptr)
	inc  bc
	ld   (ch1_env_play_ptr), bc	
	ld   a, (bc)
	ld   (ch1_volume), a
	bit  7, a
	call nz, ch1_read_note
	ret
ch2_advance_envelope:
	exx
	dec  b
	exx
	ret  nz
	ld   a, (ch2_counter)
	exx
	ld   b, a
	exx
	ld   bc, (ch2_env_play_ptr)
	inc  bc
	ld   (ch2_env_play_ptr), bc
	ld   a, (bc)
	ld   (ch2_volume), a
	bit  7, a
	call nz, ch2_read_note
	ret

ch3_advance_envelope:
	exx
	dec  c
	exx
	ret  nz
	ld   a, (ch3_counter)
	exx
	ld   c, a
	exx
	ld   bc, (ch3_env_play_ptr)
	inc  bc
	ld   (ch3_env_play_ptr), bc
	ld   a, (bc)
	ld   d, a
	ld   (ch3_period), a
	bit  7, a
	call nz, ch3_read_note
	ret

loop_playing:

	ld hl, (ch1_loop_ptr)
	ld   (ch1_song_ptr), hl
	ld hl, (ch2_loop_ptr)
	ld   (ch2_song_ptr), hl
	ld hl, (ch3_loop_ptr)
	ld   (ch3_song_ptr), hl
	call ch1_read_note
	call ch2_read_note
	call ch3_read_note
	ret

ch1_read_note:

	push hl
	push de
	ld   hl, (ch1_song_ptr)
	ld   a, (hl)
	inc  a
	jp   nz, ch1_no_envelope
	inc  hl
	ld   a, (hl)
	inc  hl
	ld   (ch1_song_ptr), hl
	ld   l, a
	ld   h, 0
	add  hl, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	ld   de, (envelope_data_ptr)
	add  hl, de
	ld   (ch1_env_sel_ptr), hl
ch1_no_envelope:
	ld   hl, (ch1_song_ptr)
	ld   a, (hl)
	ld   (ch1_period), a
	inc  hl
	ld   a, (hl)
	and  a
	jp   nz, L9D80
	pop  de
	set  6, e
	push de
L9D80:	exx
	ld   e, a
	exx
	ld   (ch1_counter), a
	inc  hl
	ld   (ch1_song_ptr), hl
	ld   hl, (ch1_env_sel_ptr)
	ld   (ch1_env_play_ptr), hl
	ld   a, (hl)
	ld   (ch1_volume), a
	pop  de
	pop  hl
	ld   a, (ch1_period)
	ld   h, a
	ret
ch2_read_note:
	push hl
	push de
	ld   hl, (ch2_song_ptr)
	ld   a, (hl)
	inc  a
	jp   nz, ch2_no_envelope
	inc  hl
	ld   a, (hl)
	inc  hl
	ld   (ch2_song_ptr), hl
	ld   l, a
	ld   h, 0
	add  hl, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	ld   de, (envelope_data_ptr)
	add  hl, de
	ld   (ch2_env_sel_ptr), hl

ch2_no_envelope:
	ld   hl, (ch2_song_ptr)
	ld   a, (hl)
	ld   (ch2_period), a
	inc  hl
	ld   a, (hl)
	exx
	ld   b, a
	exx
	ld   (ch2_counter), a
	inc  hl
	ld   (ch2_song_ptr), hl
	ld   hl, (ch2_env_sel_ptr)
	ld   (ch2_env_play_ptr), hl
	ld   a, (hl)
	ld   (ch2_volume), a
	pop  de
	pop  hl
	ld   a, (ch2_period)
	ld   l, a
	ret
ch3_read_note:
	push hl
	push de
	ld   ix, 0
	ld   hl, (ch3_song_ptr)
	ld   a, (hl)
	ld   l, a
	ld   h, 0
	add  hl, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	add  hl, hl
	ld   de, (envelope_data_ptr)
	add  hl, de
	ld   (ch3_env_play_ptr), hl
	ld   a, (hl)
	ld   (ch3_period), a
	ld   hl, (ch3_song_ptr)
	inc  hl
	ld   a, (hl)
	ld   (ch3_counter), a
	inc  hl
	ld   (ch3_song_ptr), hl
	exx
	ld   c, a
	exx
	pop  de
	pop  hl
	ld   a, (ch3_period)
	ld   d, a
	ret
	
	
	
song_speed:		db 0

envelope_data_ptr:	dw 0

ch1_counter:		db 0
ch2_counter:		db 0
ch3_counter:		db 0

sound_loop_cnt: 	db 0

ch1_song_ptr:		dw 0
ch2_song_ptr:		dw 0
ch3_song_ptr:		dw 0

ch1_loop_ptr:		dw 0
ch2_loop_ptr:		dw 0
ch3_loop_ptr:		dw 0

ch1_env_sel_ptr:	dw 0
ch2_env_sel_ptr:	dw 0

ch1_env_play_ptr:	dw 0
ch2_env_play_ptr:	dw 0
ch3_env_play_ptr:	dw 0

ch1_volume:		db 0
ch2_volume:		db 0

ch1_period:		db 0
ch2_period:		db 0
ch3_period:		db 0

;compiled music data

music_data:
	db 20h
	db 00
	dw .ch1
	dw .ch2
	dw .ch3
	dw .ch1loop
	dw .ch2loop
	dw .ch3loop
.envelopes:
	db 00h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh
	db 0dh,000h,01fh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh
	db 01h,002h,004h,00bh,005h,001h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh
	db 0eh,00eh,00dh,00dh,00ch,00ch,00bh,00bh,00ah,009h,008h,005h,004h,003h,003h,003h,004h,005h,008h,009h,00ah,00bh,00bh,00ch,00ch,00dh,00dh,00eh,00eh,00eh,0ffh,0ffh
	db 0eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00dh,00bh,00ah,009h,008h,007h,006h,005h,004h,003h,002h,0ffh,0ffh
	db 0fh,00fh,00fh,00fh,00eh,00eh,00eh,00eh,00dh,00dh,00dh,00ch,00ch,00ch,00bh,00bh,00ah,00ah,009h,008h,007h,005h,003h,001h,001h,001h,001h,001h,001h,001h,0ffh,0ffh
	db 04h,004h,004h,004h,004h,003h,003h,003h,003h,003h,003h,003h,003h,003h,002h,002h,002h,002h,002h,001h,001h,001h,001h,001h,000h,000h,000h,000h,000h,000h,0ffh,0ffh
	db 03h,003h,003h,003h,004h,005h,006h,007h,008h,009h,00ah,00bh,00ch,00dh,00eh,00fh,00fh,00fh,00eh,00dh,00bh,009h,007h,005h,003h,003h,002h,001h,001h,001h,0ffh,0ffh
	db 1dh,01ch,01bh,01ah,019h,018h,017h,016h,015h,014h,013h,012h,011h,010h,00fh,00eh,00dh,00ch,00bh,00ah,009h,008h,007h,006h,005h,004h,003h,002h,001h,000h,0ffh,0ffh
	db 1dh,01ch,01bh,01ah,019h,018h,017h,016h,015h,014h,013h,012h,011h,010h,00fh,00eh,00dh,00ch,00bh,00ah,009h,008h,007h,006h,005h,004h,003h,002h,001h,000h,0ffh,0ffh
	db 0dh,000h,01fh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh
	db 01h,002h,004h,00bh,005h,001h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh
	db 0eh,00eh,00dh,00dh,00ch,00ch,00bh,00bh,00ah,009h,008h,005h,004h,003h,003h,003h,004h,005h,008h,009h,00ah,00bh,00bh,00ch,00ch,00dh,00dh,00eh,00eh,00eh,0ffh,0ffh
	db 0eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00dh,00bh,00ah,009h,008h,007h,006h,005h,004h,003h,002h,0ffh,0ffh
	db 0fh,00fh,00fh,00fh,00eh,00eh,00eh,00eh,00dh,00dh,00dh,00ch,00ch,00ch,00bh,00bh,00ah,00ah,009h,008h,007h,005h,003h,001h,001h,001h,001h,001h,001h,001h,0ffh,0ffh
	db 04h,004h,004h,004h,004h,003h,003h,003h,003h,003h,003h,003h,003h,003h,002h,002h,002h,002h,002h,001h,001h,001h,001h,001h,000h,000h,000h,000h,000h,000h,0ffh,0ffh
	db 03h,003h,003h,003h,004h,005h,006h,007h,008h,009h,00ah,00bh,00ch,00dh,00eh,00fh,00fh,00fh,00eh,00dh,00bh,009h,007h,005h,003h,003h,002h,001h,001h,001h,0ffh,0ffh
	db 00h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh
	db 00h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh
.ch1:
	db 0ffh,005
	db 04ah,002
	db 04ah,001
	db 04ah,002
	db 04ah,001
	db 04ah,002
	db 054h,001
	db 054h,002
	db 054h,001
	db 054h,002
	db 054h,002
	db 04ah,002
	db 04ah,001
	db 04ah,002
	db 04ah,001
	db 04ah,002
	db 054h,001
	db 054h,002
	db 054h,001
	db 054h,002
	db 054h,002
	db 0ffh,007
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 0ffh,005
	db 04ah,001
	db 04ah,001
	db 03fh,002
	db 038h,002
	db 032h,002
	db 038h,002
	db 03fh,002
	db 038h,001
	db 032h,003
	db 038h,002
	db 03fh,004
	db 042h,004
	db 054h,006
	db 04ah,001
	db 04ah,001
	db 03fh,002
	db 038h,002
	db 032h,002
	db 038h,002
	db 03fh,002
	db 038h,001
	db 032h,003
	db 02ah,002
	db 032h,004
	db 038h,004
	db 032h,006
	db 02fh,002
	db 032h,004
	db 03fh,004
	db 04ah,006
	db 054h,004
	db 038h,004
	db 042h,002
	db 03fh,006
	db 04ah,002
	db 04ah,001
	db 04ah,002
	db 04ah,001
	db 04ah,002
	db 054h,001
	db 054h,002
	db 054h,001
	db 054h,002
	db 054h,002
	db 0ffh,007
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 04ah,001
	db 0ffh,005
	db 02ah,001
	db 02ah,001
	db 032h,001
	db 02ah,002
	db 032h,003
	db 038h,002
	db 03fh,001
	db 038h,002
	db 032h,003
	db 038h,004
	db 038h,003
	db 03fh,001
	db 038h,002
	db 038h,001
	db 032h,001
	db 038h,001
	db 03fh,001
	db 04ah,001
	db 054h,001
	db 02ah,001
	db 02ah,001
	db 032h,001
	db 02ah,002
	db 032h,003
	db 038h,002
	db 03fh,001
	db 038h,002
	db 032h,003
	db 038h,002
	db 03fh,004
	db 042h,004
	db 03fh,006
	db 0ffh,007
	db 02fh,004
	db 032h,004
	db 03fh,004
	db 04ah,004
	db 0ffh,005
	db 032h,001
	db 032h,001
	db 032h,001
	db 038h,001
	db 038h,001
	db 038h,001
	db 032h,001
	db 032h,001
	db 032h,001
	db 038h,001
	db 038h,001
	db 038h,001
	db 032h,001
	db 032h,001
	db 02ah,001
	db 02ah,001
	db 0ffh,007
	db 04ah,010h
	db 0ffh,004
	db 04ah,008
	db 042h,008
	db 054h,002
	db 054h,002
	db 032h,004
	db 038h,002
	db 03fh,004
	db 038h,002
	db 038h,002
	db 054h,002
	db 032h,004
	db 038h,002
	db 03fh,004
	db 04ah,002
	db 038h,002
	db 04ah,002
	db 032h,004
	db 038h,002
	db 03fh,004
	db 04ah,002
	db 0ffh,007
	db 04ah,010h
	db 0ffh,004
	db 054h,002
	db 054h,002
	db 032h,004
	db 038h,002
	db 03fh,004
	db 038h,002
	db 038h,002
	db 054h,002
	db 032h,004
	db 038h,002
	db 03fh,004
	db 038h,002
	db 038h,002
	db 04ah,002
	db 032h,002
	db 02fh,002
	db 032h,002
	db 038h,002
	db 03fh,004
	db 0ffh,003
	db 03fh,010h
	db 0ffh,005
	db 04ah,002
	db 04ah,002
	db 03fh,002
	db 04ah,001
	db 038h,002
	db 4ah,01	; djm
	db 035h,02
	db 032h,02
	db 02ah,02
	db 04ah,02
	db 04ah,02
	db 03fh,02
	db 04ah,01
	db 032h,02
	db 04ah,01
	db 035h,02
	db 038h,02
	db 03fh,02
	db 04ah,02
	db 04ah,02
	db 03fh,002
	db 04ah,001
	db 038h,002
	db 04ah,001
	db 035h,002
	db 032h,002
	db 02ah,002
	db 04ah,002
	db 04ah,002
	db 03fh,002
	db 04ah,001
	db 032h,002
	db 04ah,001
	db 02ch,002
	db 02ah,002
	db 027h,002
	db 054h,001
	db 04ah,001
	db 03fh,001
	db 04ah,001
	db 03fh,001
	db 038h,001
	db 032h,001
	db 02ah,002
	db 032h,001
	db 038h,001
	db 03fh,001
	db 038h,001
	db 03fh,001
	db 04ah,001
	db 054h,001
	db 04ah,002
	db 04ah,001
	db 054h,001
	db 04ah,001
	db 03fh,001
	db 038h,001
	db 03fh,001
	db 032h,001
	db 032h,001
	db 035h,001
	db 035h,001
	db 038h,001
	db 038h,001
	db 03fh,001
	db 03fh,001
	db 02ah,001
	db 032h,001
	db 02ah,001
	db 032h,001
	db 02ah,001
	db 032h,001
	db 02ah,001
	db 032h,001
	db 02ah,001
	db 032h,002
	db 038h,002
	db 03fh,003
	db 02ah,002
	db 02ah,002
	db 02ah,002
	db 02ah,001
	db 02ah,002
	db 02ah,001
	db 02ah,002
	db 02ah,002
	db 02ah,002
	db 02ah,002
	db 02ah,002
	db 02ah,002
	db 02ah,001
	db 02ah,002
	db 02ch,002
	db 02fh,002
	db 032h,014h
.ch1loop:
	db 000h,0ffh
	db 000h,000
.ch2:
	db 0ffh,005
	db 095h,002
	db 095h,001
	db 095h,002
	db 095h,001
	db 095h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,002
	db 095h,002
	db 095h,001
	db 095h,002
	db 095h,001
	db 095h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,002
	db 095h,002
	db 095h,001
	db 095h,002
	db 095h,001
	db 095h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,002
	db 095h,002
	db 095h,001
	db 095h,002
	db 095h,001
	db 095h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,002
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 095h,002
	db 095h,001
	db 095h,002
	db 095h,001
	db 095h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,002
	db 095h,002
	db 095h,001
	db 095h,002
	db 095h,001
	db 095h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,002
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 064h,001
	db 095h,002
	db 095h,001
	db 095h,002
	db 095h,001
	db 095h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,002
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 095h,001
	db 085h,001
	db 085h,001
	db 085h,001
	db 085h,001
	db 085h,001
	db 085h,001
	db 085h,001
	db 085h,001
	db 07eh,002
	db 07eh,002
	db 07eh,002
	db 07eh,001
	db 07eh,002
	db 07eh,001
	db 07eh,002
	db 07eh,001
	db 07eh,001
	db 07eh,001
	db 07eh,001
	db 0a8h,002
	db 0a8h,002
	db 0a8h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 070h,002
	db 070h,002
	db 070h,002
	db 070h,001
	db 070h,002
	db 070h,001
	db 070h,002
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 064h,001
	db 064h,001
	db 07eh,001
	db 07eh,001
	db 095h,001
	db 095h,001
	db 07eh,002
	db 07eh,002
	db 07eh,002
	db 07eh,001
	db 07eh,002
	db 07eh,001
	db 07eh,002
	db 07eh,001
	db 07eh,001
	db 07eh,001
	db 07eh,001
	db 0a8h,002
	db 0a8h,002
	db 0a8h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,001
	db 0a8h,002
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 0a8h,001
	db 070h,002
	db 070h,002
	db 070h,002
	db 070h,001
	db 070h,002
	db 070h,001
	db 070h,002
	db 070h,001
	db 070h,001
	db 070h,001
	db 070h,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 05eh,001
	db 054h,001
	db 054h,001
	db 054h,001
	db 054h,001
	db 095h,002
	db 095h,002
	db 07eh,002
	db 095h,001
	db 070h,002
	db 095h,001
	db 06ah,002
	db 064h,002
	db 064h,002
	db 095h,002
	db 095h,002
	db 07eh,002
	db 095h,001
	db 064h,002
	db 095h,001
	db 06ah,002
	db 070h,002
	db 07eh,002
	db 095h,002
	db 095h,002
	db 07eh,002
	db 095h,001
	db 070h,002
	db 095h,001
	db 06ah,002
	db 064h,002
	db 064h,002
	db 095h,002
	db 095h,002
	db 07eh,002
	db 095h,001
	db 064h,002
	db 095h,001
	db 06ah,002
	db 070h,002
	db 07eh,002
	db 095h,002
	db 095h,002
	db 07eh,002
	db 095h,001
	db 070h,002
	db 095h,001
	db 06ah,002
	db 064h,002
	db 054h,002
	db 095h,002
	db 095h,002
	db 07eh,002
	db 095h,001
	db 064h,002
	db 095h,001
	db 06ah,002
	db 070h,002
	db 07eh,002
	db 095h,002
	db 095h,002
	db 07eh,002
	db 095h,001
	db 070h,002
	db 095h,001
	db 06ah,002
	db 064h,002
	db 054h,002
	db 064h,002
	db 064h,002
	db 064h,002
	db 064h,001
	db 064h,002
	db 064h,001
	db 064h,002
	db 064h,002
	db 064h,002
	db 064h,002
	db 064h,002
	db 064h,002
	db 064h,001
	db 064h,002
	db 06ah,002
	db 070h,002
	db 07eh,014h
.ch2loop:
	db 000h,0ffh
	db 000h,000
.ch3:
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00bh,001
	db 00bh,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 000h,002
	db 00ah,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,002
	db 00ah,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 000h,002
	db 00ah,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 000h,002
	db 00ah,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00bh,001
	db 00ah,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 00bh,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 000h,002
	db 00ah,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 000h,002
	db 00ah,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 000h,002
	db 00ah,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 000h,002
	db 00ah,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 000h,002
	db 00ah,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,003
	db 00bh,001
	db 00ah,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00bh,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,003
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 00ah,001
	db 00bh,001
	db 00ah,001
	db 00ah,001
	db 00bh,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,002
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00ah,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 000h,001
	db 00bh,001
	db 00bh,001
	db 00bh,001
	db 000h,011h
.ch3loop:
	db 000h,0ffh
	db 000h,000


	END 

VARS_ADDR:
	db 80h



