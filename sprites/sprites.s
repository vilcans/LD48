    SECTION .text

    INCLUDE memory.inc
    INCLUDE sprites.inc

    EXTERN draw_sprite
    EXTERN draw_colored_sprite
    EXTERN preshift_sprite

ld_hl_a = $77
ld_de_a = $12

draw_colored_sprite:
    ld ($1000),a
    ; A = attributes
    ; B = x
    ; C = y
    ; DE = preshifted sprite bitmap

    push de

    ld (.attr),a
    ld a,b
    ld (.hpos),a

    push bc

    ld a,b   ; x
    and 7
    cp 17-sprite_visible_width
    ld a,ld_hl_a   ; write to screen memory
    jr nc,.wide
    ld a,0   ; nop
.wide:
    ld (.rightmost_byte_0_op),a
    ld (.rightmost_byte_1_op),a

    ; Vertical position
    ld a,c  ; y
    ld h,0
    ; divide by 8, then multiply by 32 = multiply by 4
    and $f8
    add a
    rl h
    add a
    rl h
    ld l,a   ; screen address low byte
    ld a,h   ; screen address high byte
    add $58  ; attributes at $5800
    ld h,a

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
.rightmost_byte_0_op:
    ld (hl),a
    ; Row 1
    add hl,bc
    ld (hl),a
    inc l
    ld (hl),a
    inc l
.rightmost_byte_1_op:
    ld (hl),a
    ; Row 3
    ;add hl,bc
    ;ld (hl),a
    ;inc l
    ;ld (hl),a
    ;inc l
    ;ld (hl),a

    pop bc
    pop de

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
    ; Check for 2 byte wide
    ld a,b   ; x
    and 7
    cp 17-sprite_visible_width
    jr nc,.wide
    ld a,b  ; x
    rra
    rra
    rra
    and $1f
    ld c,a

    ld a,ld_hl_a  ; ld (hl),a - in practice a nop that takes 11 cycles
    jp .width_done
.wide:
    ld a,b  ; x
    rra
    rra
    rra
    and $1f     ; A = horizontal byte position
    ld c,a   ; horizontal byte position
    ld a,ld_de_a
.width_done:
    ld (.rightmost_byte_opcode),a

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
.rightmost_byte_opcode:
    ld (de),a  ; (opcode $12) or ld (hl),a (opcode $77)
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
