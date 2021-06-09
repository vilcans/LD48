    EXTERN show_intro
    EXTERN show_text

    SECTION .text

show_intro:
    ld de,intro_text
show_text:
    push de
    xor a
    out ($fe),a
    call wait_frame
    call fill_attributes

    ld hl,$4000
    ld de,$4001
    ld bc,$17ff
    ldir

    pop de  ; text to show
    ld hl,$4000
    call rich_print

    ld de,press_key_text
    ld hl,$5000+7*$20
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
    push af
    call wait_frame
    pop af
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
