; ------------------------------------------------------------------------------
;                      Pokemon G/S/C - RTC Changer patches
;       original patches by infinest can be found here: https://infine.st/
;                 disassembled with permission by Robin Bertram
; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2019  infinest
; SPDX-FileCopyrightText: 2024  Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only
; ------------------------------------------------------------------------------



MACRO farcall ; bank, address
	ld a, BANK(\1)
	ld hl, \1
	rst FarCall
ENDM

ChangeTimeInPokegear::
	farcall _ChangeTimeInPokegear
	ret
