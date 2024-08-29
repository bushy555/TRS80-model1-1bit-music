

Selection of 1-bit music players and their tunes for the TRS-80 model 1-3 computers.
These have been converted over from the ZX Spectrum computer; most have been written by Shiru, Utz & Tim Follin, Oleg.

Some of these are a bit 'iffy' due to the large variation between the ZX Spectrum 3.5Mhz clock speed and the TRS-80's 1.7Mhz. As well as some players are specifically written for the ZX and refuse to play nicely with other z80 computers.

Please try : OctodeXL_Dance , as this may be the one of the better sounding tunes out of the lot. The Huby's are also relativiy clean.

.ASM source code,  .CMD & .CAS file for Emulators,  .WAV for real hardware.


All have been assembled to $6000, with the sound being output to the cassette port. Assembled with either Pasmo or SJASMplus to a binary, then the .BIN file converted to .CMD, .CAS and .WAV with the utility : TRS80-TOOL.EXE

All of these have been tested within the TRS80 emulator TRS80GP v2.5.3, with model 1 selected, which allows the cassette port to be audible within the emulator itself. The .CMD files can simply be loaded straight into the emulator via file --> run --> *.CMD
For real hardware, connect an amplified speaker up to the cassette out jack.



TRS-80 audio Info:
Cassette port	:  $FF
Bits		:  0, 1
	 
	ORG	$6000

	XOR	2
	OUT	(255), A

