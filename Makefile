include settings.mk

all:
	$(MAKE) -C main

run:
	$(MAKE) -C main run

debug:
	$(MAKE) -C main debug

disassemble:
	$(MAKE) -C main disassemble

# Create a new module from template.
# Usage example to create new module xyz: make newmod MODULE=xyz
newmod:
ifndef MODULE
	$(error MODULE not defined)
endif
	mkdir $(MODULE)
	sed 's/template/$(MODULE)/g' template/template.s >$(MODULE)/$(MODULE).s
	sed 's/template/$(MODULE)/g' template/Makefile >$(MODULE)/Makefile
	sed 's/template/$(MODULE)/g' template/gitignore >$(MODULE)/.gitignore

.PHONY: web
web:
	$(MAKE) -B -C main RELEASE=1
	$(MAKE) -B -C loader loader.tap RELEASE=1
	cp main/main.z80 web/$(RELEASE_NAME)-$(VERSION).z80
	cp loader/loader.tap web/$(RELEASE_NAME)-$(VERSION).tap

# Record a movie in Fuse with File->Movie->Record and save as e.g. movie.fmf.
# Then run `make movie.mp4`. Requires fmfconv and ffmpeg.
# sudo apt install fuse-emulator-utils
%.mp4: %.fmf
	fmfconv $< | ffmpeg -i - -vf scale=960:720 -r 50 \
		-codec:v h264 -codec:a aac -f mp4 -b:a 128k \
		-b:v 600k -pix_fmt yuv420p -strict -2 $@

%.gif: %.fmf
	$(eval TEMPDIR := $(shell mktemp -d))
	# -f specifies frame rate
	fmfconv -f 25 $< $(TEMPDIR)/movie.png
	# -delay is in centiseconds
	convert -delay 4 -loop 1 -layers removeDups -layers Optimize $(TEMPDIR)/movie*.png $@
	rm -r $(TEMPDIR)

%.module: %
	$(MAKE) -C $< $<.o
