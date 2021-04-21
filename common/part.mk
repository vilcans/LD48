include ../common/common.mk

# Dependencies on other modules. (Not implemented.)
DEPENDENCIES ?=

# Dependencies on generated assets.
GENERATED ?=

MODULE_OBJS = ../init/init.o $(SOURCES:.s=.o)
OBJS = $(MODULE_OBJS)

#MODULES = $(PART) $(ADDITIONAL_MODULES)
#OBJS = $(foreach mod,$(MODULES),../$(mod)/$(mod).o)

all: $(MODULE).z80

run: $(MODULE).z80
	$(FUSE) --snapshot $(MODULE).z80

# Run with debugger, stopping on write to address $1000
debug: $(MODULE).z80
	$(FUSE) --snapshot $(MODULE).z80 --debugger-command 'br write 0x1000'

# Objects depend on generated assets
$(OBJS): $(GENERATED)

$(MODULE).bin: $(OBJS) ../link.lds
	#$(MAKE) -C .. $(ADDITIONAL_MODULES)
	$(VLINK) -M -Ttext 0x$(START_ADDRESS_HEX) -T../link.lds -brawbin2 -o $@ $(OBJS)

# Disassemble the assembled code
disassemble: $(MODULE).bin
	z80dasm -g 0x${MEM_BOTTOM} -alt $(MODULE).bin
