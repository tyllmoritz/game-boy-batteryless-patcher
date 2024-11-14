; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2017-2024 Matt Currie
; SPDX-FileCopyrightText: 2024 Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------

INCLUDE "src/savestates/check_for_load_or_save.asm"
INCLUDE "src/savestates/load_and_save.asm"
INCLUDE "src/savestates/io_copy.asm"
IF !DEF(is_cgb)
INCLUDE "src/savestates/packbits_encode.asm"
INCLUDE "src/savestates/packbits_decode.asm"
ENDC
INCLUDE "src/savestates/magic_bytes.asm"
