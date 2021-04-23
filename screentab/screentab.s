    EXTERN create_screen_table
	EXTERN screen_table

	INCLUDE memory.inc

    SECTION lowmem

; Create screen table
; Input:
;   HL points to start of table
;   DE points to start of screen memory, typically $4000 or $c000,
;   but also with offset possible e.g. $4002 or $4020.
;   A holds the number of bytes to skip between each entry in the table
; Output:
;   Table filled with 192*2 bytes
create_screen_table:
	inc a
	ld (.modulo),a
	ld a,e
	ld (.offset),a
	ld e,0

	ld c,3  ; count thirds

.loop_thirds:
.loop_lines:
	push de

	ld b,8
.loop_one_line:

.offset = $+1
	ld a,32
	add e
	ld (hl),a
	inc hl
	ld a,d
	adc 0
	ld (hl),a

.modulo equ $+1
	ld a,1
	add l
	ld l,a
	ld a,h
	adc 0
	ld h,a

	inc d
	djnz .loop_one_line

	pop de
	ld a,32
	add e
	ld e,a
	jr nc,.loop_lines

	ld a,d
	add $08	; next third
	ld d,a
	dec c
	jr nz,.loop_thirds
	ret
