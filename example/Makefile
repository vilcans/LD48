MODULE = example
SOURCES = $(MODULE).s
GENERATED = sprite.bin
DEPENDENCIES = init

include ../common/part.mk

sprite.bin: sprite.png
	python $(BIN_DIR)/convert_image.py $< $@