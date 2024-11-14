INCLUDE "src/savestates/defines.asm"
INCLUDE "src/savestates/check_for_load_or_save.asm"
INCLUDE "src/savestates/load_and_save.asm"
INCLUDE "src/savestates/io_copy.asm"
IF !DEF(is_cgb)
INCLUDE "src/savestates/packbits_encode.asm"
INCLUDE "src/savestates/packbits_decode.asm"
ENDC
