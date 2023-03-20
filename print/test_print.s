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

	ld hl,$4081
	ld de,long_text
	call rich_print

.e:
	ld hl,$581f
	inc (hl)
	jr .e

text:
	db 'HELLO WORLD! Welcome to my lair!',0
text2:
	db 'hello world!',0

long_text:
	;  '------------------------------------'
	db 9,'CROWN OF THE MOUNTAIN KING',0
	db 0
	db 7,"Rumor has it that the long lost",0
	db "crown of the Mountain King can",0
	db "be found somewhere in the caverns",0
	db "below these abandoned mines.",0
	db 0
	db "Your mission is to find it,",0
	db "and get it safely back to the",0
	db "surface.",0
	db 0
	db "Steer your hovercraft carefully to",0
	db "avoid the obstacles that hide in",0
	db "the dark.",0
	db $ff
