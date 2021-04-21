; Set up interrupt handler
;
; Memory layout:
;   $fefe-$ff00 : jump to interrupt handler
;   $ff01-$ffff : stack

handler_page = $fe
handler = (handler_page<<8)|handler_page
handler_end = handler + 3

    SECTION lowmem
init:
    di
    ld sp,$0000

    ld hl,vectors
    ld de,vectors+1
    ld bc,$100
    ld (hl),handler_page
    ldir

    ld hl,handler
    ld (hl),$c3  ; jp
    inc hl
    ld (hl),<default_interrupt_handler
    inc hl
    ld (hl),>default_interrupt_handler

    ld a,>vectors
    ld i,a
    im 2
    ei

    ld hl,$5800
loop:
    inc (hl)
    jp loop

    SECTION .text
default_interrupt_handler:
    push hl
    ld hl,$5821
    inc (hl)
    pop hl
    ei
    reti

    SECTION .bss,"uR"
    ALIGN 8
vectors:
    ds $101
