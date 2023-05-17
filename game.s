.segment "HEADER"
  .byte $4E, $45, $53, $1A ; iNES header 
  .byte $02, $01           ; 2x 16KB PRG code,  1x  8KB CHR data
  .byte $01, $00           ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) jumnp ot the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

.segment "ZEROPAGE"
; Variables
buttons: .res 1 ; we reserve one byte for storing the data that is read from controller
x_scroll: .res 1
y_scroll: .res 1

; Main code segment for the program
.segment "CODE"

;constants for known addressses
JOYPAD1 = $4016
JOYPAD2 = $4017
PPUSCROLL = $2005
PLAYER_SPRITE_Y = $0200
PLAYER_SPRITE_X = $0203
PLAYERBULLET_SPRITE_Y = $0204
PLAYERBULLET_SPRITE_X = $0207

;other constants 
BUTTON_A      = 1 << 7
BUTTON_B      = 1 << 6
BUTTON_SELECT = 1 << 5
BUTTON_START  = 1 << 4
BUTTON_UP     = 1 << 3
BUTTON_DOWN   = 1 << 2
BUTTON_LEFT   = 1 << 1
BUTTON_RIGHT  = 1 << 0

PLAYER_MOVE_SPEED = 2
PLAYER_BULLET_SPEED = 3

PLAYER_BOUNDS_X_MIN = 8
PLAYER_BOUNDS_X_MAX = 240
PLAYER_BOUNDS_Y_MIN = 64
PLAYER_BOUNDS_Y_MAX = 208


reset: ; is run once after power on or reset
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
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne clear_memory

;; second wait for vblank, PPU is ready after this
vblankwait2:
  bit $2002
  bpl vblankwait2

main:
  lda $2002
  lda #$3f
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
@looppalettes:
  lda palettes, x
  sta $2007
  inx
  cpx #$20
  bne @looppalettes

  ldx #$00 	; set x to 0
@loopsprites:	lda sprites, x 	; Load sprites to $0200-$02FF
  sta $0200, x
  inx
  cpx #60 ;15 sprites, 4 bytes per sprite
  bne @loopsprites

enable_rendering:
  lda #%10010000	; Enable NMI, background pattern table 1, sprite pattern table 0
  sta $2000
  lda #%00010110	; Enable Sprites only #0
  ; lda #%00011110	; Enable Sprites and background #9
  sta $2001

forever:
  jmp forever

nmi: ; is executed every frame

; ;do background scrolling #10
;   lda $2002       ; Scrolling
;   ldx x_scroll  
;   stx PPUSCROLL   ; write x scroll position to PPU
;   ldx y_scroll    
;   dex             ; Scroll down 1 pixel
;   cpx #$ff        ; if y_scroll position is 255 then change it to 239 as y-axis only has 240 pixels
;   bne scroll_ok
;   ldx #239
; scroll_ok:
;   stx y_scroll 
;   stx PPUSCROLL   ; write y scroll position to PPU

;do DMA transfer of sprite data in $0200-$02FF to PPU OAM
  LDA #$00
  STA $2003  ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014  ; set the high byte (02) of the RAM address, start the transfer


  ; ;move sprite position #2
  ; ldx PLAYER_SPRITE_Y
  ; dex
  ; stx PLAYER_SPRITE_Y

; ;read controllers #3
;   jsr readcontroller1

; ;move player position #4
;   lda buttons
;   and #BUTTON_LEFT
;   beq notMoveLeft
;   ldx PLAYER_SPRITE_X
;   dex
;   stx PLAYER_SPRITE_X
; notMoveLeft:
;   lda buttons
;   and #BUTTON_RIGHT
;   beq notMoveRight
;   ldx PLAYER_SPRITE_X
;   inx
;   stx PLAYER_SPRITE_X
; notMoveRight:
;   lda buttons
;   and #BUTTON_UP
;   beq notMoveUp
;   ldx PLAYER_SPRITE_Y
;   dex
;   stx PLAYER_SPRITE_Y
; notMoveUp:
;   lda buttons
;   and #BUTTON_DOWN
;   beq notMoveDown
;   ldx PLAYER_SPRITE_Y
;   inx
;   stx PLAYER_SPRITE_Y
; notMoveDown:

