    EXTERN print
    EXTERN print_with_spacing

font = $3d00 - 32 * 8

    SECTION .text

print:
; Print with default spacing (7)
; In:
;   HL = text string, null terminated
;   DE = screen address
; Out:
;   HL = byte after null terminator
    ld a,7
    ;fallthrough
print_with_spacing:
; Print with specific spacing
; In:
;   A = pixels between characters
;   HL = text string, null terminated
;   DE = screen address
; Out:
;   HL = byte after null terminator
    ld (spacing),a
    ld ix,shift_jumps
    xor a   ; initial shift
    jp into_loop

each_char:
    ld a,(hl)  ; character
    inc hl
    or a
    ret z

    push hl

    ld l,a
    xor a
    REPT 3
    rl l
    rla
    ENDR
    add >font
    ld h,a

    push de
    ld b,8
each_row:
    push bc

    ld a,(hl)   ; char bitmap
    inc l
    ld c,0

jr_amount = $+1
    jr jr_start
jr_start:
shift0:
    ex de,hl
    or (hl)
    ld (hl),a
    ex de,hl
    jp next_row
shift7:
    sra a
    rr c
shift6:
    sra a
    rr c
shift5:
    sra a
    rr c
shift4:
    sra a
    rr c
shift3:
    sra a
    rr c
shift2:
    sra a
    rr c
shift1:
    sra a
    rr c

    ld b,a
    ld a,(de)
    or b
    ld (de),a
    inc e
    ld a,(de)
    or c
    ld (de),a
    dec e

next_row:
    inc d

    pop bc
    djnz each_row

    pop de
    pop hl

    ld a,(shift)
spacing = $+1
    add 0
.compare:
    cp 8
    jp c,.not_next_byte
    sub 7
    inc e
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
