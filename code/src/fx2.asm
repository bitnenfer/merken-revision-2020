section "fx2", ROM0

    include "registers.asm"
    include "memory.asm"
    include "common.asm"

    ; Assets
    include "assets/chars.inc"
    include "assets/twister.inc"

WAVE0_DATA_SIZE equ $1f
WAVE1_DATA_SIZE equ $7f
TEXT_ANIM_DELAY equ $02

fx2_COUNTER1 equ $FF
fx2_COUNTER2 equ $FF
fx2_COUNTER3 equ $FF
fx2_COUNTER4 equ $FF
fx2_SCROLL_DELAY equ 3

fx2::
    mResetFadeVariables
    mResetLoader
    mResetVars

    mSetStates STATE_WAIT_LOAD, STATE_WAIT_LOAD

    ; enable window
    ld a, [LCDC]
    set 5, a
    set 6, a ; use tiles from $9C00
    res 1, a
    ld [LCDC], a
    ld a, 110
    ld [WY], a

    ld a, 1
    ld [continue_running], a

    ; Add Data Streaming to this effect! 
    mSetROMBank 2
    mSafeVRAMMemcpy twister_map, $9800, twister_map_size
    mUpdateMusic
    mSetROMBank 2
    mSafeVRAMMemcpy twister_map, $9A40, $9C00-$9A40
    mUpdateMusic


    mSetROMBank 3
    mMemcpy wave_data2, wave_data2_copy, 128

    mSetROMBank 3
    mMemcpy wave_data1, wave_data1_copy, 128

    ld a, $01
    ld [should_load_data], a

    ld a, %11000100
    ld [OBJP0], a

    ; Set SCY Starting point 
    ld a, 20
    ld [SCY], a

    ld a,1
    ld [text_x],a
    ld [scroll_delay], a

    xor a
    ld [text_wave], a
    ld [wave1_offset_idx], a
    ld [offset_x], a
    ld [offset_x2], a
    ld [fx_counter], a
    ld [fx_counter+1], a
    ld [fx_counter+2], a
    ld [fx_counter+3], a
    ld [tmp], a

    ld a, TEXT_ANIM_DELAY - 1
    ld [text_anim], a


    call fx_write_text

    ; *********************************
    ; DON'T write anything after this.
    ; *********************************
    call fx_loop
    ret
; =================================
; FX LOOP
; =================================
fx_loop:

    call fx_on_timer

    ld a, [tmp]
    cp $01
    jr nz, .is_loading
    jp .after_loading

.is_loading:
    mUpdateMusic
    mWaitVBlank
    mSetROMBank 2
    mLoadDataIn89Frames twister_data, $8000, twister_data_size, on_load_complete

    jp fx_loop

.after_loading:
    mUpdateMusic
    call dma_transfer
    call fx_animate_text


    xor a                           ; Reset SCX to avoid residual 
    ld [SCX], a                     ;  offset on scroll X after prev frame
    ld a,[offset_x2]                ; Load the scanline scroll offset
    inc a                           ; Increment the offset
    ld [offset_x2],a                ; Store the offset in memory
    ld d,a                          ; Save it for future use and to avoid
                                    ;  memory access inside hot loop
.wait0:
    ld a,[LY]
    cp 0
    jr nz, .wait0                   ; Wait for scanline to reset to 0
    ld b, 0                         ; Set B to be the scanline where we will
                                    ;  the wave displacement
; =====================  
; START SCANLINE EFFECT
; =====================  
.test_limit:
    ld a,[LY]
    cp 110                          ; Check if we've reached the bottom of
    jr z, .next                     ;  the effect which is a couple of pixels
    jr nc, .next                    ;  before VBLANK.
.wait_ly:                           ; If we haven't we wait for 
    ld a,[LY]                       ;  the scanline to be equal to B
    cp b                            ;  our target scanline for displacement
    jr c, .wait_ly                  ;  stall until LY == B
    add a, d                        ; To the current scanline we add the scroll offset
    and WAVE1_DATA_SIZE             ; Mask the value so we don't overflow the table
    ld l, a
    ld h,HIGH(wave_data1_copy)
    ld a, [hl]                      ; Load to A the value of the offset address in the table
    add a, d                        ; Add the offset so we can do scrolling + displacement
    ld [SCX], a                     ; Store it in the LCD scroll X register.
    ld h,HIGH(wave_data2_copy)      ; Do the same thing but with a different wave table
    ld a, [hl]                      ;  on the LCD scroll Y register. 
    add a, 50
    ld [SCY], a                     
    inc b                           ; Increment B an prepare for the next scanline
    jr .test_limit
.next:
; =====================  
    xor a
    ld [SCX], a
    ld [SCY], a
    ld a, [fade_color]
    ld [BGP], a
    ld a, [current_state]
    cp STATE_END_FX
    ret z
    jp fx_loop
; =================================

; =================================
; TIMER CALLBACK
; =================================
fx_on_timer:

    ld a, [tmp]
    cp $01
    ret nz

    ld a, [wave1_offset_idx]
    add a, 4
    ld [wave1_offset_idx], a

    mDefineFadeLogic

    ld a, [fade_color]
    ld [OBJP0], a

    ld a, [current_state]
    cp STATE_RUN_FX

    ret nz

    ld a, [fx_counter]
    inc a
    cp fx2_COUNTER1
    jr nz, .end_scene

    ld a, [fx_counter+1]
    inc a
    cp fx2_COUNTER2
    jr nz, .end_scene1

    ld a, [fx_counter+2]
    inc a
    cp fx2_COUNTER3
    jr nz, .end_scene2

    ld a, [fx_counter+3]
    inc a
    cp fx2_COUNTER4
    jr nz, .end_scene3

    mSetStates STATE_FADE_OUT, STATE_END_FX

