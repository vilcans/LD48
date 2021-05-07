#!/usr/bin/env python

import xml.etree.ElementTree as ET
import struct
from array import array
import codecs
import re
import json


def to_tile_number(firstgid, d):
    d = d & 0x3fffffff   # bit 30 and 31 are mirror x, y flags
    if d >= firstgid:
        return d - firstgid
    else:
        return 0


def get_extents(data, firstgid, width, height):
    data_iter = iter(data)
    left = width
    right = 0
    top = height
    bottom = 0
    for row in range(height):
        for column in range(width):
            d = next(data_iter)
            if d >= firstgid:
                left = min(column, left)
                right = max(column + 1, right)
                top = min(row, top)
                bottom = max(row + 1, bottom)
    if left >= right:
        return None
    else:
        return left, top, right, bottom


def convert_to_binary(tile_numbers, width, height):
    """Convert tile numbers in a list to a binary array"""
    array_data = array('B')
    for n in tile_numbers:
        array_data.append(n)
    return array_data


def load_tmx(infile, exclude_layers=None, autocrop=False, convert_to_binary=convert_to_binary):
    """Get data from a Tiled file (tmx).

    Returns (layers, objects) where layer is
    (name, binary_data, metadata).
    """

    tree = ET.parse(infile)

    # Assuming only one tileset
    tileset_node = tree.find('tileset')
    firstgid = int(tileset_node.attrib['firstgid'])

    layer_nodes = tree.findall('layer')
    layers = []

    for layer_node in layer_nodes:
        data_node = layer_node.find('data')
        name = layer_node.attrib['name']
        if exclude_layers and exclude_layers.match(name):
            print(f'Layer "{name}" excluded - skipped')
            continue
        width = int(layer_node.attrib['width'])
        height = int(layer_node.attrib['height'])
        properties_node = layer_node.find('properties')
        if properties_node:
            properties = {
                node.attrib['name']: node.attrib['value']
                for node in properties_node.findall('property')
            }
        else:
            properties = {}

        encoding = data_node.attrib['encoding']
        if encoding == 'csv':
            data = [int(a) for a in re.split(r',\s*', data_node.text)]
        else:
            raw_data = codecs.decode(data_node.text.encode('ascii'), encoding)
            # raw_data is raw 32-bit integers packed into a string: decode it
            data = struct.unpack('<%dI' % (len(raw_data) / 4), raw_data)

        assert len(data) == width * height

        if autocrop:
            extents = get_extents(data, firstgid, width, height)
        else:
            extents = (0, 0, width, height)
        if extents is None:
            print(f'Layer "{name}" is empty - skipped')
            continue
        left, top, right, bottom = extents
        print(
            f'Layer "{name}": {width}x{height} left={left} top={top} right={right} bottom={bottom}')
        tile_numbers = [
            to_tile_number(firstgid, data[row * width + column])
            for row in range(top, bottom)
            for column in range(left, right)
        ]
        bin_data = convert_to_binary(tile_numbers, right - left, bottom - top)
        metadata = {
            'top': top,
            'left': left,
            'width': right - left,
            'height': bottom - top,
            'properties': properties
        }
        layers.append((name, bin_data, metadata))

    objects = {}
    for object_group in tree.findall('objectgroup'):
        object_group_name = object_group.attrib['name']
        for obj in object_group.findall('object'):
            objects.setdefault(object_group_name, []).append({
                'id': int(obj.attrib['id']),
                'x': float(obj.attrib['x']),
                'y': float(obj.attrib['y']),
                'width': float(obj.attrib['width']),
                'height': float(obj.attrib['height']),
            })

    return layers, objects


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
        '--meta', default=None,
        help='Metadata in JSON format',
    )
    parser.add_argument(
        '--layer-filename', required=False,
        help='File name pattern for layers. {0} will be replaced by layer name.',
    )
    parser.add_argument(
        '--exclude-layers', required=False,
        type=re.compile,
        help='Regular expression for layers to exclude from output'
    )
    parser.add_argument(
        '--autocrop', default=False, action='store_true',
        help='Remove empty tiles around each layer'
    )
    args = parser.parse_args()
    if not args.out and not args.layers:
        parser.error('Either give an output filename or --layers flag')

    layers, objects = load_tmx(args.tmx, args.exclude_layers, args.autocrop)

    if args.layer_filename:
        for name, data, _metadata in layers:
            filename = args.layer_filename.format(name)
            with open(filename, 'wb') as out:
                out.write(data)
    else:
        for name, data, _metadata in layers:
            args.out.write(data)

    if args.meta:
        json.dump({
            'layers': [
                {
                    'name': name,
                    'data': metadata,
                }
                for name, _, metadata in layers
            ],
            'objects': objects
        }, open(args.meta, 'w'), indent=4)


if __name__ == '__main__':
    main()
