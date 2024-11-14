; ------------------------------------------------------------------------------
; SPDX-FileCopyrightText: 2017-2024 Matt Currie
; SPDX-License-Identifier: GPL-3.0-only OR MIT
; ------------------------------------------------------------------------------

;***************************************************************************
;
; Reads the current joypad state
;
; OUTPUT:
; C = current state of the joypad
;
;***************************************************************************

    ld a,$20                    
    ldh [$ff00+$00],a            
    ldh a,[$ff00+$00]
    ldh a,[$ff00+$00]
    cpl              
    and $0f          
    swap a           
    ld b,a           
    ld a,$10         
    ldh [$ff00+$00],a 
    ldh a,[$ff00+$00]
    ldh a,[$ff00+$00]
    ldh a,[$ff00+$00]
    ldh a,[$ff00+$00]
    ldh a,[$ff00+$00]
    ldh a,[$ff00+$00]
    cpl              
    and $0f          
    or b             

IF DEF(swap_joypad)
    swap a
ENDC
IF DEF(cpl_joypad)
    cpl
ENDC


    ld c,a
    
