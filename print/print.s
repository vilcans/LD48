    EXTERN print
    EXTERN print_with_spacing

font = $3d00 - 32 * 8

    SECTION .text

print:
; Print with default spacing (7)
; In:
;   DE = text string, null terminated
;   HL = screen address
; Out:
;   DE = byte after null terminator
    ld a,7
    ;fallthrough
print_with_spacing:
; Print with specific spacing
; In:
;   A = pixels between characters
;   DE = text string, null terminated
;   HL = screen address
; Out:
;   DE = byte after null terminator
    ld (spacing),a
    ld ix,shift_jumps
    xor a   ; initial shift
    jp into_loop

each_char:
    ld a,(de)  ; character
    inc de
    or a
    ret z

    push de

    ld e,a
    xor a
    REPT 3
    rl e
    rla
    ENDR
    add >font
    ld d,a

    push hl
    ld b,8
each_row:
    push bc

    ld a,(de)   ; char bitmap
    inc e
    ld c,0

jr_amount = $+1
    jr jr_start
jr_start:
shift0:
    or (hl)
    ld (hl),a
    jp next_row
shift5:
    rla
    rl c
shift6:
    rla
    rl c
shift7:
    rla
    rl c

    inc l
    or (hl)
    ld (hl),a
    dec l
    ld a,c
    or (hl)
    ld (hl),a
    jp next_row
shift4:
    rra
    rr c
shift3:
    rra
    rr c
shift2:
    rra
    rr c
shift1:
    rra
    rr c
shift_done:
    or (hl)
    ld (hl),a
    inc l
    ld a,(hl)
    or c
    ld (hl),a
    dec l

next_row:
    inc h

    pop bc
    djnz each_row

    pop hl
    pop de

    ld a,(shift)
spacing = $+1
    add 0
.compare:
    cp 8
    jp c,.not_next_byte
    sub 7
    inc l
    jr .compare
.not_next_byte:
into_loop:
    ld (shift),a

shift = $+2
    ld a,(ix+0)
    ld (jr_amount),a

    jp each_char

shift_jumps:
    db shift0-jr_start
    db shift1-jr_start
    db shift2-jr_start
    db shift3-jr_start
    db shift4-jr_start
    db shift5-jr_start
    db shift6-jr_start
    db shift7-jr_start
