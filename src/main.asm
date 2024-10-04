IF DEF(_NORTC)
INCLUDE "src/rtc.asm"
ENDC

IF DEF(_BATTERYLESS)
INCLUDE "src/batteryless.asm"
ENDC
