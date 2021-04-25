COMMON_DIR = $(abspath $(lastword $(MAKEFILE_LIST)/..))
BASE_DIR := $(abspath $(COMMON_DIR)/..)
BIN_DIR := $(abspath $(BASE_DIR)/bin)

VASM ?= vasmz80_oldstyle
VLINK ?= vlink

FUSE_ARGS=--no-confirm-actions --graphics-filter tv2x --machine 48
FUSE=fuse $(FUSE_ARGS)

INVINCIBLE = 0
RELEASE = 0

# Must match LOWMEM in link.lds
LOWMEM = 7800
MEM_BOTTOM = $(LOWMEM)
DEFINES = -DLOWMEM='$$${LOWMEM}' -DINVINCIBLE=$(INVINCIBLE) -DRELEASE=$(RELEASE)

#	-Dstart_address=\$$$(START_ADDRESS_HEX) \
#	-Dload_address=\$$$(LOAD_ADDRESS_HEX) \
#	-DSHOW_FRAMESKIP=$(SHOW_FRAMESKIP) \
#	-DRELEASE=$(RELEASE) \

ASM_FLAGS = \
	$(DEFINES) \
	-I $(COMMON_DIR)

%.o: %.s
	$(VASM) $(ASM_FLAGS) -Fvobj -L $@.lst -o $@ $<

%.z80: %.bin
	python $(BIN_DIR)/snap.py --machine=48 --start='0x${MEM_BOTTOM}' $< $@

%.spr: %.png
	python $(BIN_DIR)/convert_image.py $< $@
