include ../common/common.mk

# Dependencies on other modules.
DEPENDENCIES ?=

# Dependencies on generated assets.
GENERATED ?=

DEPS_TARGETS = $(foreach dep, $(DEPENDENCIES), $(dep).module)

MODULE_OBJS = $(SOURCES:.s=.o)
OBJS = $(MODULE_OBJS) $(foreach dep, $(DEPENDENCIES), ../$(dep)/$(dep).o)

all: $(MODULE).z80

run: $(MODULE).z80
	$(FUSE) --snapshot $(MODULE).z80

# Run with debugger, stopping on write to address $1000
debug: $(MODULE).z80
	$(FUSE) --snapshot $(MODULE).z80 --debugger-command 'br write 0x1000'

# Objects depend on generated assets for this and other modules
$(OBJS): $(GENERATED) $(DEPS_TARGETS)

%.module:
	$(MAKE) -C .. $@

$(MODULE).bin: $(OBJS) ../link.lds
	$(VLINK) -Msections.txt -T../link.lds -brawbin1 -o $@ $(OBJS)

# Disassemble the assembled code
disassemble: $(MODULE).bin
	z80dasm -g 0x${MEM_BOTTOM} -alt $(MODULE).bin
