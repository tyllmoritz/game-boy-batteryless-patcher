; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2024 Marc Robledo
; SPDX-FileCopyrightText: 2024 Robin Bertram
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------


; Define your bootleg cartridge type.
; Valid values:
; - WRAAAAA_64KB: WR/AAA/AA cart type with 64kb (0x00010000) flashable sector size
; - WRAAAA9_64KB: WR/AAA/A9 cart type with 64kb (0x00010000) flashable sector size
; - WR555AA_64KB: WR/555/AA cart type with 64kb (0x00010000) flashable sector size
; - WR555A9_64KB: WR/555/A9 cart type with 64kb (0x00010000) flashable sector size


DEF BOOTLEG_TRUE   EQU 1 << 0
DEF BOOTLEG_A9     EQU 1 << 1
DEF BOOTLEG_555    EQU 1 << 2

; - WRAAAAA_64KB: WR/AAA/AA cart type with 64kb (0x00010000) flashable sector size
DEF WRAAAAA_64KB EQU                            BOOTLEG_TRUE ; 001 $1

; - WRAAAA9_64KB: WR/AAA/A9 cart type with 64kb (0x00010000) flashable sector size
DEF WRAAAA9_64KB EQU               BOOTLEG_A9 | BOOTLEG_TRUE ; 011 $3

; - WR555AA_64KB: WR/555/AA cart type with 64kb (0x00010000) flashable sector size
DEF WR555AA_64KB EQU BOOTLEG_555              | BOOTLEG_TRUE ; 101 $5

; - WR555A9_64KB: WR/555/A9 cart type with 64kb (0x00010000) flashable sector size
DEF WR555A9_64KB EQU BOOTLEG_555 | BOOTLEG_A9 | BOOTLEG_TRUE ; 111 $7
