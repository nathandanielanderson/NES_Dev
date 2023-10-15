;;; Size of PRG in units of 16 KiB.
prg_npage = 1
;;; Size of CHR in units of 8 KiB.
chr_npage = 1
;;; INES mapper number.
mapper = 0
;;; Mirroring (0 = horizontal, 1 = vertical)
mirroring = 1

.segment "INES"
        .byte $4e, $45, $53, $1a
        .byte prg_npage
        .byte chr_npage
        .byte ((mapper & $0f) << 4) | (mirroring & 1)
        .byte mapper & $f0

SEGMENTS {
    ZEROPAGE: load = ZP, type = zp;
    BSS:    load = RAM, type = bss;
    INES:   load = HEADER, type = ro, align = $10;
    CODE:   load = PRG0, type = ro;
    VECTOR: load = PRG0, type = ro, start = $BFFA;
    CHR0a:  load = CHR0a, type = ro;
    CHR0b:  load = CHR0b, type = ro;
}

MEMORY {
    ZP:     start = $0000, size = $0100, type = rw;
    RAM:    start = $0300, size = $0400, type = rw;
    HEADER: start = $0000, size = $0010, type = rw;
            file = %O, fill = yes;
    PRG0:   start = $8000, size = $4000, type = ro;
            file = %O, fill = yes;
    CHR0a:  start = $0000, size = $1000, type = ro;
            file = %O, fill = yes;
    CHR0b:  start = $1000, size = $1000, type = ro;
            file = %O, fill = yes;
}