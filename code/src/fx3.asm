section "fx3", ROM0

    include "registers.asm"
    include "memory.asm"
    include "common.asm"

    include "assets/matapaco.inc"
    include "assets/chars.inc"

fx3_COUNTER1 equ $FF
fx3_COUNTER2 equ $FF
fx4_SCROLL_DELAY equ 3

fx3::
	ld a, [LCDC]
	res 5, a
	res 1, a
	ld [LCDC], a

	mResetFadeVariables
    mResetLoader
    mResetVars
    mSetStates STATE_WAIT_LOAD, STATE_WAIT_LOAD
    mEnableLoading

    ; clear bottom
    mSafeVRAMMemset 0, $9A40, 441

    ld a, $80
    ld [SCY], a

    mLoadIn4SongUpdatesBANK chars_data, $8B30, chars_data_size, 0
    ; mUpdateMusic

	mSetROMBank 3
    mSafeVRAMMemcpy matapaco_map, $9800, matapaco_map_size

    call fx_write_text
    call dma_transfer

    xor a
	ld [start_scroll], a
	ld [stall_scroll], a
	ld [ease_offset], a
	ld [start_ease], a
	ld [tmp], a
    ld [$9A40], a

    ld a, 1
    ld [scroll_delay], a
    
	call fx3_loop
	ret

fx3_loop:
    ld a, [tmp]
    inc a
    inc a
    inc a
    ld [tmp], a

	mUpdateMusicWaitVBlank
	mDefineFadeLogicWithTables fx3_fade_in_table, fx3_fade_in_table_end, fx3_fade_out_table, fx3_fade_out_table_end
	mUpdateBackground
	ld a, %00110100
	ld [OBJP0], a
	mSetROMBank 3
	mLoadDataIn32Frames matapaco_data, $8000, matapaco_data_size, on_load_complete

	ld a, [fx_counter]
    inc a
    cp fx3_COUNTER1
    jr nz, .end_scene

    ld a, [fx_counter+1]
    inc a
    cp fx3_COUNTER2
    jr nz, .end_scene1

    mSetStates STATE_END_FX, STATE_END_FX

.end_scene1:
    ld [fx_counter+1], a
    jr .cont

.end_scene:
    ld [fx_counter], a

.cont:
	ld a, [start_ease]
	cp $00
	jr z, .check_scroll
	ld a, [wait_ease]

	cp $30
	jr nz, .inc_wait_ease

    ld a, [LCDC]
	set 1, a
	ld [LCDC], a

	ld h, HIGH(ease_out_elastic)
	ld a, [ease_offset]
	cp $FF
	jr z, .check_scroll
	ld l, a
	inc a
	ld [ease_offset], a
	ld a, [hl]
	ld [SCY], a
	jr .check_scroll

.inc_wait_ease:
	inc a
	ld [wait_ease], a

.check_scroll:
	ld a, [start_scroll]
	cp $00
	jr z, .end

	ld a, [stall_scroll]
	inc a
	ld [stall_scroll], a
	cp $2
	jr nz, .end

	ld a, [SCY]
	cp $00
	jr z, .scroll_complete
	inc a
	ld [SCY], a

	xor a
	ld [stall_scroll], a
	jr .end

.scroll_complete:
	ld a, 1
	ld [start_fadein], a
	xor a
	ld [start_scroll], a
    mSetStates STATE_FADE_IN, STATE_RUN_FX
    ld a, 1
    ld [start_ease], a
    ld a, 0
    ld [wait_ease], a
    ld a, fx3_COUNTER1
    ld [fx_counter], a
    ld a, fx3_COUNTER2
    ld [fx_counter+1], a

.end:
	call fx_animate_text
    call dma_transfer

    ld a, [tmp]
    ld h, HIGH(sine_wave_table8)
    ld l, a
    ld a, [hl]
    ld [SCX], a

    ld a, [current_state]
    cp STATE_END_FX
    ret z
    jp fx3_loop

on_load_complete:
	mDisableLoading
    mSetStates STATE_FADE_OUT, STATE_RUN_FX
	ld a, 1
	ld [start_scroll], a
	ret

fx_animate_text:
    xor a
    ld [text_anim], a
    ld hl, SPRITE0_Y
    ld a, [text_wave]
    ld b, a
    ld d, 35 ; origin y pos
    ld e, (matapacos_str_end-matapacos_str-1); <- char count
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
    ld h, HIGH(ease_out_bounce)
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
    jr .loop_no_move

.loop_move:
    ld a, fx4_SCROLL_DELAY
    ld [scroll_delay], a

.loop_move2:
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
    jr nz, .cont_loop2
    dec hl
    dec hl
    xor a
    ld [hl+], a
    ld [hl+], a
.cont_loop2:
    inc hl
    inc hl
    ld a, b
    add a, 10
    ld b, a
    dec e
    ret z
    jr .loop_move2

