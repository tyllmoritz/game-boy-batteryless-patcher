; ------------------------------------------------------------------------------
;                      Pokemon G/S/C - RTC Changer patches
;       original patches by infinest can be found here: https://infine.st/
;                 disassembled with permission by Robin Bertram
; ------------------------------------------------------------------------------
; GPLv3 Licence
;
; Copyright (C) 2019  infinest
; Copyright (C) 2024  Robin Bertram
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
; ------------------------------------------------------------------------------


MACRO farcall ; bank, address
	ld a, BANK(\1)
	ld hl, \1
	rst FarCall
ENDM


DEF A_BUTTON   EQU 1 << 0
DEF B_BUTTON   EQU 1 << 1
DEF SELECT     EQU 1 << 2
DEF START      EQU 1 << 3
DEF D_RIGHT    EQU 1 << 4
DEF D_LEFT     EQU 1 << 5
DEF D_UP       EQU 1 << 6
DEF D_DOWN     EQU 1 << 7


SECTION "WRAM - Time", WRAMX[wStartDay_], BANK[$1]
; init time set at newgame
wStartDay::    db
wStartHour::   db
wStartMinute:: db
wStartSecond:: db

SECTION "ROM - Bank 0 free space #0", ROM0[Bank0_FreeSpace_0]
FixAndUpdateTime:
call FixTime                 ; orig unmodified function
jp UpdateTime.afterFixTime   ; in UpdateTime (after our modified call to FixTime - run farcall GetTimeOfDay, then ret)


SECTION "ROM - Bank 0 free space #1", ROM0[Bank0_FreeSpace_1]
ChangeTimeInPokegear::
ld a, BANK(_ChangeTimeInPokegear)
ld hl, _ChangeTimeInPokegear
rst 8
ret


SECTION "ROM - Bank X free space #1", ROMX[BankX_FreeSpace_1], BANK[BankX_FreeSpace_1_BANKNUMBER]

_ChangeTimeInPokegear::

ld hl,FixAndUpdateTime
ld a,[wScriptFlags]
cp a,4
jr z,.continue1          ; continue or
jp hl               ; jump to FixAndUpdateTime

.continue1:
ld a,[wSpriteAnimAddrBackup + 1]
cp a,wSpriteAnimAddrBackup_Value
jr z,.continue2          ; continue or
jp hl               ; jump to FixAndUpdateTime

.continue2:
ld a,[wJumptableIndex]
cp a,1
jr z,.checkAButton  ; continue or
jp hl               ; jump to FixAndUpdateTime

.checkAButton:
ld b,1
ldh a,[hJoypadDown]
and a,A_BUTTON
jr z,.checkUpButton
ld b,8
.checkUpButton:
ldh a,[hJoypadDown]
and a,D_UP
jr z,.checkDownButton
call increaseTime
.checkDownButton
ldh a,[hJoypadDown]
and a,D_DOWN
jr z,.noChange
call decreaseTime
.noChange:
jp hl               ; jump to FixAndUpdateTime



increaseTime:
ld a,[wStartMinute]
add b               ; increase Minutes
cp a,60
jr nc,.nextHour
ld [wStartMinute],a
ret

.nextHour:
xor a               ; set to 00 Minutes
ld [wStartMinute],a
ld a,[wStartHour]
add a,01            ; at the next Hour
cp a,24
jr nc,.nextDay
ld [wStartHour],a
ret

.nextDay:
xor a               ; set to 00 Hours
ld [wStartHour],a
ld a,[wStartDay]
add a,01            ; at the next Day
cp a,7
jr nc,.nextWeek
ld [wStartDay],a
ret

.nextWeek:
xor a               ; set to first day of Week
ld [wStartDay],a
ret


decreaseTime:
ld a,[wStartMinute]
sub b               ; decrease Minutes
jr c,.previousHour
ld [wStartMinute],a
ret

.previousHour:
ld a,59             ; set to 59 Minutes
ld [wStartMinute],a
ld a,[wStartHour]
sub a,1             ; at the previous Hour
jr c,.previousDay
ld [wStartHour],a
ret

.previousDay:
ld a,23             ; set to 23 Hours
ld [wStartHour],a
ld a,[wStartDay]
sub a,1             ; at the previous Day
jr c,.previousWeek
ld [wStartDay],a
ret

.previousWeek:
ld a,6              ; set to last Day of Week
ld [wStartDay],a
ret



SECTION "UpdateTime: change jump", ROM0[UpdateTime_FixTime_]
;UpdateTime::
;   call GetClock
;   call FixDays
UpdateTime.fixTime:
;   call FixTime            ; <- orig code - is overwritten
    jp ChangeTimeInPokegear ; <- new  code
UpdateTime.afterFixTime:
;   farcall GetTimeOfDay
;   ret


SECTION "FixTime", ROM0[FixTime_]
FixTime:
    ;orig code unmodified - only for Label

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
