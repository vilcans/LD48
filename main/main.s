    INCLUDE "memory.inc"
    INCLUDE "sprites.inc"

map_width = 20

    SECTION .text
main:
    ld hl,screen_addresses
    ld de,$4000
    call create_screen_table

    ld hl,$4000
    ld de,$4001
    ld (hl),$55
    ld bc,$1800
    ldir
    ld bc,$2ff
    ld (hl),17o
    ldir

    ld hl,ship_spr_source
    ld de,ship_spr
    call preshift_sprite

each_frame:
    ld hl,(scroll_pos)
    inc hl
    ld (scroll_pos),hl
    ei
    halt
    di
    call draw_finescroll
    ;call draw_tiles

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

draw_finescroll:
    ld (.save_sp),sp
    ld sp,$4000+map_width

    ld a,(scroll_pos)
    and 7
    ld (.offset),a
    ld ix,bits_per_scroll
.offset = $+2
    ld c,(ix+0)  ; smc

    ld b,8
.each_line:
    xor a
    rl c
    sbc a
    ld h,a
    ld l,a

    REPT map_width/2
    push hl
    ENDR
    ld hl,$100 + map_width  ; next line
    add hl,sp
    ld sp,hl
    djnz .each_line

.save_sp = $+1
    ld sp,$0000
    ret

scroll_pos: dw 0

level:
    INCBIN "level.dat"

bits_per_scroll:
    db %11111111
    db %01111111
    db %00111111
    db %00011111
    db %00001111
    db %00000111
    db %00000011
    db %00000001

    SECTION lowmem
ship_spr_source:
    INCBIN "ship.spr"

    SECTION .bss,"uR"
ship_spr:
    ds sprite_height * 3 * 8
