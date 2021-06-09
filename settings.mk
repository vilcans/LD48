# Project-specific settings

RELEASE_NAME = CrownOfTheMountainKing
VERSION = 1.1
# Name of the Spectrum file (will be trimmed to max 10 characters)
SPECTRUM_FILENAME = Crown LD48

RELEASE = 0
INVINCIBLE = 0
LEVEL = 0

EXTRA_DEFINES = -DINVINCIBLE=$(INVINCIBLE) -DRELEASE=$(RELEASE) -DSTART_AT_LEVEL=$(LEVEL)

# Must match LOWMEM in link.lds
LOWMEM = 5b00
MEM_BOTTOM = 4000
START_PC = 5b00
