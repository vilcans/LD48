COMMON_DIR = $(abspath $(lastword $(MAKEFILE_LIST)/..))
BASE_DIR := $(abspath $(COMMON_DIR)/..)
BIN_DIR := $(abspath $(BASE_DIR)/bin)

VASM ?= vasmz80_oldstyle
VLINK ?= vlink

FUSE_ARGS=--no-confirm-actions --graphics-filter tv2x --machine 48
FUSE=fuse $(FUSE_ARGS)

INVINCIBLE = 0
RELEASE = 0
LEVEL = 0

# Must match LOWMEM in link.lds
LOWMEM = 7800
MEM_BOTTOM = 4000
START_PC = 7800
DEFINES = -DLOWMEM='$$${LOWMEM}' -DSTART_PC='$$${START_PC}' -DINVINCIBLE=$(INVINCIBLE) -DRELEASE=$(RELEASE) -DSTART_AT_LEVEL=$(LEVEL)

ASM_FLAGS = \
	$(DEFINES) \
	-I $(COMMON_DIR)

%.o: %.s
	$(VASM) $(ASM_FLAGS) -Fvobj -L $@.lst -o $@ $<

%.z80: %.bin
	python $(BIN_DIR)/snap.py --machine=48 --start='0x${MEM_BOTTOM}' --pc='0x${START_PC}' $< $@

%.snappy: %
	cat $< | szip -fk --raw > $@

%.wav: %.tap
	tape2wav -r 44100 $< $@
