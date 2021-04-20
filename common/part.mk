include ../common/common.mk

MODULE_OBJS = $(SOURCES:.s=.o)
OBJS = $(MODULE_OBJS)

#MODULES = $(PART) $(ADDITIONAL_MODULES)
#OBJS = $(foreach mod,$(MODULES),../$(mod)/$(mod).o)

all: $(MODULE).z80

run: $(MODULE).z80
	$(FUSE) --snapshot $(MODULE).z80

$(MODULE).bin: $(OBJS) ../link.lds
	#$(MAKE) -C .. $(ADDITIONAL_MODULES)
	$(VLINK) -M -Ttext 0x$(START_ADDRESS_HEX) -T../link.lds -brawbin2 -o $@ $(OBJS)

# Disassemble the assembled code
disassemble: $(MODULE).bin
	z80dasm -g 0x${MEM_BOTTOM} -alt $(MODULE).bin
