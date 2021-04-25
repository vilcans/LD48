    SECTION .text
p:
    out ($fe),a
    inc a
    and 7
    jr p
