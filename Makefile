# Makefile specific
.PHONY: clean all
.SECONDEXPANSION:

ifneq ($(wildcard rgbds/.*),)
RGBDS = rgbds/
endif

RGBDS ?=
RGBASM  ?= $(RGBDS)rgbasm
RGBFIX  ?= $(RGBDS)rgbfix
RGBGFX  ?= $(RGBDS)rgbgfx
RGBLINK ?= $(RGBDS)rgblink


# get targets - every roms/* subdir with a input.gbc present
# targets = $(patsubst %/, %, $(subst roms/, , $(dir $(wildcard roms/*/input.gbc))))
# targets = $(shell for dir in roms/*/*/settings.asm; do echo $$dir | cut -d "/" -f 3;done)
targets = $(shell for dir in roms/*/*/settings.asm; do [ -e "$$(dirname $$dir)/$$(echo $$dir | cut -d '/' -f 3).gbc" ] && echo $$(dirname $$dir);done)

define CODEBLOCK_ROMS
roms_nortc += $(shell grep -o "^IF DEF(_NORTC)" ${targetdir}/settings.asm >/dev/null && echo "${targetdir}/$(shell echo ${targetdir} | cut -d '/' -f 3 )_nortc.gbc")
roms_batteryless-AAA-A9 += $(shell grep -o "^IF DEF(_BATTERYLESS)" ${targetdir}/settings.asm >/dev/null && echo "${targetdir}/$(shell echo ${targetdir} | cut -d '/' -f 3 )_batteryless-AAA-A9.gbc")
roms_batteryless-555-A9 += $(shell grep -o "^IF DEF(_BATTERYLESS)" ${targetdir}/settings.asm >/dev/null && echo "${targetdir}/$(shell echo ${targetdir} | cut -d '/' -f 3 )_batteryless-555-A9.gbc")
roms_batteryless-AAA-AA += $(shell grep -o "^IF DEF(_BATTERYLESS)" ${targetdir}/settings.asm >/dev/null && echo "${targetdir}/$(shell echo ${targetdir} | cut -d '/' -f 3 )_batteryless-AAA-AA.gbc")
roms_batteryless-555-AA += $(shell grep -o "^IF DEF(_BATTERYLESS)" ${targetdir}/settings.asm >/dev/null && echo "${targetdir}/$(shell echo ${targetdir} | cut -d '/' -f 3 )_batteryless-555-AA.gbc")
roms_batteryless-AAA-A9_nortc += $(shell { grep -o "^IF DEF(_NORTC)" ${targetdir}/settings.asm >/dev/null && grep -o "^IF DEF(_BATTERYLESS)" ${targetdir}/settings.asm >/dev/null ;} && echo "${targetdir}/$(shell echo ${targetdir} | cut -d '/' -f 3 )_batteryless-AAA-A9_nortc.gbc")
roms_batteryless-555-A9_nortc += $(shell { grep -o "^IF DEF(_NORTC)" ${targetdir}/settings.asm >/dev/null && grep -o "^IF DEF(_BATTERYLESS)" ${targetdir}/settings.asm >/dev/null ;} && echo "${targetdir}/$(shell echo ${targetdir} | cut -d '/' -f 3 )_batteryless-555-A9_nortc.gbc")
roms_batteryless-AAA-AA_nortc += $(shell { grep -o "^IF DEF(_NORTC)" ${targetdir}/settings.asm >/dev/null && grep -o "^IF DEF(_BATTERYLESS)" ${targetdir}/settings.asm >/dev/null ;} && echo "${targetdir}/$(shell echo ${targetdir} | cut -d '/' -f 3 )_batteryless-AAA-AA_nortc.gbc")
roms_batteryless-555-AA_nortc += $(shell { grep -o "^IF DEF(_NORTC)" ${targetdir}/settings.asm >/dev/null && grep -o "^IF DEF(_BATTERYLESS)" ${targetdir}/settings.asm >/dev/null ;} && echo "${targetdir}/$(shell echo ${targetdir} | cut -d '/' -f 3 )_batteryless-555-AA_nortc.gbc")
endef
$(foreach targetdir, ${targets}, $(eval $(CODEBLOCK_ROMS)))

