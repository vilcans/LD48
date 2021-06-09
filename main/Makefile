MODULE = main
SOURCES = $(MODULE).s
DEPENDENCIES = init sprites screentab screen text print intro
GENERATED = ship.spr \
	levels.dat \
	leveldata.inc

include ../common/part.mk

levels.dat leveldata.inc: ../map/level.tmx
	PYTHONPATH=$(BIN_DIR) python $(BIN_DIR)/levels.py $< levels.dat leveldata.inc
