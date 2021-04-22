    SECTION .text

    ld hl,$5800
    ld de,$5801
    ld bc,$2ff
    ld (hl),17o
    ldir

    ld hl,sprite
    ld de,preshifted
    call preshift_sprite

    ld de,preshifted
    ld hl,$4000
    ld c,8
.each_char:
    ld b,8
.each_row:
    ; byte 0
    ld a,(de)
    ld (hl),a
    inc de
    inc l
    ; byte 1
    ld a,(de)
    ld (hl),a
    inc de
    inc l
    ; byte 2
    ld a,(de)
    ld (hl),a
    inc de

    dec l
    dec l
    inc h
    djnz .each_row
    ld a,h
    add -8
    ld h,a
    ld a,l
    add 32
    ld l,a
    dec c
    jr nz,.each_char

freeze:
    jr freeze

preshift_sprite:

sprite_height = 16

    ld hl,sprite
    ld de,preshifted

    push de    ; save original pointer

    ; First "shift" is simply a copy
    ld b,sprite_height
    xor a
.copy_row:
    push bc
    ldi
    ldi
    ; third byte is padding
    xor a
    ld (de),a
    inc de
    pop bc
    djnz .copy_row

    pop hl  ; get original target pointer

    ld b,7*sprite_height  ; shift number
.shifts:
    ; byte 0
    ld a,(hl)
    inc hl
    srl a
    ld (de),a
    inc de
    ; byte 1
    ld a,(hl)
    inc hl
    rra
    ld (de),a
    inc de
    ; byte 2
    ld a,(hl)
    inc hl
    rra
    ld (de),a
    inc de

    djnz .shifts
    ret

sprite:
    INCBIN circle.spr

    SECTION .bss,"uR"
preshifted:
    ds sprite_height * 3 * 8
preshifted_end:
