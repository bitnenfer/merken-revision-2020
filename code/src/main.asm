    include "macros.asm"
    include "registers.asm"
    include "memory.asm"
    include "common.asm"
    include "assets/chars.inc"

dummy_vblank_address equ $C000

; =======================
; INTERRUPTS
; =======================
section "VBlank", ROM0[$0040]
    reti

section "LCDS", ROM0[$0048]
    reti

section "Timer", ROM0[$0050]
    reti

section "Serial", ROM0[$0058]
    reti

section "Joypad", ROM0[$0060]
    reti 

section "EndInterrupts", ROM0[$0100]
    nop
; =======================
    jp entry_point

; =======================
; HEADER
; =======================
    ;; NINTENDO LOGO
    db $CE,$ED,$66,$66 
    db $CC,$0D,$00,$0B
    db $03,$73,$00,$83
    db $00,$0C,$00,$0D
    db $00,$08,$11,$1F
    db $88,$89,$00,$0E
    db $DC,$CC,$6E,$E6
    db $DD,$DD,$D9,$99
    db $BB,$BB,$67,$63
    db $6E,$0E,$EC,$CC
    db $DD,$DC,$99,$9F
    db $BB,$B9,$33,$3E

    ;; TITLE
    db "M","E","R","K"  
    db "E","N",$00,$00  
    db $00,$00,$00,$00  
    db $00,$00,$00

    ; GAMEBOY COLOR
    db $00          
    ;; MAKER
    db $00,$00          
    ;; MACHINE
    db $00          
    ;; CARTRIDGE TYPE
    db $01         
    ;; ROM SIZE
    db $01          
    ;; RAM SIZE
    db $00          
    ;; COUNTRY
    db $01          
    ;; GAMEBOY
    db $00          
    ;; ROM VERSION
    db $00          
    ;; NEGATIVE CHECK
    db $67          
    ;; CHECK SUM
    db $00,$00 
; =======================

section "EntryPoint", ROM0[$0150]

entry_point:
; =======================================
;      **** DMG Firewall ****
; =======================================
; Only DMG cool kids can play this demo
; =======================================
; Check we're running on DMG-CPUs
; Accumulator should be $11 on CBG or AGB
    cp $11
    jr nz, .is_dmg
; =======================================
;   jp not_dmg ; <-- Uncomment this to allow only DMG
    xor a
    jr .start    

.is_dmg:
    ld a, 1

.start:
    ld [is_dmg],a           ; Store a 1 or 0 to indicate if the system is DMG.
    ld sp, STACK_TOP        ; Set Stack Pointer
    ld a, %11100100          
    ld [fade_color], a      ; Set initial fade color to default gradient
    call init_dma           ; Load DMA subroutine to HRAM
    call dma_transfer       ; Initialize OAM to 0
    mInitializeMusic        ; Initialize Music
    mSelectSong 0           ; Initialize Song

.demo_run:
    call fx1
    call fx3
    call fx4
    call fx2
    call fx6
    call fx7
    call fx8
    call fx9
    call fx5 ;<-- The end
    
; =======================================
; =======================================

stall::
    ld a, $FF
.w:
    dec a
    jr nz,.w
    ret

stall2::
    ld a, b
.w:
    dec a
    jr nz,.w
    ret

not_dmg:
    call init_dma
    call dma_transfer
    ld a, $FF
    ld [BGP], a
    ld a, %11000100
    ld [OBJP0], a
    mSetROMBank 0
    mSafeVRAMMemcpy chars_data, $8010, chars_data_size
    call fx_write_text
    call dma_transfer
    ld a, [LCDC]
    set 1, a
    ld [LCDC], a
    xor a
    xor a
    ld [text_wave], a
    ld [wave1_offset_idx], a
    ld [offset_x], a
    ld [offset_x2], a
    ld [tmp], a

    ; TODO: show a nice little message
.loop:
    mWaitVBlank
    call fx_animate_text
    call dma_transfer
    jr .loop

fx_write_text:
    ld de, dmg_str
    ld hl, SPRITE0_Y
    ld b, 20  ; X
    ld c, 20    ; Y
.loop:
    ld a, c
    ld [hl+], a ; set Y
    ld a, b
    ld [hl+], a ; set X
    ld a, [de]
    cp $00
    jr z, .clean_up
    ld [hl+], a ; set ID
    inc de
    inc hl
    ld a, b
    add a, 13   ; X offset between char
    ld b, a
    jr .loop
.clean_up:
    xor a
    dec hl
    ld [hl-], a
    ld [hl], a
    ret

