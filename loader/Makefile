include ../common/common.mk

DECOMPRESS_ADDRESS = 0xff80
ASM_FLAGS += -Ddecompress_address=$(DECOMPRESS_ADDRESS)
SPECTRUM_FILENAME ?= $(RELEASE_NAME)

MAIN_MODULE ?= main

all: loader.tap

debug: loader.tap
	$(FUSE) --debugger-command 'br write 0x1000' loader.tap

run: loader.tap
	$(FUSE) loader.tap

run128: loader.tap
	$(FUSE) --machine=128 loader.tap

loader.bin: loader.o
	$(VLINK) -Msections.txt -brawbin1 -o $@ loader.o

loader.o: main.bin.snappy decompress.bin

decompress.bin: decompress.o ../snappy/snappy.s
	$(MAKE) -C ../snappy snappy.o
	$(VLINK) -Mdecompress-sections.txt -Ttext $(DECOMPRESS_ADDRESS) -brawbin1 -o $@ decompress.o ../snappy/snappy.o

main.bin: ../$(MAIN_MODULE)/$(MAIN_MODULE).bin
	cp $< $@

runner.bin: runner.bas
	zmakebas -r -o $@ $<

loader.tap: loader.bin runner.bin
	python $(BIN_DIR)/tobasic.py -f "$(SPECTRUM_FILENAME)" --mc=loader.bin runner.bin $@

../$(MAIN_MODULE)/$(MAIN_MODULE).bin:
	$(MAKE) -C ../main main.bin
