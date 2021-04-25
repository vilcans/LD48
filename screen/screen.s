    EXTERN invert_screen
    EXTERN save_screen_attributes
    EXTERN restore_screen_attributes

    SECTION lowmem
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

save_screen_attributes:
    ld hl,$5800
    ld de,saved_attributes
    ld bc,$300
    ldir
    ret

restore_screen_attributes:
    ld hl,saved_attributes
    ld de,$5800
    ld bc,$300
    ldir
    ret

    SECTION screen
    INCBIN "screen.scr"

    SECTION .bss
saved_attributes:
    ds $300
