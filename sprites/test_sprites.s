    INCLUDE memory.inc
    INCLUDE sprites.inc

test_sprites:
    ld hl,$5800
    ld de,$5801
    ld bc,$2ff
    ld (hl),17o
    xor a
    ldir

    ld hl,screen_addresses
    ld de,$4000
    call create_screen_table

    ld hl,sprite
    ld de,preshifted
    call preshift_sprite

each_frame:
    ei
    halt
    di
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
    ld de,preshifted
    call draw_sprite

    ld a,0
    out ($fe),a

    jp each_frame


sprite:
    INCBIN circle.spr

    SECTION .bss,"uR"
preshifted:
    ds sprite_height * 3 * 8
preshifted_end:
