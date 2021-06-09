    EXTERN show_intro

    SECTION .text

show_intro:
    xor a
    out ($fe),a
    call fill_attributes

    ld hl,$4000
    ld de,$4001
    ld bc,$1800
    ldir

    ld de,intro_text
    ld hl,$4000
    call rich_print

    xor a
.fade_in:
    inc a
    call fill_attributes
    cp 7
    jr nz,.fade_in

    call wait_for_key

    ld a,7
fade_out:
    dec a
    halt
    call fill_attributes
    or a
    jr nz,fade_out
    ret

wait_for_key:
.wait_release:
    ld a,$bf
    in a,($fe)
    rra
    jr nc,.wait_release
.wait:
    ld a,$bf
    in a,($fe)
    rra
    jr c,.wait
    ret
