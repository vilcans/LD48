	SECTION .text

	ld hl,$5800
	ld (hl),17o
	ld de,$5801
	ld bc,$2ff
	ldir

	ld de,sprite
	ld hl,$4000
	ld c,3
.each_char:
	ld b,8
.each_row:
	ld a,(de)
	ld (hl),a
	inc de
	inc l
	ld a,(de)
	ld (hl),a
	inc de
	dec l
	inc h
	djnz .each_row
	ld a,h
	add -8
	ld h,a
	ld a,l
	add 32
	ld l,a
	dec c
	jr nz,.each_char

	ld hl,interrupt
	call set_interrupt

freeze:
	jr freeze

interrupt:
	push hl
	ld hl,$581f
	inc (hl)
	pop hl
	ei
	reti

sprite:
	INCBIN sprite.bin

	SECTION .bss,"uR"
