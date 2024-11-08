; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2024 Marc Robledo
; SPDX-FileCopyrightText: 2024 Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------


; hook game's boot and execute our boot_hook subroutine beforehand
PUSHS
IF DEF(GAME_BOOT_OFFSET)
	SECTION "ROM - Entry point", ROM0[$0100]
	nop
	;jp		boot_original
	jp		boot_hook

	SECTION "ROM - Original game boot", ROM0[GAME_BOOT_OFFSET]
	boot_original:
ENDC
POPS

IF DEF(GAME_BOOT_OFFSET)
	boot_hook:
		;this will be run during boot, will copy savegame from Flash ROM to SRAM
		push	af
		ld		a, BANK(copy_save_flash_to_sram)
		ld		[rROMB0], a
		IF DEF(_BATTERYLESS)
			call	copy_save_flash_to_sram
		ENDC
		ld		a, 1
		ld		[rROMB0], a
		pop		af
		jp		boot_original
ENDC