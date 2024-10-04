; RTC Patch for Pokemon Gold
; --------------------------
; disassembled from:
; https://www.infine.st/
; https://www.romhacking.net/hacks/4450/
; --------------------------
; This patch allows the player to change the real-time clock while in the Pokegears clock menu.
; Simply press up to advance and down to turn back the time.
; Holding the A button allows you to change it faster.

; Patch to "Pokemon - Gold Version (USA, Europe) (SGB Enhanced).gbc"
; MD5: a6924ce1f9ad2228e1c6580779b23878
; SHA-1: d8b8a3600a465308c9953dfa04f0081c05bdcb94
; SHA-256: fb0016d27b1e5374e1ec9fcad60e6628d8646103b5313ca683417f52b97e7e4e

DEF FarCall EQU $8

DEF Bank0_FreeSpace_0 EQU $0051
DEF Bank0_FreeSpace_1 EQU $0063
DEF BankX_FreeSpace_1 EQU $754e
DEF BankX_FreeSpace_1_BANKNUMBER EQU $1


IF DEF(_NORTC)
DEF hJoypadDown EQU $ffa6
DEF wStartDay_ EQU $d1dc
DEF wScriptFlags EQU $d15b
DEF wSpriteAnimAddrBackup EQU $c5c0
DEF wSpriteAnimAddrBackup_Value EQU $c5
DEF wJumptableIndex EQU $ce63

DEF UpdateTime_FixTime_ EQU $046d
DEF FixTime_ EQU $04de
DEF PokegearClock_Joypad_buttoncheck_ EQU $4f0e
DEF PokegearClock_Joypad_BANK EQU $24
ENDC


IF DEF(_BATTERYLESS)
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
DEF GAME_BOOT_OFFSET EQU $05c6



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
DEF BANK0_FREE_SPACE EQU $70



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
DEF WRAM_FREE_SPACE EQU $c300 ;using Shadow OAM for now
; DEF WRAM_BANK_NUMBER EQU $1



; NEW CODE LOCATION
; -----------------
; We need ~80 bytes (~0x50 bytes) to store our new battery-less save code.
; As stated above, they will be copied from ROM to WRAM0 when trying to save.
DEF BATTERYLESS_CODE_BANK EQU $1
DEF BATTERYLESS_CODE_OFFSET EQU $7640



; GAME ENGINE'S CURRENT BANK BACKUP LOCATION
; ------------------------------------------
; Games usually store the current ROM bank number in RAM or HRAM, so they can
; restore the correct bank when switching back from VBlank.
; We will reuse that byte when switching to our battery-less code bank and,
; afterwards, so we can restore to the previous bank.
DEF GAME_ENGINE_CURRENT_BANK_OFFSET EQU $ff9f



; SAVEGAME LOCATION IN FLASH ROM
; ------------------------------
; Starting Flash ROM bank where savegame data will be saved.
; IMPORTANT: It must be an entire 64kb flashable block!
; If the game has not a free 64kb block, just use a bank bigger than the
; original ROM and RGBDS will expand the ROM and fix the header automatically.
DEF BANK_FLASH_DATA EQU $80



; EMBED CUSTOM SAVEGAME
; ---------------------
; Just place a sav file next to the input ROM - with the extension .sav instead of .gbc
; If a sav file is present, it will be included into the batteryless ROM.



; ORIGINAL SAVE SUBROUTINE
; ------------------------
; We need to find the original game's saving subroutine and hook our new code
; afterwards.
SECTION "Original call #1 to _SaveGameData", ROMX[$4c23], BANK[$05]
;call	$4ccc ; _SaveGameData
call	save_sram_hook
SECTION "Original call #2 to _SaveGameData", ROMX[$4ca2], BANK[$05]
;call	$4ccc ; _SaveGameData
call	save_sram_hook

SECTION "Save SRAM hook", ROM0[$00F0]
save_sram_hook:
	;original code
	call	$4ccc ; _SaveGameData
	;new code
	call	save_sram_to_flash
	ret

ENDC
