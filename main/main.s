    INCLUDE "memory.inc"
    INCLUDE "sprites.inc"

map_width = 20
visible_height_rows = 24

extra_delay = 2

ship_sprite_row = 12
ship_sprite_y = ship_sprite_row * 8

lives_column = map_width + 1
lives_row = 21

ship_color = 05o

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
    ld (hl),$00
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

    ;ld a,ship_color
    ld bc,((lives_column * 8 + 4) << 8) | (lives_row * 8 + 4)
    ld de,ship_spr
    call draw_sprite

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
    ld a,ship_color
    call draw_colored_sprite

    border 0

    jp each_frame

draw_tiles:
level_ptr = $+1
    ld hl,level

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

    ; --------------------
    ; Update level pointer
    ;ld hl,(scroll_pos)

    ; Divide by 8 and multiply by map_width
    ld a,l
    sra h
    rra     ; /2
    and $fc  ; now HA = scroll_pos / 8 * 4
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
    ld (level_ptr),hl

    ; --------------------
    ; Check for collision

    ld a,(ship_sprite_x)
    and $f8
    rrca
    rrca
    rrca
    ld e,a
    ld d,0
    add hl,de
    ld de,ship_sprite_row * map_width
    add hl,de

    ; Collect collisions
    ; if paper is not 0, that cell has collided

    ld de,($08 << 8) | 70o  ; D = comparison, E = paper mask, needed to mask out bright bit

.get_collision MACRO
    ld a,(hl)
    and e
    cp d    ; check paper color
    rl c    ; save bit
    ENDM

    ; Top left
    .get_collision
    ; Top middle
    inc hl
    .get_collision
    ; Top right
    inc hl
    .get_collision

    ; Go to next row
    ld a,l
    add map_width - 2
    ld l,a
    ld a,h
    adc 0
    ld h,a

    ; Middle left
    .get_collision
    ; Middle right
    inc hl
    inc hl  ; skip middle center
    .get_collision

    ; Go to next row
    ld a,l
    add map_width - 2
    ld l,a
    ld a,h
    adc 0
    ld h,a

    ; Bottom left
    .get_collision
    ; Bottom middle
    inc hl
    .get_collision
    ; Bottom right
    inc hl
    .get_collision

    ; Collision bits:
    ; 7 = top left
    ; 6 = top middle
    ; 5 = top right
    ; 4 = center left
    ; 3 = center right
    ; 2 = bottom left
    ; 1 = bottom middle
    ; 0 = bottom right

    ; Create collision mask
    ld b,%11111111
    ; On a thin sprite, do not check the rightmost collisions
    ld a,(ship_sprite_x)
    and 7
    cp 17-sprite_visible_width
    jr nc,.wide_sprite
    ;     76543210
    ld b,%11010110
.wide_sprite:
    ; If the y position is divisible by 8, do not check the bottom collisions
    ld a,(scroll_pos)
    and 7
    cp sprite_height+1-sprite_visible_height
    jr nc,.not_even_y
    ;     76543210
    ld a,%11111000
    and b
    ld b,a
.not_even_y:

    ld a,c
    cpl
    ld ($423f),a   ; collisions unmasked
    and b
    ld ($443f),a   ; collision masked
    ld (collisions),a
    ld a,b
    ld ($433f),a   ; collision mask

    ; Debug draw collisions
    ld a,(collisions)
    ld c,a
    ld e,07o  ; mask

    ; Debug draw top
.addr SET $5800 + (lives_column + lives_row * $20);
    REPT 3
    rl c
    sbc a
    and e
    ld (.addr),a
.addr SET .addr + 1
    ENDR

    ; Debug draw middle
.addr SET $5800 + (lives_column + (lives_row + 1) * $20);
    rl c
    sbc a
    and e
    ld (.addr),a
    rl c
    sbc a
    and e
    ld (.addr + 2),a

    ; Debug draw bottom
.addr SET $5800 + (lives_column + (lives_row + 2) * $20);
    REPT 3
    rl c
    sbc a
    and e
    ld (.addr),a
.addr SET .addr + 1
    ENDR
    ret

scroll_pos: dw 0

ship_sprite_x: db map_width*4-8

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

collisions:
    ds 1
