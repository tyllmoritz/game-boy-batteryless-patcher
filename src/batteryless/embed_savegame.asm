; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2024 Marc Robledo
; SPDX-FileCopyrightText: 2024 Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------


IF !DEF(EMBED_SAVEGAME)
    DEF EMBED_SAVEGAME EQUS "\"src/empty_savegame.sav\""
ENDC
; ----------- Embed savegame ------------
IF DEF(EMBED_SAVEGAME)
	SECTION "Flash ROM - Embed savegame (first 16kb)", ROMX[$4000], BANK[BANK_FLASH_DATA]
	INCBIN EMBED_SAVEGAME, 0, 8192
	IF SRAM_SIZE_32KB
		INCBIN EMBED_SAVEGAME, 8192, 8192
		SECTION "Flash ROM - Embed savegame (last 16kb)", ROMX[$4000], BANK[BANK_FLASH_DATA + 1]
		INCBIN EMBED_SAVEGAME, 16384, 16384
	ENDC
ENDC