    SECTION .text

    ld hl,$4000
    ld de,save_screen
    ld bc,$1b00
    ldir

p:
    ld hl,save_screen
    ld de,$4000
    ld bc,$1b00
    ldir
    ld a,1     ; original
    call wait

    call save_screen_attributes

    ld hl,$5800
    ld de,$5801
    ld bc,$2ff
    ld (hl),17o
    ldir
    ld a,6    ; no attributes
    call wait

    call restore_screen_attributes

    call invert_screen
    ld a,2  ;inverted
    call wait

    ld hl,$5800
    ld de,$5801
    ld bc,$2ff
    ld (hl),17o
    ldir
    ld a,5    ; no attributes
    call wait

    jr p

wait:
    out ($fe),a
    ld b,100
.w:
    push bc
    call wait_frame
    pop bc
    djnz .w
    ret

    SECTION .bss
save_screen:
    ds $1b00
