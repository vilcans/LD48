    SECTION lowmem
    jp main

    SECTION .text
main:
    ld hl,$5800
    ld de,data
loop:
    inc (hl)
    jp loop
