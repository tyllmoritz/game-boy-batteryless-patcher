; ------------------------------------------------------------------------------
;                      Pokemon G/S/C - RTC Changer patches
;       original patches by infinest can be found here: https://infine.st/
;                 disassembled with permission by Robin Bertram
; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2019  infinest
; SPDX-FileCopyrightText: 2024  Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only
; ------------------------------------------------------------------------------



SECTION "WRAM - Time", WRAMX[wStartDay_], BANK[$1]
; init time set at newgame
wStartDay::    db
wStartHour::   db
wStartMinute:: db
wStartSecond:: db