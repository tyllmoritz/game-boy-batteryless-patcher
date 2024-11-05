.SUFFIXES:
.PHONY: clean all
.SECONDEXPANSION:

SHELL := $(shell which bash)

RGBDS   ?=
RGBASM  := ${RGBDS}rgbasm
RGBLINK := ${RGBDS}rgblink
RGBFIX  := ${RGBDS}rgbfix
RGBGFX  := ${RGBDS}rgbgfx

# find character that is not used in files
separator = $(shell printf '%b' "\u$$(printf '%x' "$$(( 0x$$(printf '%x' "'$$((echo '}'; find * -type f) | grep -o . | LC_ALL=C sort -u | tail -n 1 | tr -d "\n")") + 1))")")
# define space, tab and newline variables
blank :=
space := $(blank) $(blank)

# define functions for string manipulation
replace_space = $(subst $(space),$(separator),$1)
reinsert_space = $(subst $(separator),$(space),$1)
reinsert_space_escaped = $(subst $(separator),\$(space),$1)
escape_space = $(subst $(space),\$(space),$1)
dir = $(call reinsert_space ,$(dir $(call replace_space,$1)))

# get all configfiles with "; ROM" and "; SHA1" lines configured to files that exist and have a matching checksum
#  loop over null-terminated output of find, check sha1sum with bsd or gnu tool, echo filename if checksum matches
configfiles = $(shell while IFS='' read -r -d $$'\0' file <&3; do $$(command -v sha1sum || command -v shasum) -c <(echo "$$(sed -n 's/^; SHA1 \(.*\)$$/\1/p' "$$file")  original-roms/$$(sed -n 's/^; ROM \"\(.*\)\"$$/\1/p' "$$file")") &>/dev/null && echo "$$file" | sed 's/ /$(separator)/g'; done 3< <(find * -type f -name "*.asm" -print0) )

# for each configfile set variables roms, %_baserom, %_configfile and RGBASMFLAGS
define get_config_info
baserom = $(shell echo "original-roms/$$(sed -n 's/^; ROM \"\(.*\)\"$$/\1/p' "$(call reinsert_space,${configfile})")" | sed 's/ /${separator}/g')
${configfile}_roms = $(shell sed -n 's/^; builds \"\(.*\)\" with \(.*\)$$/\1/p' "$(call reinsert_space,${configfile})" | sed 's/ /${separator}/g')
endef
define set_rom_vars
	roms += $(targetrom)
	patched-roms/${targetrom}_baserom := $(baserom)
	${targetrom}_configfile := ${configfile}
	$(foreach configopt, $(shell grep '; builds "$(call reinsert_space,${targetrom})" with ' "$(call reinsert_space,${configfile})" | sed -n 's/.*with \(.*\)$$/\1/p'), \
	    $(eval patched-roms/$(call reinsert_space_escaped,${targetrom}): RGBASMFLAGS += -D$(configopt)) \
	    $(eval build/$(call reinsert_space_escaped,${targetrom:=.mk}): RGBASMFLAGS += -D$(configopt)) \
	)
endef
$(foreach configfile,${configfiles},$(eval $(get_config_info)) $(foreach targetrom,$(${configfile}_roms), $(eval $(set_rom_vars))))

all: $(call reinsert_space_escaped,$(addprefix patched-roms/,$(roms)))

patches: $(call reinsert_space_escaped,$(addprefix patches/,$(roms:=.bps)))

patches/%.bps: patched-roms/$$(call escape_space,%)
	$(shell mkdir -p $(call dir, $@))
	flips --create --bps '$(call reinsert_space ,$($(call replace_space,$(<))_baserom))' '$<' '$@'

patched-roms/%: build/$$(call escape_space,%).o
	$(shell mkdir -p $(call dir, $@))
	$(RGBLINK) $(RGBLINKFLAGS) -p0 -O '$(call reinsert_space ,$($(call replace_space,$(@))_baserom))' -o '$@' '$<' \
	&& $(RGBFIX) -p0 -v '$@'

build/%.o: build/$$(call escape_space,%).mk
	touch -c '$@'
	if [ ! -s '$@' ]; then rm '$<' && make '$<'; fi

build/%.mk: $$(call reinsert_space_escaped,$$($$(call replace_space,%)_configfile))
	$(shell mkdir -p $(call dir, $@))
	$(RGBASM) ${RGBASMFLAGS} -M - -MG -MQ '$(call reinsert_space_escaped,$(@))' -MQ '$(call reinsert_space_escaped,$(@:.mk=.o))' -o 'build/$*.o' --preinclude '$(<)' src/main.asm | sed 's/ /\\ /g; s/\([\\:]\)\\ /\1 /g; s/\\ build\// build\//' > '$(@)'

ifeq ($(filter clean,${MAKECMDGOALS}),)
include $(call reinsert_space_escaped,$(addprefix build/,$(roms:=.mk)))
endif

clean:
	$(RM) $(call reinsert_space,$(addsuffix ',$(addprefix 'patched-roms/,$(roms)) \
	                                          $(addprefix 'build/,$(roms:=.o)) \
	                                          $(addprefix 'build/,$(roms:=.mk))))
