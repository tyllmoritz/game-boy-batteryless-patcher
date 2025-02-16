; ------------------------------------------------------------------------------
;                Battery-less patch for Pokemon Prism (v0.95.0254)
;             (find hack here: https://rainbowdevs.com/title/prism/)
; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2024 Marc Robledo
; SPDX-FileCopyrightText: 2024 Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------
;
; ROM "Pokemon - Prism (v0.95.0254).gbc"
; SHA1 752076692ae3387cf426ce5f51a98c6b60e8df6a
;
; builds "batteryless/Pokemon - Prism (v0.95.0254) (batteryless).gbc" with _BATTERYLESS
;
; ------------------------------------------------------------------------------


; CARTRIDGE TYPE AND ROM SIZE
; ---------------------------
; Usually, it's safe to keep the same original game's ROM type and size, since
; RGBDS will automatically fix the ROM's header if we expand it for the
; savegame.
; Uncomment the following constants if you want to manually specify cartridge
; type and/or size:
; DEF CHANGE_CART_TYPE EQU CART_ROM_MBC5_RAM_BAT
; DEF CHANGE_CART_SIZE EQU CART_ROM_2048KB ;128 banks



; SRAM ORIGINAL SIZE
; ------------------
; Set to 1 if game's original SRAM is 32kb
DEF SRAM_SIZE_32KB EQU 1

IF DEF(_BATTERYLESS)

; GAME BOOT OFFSET
; ----------------
; we are not defining GAME_BOOT_OFFSET, we are coding our custom hook for the
; entry point, since this hack does not use the common nop+jp entry point
SECTION "ROM - Entry point", ROM0[$0100]
; original code
; ldh		[$ffe6], a
; jr		$016c
nop
jp		boot_hook

SECTION "ROM - Custom entry point", ROM0[$3fa0]
boot_hook:
	;this will be run during boot, will copy savegame from Flash ROM to SRAM
	push	af
	ld		a, BANK(copy_save_flash_to_sram)
	ld		[rROMB0], a
	call	copy_save_flash_to_sram
	ld		a, 1
	ld		[rROMB0], a
	pop		af

	;original entry point code
	ldh		[$ffe6], a	
	jp		$016c



; BANK 0 ROM FREE SPACE
; ---------------------
; We need ~60 bytes (~0x3c bytes) in bank 0 for our new subroutines:
; - new boot: will read savegame from Flash ROM and write to SRAM during boot
; - new save/erase: will copy SRAM to Flash ROM when saving game
; - copying helper subroutine
; Hopefully, there should be enough space at the end of bank 0.
; If there is not enough space there, check $0070-$0100, some games didn't
; store anything there.
; In the worst scenario, you will need to carefully move some code/data to
; other banks.
DEF BANK0_FREE_SPACE EQU $3fc0



; RAM FREE SPACE
; --------------
; Bootleg's Flash ROM reading is locked when trying to write to it, so we need
; to store and run our new subroutines in WRAM instead of ROM.
; We need ~80 bytes (~0x50 bytes).
; Check which WRAM sections are safe to write with a debugger.
; If the game uses some compression or temporary section to store data, that
; should be safe to use.
; In the worst scenario, use shadow OAM space. It will just glitch sprites for
; a single frame.
; If it's a color-only game, $d000-$dfff is banked.
; Therefore you have to add a WRAM_BANK_NUMBER to use this address space.
; Additionaly - the Stack has to be in WRAM0 $c000-$cfff for this to work
DEF WRAM_FREE_SPACE EQU $d997
DEF WRAM_BANK_NUMBER EQU $2



; NEW CODE LOCATION
; -----------------
; We need ~80 bytes (~0x50 bytes) to store our new battery-less save code.
; As stated above, they will be copied from ROM to WRAM0 when trying to save.
DEF BATTERYLESS_CODE_BANK EQU $80
DEF BATTERYLESS_CODE_OFFSET EQU $4000



; GAME ENGINE'S CURRENT BANK BACKUP LOCATION
; ------------------------------------------
; Games usually store the current ROM bank number in RAM or HRAM, so they can
; restore the correct bank when switching back from VBlank.
; We will reuse that byte when switching to our battery-less code bank and,
; afterwards, so we can restore to the previous bank.
DEF GAME_ENGINE_CURRENT_BANK_OFFSET EQU $ff9d



; SAVEGAME LOCATION IN FLASH ROM
; ------------------------------
; Starting Flash ROM bank where savegame data will be saved.
; IMPORTANT: It must be an entire 64kb flashable block!
; If the game has not a free 64kb block, just use a bank bigger than the
; original ROM and RGBDS will expand the ROM and fix the header automatically.
DEF BANK_FLASH_DATA EQU $84



; EMBED CUSTOM SAVEGAME
; ---------------------
; Just place a sav file next to the input ROM - with the extension .sav instead of .gbc
; If a sav file is present, it will be included into the batteryless ROM.



; ORIGINAL SAVE SUBROUTINE
; ------------------------
; We need to find the original game's saving subroutine and hook our new code
; afterwards.
SECTION "Original save SRAM subroutine end", ROMX[$4d71], BANK[5]
;call	$4df3
call	save_sram_hook

SECTION "Save SRAM hook", ROMX[$7ff8], BANK[5]
save_sram_hook:
	;original code
	call	$4df3
	
	;new code
	jp	save_sram_to_flash

ENDC
