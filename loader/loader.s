    SECTION .text

	di
	ld sp,0

	; This code is relocatable,
	; so we need to figure out where in memory we are
	; Put a $c9 (ret instruction at $ffff) and call it.
	ld a,$c9
	push af
	call $ffff
reference_point:
	dec sp
	dec sp
	pop hl
	; hl now points to reference_point

	; Copy compressed data and decompress function
	; so that decompress appears at decompress_address
	; Copy backwards so source and destination may overlap

	ld bc,copy_end-reference_point-1
	add hl,bc
	ld de,decompress_address+decompress_size-1
	ld bc,copy_end-copy_start
	lddr

	; Decompress
    ld hl,target_compressed_data
	ld de,$4000	; decompress to this address
	jp decompress_address

copy_start:

compressed_data:
    INCBIN "main.bin.snappy"
    db 3
compressed_size = $-compressed_data

target_compressed_data = decompress_address - compressed_size

decompress:
	; After copying, this code will be at decompress_address
    INCBIN "decompress.bin"
decompress_size = $-decompress

copy_end:
