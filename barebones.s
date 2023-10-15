.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4e, $45, $53, $1a
  .byte 2                 ; 2x 16KB PRG code
  .byte 1                 ; 1x 8KB CHR data
  .byte $01, $00          ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first truns on or is reset, it will jumpt to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"

reset:
  sei       ; disable IRQs
  cld       ; disable decimal mode
  ldx #$40
  stx $4017 ; disable APU fram IRQ
  ldx #$ff  ; Set up stack
  txs       ; .
  inx       ; now X = 0
  stx $2000 ; disable NMI
  stx $2001 ; disable rendering
  stx $4010 ; disable DMC IRQs