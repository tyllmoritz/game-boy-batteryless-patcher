; ------------------------------------------------------------------------------
;                      Pokemon G/S/C - RTC Changer patches
;       original patches by infinest can be found here: https://infine.st/
;                 disassembled with permission by Robin Bertram
; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2019  infinest
; SPDX-FileCopyrightText: 2024  Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only
; ------------------------------------------------------------------------------



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


FixAndUpdateTime:
call FixTime                 ; orig unmodified function
jp UpdateTime.afterFixTime   ; in UpdateTime (after our modified call to FixTime - run farcall GetTimeOfDay, then ret)
