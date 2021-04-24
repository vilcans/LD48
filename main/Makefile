MODULE = main
SOURCES = $(MODULE).s
DEPENDENCIES = ../sprites/sprites.o ../screentab/screentab.o
GENERATED = ship.spr \
	level.dat

include ../common/part.mk

level.dat: ../map/level.tmx
	python $(BIN_DIR)/tiled_to_bin.py --autocrop --exclude-layers=helper $< $@
