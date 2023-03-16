MODULE = text
SOURCES = $(MODULE).s
DEPENDENCIES =
GENERATED = version.txt

include ../common/module.mk

VERSION_FILE = version_$(VERSION).txt

$(VERSION_FILE):
	echo -n $(VERSION) >$@

version.txt: version_$(VERSION).txt
	cp $< $@
