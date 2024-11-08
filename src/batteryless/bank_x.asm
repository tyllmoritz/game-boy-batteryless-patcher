; Game Boy battery-less patching for bootleg cartridges
; based on BennVennElectronic's tutorial (https://www.youtube.com/watch?v=l2bx-udTN84)
; ------------------------------------------------------------------------------------
; see README file
; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2024 Marc Robledo
; SPDX-FileCopyrightText: 2024 Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------


copy_save_flash_to_sram:
	;copy code from Flash ROM to SRAM, this is executed during game's intercepted boot
	ld		a, CART_SRAM_ENABLE
	ld		[rRAMG], a ;enable SRAM

	xor		a
	ld		[rRAMB], a ;set RAM bank 0
	ld		hl, $4000 ;source (Flash ROM)
	ld		de, _SRAM ;target (SRAM)
	ld		bc, $2000 ;size
	ld		a, BANK_FLASH_DATA ;set source ROM bank
	call	bank_switch_and_copy_from_flash_to_sram

	IF SRAM_SIZE_32KB
		;8kb-16kb
		ld		a, 1
		ld		[rRAMB], a ;set RAM bank 1
		;hl is $6000 here
		ld		de, _SRAM ;target (SRAM)
		ld		bc, $2000 ;size
		ld		a, BANK_FLASH_DATA ;set source ROM bank
		call	bank_switch_and_copy_from_flash_to_sram

		;16kb-24kb
		ld		a, 2
		ld		[rRAMB], a ;set RAM bank 2
		ld		hl, $4000 ;source (Flash ROM)
		ld		de, _SRAM ;target (SRAM)
		ld		bc, $2000 ;size
		ld		a, BANK_FLASH_DATA + 1 ;set source ROM bank
		call	bank_switch_and_copy_from_flash_to_sram

		;24kb-32kb
		ld		a, 3
		ld		[rRAMB], a ;set RAM bank 3
		;hl is $6000 here
		ld		de, _SRAM ;target (SRAM)
		ld		bc, $2000 ;size
		ld		a, BANK_FLASH_DATA + 1 ;set source ROM bank
		call	bank_switch_and_copy_from_flash_to_sram
	ENDC

	ld		a, CART_SRAM_DISABLE
	ld		[rRAMG], a ;disable SRAM
	
	ret



;parameters:
; - hl: source
; - de: target
; - bc: size
copy_data:
.loop:
	ld		a, [hli]
	ld		[de], a
	inc		de
	dec		bc
	ld		a, c
	or		b
	jr		nz, .loop
	ret


erase_and_write_ram_banks:
	;safe to be run from ROM, since it will copy the needed subroutines to RAM and call them there

	;ld a, BOOTLEG_CARTRIDGE_TYPE
	ld		hl, bootleg_read_identifier
	ld		de, wram_bootleg_read_identifier
	ld		bc, bootleg_read_identifier.end - bootleg_read_identifier
	call	copy_data
	call	wram_bootleg_read_identifier
	ld [WRAM_FREE_SPACE], a
	cp a, $0
	jr nz, .bootleg_detected
	ret
.bootleg_detected

	;erase 64kb block
	ld		hl, erase_one_flash_erase_block
	ld		de, wram_erase_one_flash_erase_block
	ld		bc, erase_one_flash_erase_block.end - erase_one_flash_erase_block
	call	copy_data
	; patch code for bootleg_cartridge_type
	ld a, [WRAM_FREE_SPACE]
	bit 1, a
	jr z, .AA_cartridge_1
	ld a, $3
	ld [wram_erase_one_flash_erase_block.set_bootleg_cartridge_swapped_datalines + 1], a
.AA_cartridge_1
	ld a, [WRAM_FREE_SPACE]
	bit 2, a
	jr z, .AAA_cartridge_1
	ld		hl, erase_one_flash_erase_block_555_code
	ld		de, wram_erase_one_flash_erase_block.bootleg_code
	ld		bc, erase_one_flash_erase_block_555_code.end - erase_one_flash_erase_block_555_code
	call	copy_data
.AAA_cartridge_1
	; run code from wram
	call	wram_erase_one_flash_erase_block
	nop

	;write
	ld		hl, write_sram_to_flash_rom
	ld		de, wram_write_sram_to_flash_rom
	ld		bc, write_sram_to_flash_rom.end - write_sram_to_flash_rom
	call	copy_data
	; patch code for bootleg_cartridge_type
	ld a, [WRAM_FREE_SPACE]
	bit 1, a
	jr z, .AA_cartridge_2
	ld a, $3
	ld [wram_write_sram_to_flash_rom.set_bootleg_cartridge_swapped_datalines + 1], a
