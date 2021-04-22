MODULE = sprite
SOURCES = $(MODULE).s
DEPENDENCIES =
GENERATED = circle.spr

include ../common/part.mk

%.spr: %.png
	python $(BIN_DIR)/convert_image.py $< $@
