; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2024 Marc Robledo
; SPDX-FileCopyrightText: 2024 Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------



; --------------- RAM/HRAM ---------------
; define section and label for game's current bank byte
IF GAME_ENGINE_CURRENT_BANK_OFFSET >= _HRAM
	SECTION "HRAM - original game's bank switch backup", HRAM[GAME_ENGINE_CURRENT_BANK_OFFSET]
ELIF GAME_ENGINE_CURRENT_BANK_OFFSET >= _RAMBANK
	SECTION "WRAMX - original game's bank switch backup", WRAMX[GAME_ENGINE_CURRENT_BANK_OFFSET], BANK[1]
ELIF GAME_ENGINE_CURRENT_BANK_OFFSET >= _RAM
	SECTION "WRAM0 - original game's bank switch backup", WRAM0[GAME_ENGINE_CURRENT_BANK_OFFSET]
ELSE
	SECTION "SRAM - original game's bank switch backup", SRAM[GAME_ENGINE_CURRENT_BANK_OFFSET], BANK[0]
ENDC

_current_game_bank:
	DB