.end_scene3:
    ld [fx_counter+3], a
    ld a,%11000100
    ld [OBJP0], a
    ret

.end_scene2:
    ld [fx_counter+2], a
    ld a,%11000100
    ld [OBJP0], a

    ret

.end_scene1:
    ld [fx_counter+1], a
    ld a,%11000100
    ld [OBJP0], a

    ret

.end_scene:
    ld [fx_counter], a
    ld a,%11000100
    ld [OBJP0], a

    ret
; =================================

; =================================
; TIMER CALLBACK
; =================================

fx_animate_text:
    xor a
    ld [text_anim], a
    ld hl, SPRITE0_Y
    ld a, [text_wave]
    ld b, a
    ld d, 140 ; origin y pos
    ld e, (hello_world_end-hello_world-1); <- char count
    ld a, [text_wave]
    add a, 5
    ld [text_wave], a

    ld a, [scroll_delay]
    dec a
    ld [scroll_delay], a
    jr z, .loop_move

.loop_no_move:
    push hl
    ld a, b
    ld h, HIGH(sine_wave_table8)
    ld l, a
    ld a, [hl]
    pop hl
    ld c, a
    ld a, d
    add a, c
    ld [hl+], a
    ld a, [hl]
    ;dec a
    ld [hl+], a
    inc hl
    inc hl
    ld a, b
    add a, 30
    ld b, a
    dec e
    ret z
    jr .loop_no_move

.loop_move:
    ld a, fx2_SCROLL_DELAY
    ld [scroll_delay], a
.loop_move2:
    push hl
    ld a, b
    ld h, HIGH(sine_wave_table8)
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
    inc hl
    inc hl
    ld a, b
    add a, 30
    ld b, a
    dec e
    ret z
    jr .loop_move2


; Don't call this every frame!
fx_write_text:
    ld de, hello_world
    ld hl, SPRITE0_Y
    ld b, 35  ; X
    ld c, 16    ; Y
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
    add a, 15   ; X offset between char
    ld b, a
    jr .loop
.clean_up:
    xor a
    dec hl
    ld [hl-], a
    ld [hl], a
    ret

on_load_complete:
    mSetStates STATE_FADE_IN, STATE_RUN_FX
    ld a,[LCDC]
    set 1, a
    ld [LCDC], a
    ld a, $01
    ld [tmp], a
    ret

; ASSETS
chars_data:: incbin "assets/chars.td"
hello_world: incbin "assets/intro_text.str"
hello_world_end:

SECTION "WaveData1", ROMX,BANK[3],ALIGN[8]
wave_data1:
    db $00,$00,$00,$00,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$04
    db $04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
    db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$04,$04,$04,$04
    db $04,$03,$03,$03,$03,$02,$02,$02,$02,$01,$01,$01,$01,$00,$00,$00
    db $00,$00,$00,$FF,$FF,$FF,$FF,$FE,$FE,$FE,$FE,$FD,$FD,$FD,$FD,$FC
    db $FC,$FC,$FC,$FC,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB
    db $FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FB,$FC,$FC,$FC,$FC
    db $FC,$FD,$FD,$FD,$FD,$FE,$FE,$FE,$FE,$FF,$FF,$FF,$00,$00,$00,$00


SECTION "WaveData2", ROMX,BANK[3],ALIGN[8]
wave_data2:
    db $00,$02,$04,$07,$09,$0B,$0E,$10,$12,$14,$16,$18,$1A,$1C,$1E,$20
    db $22,$23,$25,$26,$28,$29,$2A,$2B,$2C,$2D,$2E,$2E,$2F,$2F,$2F,$2F
    db $2F,$2F,$2F,$2F,$2E,$2E,$2D,$2C,$2C,$2B,$29,$28,$27,$26,$24,$22
    db $21,$1F,$1D,$1B,$19,$17,$15,$13,$11,$0F,$0C,$0A,$08,$05,$03,$01
    db $FF,$FD,$FB,$F8,$F6,$F4,$F1,$EF,$ED,$EB,$E9,$E7,$E5,$E3,$E1,$DF
    db $DE,$DC,$DA,$D9,$D8,$D7,$D5,$D4,$D4,$D3,$D2,$D2,$D1,$D1,$D1,$D1
    db $D1,$D1,$D1,$D1,$D2,$D2,$D3,$D4,$D5,$D6,$D7,$D8,$DA,$DB,$DD,$DE
    db $E0,$E2,$E4,$E6,$E8,$EA,$EC,$EE,$F0,$F2,$F5,$F7,$F9,$FC,$FE,$00

section "fx2Data", ROMX,BANK[2]
twister_data: incbin "assets/twister.td"
twister_map: incbin "assets/twister.tm"


section "WaveData1Copy", WRAM0, ALIGN[8]
wave_data1_copy: ds $ff

section "WaveData2Copy", WRAM0, ALIGN[8]
wave_data2_copy: ds $ff