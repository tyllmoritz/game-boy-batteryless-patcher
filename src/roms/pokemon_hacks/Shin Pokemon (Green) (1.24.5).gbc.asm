; ------------------------------------------------------------------------------
;                           Shin Pokemon (Green)
;         find hack here: https://www.romhacking.net/hacks/8189/
;         source: https://github.com/jojobear13/shinpokered
;         patch:  https://github.com/jojobear13/shinpokered/releases/tag/1.24.5
; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2024 Marc Robledo
; SPDX-FileCopyrightText: 2024 Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------
;
; ROM "Shin Pokemon (Green) (1.24.5).gbc"
; SHA1 ece5a732cbaaf268b23f9d946b4ad43ae3784440
;
; builds "batteryless/Shin Pokemon (Green) (1.24.5) (batteryless).gbc" with _BATTERYLESS
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



; GAME BOOT OFFSET
; ----------------
; Put here the game's boot jp offset found in in 0:0101.
; Usually $0150, but could be different depending on game.
DEF GAME_BOOT_OFFSET EQU $0150



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
DEF BANK0_FREE_SPACE EQU $0000



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
DEF WRAM_FREE_SPACE EQU $c340 ;using Shadow OAM for now
; DEF WRAM_BANK_NUMBER EQU $1

IF DEF(_BATTERYLESS)

; NEW CODE LOCATION
; -----------------
; We need ~80 bytes (~0x50 bytes) to store our new battery-less save code.
; As stated above, they will be copied from ROM to WRAM0 when trying to save.
DEF BATTERYLESS_CODE_BANK EQU $3f
DEF BATTERYLESS_CODE_OFFSET EQU $7b00



; GAME ENGINE'S CURRENT BANK BACKUP LOCATION
; ------------------------------------------
; Games usually store the current ROM bank number in RAM or HRAM, so they can
; restore the correct bank when switching back from VBlank.
; We will reuse that byte when switching to our battery-less code bank and,
; afterwards, so we can restore to the previous bank.
DEF GAME_ENGINE_CURRENT_BANK_OFFSET EQU $ffb9



; SAVEGAME LOCATION IN FLASH ROM
; ------------------------------
; Starting Flash ROM bank where savegame data will be saved.
; IMPORTANT: It must be an entire 64kb flashable block!
; If the game has not a free 64kb block, just use a bank bigger than the
; original ROM and RGBDS will expand the ROM and fix the header automatically.
DEF BANK_FLASH_DATA EQU $40



; EMBED CUSTOM SAVEGAME
; ---------------------
; Just place a sav file next to the input ROM - with the extension .sav instead of .gbc
; If a sav file is present, it will be included into the batteryless ROM.



; ORIGINAL SAVE SUBROUTINE
; ------------------------
; We need to find the original game's saving subroutine and hook our new code
; afterwards.
SECTION "Original save SRAM subroutine end", ROMX[$7a06],BANK[$1c]
;call    $7939
call    save_sram_hook
ret

SECTION "Save SRAM hook", ROMX[$7ff0],BANK[$1c]
save_sram_hook:
    ;original code
    call    $7939
    
    ;new code
    jp    save_sram_to_flash

ENDC