; ;move player position advanced  #11
;   lda buttons
;   and #BUTTON_LEFT
;   beq notMoveLeft
;   lda PLAYER_SPRITE_X
;   sec
;   sbc #PLAYER_MOVE_SPEED
;   cmp #PLAYER_BOUNDS_X_MIN
;   bcc notMoveLeft
;   sta PLAYER_SPRITE_X
; notMoveLeft:
;   lda buttons
;   and #BUTTON_RIGHT
;   beq notMoveRight
;   lda PLAYER_SPRITE_X
;   clc
;   adc #PLAYER_MOVE_SPEED
;   cmp #PLAYER_BOUNDS_X_MAX
;   bcs notMoveRight
;   sta PLAYER_SPRITE_X
; notMoveRight:
;   lda buttons
;   and #BUTTON_UP
;   beq notMoveUp
;   lda PLAYER_SPRITE_Y
;   sec
;   sbc #PLAYER_MOVE_SPEED
;   cmp #PLAYER_BOUNDS_Y_MIN
;   bcc notMoveUp
;   sta PLAYER_SPRITE_Y
; notMoveUp:
;   lda buttons
;   and #BUTTON_DOWN
;   beq notMoveDown
;   lda PLAYER_SPRITE_Y
;   clc
;   adc #PLAYER_MOVE_SPEED
;   cmp #PLAYER_BOUNDS_Y_MAX
;   bcs notMoveDown
;   sta PLAYER_SPRITE_Y
; notMoveDown:

; ;fire bullet  #7
;   lda buttons
;   and #BUTTON_A
;   beq noBulletFire
;   ;check if bullet already active, can only fire if no bullet active
;   lda PLAYERBULLET_SPRITE_X
;   cmp #$ff ; if x position is 255 then no bullet active
;   bne noBulletFire
;   ;spawn bullet at player position
;   lda PLAYER_SPRITE_Y
;   sta PLAYERBULLET_SPRITE_Y
;   lda PLAYER_SPRITE_X
;   sta PLAYERBULLET_SPRITE_X
; noBulletFire:

; moveBullets: #8
;   lda PLAYERBULLET_SPRITE_Y
;   sec
;   sbc #PLAYER_BULLET_SPEED
;   sta PLAYERBULLET_SPRITE_Y
;   cmp #240 ; if y position >= 240 then move bullet off screen (x->255)
;   bcc bullet_ok
;   lda #$ff
;   sta PLAYERBULLET_SPRITE_X 
; bullet_ok:

rti


sprites: ;ypos, char, attr, xpos
  .byte 110, $11, $00, 30 ;H
  .byte 110, $0e, $00, 40 ;E
  .byte 110, $15, $00, 50 ;L
  .byte 110, $15, $00, 60 ;L
  .byte 110, $18, $00, 70 ;O

  .byte 80, $1d, $00, 90;T
  .byte 90, $0e, $00, 100 ;E
  .byte 100, $1a, $00, 110 ;Q
  .byte 110, $17, $00, 120 ;N
  .byte 120, $0A, $00, 130 ;A
  .byte 130, $1d, $00, 140 ;T
  .byte 140, $12, $00, 150 ;I
  .byte 150, $18, $00, 160 ;O
  .byte 160, $17, $00, 170 ;N
  .byte 170, $24, $00, 180 ;!

palettes:
  ; Background Palette
  .byte $0f, $20, $12, $01 ; stars
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

  ; Sprite Palette
  .byte $0f, $31, $21, $06 ; used for player
  .byte $0f, $16, $00, $27 ; used for bullet
  .byte $0f, $13, $23, $00
  .byte $0f, $12, $22, $00


.include "buttons.inc"


; Character memory
.segment "CHARS"

.incbin "font.chr" ;#5
; .include "chars.inc" ;#6