fx_animate_text:
    xor a
    ld [text_anim], a
    ld hl, SPRITE0_Y
    ld a, [text_wave]
    ld b, a
    ld d, 100 ; origin y pos
    ld e, (end_dmg_str-dmg_str-1); <- char count
    ld a, [text_wave]
    add a, 5
    ld [text_wave], a
.loop:
    push hl
    ld a, b
    ld h, HIGH(ease_out_bounce)
    ld l, a
    ld a, [hl]
    pop hl
    ld c, a
    ld a, d
    add a, c
    ld [hl+], a
    ld a, [hl]
    dec a
    ld [hl+], a
    ld a, [hl]
    cp $D0
    jr nz, .cont_loop
    dec hl
    dec hl
    xor a
    ld [hl+], a
    ld [hl+], a
.cont_loop:
    inc hl
    inc hl
    ld a, b
    add a, 10
    ld b, a
    dec e
    ret z
    jr .loop

section "DMG", ROM0
dmg_str: incbin "assets/dmg.str"
end_dmg_str:

section "SineWaveTable8", ROM0, ALIGN[8]
sine_wave_table8::
    db $00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02
    db $03,$03,$03,$03,$03,$03,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05
    db $05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07
    db $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
    db $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
    db $07,$07,$07,$07,$07,$06,$06,$06,$06,$06,$06,$06,$06,$06,$05,$05
    db $05,$05,$05,$05,$05,$04,$04,$04,$04,$04,$04,$03,$03,$03,$03,$03
    db $02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FE,$FE,$FE,$FE,$FE,$FE
    db $FD,$FD,$FD,$FD,$FD,$FC,$FC,$FC,$FC,$FC,$FC,$FB,$FB,$FB,$FB,$FB
    db $FB,$FB,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$F9,$F9,$F9,$F9,$F9
    db $F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9
    db $F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9,$F9
    db $F9,$F9,$F9,$F9,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA,$FB,$FB,$FB
    db $FB,$FB,$FB,$FB,$FC,$FC,$FC,$FC,$FC,$FC,$FD,$FD,$FD,$FD,$FD,$FD
    db $FE,$FE,$FE,$FE,$FE,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00
sine_wave_table8_end::


section "BellCurve", ROM0, ALIGN[8]
bell_curve::
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01
    db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$02
    db $02,$02,$02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$03,$03
    db $03,$03,$03,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
    db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$06,$06,$06
    db $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07,$07
    db $07,$07,$07,$07,$07,$07,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
    db $08,$08,$08,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
    db $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0B,$0B,$0B
    db $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0C,$0C,$0C,$0C,$0C,$0C,$0C
    db $0C,$0C,$0C,$0C,$0C,$0C,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D
    db $0D,$0D,$0D,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
    db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$10,$10,$10,$10
    db $10,$10,$10,$10,$10,$10,$10,$10,$10,$11,$11,$11,$11,$11,$11,$11
    db $11,$11,$11,$11,$11,$11,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12
    db $12,$12,$12,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13
bell_curve_end::

section "FadeOutTable", ROM0, ALIGN[8]
fade_out_table::
    db %11100100
    db %11100100
    db %11100100
    db %11101001
    db %11101001
    db %11111001
    db %11111001
    db %11111001
    db %11111010
    db %11111010
    db %11111110
    db %11111110
    db %11111110
    db %11111111
    db %11111111
    db %11111111
fade_out_table_end::

section "FadeInTable", ROM0, ALIGN[8]
fade_in_table::
    db %11111111
    db %11111111
    db %11111111
    db %11111110
    db %11111110
    db %11111110
    db %11111010
    db %11111010
    db %11111001
    db %11111001
    db %11111001
    db %11101001
    db %11101001
    db %11100100
    db %11100100
    db %11100100
fade_in_table_end::

section "CommonVariables", WRAM0
; =================================
; COMMON VARIABLES
; =================================
current_state:: ds 1
next_state:: ds 1
fade_in_offset:: ds 1
fade_out_offset:: ds 1
fade_color:: ds 1
; =================================

load_tiles:: ds $01
fx_counter:: ds $04
continue_running:: ds 1
wave1_offset_idx:: ds $01
offset_x:: ds $01
offset_x2:: ds $01
wave_offset:: ds $01
text_wave:: ds $01
text_anim:: ds $01
text_x:: ds $01
tmp:: ds $02
sp_save:: ds $02
should_load_data:: ds $01
load_step:: ds $01
should_play_music:: ds $01
is_dmg:: ds $01

section "Vectors", WRAM0

timer_interrupt_callback:: ds 2

SECTION "Music",ROMX[$4000],BANK[MusicBank]

INCBIN "assets/carillon.bin"              ; player code and music data

SECTION "Reserved",WRAM0[$c7c0]

ds      $30                     ; $c7c0 - $c7ef for player variables