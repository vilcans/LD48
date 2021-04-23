    SECTION .text
template:
    ld hl,$5800
loop:
    inc (hl)
    jp loop

    SECTION .bss,"uR"
