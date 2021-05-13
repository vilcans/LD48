#!/usr/bin/env python

from array import array
import struct
import argparse

# TAP file format:
# http://www.zxshed.co.uk/sinclairfaq/index.php5?title=TAP_format

REM = b'\xea'
mc_marker = REM + b'MACHINE_CODE_HERE\x0d'


def to_block(flag, data):
    """Creates a TAP block from raw bytes"""
    block = array('B')
    total = len(data) + 2  # including flag and checksum
    block.append(total & 0xff)
    block.append(total >> 8)
    block.append(flag)
    block += data

    checksum = flag
    for d in data:
        checksum ^= d
    block.append(checksum & 0xff)

    return block


def get_header(data_length, param1, param2, type, filename='HELLO'):
    """Creates a Spectrum tape header (17 bytes)

    param1 =
        * autostart line number for basic or >= 32768 if no autostart
        * start of code block for binary

    param2 =
        * start of variable area relative to start of program for basic
        * 32768 for code
    """
    header = array('B')
    # type: 0=program, 3=code
    header.append(type)
    for c in filename.ljust(10)[:10]:
        header.append(ord(c))
    header += array('B', [
        # length of data
        data_length & 0xff, data_length >> 8,
        # autostart line number for basic or >= 32768 if no autostart
        # start of code block for binary
        param1 & 0xff, param1 >> 8,
        # start of variable area relative to start of program
        # 32768 for code
        param2 & 0xff, param2 >> 8,
    ])
    return header


def make_tap(
    basic_binary_data,
    output_tap_file,
    spectrum_filename='DEMO',
    autostart_line_number=0
):
    # Make with:
    # zmakebas -r -o runner.bin runner.bas
    basic_data = array('B', basic_binary_data)

    header_block = get_header(
        len(basic_data),
        param1=autostart_line_number,
        param2=len(basic_data),
        type=0,
        filename=spectrum_filename
    )

    with open(output_tap_file, 'wb') as out:
        to_block(0x00, header_block).tofile(out)
        to_block(0xff, basic_data).tofile(out)


def main():
    parser = argparse.ArgumentParser(
        description='Convert a BASIC program that runs machine code')
    parser.add_argument('-f', '--filename', metavar='FILENAME', default='DEMO',
                        help='Spectrum file name')
    parser.add_argument('--mc', metavar='MC',
                        help='machine code to inject into BASIC program')
    parser.add_argument('basic', metavar='BASIC',
                        help='binary BASIC file, e.g. created using zmakebas')
    parser.add_argument('tap', metavar='TAP',
                        help='tap file to write resulting program to')

    args = parser.parse_args()

    basic = open(args.basic, 'rb').read()
    if args.mc:
        machine_code = open(args.mc, 'rb').read()
        basic_line = REM + machine_code + b'\x0d'
        # Replace marker with actual code
        pos = basic.index(mc_marker)
        line_length = len(basic_line)
        basic = b''.join((
            basic[:pos - 2],
            struct.pack('<H', line_length),
            basic_line,
            basic[pos + len(mc_marker):]
        ))

    make_tap(basic, args.tap, args.filename)


if __name__ == '__main__':
    main()

# 00000000  13 00 00 00 41 00 00 00 00 00 00 00 00 00 08 00  |....A...........|
# 00000010  0a 00 08 00 4b 0a 00 ff 00 0a 04 00 f1 61 3d 61  |....K........a=a|

# 00000000  13 00 00 00 44 45 4d 4f 20 20 20 20 20 20 a3 00  |....DEMO      ..|
#           ^^ ^^ TAP block size
#                 ^^ flag byte (A reg, 00 for headers, ff for data blocks)
#                    ^^ first byte of header (type)
#                       ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ file name
#                                                     ^^ ^^ length of data block
# 00000010  00 80 a3 00 83 a5 00 ff 00 0a 27 00 f1 61 3d be  |..........'..a=.|
#           ^^ ^^ ^^ ^^ param1, param2
#                       ^^ checksum
#                          ^^ ^^ TAP block size
#                                ^^ flag, ff = data block
#                                   ^^ ^^ line number
#                                         ^^ ^^ line length
# 00000020  32 33 36 33 35 0e 00 00 53 5c 00 2b 32 35 36 0e  |23635...S\.+256.|
# 00000030  00 00 00 01 00 2a be 32 33 36 33 36 0e 00 00 54  |.....*.23636...T|
# 00000040  5c 00 0d 00 14 1d 00 f1 6c 3d be 28 61 2b 31 0e  |\.......l=.(a+1.|
# 00000050  00 00 01 00 00 29 2b 32 35 36 0e 00 00 00 01 00  |.....)+256......|
# 00000060  2a be 61 0d 00 1e 1b 00 fa 6c 3d 32 35 35 0e 00  |*.a......l=255..|
# 00000070  00 ff 00 00 cb f9 c0 61 2b 35 0e 00 00 05 00 00  |.......a+5......|
# 00000080  3a e2 0d 00 28 23 00 f1 61 3d 61 2b be 28 61 2b  |:...(#..a=a+.(a+|
# 00000090  32 0e 00 00 02 00 00 29 2b 34 0e 00 00 04 00 00  |2......)+4......|
# 000000a0  3a ec 32 0e 00 00 02 00 00 0d 00 ff 0d 00 ea 30  |:.2............0|
# 000000b0  31 32 33 34 35 36 37 38 39 30 0d 0b              |1234567890..|
# 000000bc
