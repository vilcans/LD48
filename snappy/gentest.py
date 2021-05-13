import sys
data = (
    b'\x01' * 0x20 +
    b'\x02' * 0x80 +
    b'\x03' * 0x400 +
    b'FACEBOOT' * 4 +
    b'ABC'
)
sys.stdout.buffer.write(data)
