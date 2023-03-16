MODULE = snappy
SOURCES = test_snappy.s $(MODULE).s
DEPENDENCIES = init
GENERATED = test.bin test.bin.snappy

include ../common/module.mk

test.bin: gentest.py
	python gentest.py >$@
