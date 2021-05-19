    ld ($1000),a
    ld hl,$5800
    ld de,$5801
    ld (hl),70o
    ld bc,$2ff
    ldir

    ld hl,text
    ld de,$4000
    call print
.e:
    ld hl,$581f
    inc (hl)
    jr .e

text:
    db 'HELLO WORLD!',0
