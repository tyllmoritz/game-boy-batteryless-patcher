; Game Boy battery-less patching for bootleg cartridges
; based on BennVennElectronic's tutorial (https://www.youtube.com/watch?v=l2bx-udTN84)
; ------------------------------------------------------------------------------------
; see README file
; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2024 Marc Robledo
; SPDX-FileCopyrightText: 2024 Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------



save_sram_to_flash:
	; IF DEF(DISABLE_HW_WHEN_SAVING)
	; 	;disable screen, timer and speaker
	; 	ldh		a, [rIE]
	; 	push	af
	; 	ldh		a, [rIF]
	; 	push	af
	; 	ldh		a, [rTAC]
	; 	push	af
	; 	ldh		a, [rSTAT]
	; 	push	af
	; 	ldh		a, [rNR50]
	; 	push	af
	; 	halt 
	; 	xor  a
	; 	ld   [rIE], a
	; 	ld   [rIF], a
	; 	ld   [rTAC], a
	; 	ld   [rSTAT], a
	; 	ld   [rNR50], a
	; ENDC

	;this will be run when the game saves, will copy savegame from SRAM to Flash ROM
	di
	push	af
	push	bc
	push	de
	push	hl

	IF DEF(WRAM_BANK_NUMBER)
		ldh a,[rSMBK]
		ld b,a
		ld a,WRAM_BANK_NUMBER
		ldh [rSMBK],a
		ld a,b
		push af
	ENDC

	ld		a, BANK(erase_and_write_ram_banks)
	ld		[rROMB0], a
	call	erase_and_write_ram_banks
	IF GAME_ENGINE_CURRENT_BANK_OFFSET >= _HRAM
		ldh		a, [_current_game_bank]
	ELSE
		ld		a, [_current_game_bank]
	ENDC
	ld		[rROMB0], a

	IF DEF(WRAM_BANK_NUMBER)
		pop af
		ldh [rSMBK],a ; set to previous wram bank
	ENDC

	pop		hl
	pop		de
	pop		bc
	pop		af


	; IF DEF(DISABLE_HW_WHEN_SAVING)
	; 	;reenable screen, timer and speaker
	; 	pop		af
	; 	ldh		[rNR50], a
	; 	pop		af
	; 	ldh		[rSTAT], a
	; 	pop		af
	; 	ldh		[rTAC], a
	; 	pop		af
	; 	ldh		[rIF], a
	; 	pop		af
	; 	ldh		[rIE], a
	; ENDC

	reti

bank_switch_and_copy_from_flash_to_sram:
	;this subroutine is called by copy_save_flash_to_sram
	;we store it in bank 0 to make bank switching easier while copying from Flash ROM to SRAM
	ld		[rROMB0], a
.loop:
	ld		a, [hli]
	ld		[de], a
	inc		de
	dec		bc
	ld		a, c
	or		b
	jr		nz, .loop
	ld		a, BANK(copy_save_flash_to_sram)
	ld		[rROMB0], a
	ret




