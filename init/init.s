; Set up interrupt handler
;
; Memory layout:
;   $fefe-$ff00 : jump to interrupt handler
;   $ff01-$ffff : stack

handler_page = $fe
handler = (handler_page<<8)|handler_page
interrupt_routine = handler +1
handler_end = handler + 3

    EXTERN set_interrupt
    EXTERN wait_frame

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
    ld (hl),<default_interrupt_routine
    inc hl
    ld (hl),>default_interrupt_routine

    ld a,>vectors
    ld i,a
    im 2
    ei

    jp START_MAIN

set_interrupt:
; Change the interrupt routine to the one pointed to by HL.
; It should push/pop as necessary and end with EI + RETI.
    di
    ld a,l
    ld (interrupt_routine),a
    ld a,h
    ld (interrupt_routine+1),a
    ei
    ret

default_interrupt_routine:
    push bc
    push af

    ld a,$bf
    in a,($fe)  ; read key row: H J K L enter
    and 1
    ld c,a
last_key = $+1
    xor $01
    call nz,key_changed

    ld a,(paused)
    ld ($581e),a
    pop af
    pop bc
    ei
    reti

wait_frame:
    ei
    halt
    di
    ld a,(paused)
    or a
    jr nz,wait_frame
    ret

key_changed:
    ld a,c
    ld (last_key),a
    rra
    ret c ; key was released

    ld a,(paused)
    cpl
    ld (paused),a
    ret

paused: db 0

    SECTION .bss,"uR"
    ALIGN 8
vectors:
    ds $101
