    EXTERN print

font = $3d00 - 32 * 8

    SECTION .text
print:
.each_char:
    ld a,(hl)  ; character
    inc hl
    or a
    ret z

    push hl

    ld l,a
    xor a
    REPT 3
    rl l
    rla
    ENDR
    add >font
    ld h,a

    push de
    ld b,8
.each_row:
    ld a,(hl)
    inc l
    ld (de),a
    inc d
    djnz .each_row

    pop de
    inc e
    pop hl
    jp .each_char
