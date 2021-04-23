MODULE = sprite
SOURCES = $(MODULE).s
DEPENDENCIES = ../screentab/screentab.o
GENERATED = circle.spr

include ../common/part.mk

%.spr: %.png
	python $(BIN_DIR)/convert_image.py $< $@
