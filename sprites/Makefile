MODULE = sprites
SOURCES = test_sprites.s $(MODULE).s
DEPENDENCIES = ../screentab/screentab.o
GENERATED = circle.spr

include ../common/part.mk

%.spr: %.png
	python $(BIN_DIR)/convert_image.py $< $@
