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
    jr z,.only_lower
    ld b,a  ; number of upper lines to draw
    xor 7
    ld (.lower_lines),a

    ld de,$fefe
    ld iy,.return1
    jp draw_lines
.return1:
.lower_lines = $+1
    ld a,$07
    or a
    jr z,.return2
    ld b,a
.into_lower:
    ld de,$0101
    ld iy,.return2
    jp draw_lines
.return2:
.save_sp = $+1
    ld sp,$0000
    ret
.only_lower:
    ld b,8
    jr .into_lower

draw_lines:
; DE = bytes to fill with
; B = number of lines to fill
; SP = end of area to fill
; IY = return address

.each_line:
    REPT map_width/2
    push de
    ENDR
    ld hl,$100 + map_width  ; next line
    add hl,sp
    ld sp,hl
    djnz .each_line
    jp (iy)

scroll_pos: dw 0

level:
    INCBIN "level.dat"

    SECTION lowmem
ship_spr_source:
    INCBIN "ship.spr"

    SECTION .bss,"uR"
ship_spr:
    ds sprite_height * 3 * 8
