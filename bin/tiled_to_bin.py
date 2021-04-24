#!/usr/bin/env python

import xml.etree.ElementTree as ET
import struct
from array import array
import codecs
import re


def to_tile_number(firstgid, d):
    d = d & 0x3fffffff   # bit 30 and 31 are mirror x, y flags
    if d >= firstgid:
        return d - firstgid
    else:
        return 0


# def convert_to_binary(tile_numbers, width, height):
#    """Convert tile numbers in a list to a binary array"""
#    array_data = array('B')
#    for n in tile_numbers:
#        array_data.append(n)
#    return array_data


def spectrum_attr(tile):
    bright = (tile >> 3) & 1
    color = tile & 7
    return (color, bright)


def convert_to_binary(tile_numbers, width, height):
    array_data = array('B')
    for row in range(height):
        for column in range(width):
            top = tile_numbers[row * width + column]
            if row < height - 1:
                bottom = tile_numbers[(row + 1) * width + column]
            else:
                bottom = top

            c0, b0 = spectrum_attr(top)
            c1, b1 = spectrum_attr(bottom)

            # Top row is paper, bottom is ink
            b = ((b0 | b1) << 6) | c1 | (c0 << 3)
            array_data.append(b)

    return array_data


def convert_tmx(infile):
    tree = ET.parse(infile)

    # Assuming only one tileset
    tileset_node = tree.find('tileset')
    firstgid = int(tileset_node.attrib['firstgid'])

    layer_nodes = tree.findall('layer')
    layers = []

    for layer_node in layer_nodes:
        data_node = layer_node.find('data')
        name = layer_node.attrib['name']
        width = int(layer_node.attrib['width'])
        height = int(layer_node.attrib['height'])
        print(f'Layer "{name}": {width}x{height}')

        encoding = data_node.attrib['encoding']
        if encoding == 'csv':
            data = [int(a) for a in re.split(r',\s*', data_node.text)]
        else:
            raw_data = codecs.decode(data_node.text.encode('ascii'), encoding)
            # raw_data is raw 32-bit integers packed into a string: decode it
            data = struct.unpack('<%dI' % (len(raw_data) / 4), raw_data)

        assert len(data) == width * height
        tile_numbers = [to_tile_number(firstgid, d) for d in data]
        bin_data = convert_to_binary(tile_numbers, width, height)
        layers.append((name, bin_data))

    return layers


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Convert Tiled to binary')
    parser.add_argument(
        'tmx', type=argparse.FileType('r'),
        help='Tiled file',
    )
    parser.add_argument(
        'out', type=argparse.FileType('wb'), nargs='?', default=None,
        help='Binary data',
    )
    parser.add_argument(
        '--layers', required=False,
        help='Pattern for layers. {0} will be replaced by layer name.',
    )

    args = parser.parse_args()
    if not args.out and not args.layers:
        parser.error('Either give an output filename or --layers flag')

    layers = convert_tmx(args.tmx)

    if args.layers:
        for name, data in layers:
            filename = args.layers.format(name)
            with open(filename, 'wb') as out:
                out.write(data)
    else:
        for name, data in layers:
            args.out.write(data)


if __name__ == '__main__':
    main()
