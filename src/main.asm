; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2024 Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------

IF DEF(_NORTC)
INCLUDE "src/rtc.asm"
ENDC

IF DEF(_BATTERYLESS)
INCLUDE "src/batteryless.asm"
ENDC
