; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2024 Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------

INCLUDE "src/header.asm"


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


; ---------- WRAM/HRAM/SRAM --------------
IF DEF(_NORTC)
INCLUDE "src/rtc/wram.asm"
ENDC
IF DEF(GAME_ENGINE_CURRENT_BANK_OFFSET)
INCLUDE "src/game_engine_current_bank.asm"
ENDC
