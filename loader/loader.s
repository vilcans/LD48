	SECTION .text

reference_point:
	di
	ld sp,0

	; This code is relocatable,
	; so we need to figure out where in memory we are.
	; Using the fact that BASIC set BC to the argument to USR,
	; so BC = reference_point.
	; Copy compressed data and decompress function
	; so that decompress appears at decompress_address
	; Copy backwards so source and destination may overlap

	ld hl,copy_end-reference_point-1
	add hl,bc
	ld de,decompress_address+decompress_size-1
	ld bc,copy_end-copy_start
	lddr

	; Decompress
	ld hl,target_compressed_data
	ld de,MEM_BOTTOM	; decompress to this address
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