.AA_cartridge_2
	ld a, [WRAM_FREE_SPACE]
	bit 2, a
	jr z, .AAA_cartridge_2
	ld		hl, write_sram_to_flash_rom_555_code
	ld		de, wram_write_sram_to_flash_rom.bootleg_code
	ld		bc, write_sram_to_flash_rom_555_code.end - write_sram_to_flash_rom_555_code
	call	copy_data
.AAA_cartridge_2
	call	wram_write_sram_to_flash_rom
	nop

	IF SRAM_SIZE_32KB
		REPT 7 - 1
			nop ;some dummy nops to guarantee correct flashing, might not be needed?
		ENDR

		;8kb-16kb
		;edit subroutine directly in RAM, changing some values
		ld		a, HIGH($6000)
		ld		[wram_write_sram_to_flash_rom.set_destination_offset + 2], a ;destination ROM offset=$6000
		ld		a, 1
		ld		[wram_write_sram_to_flash_rom.set_source_copy_bank + 1], a ;source SRAM bank=1
		call	wram_write_sram_to_flash_rom
		nop
		REPT 7 - 1
			nop ;some dummy nops to guarantee correct flashing, might not be needed?
		ENDR

		;16kb-24kb
		;edit subroutine directly in RAM, changing some values
		ld		a, BANK_FLASH_DATA + 1
		ld		[wram_write_sram_to_flash_rom.set_destination_bank + 1], a ;destination ROM bank=BANK_FLASH_DATA + 1
		ld		a, HIGH($4000)
		ld		[wram_write_sram_to_flash_rom.set_destination_offset + 2], a ;destination ROM offset=$4000
		ld		a, 2
		ld		[wram_write_sram_to_flash_rom.set_source_copy_bank + 1], a ;source SRAM bank=2
		call	wram_write_sram_to_flash_rom
		nop
		REPT 7 - 1
			nop ;some dummy nops to guarantee correct flashing, might not be needed?
		ENDR

		;24kb-32kb
		;edit subroutine directly in RAM, changing some values
		ld		a, HIGH($6000)
		ld		[wram_write_sram_to_flash_rom.set_destination_offset + 2], a ;destination ROM offset=$6000
		ld		a, 3
		ld		[wram_write_sram_to_flash_rom.set_source_copy_bank + 1], a ;source SRAM bank=3
		call	wram_write_sram_to_flash_rom
		nop
	ENDC

	ret

erase_one_flash_erase_block:
IF DEF(WRAM_BANK_NUMBER)
LOAD UNION "WRAM Code", WRAMX[WRAM_FREE_SPACE + 1], BANK[WRAM_BANK_NUMBER]
ELSE
LOAD UNION "WRAM Code", WRAM0[WRAM_FREE_SPACE + 1]
ENDC
wram_erase_one_flash_erase_block:

.set_bootleg_cartridge_swapped_datalines
	ld		b, $0

	ld		a, BANK_FLASH_DATA
	ld		[rROMB0], a
	nop

	ld		a, $f0
	ld		[$4000], a

.bootleg_code
	ld		a, $aa
	xor		a, b
	ld		[$0aaa], a

	ld		a, $55
	xor		a, b
	ld		[$0555], a
	nop

	ld		a, $80
	ld		[$0aaa], a

	ld		a, $aa
	xor		a, b
	ld		[$0aaa], a

	ld		a, $55
	xor		a, b
	ld		[$0555], a

	nop

	ld		a, $30
	ld		[$4000], a
	nop

.loop:
	ld		a, [$4000]
	cp		a, $ff
	jr		z, .end
	jr		.loop
	;jr		nz, .loop ;possible optimization? to-do: test if it's not breaking anything
.end:
	nop

	ld		a, $f0
	ld		[rRAMB], a
	ld		a, BANK_X_FREE_SPACE_BANK
	ld		[rROMB0], a
	ret
ENDL
.end




write_sram_to_flash_rom:
IF DEF(WRAM_BANK_NUMBER)
LOAD UNION "WRAM Code", WRAMX[WRAM_FREE_SPACE + 1], BANK[WRAM_BANK_NUMBER]
ELSE
LOAD UNION "WRAM Code", WRAM0[WRAM_FREE_SPACE + 1]
ENDC
wram_write_sram_to_flash_rom:
.set_destination_bank:
	ld		a, BANK_FLASH_DATA
	ld		[rROMB0], a
	ld		hl, _SRAM
.set_destination_offset:
	ld		de, $4000
.loop:
	ld		a, CART_SRAM_ENABLE
	ld		[rRAMG], a ;enable SRAM

	;RTC (not needed?)
	;ld		a, 1
	;ld		[$6000], a
	
