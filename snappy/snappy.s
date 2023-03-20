	SECTION .text
	EXTERN snappy_decompress

snappy_decompress:
	IF 0
	; Skipping length calculation - it uses the wrong byte order
	xor a
	ld b,a
	ld c,a
.get_length:
	ld a,(hl)
	inc hl
	REPT 7
	sla c
	rl b
	ENDR
	or a
	jp p,.length_done
	and $7f
	or c
	ld c,a
	jr .get_length
.length_done:
	or c
	ld c,a
	; BC = length
	ELSE
	; Skip length
.next_length_byte:
	bit 7,(hl)
	inc hl
	jp nz,.next_length_byte
	ENDIF

decompress_loop:
	ld a,(hl)
	inc hl

	ld b,0  ; high byte of length

	; Lowest bits:
	;  00 = literal
	;  01 = copy with 1-byte offset
	;  10 = copy with 2-byte offset
	;  11 = copy with 4-byte offset, not supported - ends the decompression

	srl a
	jr c,.copy_1_or_4
	; Literal or copy with 2-byte offset
	rra  ; carry is known to be cleared by srl above
	jr c,copy2

	; Literal:
	;  n < 60 => copy n + 1 bytes
	;  n = 60 => use next byte as length
	;  n = 61 => use next 2 bytes as length
	;  n = 62 => use next 3 bytes as length (not supported)
	;  n = 63 => use next 4 bytes as length (not supported)
	sub 60
	jr c,.short_literal
	jr nz,.two_byte_length

	; One byte length
	ld c,(hl)
	inc bc
	inc hl
	ldir
	jp decompress_loop

.two_byte_length:
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	inc bc
	ldir
	jp decompress_loop

.short_literal:
	add 61
	ld b,0
	ld c,a
	ldir
	jp decompress_loop

.copy_1_or_4:
	srl a
	ret c   ; 4 byte offset not supported - end
copy1:
	; Copy with 3 bit length and 11 bit offset
	; These elements can encode lengths between [4..11] bytes and offsets
	; between [0..2047] bytes. (len-4) occupies three bits and is stored
	; in bits [2..4] of the tag byte.
	; The offset occupies 11 bits, of which the
	; upper three are stored in the upper three bits ([5..7]) of the tag byte,
	; and the lower eight are stored in a byte following the tag byte.

	; As we have shifted twice, A is now
	;   bits [0..2] = len - 4
	;   bits [3..5] = upper three bits [8..10] of offset. Next byte has lower 8 bits
	ld b,a
	srl b
	srl b
	srl b      ; B = MSB of offset
	ld c,(hl)  ; C = LSB of offset
	inc hl

	push hl
	ld h,d
	ld l,e
	and %111   ; len - 4, also clears carry
	sbc hl,bc
	add 4      ; length
	ld c,a
	ld b,0
	ldir
	pop hl

	jp decompress_loop

copy2:
	; Copy with 2 byte offset
	; These elements can encode lengths between [1..64] and offsets from
	; [0..65535]. (len-1) occupies six bits and is stored in the upper
	; six bits ([2..7]) of the tag byte. The offset is stored as a
	; little-endian 16-bit integer in the two bytes following the tag byte.

	; As we have shifted twice, A is now len - 1

	ld c,(hl)  ; C = LSB of offset
	inc hl
	ld b,(hl)  ; B = MSB of offset
	inc hl

	push hl
	ld h,d
	ld l,e
	or a       ; clear carry
	sbc hl,bc
	inc a      ; length
	ld c,a
	ld b,0
	ldir
	pop hl

	jp decompress_loop
