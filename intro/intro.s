    EXTERN show_intro

    SECTION .text

show_intro:
    xor a
    out ($fe),a

    ld hl,$4000
    ld de,$4001
    ld bc,$1800
    ldir
    ld bc,$2ff
    ld (hl),7
    ldir

    ld de,intro_text
    ld hl,$4000
    call rich_print

    call wait_for_key

    ld a,7
fade_out:
    dec a
    halt
    ld hl,$5800
    ld de,$5801
    ld bc,$2ff
    ld (hl),a
    ldir
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
