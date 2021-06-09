    EXTERN init_screen
    EXTERN invert_screen
    EXTERN show_game_screen
    EXTERN restore_screen_attributes
    EXTERN draw_fuel_meter
    EXTERN draw_fuel_meter_part

    INCLUDE "memory.inc"
    INCLUDE "screen.inc"

    SECTION lowmem

init_screen:
    ld hl,screen_addresses
    ld de,$4000 + map_left_edge
    jp create_screen_table

draw_fuel_meter_part:
; Draw one pixel of the fuel meter
; C = amount left: 0 to fuel_meter_height - 1

    ld a,fuel_meter_height - 1
    sub c
    ret m
    ld c,a

    ld hl,fuel_meter_bitmap
    ld b,0
    add hl,bc
    ld a,(hl)  ; bitmap
    ex af,af'

    ld hl,screen_addresses + fuel_meter_top * 2
    or a   ; clear carry
    rl c
    add hl,bc
    ld a,(hl)
    inc l
    ld e,a
    ld a,(hl)
    ld d,a

    ex af,af'
    dec e
    dec e  ; compensate for map_left_edge
    ld (de),a
    ret

; Redraw the full fuel meter
draw_fuel_meter:
    ld (.save_sp),sp
    ld sp,screen_addresses + fuel_meter_top * 2

    ld de,fuel_meter_bitmap
    ld b,fuel_meter_height
.each:
    pop hl
    dec l
    dec l  ; compensate for map_left_edge
    ld a,(de)
    inc de
    ld (hl),a
    djnz .each

.save_sp = $+1
    ld sp,$0000
    ret

invert_screen:
    ld hl,$4000
    ld d,$ff
.each_pix:
    ld a,(hl)
    xor d
    ld (hl),a
    inc hl
    ld a,h
    cp $58
    jr nz,.each_pix

.each_attr:
    ld a,(hl)
    ld d,a

    ; Paper to ink
    rra
    rra
    rra
    and 7
    ld e,a

    ; ink to paper
    ld a,d
    rla
    rla
    rla
    and 70o
    or e
    ld e,a

    ld a,d
    and $c0  ; keep flash and bright
    or e

    ld (hl),a
    inc hl
    ld a,h
    cp $5b
    jr nz,.each_attr

    ret

show_game_screen:
    ld hl,game_screen
    ld de,$4000
    ld bc,$1800+$300
    ldir
    ret

restore_screen_attributes:
    ld hl,game_screen_attributes
    ld de,$5800
    ld bc,$300
    ldir
    ret

fuel_meter_bitmap:
    db %00111100 ^ $ff
    ds fuel_meter_height - 2, %01111110 ^ $ff
    db %00111100 ^ $ff

game_screen:
game_screen_attributes = game_screen+$1800
    INCBIN "screen.scr"