roms = $(roms_nortc) $(roms_batteryless-AAA-A9) $(roms_batteryless-AAA-A9_nortc) $(roms_batteryless-555-A9) $(roms_batteryless-555-A9_nortc) $(roms_batteryless-AAA-AA) $(roms_batteryless-AAA-AA_nortc) $(roms_batteryless-555-AA) $(roms_batteryless-555-AA_nortc)

ifeq (,$(shell command -v flips))
all: roms
else
all: patches
endif

roms: $(roms)

patches: $(roms:.gbc=.bps)


# Create a sym/map for debug purposes if `make` run with `DEBUG=1`
ifeq ($(DEBUG),1)
RGBLINKFLAGS += -n $(@:.gbc=.sym) -m $(@:.gbc=.map)
RGBASMFLAGS = -E
endif


$(roms_nortc:.gbc=.o): RGBASMFLAGS += -D_NORTC
$(roms_batteryless-AAA-A9:.gbc=.o): RGBASMFLAGS += -D_BATTERYLESS -DBOOTLEG_CARTRIDGE_TYPE=1
$(roms_batteryless-AAA-A9_nortc:.gbc=.o): RGBASMFLAGS += -D_BATTERYLESS -DBOOTLEG_CARTRIDGE_TYPE=1 -D_NORTC
$(roms_batteryless-555-A9:.gbc=.o): RGBASMFLAGS += -D_BATTERYLESS -DBOOTLEG_CARTRIDGE_TYPE=2
$(roms_batteryless-555-A9_nortc:.gbc=.o): RGBASMFLAGS += -D_BATTERYLESS -DBOOTLEG_CARTRIDGE_TYPE=2 -D_NORTC
$(roms_batteryless-AAA-AA:.gbc=.o): RGBASMFLAGS += -D_BATTERYLESS -DBOOTLEG_CARTRIDGE_TYPE=3
$(roms_batteryless-AAA-AA_nortc:.gbc=.o): RGBASMFLAGS += -D_BATTERYLESS -DBOOTLEG_CARTRIDGE_TYPE=3 -D_NORTC
$(roms_batteryless-555-AA:.gbc=.o): RGBASMFLAGS += -D_BATTERYLESS -DBOOTLEG_CARTRIDGE_TYPE=4
$(roms_batteryless-555-AA_nortc:.gbc=.o): RGBASMFLAGS += -D_BATTERYLESS -DBOOTLEG_CARTRIDGE_TYPE=4 -D_NORTC



$(roms:.gbc=.bps): $$(patsubst %.bps,%.gbc,$$@)
	flips --create --bps $(@D)/$(shell echo $(@D) | cut -d '/' -f 3).gbc $< $@

$(roms): $$(patsubst %.gbc,%.o,$$@)
	$(RGBLINK) $(RGBLINKFLAGS) -p0 -O $(@D)/$(shell echo $(@D) | cut -d '/' -f 3).gbc -o $@ $<
	$(RGBFIX) -p0 -v $@

define SAVEFILE_RGBASMFLAGS
ifneq ("$(wildcard $(savefile))","")
$(savefile:.sav=.o):  RGBASMFLAGS += -DEMBED_SAVEGAME=\"$(savefile)\"
endif
endef
$(foreach savefile,$(roms:.gbc=.sav), $(eval $(SAVEFILE_RGBASMFLAGS) ))

$(roms:.gbc=.o): $$(@D)/settings.asm src/main.asm $$(shell tools/scan_includes.sh $$(@D)/settings.asm src/main.asm) $$(wildcard $$(subst .o,.sav,$$@))
	$(RGBASM) $(RGBASMFLAGS) -o $@ --preinclude $< src/main.asm


clean:
	$(RM) $(roms) \
	$(roms:.gbc=.bps) \
	$(roms:.gbc=.sym) \
	$(roms:.gbc=.map) \
	$(roms:.gbc=.o)

