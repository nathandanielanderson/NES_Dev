.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per  frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"

reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  .
  inx		; now X = 0
  stx $2000	; disable NMI
  stx $2001 	; disable rendering
  stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
vblankwait1:
  bit $2002
  bpl vblankwait1

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

;; second wait for vblank, PPU is ready after this
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
  lda #%10000000	; Enable NMI
  sta $2000
  lda #%00010000	; Enable Sprites
  sta $2001

forever:

  jmp forever

nmi:
  ldx #$00 	; Set SPR-RAM address to 0
  stx $2003
@loop:	lda msg, x 	; Load the msg message into SPR-RAM
  sta $2004
  inx
  cpx #$24 ; 4 * msg lines
  bne @loop
  rti

msg:
  .byte $00, $00, $00, $00 	; Why do I need these here? 
  .byte $6c, $07, $00, $6c
  .byte $6c, $08, $00, $76
  .byte $6c, $20, $00, $80
  .byte $6c, $16, $00, $8A
  .byte $6c, $0E, $00, $94
  .byte $6c, $11, $00, $9E 	; ADDED
  .byte $6c, $0B, $00, $A8 	; ADDED
  .byte $6c, $03, $00, $B2 	; ADDED
  

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

; Character memory
.segment "CHARS"
  .byte %00111100 ; A (00)
  .byte %01111110
  .byte %11100111
  .byte %11000011
  .byte %11000011
  .byte %11111111
  .byte %11000011
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111110 ; B (01)
  .byte %11000011
  .byte %11000011
  .byte %11111110
  .byte %11000011
  .byte %11000011
  .byte %11111111
  .byte %11111110
  .byte $00, $00, $00, $00, $00, $00, $00, $00 

  .byte %01111110 ; C (02)
  .byte %11111111
  .byte %11000011
  .byte %11000000
  .byte %11000000
  .byte %11000011
  .byte %11111111
  .byte %01111110
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111100 ; D (03)
  .byte %11111110
  .byte %11000111
  .byte %11000011
  .byte %11000011
  .byte %11000111
  .byte %11111110
  .byte %11111100
  .byte $00, $00, $00, $00, $00, $00, $00, $00
    
  .byte %11111111 ; E (04)
  .byte %11111111
  .byte %11100000
  .byte %11111110
  .byte %11111110
  .byte %11100000
  .byte %11111111
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111111 ; F (05)
  .byte %11111111
  .byte %11100000
  .byte %11111110
  .byte %11111110
  .byte %11100000
  .byte %11100000
  .byte %11100000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111110 ; G (06)
  .byte %11111111
  .byte %11000011
  .byte %11000000
  .byte %11001111
  .byte %11000011
  .byte %11111111
  .byte %01111110
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  
  .byte %11000011 ; H (07)
  .byte %11000011
  .byte %11000011
  .byte %11111111
  .byte %11111111
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  
  .byte %11111111 ; I (08)
  .byte %11111111
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %11111111
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111111 ; J (09)
  .byte %01111111
  .byte %00001100
  .byte %00001100
  .byte %00001100
  .byte %11001100
  .byte %11111100
  .byte %01111000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000011 ; K (0A)
  .byte %11000111
  .byte %11001110
  .byte %11111100
  .byte %11111100
  .byte %11001110
  .byte %11000111
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11100000 ; L (0B)
  .byte %11100000
  .byte %11100000
  .byte %11100000
  .byte %11100000
  .byte %11100000
  .byte %11111111
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000011 ; M (0C)
  .byte %11000011
  .byte %11100111
  .byte %11111111
  .byte %11111111
  .byte %11011011
  .byte %11011011
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000011 ; N (0D)
  .byte %11100011
  .byte %11110011
  .byte %11111011
  .byte %11011111
  .byte %11001111
  .byte %11000111
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %00111100 ; O (0E)
  .byte %01111110
  .byte %11100111
  .byte %11000011
  .byte %11000011
  .byte %11100111
  .byte %01111110
  .byte %00111100
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111110 ; P (0F)
  .byte %11111111
  .byte %11100011
  .byte %11100011
  .byte %11111110
  .byte %11100000
  .byte %11100000
  .byte %11100000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111110 ; Q (10)
  .byte %11111111
  .byte %11000011
  .byte %11000011
  .byte %11001011
  .byte %11000111
  .byte %11111110
  .byte %01111101
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111110 ; R (11)
  .byte %11111111
  .byte %11100011
  .byte %11100011
  .byte %11111110
  .byte %11111100
  .byte %11100110
  .byte %11100011
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111110 ; S (12)
  .byte %11111111
  .byte %11000000
  .byte %11111110
  .byte %01111111
  .byte %00000011
  .byte %11111111
  .byte %01111110
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111111 ; T (13)
  .byte %11111111
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000011 ; U (14)
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11111111
  .byte %01111110
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000011 ; V (15)
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11100111
  .byte %01111110
  .byte %00111100
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000011 ; W (16)
  .byte %11000011
  .byte %11011011
  .byte %11011011
  .byte %11111111
  .byte %11111111
  .byte %11100111
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000011 ; X (17)
  .byte %11100111
  .byte %01100110
  .byte %00111100
  .byte %00111100
  .byte %01100110
  .byte %11100111
  .byte %11000011
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11000011 ; Y (18)
  .byte %11000011
  .byte %01100110
  .byte %00111100
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %11111111 ; Z (19)
  .byte %11100111
  .byte %00001110
  .byte %00011100
  .byte %00111000
  .byte %01110000
  .byte %11100111
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00