; Don't call this every frame!
fx_write_text:
    ld de, matapacos_str
    ld hl, SPRITE0_Y
    ld b, -120  ; X
    ld c, 24    ; Y
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

matapacos_str:: incbin "assets/matapacos.str"
matapacos_str_end::

section "fx3Vars", WRAM0
start_scroll: ds $01
stall_scroll: ds $01
start_fadein: ds $01
start_ease: ds $01
ease_offset: ds $01
wait_ease: ds $01
scroll_delay:: ds $01
curr_wave:: ds $01

section "EaseOutElastic", ROM0, ALIGN[8]
ease_out_elastic::
    db $00,$00,$00,$00,$FF,$FE,$FE,$FD,$FC,$FB,$FA,$F9,$F8,$F6,$F5,$F4
    db $F2,$F1,$F0,$EE,$ED,$EB,$EA,$E8,$E7,$E6,$E4,$E3,$E2,$E1,$E0,$DF
    db $DE,$DD,$DC,$DB,$DA,$DA,$D9,$D9,$D8,$D8,$D8,$D7,$D7,$D7,$D7,$D7
    db $D7,$D8,$D8,$D8,$D8,$D9,$D9,$DA,$DA,$DA,$DB,$DB,$DC,$DC,$DD,$DD
    db $DD,$DE,$DE,$DF,$DF,$DF,$E0,$E0,$E0,$E0,$E0,$E0,$E1,$E1,$E1,$E1
    db $E1,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$DF,$DF,$DF,$DF,$DE,$DE,$DE,$DE
    db $DE,$DD,$DD,$DD,$DD,$DD,$DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC
    db $DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC,$DD,$DD,$DD,$DD,$DD,$DD
    db $DD,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DF,$DF,$DF,$DF,$DF
    db $DF,$DF,$DF,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE
    db $DE,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD
    db $DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD
    db $DD,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE
    db $DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE
    db $DE,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD
    db $DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD

section "EaseOutBounce", ROM0, ALIGN[8]
ease_out_bounce::
    db $01,$00,$00,$00,$00,$00,$FF,$FF,$FE,$FE,$FE,$FD,$FD,$FC,$FC,$FC
    db $FB,$FB,$FB,$FA,$FA,$FA,$F9,$F9,$F9,$F8,$F8,$F8,$F7,$F7,$F7,$F6
    db $F6,$F6,$F6,$F5,$F5,$F5,$F5,$F4,$F4,$F4,$F4,$F4,$F3,$F3,$F3,$F3
    db $F3,$F3,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2
    db $F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F3
    db $F3,$F3,$F3,$F3,$F3,$F4,$F4,$F4,$F4,$F4,$F5,$F5,$F5,$F5,$F6,$F6
    db $F6,$F7,$F7,$F7,$F7,$F8,$F8,$F8,$F9,$F9,$F9,$FA,$FA,$FA,$FB,$FB
    db $FC,$FC,$FC,$FD,$FD,$FD,$FE,$FE,$FF,$FF,$FF,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$FF,$FF,$FF,$FE,$FE,$FD,$FD,$FD,$FC,$FC,$FC
    db $FB,$FB,$FA,$FA,$FA,$F9,$F9,$F9,$F8,$F8,$F8,$F7,$F7,$F7,$F7,$F6
    db $F6,$F6,$F5,$F5,$F5,$F5,$F4,$F4,$F4,$F4,$F4,$F3,$F3,$F3,$F3,$F3
    db $F3,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2
    db $F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F2,$F3,$F3
    db $F3,$F3,$F3,$F3,$F4,$F4,$F4,$F4,$F4,$F5,$F5,$F5,$F5,$F6,$F6,$F6
    db $F6,$F7,$F7,$F7,$F8,$F8,$F8,$F9,$F9,$F9,$FA,$FA,$FA,$FB,$FB,$FB
    db $FC,$FC,$FC,$FD,$FD,$FE,$FE,$FE,$FF,$FF,$00,$00,$00,$00,$00,$00

section "FadeOutTableFx3", ROM0, ALIGN[8]
fx3_fade_out_table:
    db %11111111
    db %11111111
    db %11111110
    db %11111110
    db %11111101
    db %11111101
    db %11111100
    db %11111100
    db %11111100
    db %11111100
    db %11111100
    db %11111100
fx3_fade_out_table_end:

section "FadeInTableFx3", ROM0, ALIGN[8]
fx3_fade_in_table:
    db %11111100
    db %11111100
    db %11111100
    db %11111000
    db %11111000
    db %11111000
    db %11101000
    db %11101000
    db %11101000
    db %11101000
    db %11100100
    db %11100100
fx3_fade_in_table_end:

section "fx3Data", ROMX,BANK[3]
matapaco_data: incbin "assets/matapaco.td"
matapaco_map: incbin "assets/matapaco.tm"
