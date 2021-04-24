    INCLUDE "memory.inc"
    INCLUDE "sprites.inc"

map_width = 20
visible_height_rows = 24

extra_delay = 2

ship_sprite_y = 96

border MACRO
    ld a,\1
    out ($fe),a
    ENDM

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

    ld hl,$481f
    ld (hl),$ff
    ld hl,$501f
    ld (hl),$ff

    ld hl,ship_spr_source
    ld de,ship_spr
    call preshift_sprite

each_frame:
    border 6
    call prepare_finescroll

    border 1  ; top third finescroll
    ld hl,$4000+map_width
    call draw_finescroll_third

    border 0
    ld bc,extra_delay
.delay:
    djnz .delay  ; 3323 cycles
    dec c
    jr nz,.delay

    border 7  ; draw_tiles
    call draw_tiles

    border 4  ; movement
    call movement

    border 0
frame_counter = $+1
    ld a,0
    inc a
    ld (frame_counter),a

    rra
    rra
    sbc a
    ld b,a
sound = $+1
    ld a,0
    and b
    out ($fe),a

    call wait_frame               ; Next frame starts!

    border 2  ; middle third finescroll
    ld hl,$4800+map_width
    call draw_finescroll_third
    border 3   ; bottom finescroll
    ld hl,$5000+map_width
    call draw_finescroll_third
    border 6

    border 5   ; draw sprite
    ; set B=x, C=y
    ld c,ship_sprite_y
    ld a,(ship_sprite_x)
    ld b,a
    ld de,ship_spr
    ld a,05o
    call draw_colored_sprite

    border 0

    jp each_frame

draw_tiles:
    ld hl,(scroll_pos)

    ; Get coarse position
    ; mul with map_width
    ; Divide by 8 and multiply by 20
    ld a,l

    ; Divide by 8, and multiply by 4
    sra h
    rra     ; /2
    and $fc  ; now HA = scroll_pos / 8 * 4

    ; Multiply by map_width
    ld d,h
    ld e,a     ; DE = *4
    add a     ; *8
    rl h
    add a     ; *16
    rl h
    ld l,a
    add hl,de  ; *20

    ld de,level
    add hl,de

    ld de,$5800
    ld a,visible_height_rows  ; row counter
.each_row:
    REPT map_width
    ldi
    ENDR

    ld bc,32-map_width
    ex de,hl
    add hl,bc
    ex de,hl

    dec a
    jp nz,.each_row
    ret

prepare_finescroll:
    ld a,(scroll_pos)
    and 7
    ld (.offset),a
    ld ix,bits_per_scroll
.offset = $+2
    ld a,(ix+0)  ; E = whether to set paper or ink
    ld ($401f),a
    ld (finescroll_bits),a
    ret

draw_finescroll_third:
; HL = end of first line to draw in screen memory
    ld (.save_sp),sp
    ld sp,hl

finescroll_bits = $+1
    ld e,$00
    ld c,8  ; row count
.each_row:
    ld b,8
.each_line:
    xor a
    rlc e   ; paper or ink? into carry
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

    ld hl,-$800 + 32
    add hl,sp
    ld sp,hl
    dec c
    jp nz,.each_row

.save_sp = $+1
    ld sp,$0000
    ret

movement:
    ld a,(ship_sprite_x)
    ld b,a
    ld hl,(scroll_pos)
    ld c,0      ; sound

    ld a,$fd
    in a,($fe)  ; read key row: GFDSA
    rra
    jp c,.not_left
    dec b
.not_left:
    rra
    jp c,.not_down
    inc hl
.not_down:
    rra
    jp c,.not_right
    inc b
.not_right:

    ld a,$fb
    in a,($fe)  ; read key row: TREWQ
    and %10
    jp nz,.not_up
    dec hl
    ld c,$18
.not_up:
    ld a,b
    ld (ship_sprite_x),a
    ld (scroll_pos),hl
    ld a,c
    ld (sound),a
    ret

scroll_pos: dw 0

ship_sprite_x: db map_width*4-8

ship_pos_x: db map_width * 4 - 8
ship_pos_y: dw 128

level:
    INCBIN "level.dat"

bits_per_scroll:
    db %00000000
    db %00000001
    db %00000011
    db %00000111
    db %00001111
    db %00011111
    db %00111111
    db %01111111

    SECTION lowmem
ship_spr_source:
    INCBIN "ship.spr"

    SECTION .bss,"uR"
ship_spr:
    ds sprite_height * 3 * 8
