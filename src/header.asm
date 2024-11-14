; ---------------- HEADER ----------------
; modify game header if needed
IF DEF(uses_mbc5)
    DEF CHANGE_CART_TYPE EQU CART_ROM_MBC5_RAM_BAT
ELIF DEF(_SAVESTATES)
    DEF CHANGE_CART_TYPE EQU CART_ROM_MBC1_RAM_BAT
ENDC
IF DEF(CHANGE_CART_TYPE)
	SECTION "Header: Cart type", ROM0[$0147]
	DB CHANGE_CART_TYPE
ENDC
IF DEF(CHANGE_CART_SIZE)
	SECTION "Header: Cart size", ROM0[$0148]
	DB CHANGE_CART_SIZE
ENDC
IF DEF(RAMSIZE)
	SECTION "ram size", ROM0[$0149]
    DB RAMSIZE
ENDC
SECTION "Header: checksums", ROM0[$014d]
    DB $00, $00, $00 ; zero out to stop warning from rgbfix
ENDSECTION
