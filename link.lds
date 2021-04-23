SECTIONS {
    RAMTOP = 0xfefe;  /* must match handler_page in init.s */
    LOWMEM = 0x7800;  /* must match LOWMEM in common.mk */
    /* screentable hardcoded to be at $8000, $180 bytes */
    HIGHMEM = 0x8180;

    lowmem LOWMEM : AT(LOWMEM) {
        *.o(lowmem)
        LOWMEM_END = .;
        ASSERT(. <= HIGHMEM, "Lowmem too large");
    }

    .text : {
        . = HIGHMEM;
        START_MAIN = .;  /* Assuming main code starts here */
        *.o(.text)
        ASSERT(. <= RAMTOP, "Out of RAM for text");
    }
    TEXT_END = .;

    BSS_START = ALIGN(0x100);

    .bss BSS_START : AT(BSS_START) {
        *.o(.bss)
        ASSERT(. <= RAMTOP, "Out of RAM for bss");
    }

    /* reusebss is a text segment that overlaps the BSS segment */
    reusebss TEXT_END : {
        *.o(reusebss)
        ASSERT(. <= RAMTOP, "Out of RAM for reusebss");
    }
}
/* vim: set ts=4 sw=4 tw=0 et :*/
