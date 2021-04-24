    SECTION .text

    INCLUDE memory.inc
    INCLUDE sprites.inc

    EXTERN draw_sprite
    EXTERN draw_colored_sprite
    EXTERN preshift_sprite

draw_colored_sprite:
    ; A = attributes
    ; B = x
    ; C = y
    ; DE = preshifted sprite bitmap

    ld (.attr),a
    ld a,b
    ld (.hpos),a

    push bc

    ; Vertical position
    ld a,c  ; y
    ld b,0
    ; divide by 8, then multiply by 32 = multiply by 4
    and $f8
    add a
    rl b
    add a
    rl b
    ld c,a

    ld hl,$5800
    add hl,bc

    ; Horizontal position
.hpos = $+1
    ld a,$00
    srl a
    srl a
    srl a
    add l
    ld l,a
    ld a,h
    adc 0
    ld h,a

.attr = $+1
    ld a,$00
    ld bc,30

    ; Row 0
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    ; Row 1
    add hl,bc
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    ; Row 3
    ;add hl,bc
    ;ld (hl),a
    ;inc l
    ;ld (hl),a
    ;inc l
    ;ld (hl),a

    pop bc

draw_sprite:
    ; B = x
    ; C = y
    ; DE = preshifted sprite bitmap

    ld (save_sp),sp

    ; Get address in screen_addresses
    ld a,c      ; y
    add a
    ld (set_sp),a  ; low byte
    ld a,screen_addresses>>9
    adc a
    ld (set_sp+1),a  ; high byte

    ; Horizontal bit position
    ld a,b  ; x
    and 7
    ; mul by 3*sprite_height = 3*16
    ld h,$00
    ld l,a
    add a
    add l     ; * 3
    ld l,a
    add hl,hl ; * 3 * 2
    add hl,hl ; * 3 * 4
    add hl,hl ; * 3 * 8
    add hl,hl ; * 3 * 16

    ; Add source address
    add hl,de

    ; Horizontal byte position
    ld a,b  ; x
    rra
    rra
    rra
    and $1f     ; A = horizontal byte position
    ld c,a   ; horizontal byte position

set_sp = $+1
    ld sp,screen_addresses

    ; In loop: HL = source, DE = screen
    ld b,sprite_height
.each_row:
    pop de
    ld a,c    ; horizontal byte position
    add e
    ld e,a

    ; byte 0
    ld a,(hl)
    ld (de),a
    inc hl
    inc e
    ; byte 1
    ld a,(hl)
    ld (de),a
    inc hl
    inc e
    ; byte 2
    ld a,(hl)
    ld (de),a
    inc hl

    djnz .each_row
save_sp = $+1
    ld sp,$0000
    ret

preshift_sprite:
    ; ld hl,sprite  ; source sprite
    ; ld de,preshifted  ; target memory

    push de    ; save original pointer

    ; First "shift" is simply a copy
    ld b,sprite_height
    xor a
.copy_row:
    push bc
    ldi
    ldi
    ; third byte is padding
    xor a
    ld (de),a
    inc de
    pop bc
    djnz .copy_row

    pop hl  ; get original target pointer

    ld b,7*sprite_height  ; shift number
.shifts:
    ; byte 0
    ld a,(hl)
    inc hl
    srl a
    ld (de),a
    inc de
    ; byte 1
    ld a,(hl)
    inc hl
    rra
    ld (de),a
    inc de
    ; byte 2
    ld a,(hl)
    inc hl
    rra
    ld (de),a
    inc de

    djnz .shifts
    ret
