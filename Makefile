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

# Build tools when building the rom.
# This has to happen before the rules are processed, since that's when scan_includes is run.
ifeq (,$(filter clean tools,$(MAKECMDGOALS)))
$(info $(shell $(MAKE) -C tools))
endif


# get targets - every roms/* subdir with a input.gbc present
# targets = $(patsubst %/, %, $(subst roms/, , $(dir $(wildcard roms/*/input.gbc))))
# targets = $(shell for dir in roms/*/*/settings.asm; do echo $$dir | cut -d "/" -f 3;done)
targets = $(shell for dir in roms/*/*/settings.asm; do [ -e "$$(dirname $$dir)/$$(echo $$dir | cut -d '/' -f 3).gbc" ] && echo $$(dirname $$dir);done)

define CODEBLOCK_ROMS
roms_nortc += $(shell grep -o "^IF DEF(_NORTC)" ${targetdir}/settings.asm >/dev/null && echo "${targetdir}/$(shell echo ${targetdir} | cut -d '/' -f 3 )_nortc.gbc")
roms_batteryless += $(shell grep -o "^IF DEF(_BATTERYLESS)" ${targetdir}/settings.asm >/dev/null && echo "${targetdir}/$(shell echo ${targetdir} | cut -d '/' -f 3 )_batteryless.gbc")
roms_batteryless_nortc += $(shell { grep -o "^IF DEF(_NORTC)" ${targetdir}/settings.asm >/dev/null && grep -o "^IF DEF(_BATTERYLESS)" ${targetdir}/settings.asm >/dev/null ;} && echo "${targetdir}/$(shell echo ${targetdir} | cut -d '/' -f 3 )_batteryless_nortc.gbc")
endef
$(foreach targetdir, ${targets}, $(eval $(CODEBLOCK_ROMS)))

roms = $(roms_nortc) $(roms_batteryless) $(roms_batteryless_nortc)

ifeq (,$(shell command -v flips))
all: roms_nortc roms_batteryless roms_batteryless_nortc
else
all: patches_nortc patches_batteryless patches_batteryless_nortc
endif

patches_nortc: $(roms_nortc:.gbc=.bps)

roms_nortc: $(roms_nortc)

patches_batteryless: $(roms_batteryless:.gbc=.bps)

roms_batteryless: $(roms_batteryless)

patches_batteryless_nortc: $(roms_batteryless_nortc:.gbc=.bps)

roms_batteryless_nortc: $(roms_batteryless_nortc)

tools:
	$(MAKE) -C tools/

# Create a sym/map for debug purposes if `make` run with `DEBUG=1`
ifeq ($(DEBUG),1)
RGBLINKFLAGS += -n $(@:.gbc=.sym) -m $(@:.gbc=.map)
RGBASMFLAGS = -E
endif


$(roms_nortc:.gbc=.o): RGBASMFLAGS += -D_NORTC
$(roms_batteryless:.gbc=.o): RGBASMFLAGS += -D_BATTERYLESS
$(roms_batteryless_nortc:.gbc=.o): RGBASMFLAGS += -D_BATTERYLESS -D_NORTC



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

$(roms:.gbc=.o): $$(@D)/settings.asm src/main.asm $$(shell tools/scan_includes $$(@D)/settings.asm) $$(shell tools/scan_includes src/main.asm 2>/dev/null) $$(wildcard $$(subst .o,.sav,$$@))
	$(RGBASM) $(RGBASMFLAGS) -o $@ --preinclude $< src/main.asm


clean:
	$(RM) $(roms) \
	$(roms:.gbc=.bps) \
	$(roms:.gbc=.sym) \
	$(roms:.gbc=.map) \
	$(roms:.gbc=.o)
	$(MAKE) clean -C tools/

