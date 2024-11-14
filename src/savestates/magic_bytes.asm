RAM_SHARING_MAGIC_BYTES:
    DB "SRAM_CFG"
    DB SAVE_STATE_RAM_BANK
    IF DEF(is_cgb)
        DB save_state_vram_bank_0
    ELSE
        DB SAVE_STATE_RAM_BANK_VRAM
    ENDC
    IF DEF(game_uses_save_ram)
        DB SAVE_STATE_SRAM_BANK_0
    ENDC
SAVE_STATE_PATCH_MAGIC_BYTES:
    DB "SSPMB"
