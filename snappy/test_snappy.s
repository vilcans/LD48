decompress_address = $c000

    SECTION .text

    ld ($1000),a
    ld hl,source
    ld de,decompress_address
    call snappy_decompress
    ld a,$42
    ld (de),a

    ld hl,reference
    ld de,decompress_address
    ld bc,reference_end-reference
.compare:
    ld a,(de)
    inc de
    cpi
    jr nz,.mismatch
    jp pe,.compare

.ok:
    ld a,4
    out ($fe),a
    jr .ok

.mismatch:
    dec de
    dec hl
.err:
    ld a,2
    out ($fe),a
    ld ($1000),a
    jr .err

source:
    INCBIN "test.bin.snappy"
    db 3
source_end:

    ALIGN 8
reference:
    INCBIN "test.bin"
reference_end:
    db 99
