    INCLUDE "memory.inc"
    INCLUDE "sprites.inc"

map_width = 20

    SECTION .text
main:
    ld ($1000),a
    ld hl,screen_addresses
    ld de,$4000
    call create_screen_table

    ld hl,$5800
    ld de,$5801
    ld bc,$2ff
    ld (hl),17o
    ldir

    ld hl,ship_spr_source
    ld de,ship_spr
    call preshift_sprite

each_frame:
    ei
    halt
    di
    call draw_tiles

    ld hl,$4000
    ld de,$4001
    ld (hl),$55
    ld bc,$17ff
    ldir

    ld a,6
    out ($fe),a

x_pos = $+1
    ld a,-1 ; x
    inc a
    ld (x_pos),a
    ld b,a  ; x

y_pos = $+1
    ld a,0 ; y
    inc a
    ld (y_pos),a
    ld c,a
    ld de,ship_spr
    call draw_sprite

    ld a,0
    out ($fe),a

    jp each_frame

draw_tiles:
    ld hl,level
    ld de,$5800
    ld c,10  ; row counter
.each_row:
    push bc
    ld bc,map_width
    ldir
    ld bc,32-map_width
    ex de,hl
    add hl,bc
    ex de,hl
    pop bc

    dec c
    djnz .each_row
    ret

level:
    INCBIN "level.dat"

    SECTION lowmem
ship_spr_source:
    INCBIN "ship.spr"

    SECTION .bss,"uR"
ship_spr:
    ds sprite_height * 3 * 8
