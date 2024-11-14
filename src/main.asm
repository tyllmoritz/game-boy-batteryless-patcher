; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2024 Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------


; ------------- DEFINITIONS --------------
; include definitions
INCLUDE "src/hardware.inc" ;https://github.com/gbdev/hardware.inc
IF DEF(GAME_ENGINE_CURRENT_BANK_OFFSET)
INCLUDE "src/game_engine_current_bank.asm"
ENDC
IF DEF(_NORTC)
INCLUDE "src/rtc/buttons.inc"
INCLUDE "src/rtc/wram.asm"
ENDC
IF DEF(_BATTERYLESS)
INCLUDE "src/batteryless/bootleg_types.inc"
ENDC

; ---------------- HEADER ----------------
; modify game header if needed
IF DEF(uses_mbc5)
    DEF CHANGE_CART_TYPE EQU CART_ROM_MBC5_RAM_BAT
ELIF DEF(_SAVESTATES)
    DEF CHANGE_CART_TYPE EQU CART_ROM_MBC1_RAM_BAT
ENDC
IF DEF(CHANGE_CART_TYPE)
	SECTION "Header: Cart type", ROM0[$0147]
	DB CHANGE_CART_TYPE
ENDC
IF DEF(CHANGE_CART_SIZE)
	SECTION "Header: Cart size", ROM0[$0148]
	DB CHANGE_CART_SIZE
ENDC
IF DEF(RAMSIZE)
	SECTION "ram size", ROM0[$0149]
    DB RAMSIZE
ENDC
SECTION "Header: checksums", ROM0[$014d]
    DB $00, $00, $00 ; zero out to stop warning from rgbfix
ENDSECTION


; --------------- BANK 0 -----------------
IF DEF(BANK0_FREE_SPACE)
SECTION "ROM - Bank 0 - Free Space", ROM0[BANK0_FREE_SPACE]
IF DEF(_BATTERYLESS)
	INCLUDE "src/boot_hook.asm" ; hook to inject code at boot
	INCLUDE "src/batteryless/bank_0.asm"
ENDC
IF DEF(_NORTC)
	INCLUDE "src/rtc/bank_0.asm"
ENDC
ENDC


; --------------- BANK X -----------------
IF DEF(BANK_X_FREE_SPACE_OFFSET)
SECTION "ROM - Free space", ROMX[BANK_X_FREE_SPACE_OFFSET], BANK[BANK_X_FREE_SPACE_BANK]
IF DEF(_BATTERYLESS)
	INCLUDE "src/batteryless/bank_x.asm"
ENDC
IF DEF(_NORTC)
	INCLUDE "src/rtc/bank_x.asm"
ENDC
ENDC


; ------ ADDITIONAL CHANGES TO ROM -------
IF DEF(_BATTERYLESS)
INCLUDE "src/batteryless/embed_savegame.asm"
ENDC
IF DEF(_NORTC)
INCLUDE "src/rtc/hook_in_updatetime.asm"
INCLUDE "src/rtc/pokegear_dont-quit_on-A-button.asm"
ENDC
