    ld hl,$5800
    ld de,$5801
    ld (hl),70o
    ld bc,$2ff
    ldir

    ld hl,$3c00+'H'*8
    ld de,$4020
    ld b,8
.lp:
    ld a,(hl)
    inc hl
    ld (de),a
    inc d
    djnz .lp

    ld hl,$4000
    ld de,text
    ld ($1000),a
    call print

    ld hl,$4040
    ld de,text2
    ld a,9
    call print_with_spacing

.e:
    ld hl,$581f
    inc (hl)
    jr .e

text:
    db 'HELLO WORLD! Welcome to my lair!',0
text2:
    db 'hello world!',0
