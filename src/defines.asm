; ------------- DEFINITIONS --------------
; include definitions
INCLUDE "src/hardware.inc" ;https://github.com/gbdev/hardware.inc
IF DEF(_NORTC)
INCLUDE "src/rtc/buttons.inc"
ENDC
IF DEF(_BATTERYLESS)
INCLUDE "src/batteryless/bootleg_types.inc"
ENDC
IF DEF(_SAVESTATES)
INCLUDE "src/savestates/defines.asm"
ENDC