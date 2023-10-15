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
  sei           ; disable IRQs
  cld           ; disable decimal mode
  ldx #$40
  stx $4017     ; disable APU fram IRQ
  ldx #$ff      ; Set up stack
  txs           ; .
  inx           ; now X = 0
  stx $2000     ; disable NMI
  stx $2001     ; disable rendering
  stx $4010     ; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
vblankwait1:
  bit $2002   ; Accumulator ^ Memory Location, Mem[7] -> N-flag, Mem[6] -> V-flag
  bpl vblankwait1 ; Branch on N = 0

clear_memory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x    ; [Address], x :
  sta $0300, x    ; X-Indexed Absolute
  sta $0500, x    ; adds X register to address
  sta $0600, x    ; so incrementing X until it 
  sta $0400, x    ; flips resulting in #$00 being
  sta $0700, x    ; loaded from $0000 thru $07FF
  inx
  bne clear_memory

;; second wait for vblank, PPU is ready sfter this
vblankwait2:
  bit $2002
  bpl vblankwait2

main:
load_palettes:
  lda $2002
  lda #$3f
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
@loop:
  lda palettes, x 
  sta $2007
  inx
  cpx #$20
  bne @loop

enable_rendering:
  lda #%10000000  ; Enable NMI
  sta $2000
  lda #%00010000  ; Enable Sprites
  sta $2001

forever:

  jmp forever

nmi:
ldx #$00    ; Set SPR-RAM address to 0
stx $2003
rti

palettes:
; Background Palette
.byte $0f, $00, $00, $00
.byte $0f, $00, $00, $00
.byte $0f, $00, $00, $00
.byte $0f, $00, $00, $00

; Sprite Palette
.byte $0f, $20, $00, $00
.byte $0f, $00, $00, $00
.byte $0f, $00, $00, $00
.byte $0f, $00, $00, $00
