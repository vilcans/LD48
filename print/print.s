    EXTERN print
    EXTERN print_with_spacing
    EXTERN rich_print

font = $3d00 - 32 * 8

    SECTION .text

rich_print:
; Print several lines.
; In:
;   DE = text string, each line null terminated, ending with $ff
;   HL = screen address

    ld a,7
    ld (spacing),a

    ld a,(de)
.each_string:
    cp 32
    jr z,.next_line
    jr nc,.no_starting_control
    inc de
    or a
    jr z,.next_line
    ld (spacing),a
.no_starting_control:
    push hl
    call print_with_current_spacing
    pop hl

.next_line:
    ld a,l
    add $20
    ld l,a
    jr nc,.not_next_third
    ld a,h
    add 8
    ld h,a
.not_next_third:

    ld a,(de)
    or a
    jp p,.each_string
    ret

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
print_with_current_spacing:
    ld ix,shift_jumps
    xor a   ; initial shift
    jp into_loop

each_char:
    ld a,(de)  ; character
    inc de
    or a
    ret z
    push de
    jp m,special_character

    ld e,a
    xor a
    REPT 3
    rl e
    rla
    ENDR
    add >font
    ld d,a

special_character_return:
    push hl
    ld b,8
each_row:
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
    djnz each_row

    pop hl
    pop de

    ld a,(shift)
spacing = $+1
    add 0
.compare:
    cp 8
    jr c,.not_next_byte
    sub 8
    inc l
    jr .compare
.not_next_byte:
into_loop:
    ld (shift),a

shift = $+2
    ld a,(ix+0)
    ld (jr_amount),a

    jp each_char

special_character:
    ex de,hl
    ld hl,special_bitmaps-$80*8
    ld c,a
    xor a
    REPT 3
    rl c
    rla
    ENDR
    ld b,a
    add hl,bc
    ex de,hl

    jp special_character_return

shift_jumps:
    db shift0-jr_start
    db shift1-jr_start
    db shift2-jr_start
    db shift3-jr_start
    db shift4-jr_start
    db shift5-jr_start
    db shift6-jr_start
    db shift7-jr_start

special_bitmaps:
    db %11110000
    db %11110000
    db %11110000
    db %11110000
    db %00001111
    db %00001111
    db %00001111
    db %00001111
