; ------------------------------------------------------------------------------
;                      Pokemon G/S/C - RTC Changer patches
;       original patches by infinest can be found here: https://infine.st/
;                 disassembled with permission by Robin Bertram
; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2019  infinest
; SPDX-FileCopyrightText: 2024  Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only
; ------------------------------------------------------------------------------



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