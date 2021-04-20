#!/usr/bin/env python

# Convert a raw memory dump to a z80 snapshot

import struct
import re
import argparse

compress_re = re.compile(r'(.)\1{1,254}')


def _compress_replace(match):
    i = match.start()
    length = len(match.group(0))
    byte = match.group(1)

    if byte != '\xed' and length < 5:
        return byte * length

    if i >= 0 and match.string[i - 1] == '\xed':
        return byte + '\xed\xed' + chr(length - 1) + byte

    return '\xed\xed' + chr(length) + byte


def compress(data):
    r"""Does the z80 format's RLE-like compression.

    Repetitions of five or more of the same byte is compressed:

    >>> compress(b'AAAAA')
    b'\xed\xed\x05A'
    >>> compress(b'AAAAAA')
    b'\xed\xed\x06A'
    >>> compress(b'AAAAAACCCCC')
    b'\xed\xed\x06A\xed\xed\x05C'

    Except for ED, where two repetitions is enough to "compress":

    >>> compress(b'A\xed\xedB')
    b'A\xed\xed\x02\xedB'

    And if the repeated character is right after an ED,
    the very first character is not included in the repetition:

    >>> compress(b'\xedAAAAAA')
    b'\xedA\xed\xed\x05A'

    Maximum compressable repetition is 255:

    >>> compress(b'X' * 256)
    b'\xed\xed\xffXX'

    Repetitions shorter than 5 (or 2) characters are not compressed:

    >>> compress(b'abc')
    b'abc'
    >>> compress(b'AAAA')
    b'AAAA'
    >>> compress(b'A\xedB')
    b'A\xedB'

    See format at http://www.worldofspectrum.org/faq/reference/z80format.htm
    """
    compressed = compress_re.sub(_compress_replace, data.decode('latin-1')).encode('latin-1')
    return compressed
    # 48k z80 format would append 00 ED ED 00 here


def write_header(out, pc=0x0000):
    def write_bytes(*values):
        for v in values:
            out.write(struct.pack('B', v))
    def write_words(*values):
        for v in values:
            out.write(struct.pack('<H', v))

    # All register pairs are low byte first, e.g. L, H
    # except AF and AF' where A comes first followed by F.
    write_words(0, 0, 0)   # AF, BC, HL
    write_words(0)   # PC, zero to signal z80 format > 1
    write_words(0)   # SP, stack pointer
    write_bytes(0)   # Interrupt register
    write_bytes(0)   # Refresh register (bit 7 not significant)
    # Bit 0  : Bit 7 of the R-register
    # Bit 1-3: Border colour
    # Bit 4  : 1=Basic SamRom switched in
    # Bit 5  : 1=Block of data is compressed
    # Bit 6-7: No meaning
    write_bytes(0)
    write_words(*([0] * 7))   # DE, BC', DE', HL', AF', IY, IX
    write_bytes(0)   # Interrupt flipflop, 0=DI, otherwise EI
    write_bytes(0)   # IFF2 (not particularly important...)
    # Bit 0-1: Interrupt mode (0, 1 or 2)
    # Bit 2  : 1=Issue 2 emulation
    # Bit 3  : 1=Double interrupt frequency
    # Bit 4-5: 1=High video synchronisation
    #          3=Low video synchronisation
    #          0,2=Normal
    # Bit 6-7: 0=Cursor/Protek/AGF joystick
    #          1=Kempston joystick
    #          2=Sinclair 2 Left joystick (or user
    #            defined, for version 3 .z80 files)
    #          3=Sinclair 2 Right joystick
    write_bytes(0)
    # Length of additional header block (see below)
    # 23 for version 2 files, and 54 or 55 for version 3;
    # the fields marked '*' are the ones that are present in the version 2 header.
    # The final byte (marked '**') is present only if the word at position 30 is 55.
    write_words(55)  # version 3
    write_words(pc)  # PC
    write_bytes(4)              # Spectrum 128

    # If in SamRam mode, bitwise state of 74ls259.
    # For example, bit 6=1 after an OUT 31,13 (=2*6+1)
    # If in 128 mode, contains last OUT to 0x7ffd
    # If in Timex mode, contains last OUT to 0xf4
    write_bytes(0x10)

    # Contains 0xff if Interface I rom paged
    # If in Timex mode, contains last OUT to 0xff
    write_bytes(0)

    # Bit 0: 1 if R register emulation on
    # Bit 1: 1 if LDIR emulation on
    # Bit 2: AY sound in use, even on 48K machines
    # Bit 6: (if bit 2 set) Fuller Audio Box emulation
    # Bit 7: Modify hardware (see below)
    write_bytes(0b111)

    # Last OUT to port 0xfffd (soundchip register number)
    write_bytes(0)

    # Contents of the sound chip registers
    write_bytes(*([0] * 16))

    # Low T state counter
    write_words(0)

    # Hi T state counter
    write_bytes(0)

    # Flag byte used by Spectator (QL spec. emulator)
    # Ignored by Z80 when loading, zero when saving
    write_bytes(0)

    # 0xff if MGT Rom paged
    write_bytes(0)

    # 0xff if Multiface Rom paged. Should always be 0.
    write_bytes(0)

    # 0xff if 0-8191 is ROM, 0 if RAM
    write_bytes(0xff)

    # 0xff if 8192-16383 is ROM, 0 if RAM
    write_bytes(0xff)

    # 5 x keyboard mappings for user defined joystick
    write_bytes(*([0] * 10))

    # 5 x ASCII word: keys corresponding to mappings above
    write_bytes(*([0] * 10))

    # MGT type: 0=Disciple+Epson,1=Disciple+HP,16=Plus D
    write_bytes(0)

    # Disciple inhibit button status: 0=out, 0ff=in
    write_bytes(0)

    # Disciple inhibit flag: 0=rom pageable, 0ff=not
    write_bytes(0)

    # Last OUT to port 0x1ffd
    write_bytes(0)


def create_snapshot(source_file, destination_file, start_address):
    # Fill lower memory with zeroes
    dump = b'\0' * start_address
    dump += open(source_file, 'rb').read()
    assert len(dump) <= 65536, 'code is too big!'

    empty_page = b'\0' * 0x4000
    pages = [empty_page] * 8

    def get_page(address):
        data = dump[address:address + 0x4000]
        return data + b'\0' * (0x4000 - len(data))

    pages[5] = get_page(0x4000)
    pages[2] = get_page(0x8000)
    pages[0] = get_page(0xc000)

    #assert len(header) == 87

    with open(destination_file, 'wb') as out:
        write_header(out, pc=start_address)

        for page in range(8):
            z80page = page + 3
            compressed = compress(pages[page])
            # page header
            out.write(struct.pack('<HB', len(compressed), z80page))
            out.write(compressed)


def main():
    parser = argparse.ArgumentParser(
        description='Create a z80 snapshot from a memory dump')
    parser.add_argument(
        '--start', metavar='ADDRESS',
        type=lambda v: int(v, 0),
        required=True,
        help='Start address of memory dump, hex (with 0x prefix) or decimal')
    parser.add_argument('source',
        help='File containing the memory dump')
    parser.add_argument('destination',
        help='File to write z80 snapshot to')

    args = parser.parse_args()
    create_snapshot(
        args.source, args.destination,
        start_address=args.start)


if __name__ == '__main__':
    main()
