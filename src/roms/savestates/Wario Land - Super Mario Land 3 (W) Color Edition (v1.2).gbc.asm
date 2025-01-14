; md5 ee6bcaa3ff5b992bac378591a02b2e6f

; ROMBANKS 64
; ROM "Wario Land - Super Mario Land 3 (W) Color Edition (v1.2).gbc"
; SHA1 239f0129d21250e3c6976229435161e6862dc334
; builds "savestates/Wario Land - Super Mario Land 3 (W) Color Edition (v1.2) (savestates).gbc" with _SAVESTATES


; config
DEF is_cgb EQU 1
DEF current_rom_bank EQU $a8c5
DEF game_uses_save_ram EQU 1
DEF uses_mbc5 EQU 1


; joypad
DEF joypad EQU $ff80
DEF joypad_2 EQU $ff81

SECTION "joypad read", ROM0[$11f0] ; length: $20
    INCLUDE "src/savestates/call_relocated_read_from_joypad_in_other_bank.asm"
    ret
ENDSECTION


; save/load state
SECTION "save/load state", ROMX[$5C01], BANK[$0011] ; length: $0315
    DB "--- Save Patch ---"
    INCLUDE "src/savestates/joypad_read_and_check.asm"
    INCLUDE "src/savestates/save_state_includes.asm"
ENDSECTION

; Generated with patch-builder.py
