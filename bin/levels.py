import re

from tiled_to_bin import load_tmx
from io import BytesIO
from math import ceil, floor


def main():
    import argparse
    parser = argparse.ArgumentParser(description='Convert Tiled to level data')
    parser.add_argument(
        'tmx', type=argparse.FileType('r'),
        help='Tiled file',
    )
    parser.add_argument(
        'out',
        help='Binary data',
    )
    parser.add_argument(
        'meta',
        help='Metadata as source code',
    )
    args = parser.parse_args()

    layers, objects = load_tmx(
        args.tmx, exclude_layers=re.compile('helper'), autocrop=True)

    for layer_num, (name, data, metadata) in enumerate(layers):
        assert metadata['width'] == 20, f"Wrong width on layer {name}: {metadata['width']}"
        print(f'Layer {layer_num}: {name}')

    bin_out = BytesIO()
    data_offsets = []
    for _name, data, _metadata in layers:
        data_offsets.append(bin_out.tell())
        bin_out.write(data)

    connections = []

    for obj in objects['connections']:
        print('Finding rooms for object:', obj)
        column_range = range(
            floor(obj['x'] // 8),
            ceil((obj['x'] + obj['width']) // 8)
        )
        row_range = range(
            floor(obj['y'] // 8),
            ceil((obj['y'] + obj['height']) // 8)
        )
        print('row', row_range, 'column', column_range)
        left_layer = None
        right_layer = None
        for layer_number, (layer_name, _, metadata) in enumerate(layers):
            layer_rows = range(
                metadata['top'], metadata['top'] + metadata['height'])
            #print(f'Trying layer {layer_name} ({metadata}) for rows {row_range} and columns {column_range}')
            if not (set(layer_rows) & set(row_range)):
                #print('Not in vertical range')
                continue
            if metadata['left'] in column_range:
                print(
                    f'Adding layer {layer_name} ({metadata}) as a right connection')
                assert right_layer is None, f'Multiple layers at the right. Previous: {right_layer}'
                right_layer = (layer_number, row_range)
            if (metadata['left'] + metadata['width']) in column_range:
                print(
                    f'Adding layer {layer_name} ({metadata}) as a left connection')
                assert left_layer is None, f'Multiple layers at the left. Previous: {left_layer}'
                left_layer = (layer_number, row_range)
        assert left_layer and right_layer, \
            f'Object is not connected to the left and right: {obj} (rows {row_range} columns {column_range}' + \
            f'Left: {left_layer} Right: {right_layer}'
        print(
            f'Object is connection between {left_layer} and {right_layer}: {obj}')

        connections.append((left_layer, right_layer))

    # for name, _data, metadata in layers:

    with open(args.meta, 'w') as out:
        for layer_number, ((name, data, this_metadata), offset) in enumerate(zip(layers, data_offsets)):
            ship_color = this_metadata["properties"].get('ship_color', '05o')
            out.write('\n'.join([
                f'; Level {layer_number} ("{name}")',
                f'level_{layer_number}_data:',
                f'\tdw level_data + {offset}',
                f'\tdw .level_{layer_number}_exits_right',
                f'\tdb {ship_color}  ; ship color',
            ]) + '\n')

            left_connections = [
                (left_layer, right_layer)
                for (left_layer, right_layer) in connections
                if right_layer[0] == layer_number
            ]
            right_connections = [
                (right_layer, left_layer)
                for (left_layer, right_layer) in connections
                if left_layer[0] == layer_number
            ]
            for (side, side_connections) in [
                ('left', left_connections),
                ('right', right_connections),
            ]:
                out.write('\n'.join([
                    f'.level_{layer_number}_exits_{side}:',
                ]) + '\n')
                for (connected_layer, this_layer) in sorted(
                    side_connections, reverse=True,
                    key=lambda compare_layers: compare_layers[1][1].start
                ):
                    _, exit_rows = this_layer
                    connected_layer_number, _ = connected_layer
                    this_top = this_metadata['top']
                    connected_top = layers[connected_layer_number][2]['top']
                    vertical_offset = this_top - connected_top
                    out.write('\n'.join([
                        f'\tdw {exit_rows.start - this_top} ; exit start row',
                        f'\tdb {exit_rows.stop - exit_rows.start} ; exit height',
                        f'\tdw level_{connected_layer_number}_data ; {layers[connected_layer_number][0]}',
                        f'\tdw {vertical_offset * 8}  ; that level is {vertical_offset} tiles offset',
                    ]) + '\n')
                out.write('\tdb 0,0,0  ; end\n')
            out.write('\n')

    with open(args.out, 'wb') as out:
        out.write(bin_out.getvalue())


if __name__ == '__main__':
    main()