.set_source_copy_bank:
	IF SRAM_SIZE_32KB
		ld		a, $00 ;so we can replace $00 with following block indexes later
	ELSE
		xor		a
	ENDC
	ld		[rRAMB], a
	ld		a, [hl]
	ld		b, a

	xor		a

.set_bootleg_cartridge_swapped_datalines
	ld		c, $0

	;RTC (not needed?)
	;ld		[$6000], a

	ld		[rRAMG], a ;disable SRAM
	ld		a, $f0
	ld		[rRAMB], a

.bootleg_code
	ld		a, $aa
	xor		a, c
	ld		[$0aaa], a

	ld		a, $55
	xor		a, c
	ld		[$0555], a

	nop
	ld		a, $a0
	ld		[$0aaa], a
	nop

	ld		a, b
	ld		[de], a
.unknown_small_loop:
	ld		a, [de]
	xor		b
	jr		z, .skip
	nop
	jr		.unknown_small_loop
.skip:
	inc		hl
	inc		de
	ld		a, h
	cp		a, $c0
	jr		nz, .loop

	ld		a, $f0
	ld		[rRAMB], a
	ld		a, BANK_X_FREE_SPACE_BANK
	ld		[rROMB0], a

	ret
ENDL
.end

erase_one_flash_erase_block_555_code:
	ld		a, $aa
	xor		a, b
	ld		[$0555], a

    ld		a, $55
	xor		a, b
    ld		[$02aa], a
	nop

    ld		a, $80
    ld		[$0555], a

    ld		a, $aa
	xor		a, b
    ld		[$0555], a

    ld		a, $55
	xor		a, b
    ld		[$02aa], a
.end

write_sram_to_flash_rom_555_code:
	ld		a, $aa
	xor		a, c
	ld		[$0555], a

	ld		a, $55
	xor		a, c
	ld		[$02aa], a

	nop
	ld		a, $a0
	ld		[$0555], a
	nop
.end

bootleg_read_identifier:
	IF DEF(WRAM_BANK_NUMBER)
	LOAD UNION "WRAM Code", WRAMX[WRAM_FREE_SPACE + 1], BANK[WRAM_BANK_NUMBER]
	ELSE
	LOAD UNION "WRAM Code", WRAM0[WRAM_FREE_SPACE + 1]
	ENDC
wram_bootleg_read_identifier:
	ld a,[$0000]
	ld h,a ; the content of $0000 should not be equal to the manufacturer ids

	; detect WRAAAA9_64KB cart
	ld a,$F0
	ld [$0000],a
	nop
	ld a,$A9
	ld [$0AAA],a
	nop
	ld a,$56
	ld [$0555],a
	nop
	ld a,$90
	ld [$0AAA],a
	nop
	
	ld a,[$0000]
	cp h
	jp z, .not_cartridgetype_WRAAAA9_64KB
	ld a,$F0
	ld [$0000],a
	ld a,WRAAAA9_64KB
	ret
	
	.not_cartridgetype_WRAAAA9_64KB
	; detect 555/A9 cart
	ld a,$F0
	ld [$0000],a
	nop
	ld a,$A9
	nop
	ld [$0555],a
	nop
	ld a,$56
	nop
	ld [$02AA],a
	nop
	ld a,$90
	ld [$0555],a
	nop
	
	ld a,[$0000]
	cp h
	jp z, .not_cartridgetype_WR555A9_64KB
	ld a,$F0
	ld [$0000],a
	ld a,WR555A9_64KB
	ret
	
	.not_cartridgetype_WR555A9_64KB
	
	; detect AAA/AA cart
	ld a,$F0
	ld [$0000],a
	nop
	ld a,$AA
	ld [$0AAA],a
	nop
	ld a,$55
	ld [$0555],a
	nop
	ld a,$90
	ld [$0AAA],a
	nop
	
	ld a,[$0000]
	cp h
	jp z, .not_cartridgetype_WRAAAAA_64KB
	ld a,$F0
	ld [$0000],a
	ld a,WRAAAAA_64KB
	ret
	
	.not_cartridgetype_WRAAAAA_64KB
	
	; detect 555/AA cart
	ld a,$F0
	ld [$0000],a
	nop
	ld a,$AA
	ld [$0555],a
	nop
	ld a,$55
	ld [$02AA],a
	nop
	ld a,$90
	ld [$0555],a
	nop
	
	ld a,[$0000]
	cp h
	jp z, .not_cartridgetype_WR555AA_64KB
	ld a,$F0
	ld [$0000],a
	ld a,WR555AA_64KB
	ret
	
	.not_cartridgetype_WR555AA_64KB
	ld a,$F0
	ld [$0000],a
	ld a,$0 ; no compatible cartridge detected
	ret
ENDL
.end
