; ------------------------------------------------------------------------------
;                      Pokemon G/S/C - RTC Changer patches
;       original patches by infinest can be found here: https://infine.st/
;                 disassembled with permission by Robin Bertram
; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2019  infinest
; SPDX-FileCopyrightText: 2024  Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only
; ------------------------------------------------------------------------------


SECTION "PokegearClock_Joypad: overwrite exit Buttons", ROMX[PokegearClock_Joypad_buttoncheck_], BANK[PokegearClock_Joypad_BANK]
;PokegearClock_Joypad:
;   call .UpdateClock
;   ld hl, hJoyLast
;   ld a, [hl]
PokegearClock_Joypad.buttoncheck:
;   and A_BUTTON | B_BUTTON | START | SELECT    ; <- orig code - is overwritten
    and B_BUTTON | START | SELECT               ; <- new  code
;   jr nz, .quit
;   ld a, [hl]
;   and D_RIGHT
;   ret z
;   ld a, [wPokegearFlags]
;   bit POKEGEAR_MAP_CARD_F, a
;   jr z, .no_map_card
;   ld c, POKEGEARSTATE_MAPCHECKREGION
;   ld b, POKEGEARCARD_MAP
;   jr .done
