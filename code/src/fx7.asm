section "fx7", ROM0

    include "registers.asm"
    include "memory.asm"
    include "common.asm"

	include "assets/gradient.inc"

DELAY equ 1
fx7_COUNTER1 equ $FF
fx7_COUNTER2 equ $FF
fx7_COUNTER3 equ $10

fx7::
	mResetFadeVariables
    mResetLoader
    mResetVars
    mSetStates STATE_FADE_IN, STATE_RUN_FX
    mEnableLoading

    mSetROMBank 3

    ld de,gradient_data
    ld hl,$8C00
    ld bc,gradient_data_size
    call safe_vram_memcpy

    xor a
    ld hl,VRAM_BGMAP0_START
    ld bc,VRAM_BGMAP0_END-VRAM_BGMAP0_START
    call unsafe_memset

    xor a
    ld [current_index],a
    ld [frames_rendered],a
    ld [fx_counter], a
    ld [fx_counter+1], a
    ld [fx_counter+2], a

    ld a, 32
    ld [current_index],a
    
    ld h,high(frame_list)
    ld a,[current_index]
    and a,$01
    rl a
    ld l,a
    ld a,[hl+]
    ld [current_frame],a
    ld a,[hl+]
    ld [current_frame+1],a


    ld a,high(tiles_start)
    ld [current_frame],a
    ld a,low(tiles_start)
    ld [current_frame+1],a

    ld a, %11100100
    ld [BGP], a

    ld a, DELAY
    ld [delay], a

    call fx7_loop
	ret

fx7_loop:
	mUpdateMusic
	mDefineFadeLogic
	mUpdateBackground

    ld a, [fx_counter]
    inc a
    cp fx7_COUNTER1
    jr nz, .end_scene

    ld a, [fx_counter+1]
    inc a
    cp fx7_COUNTER2
    jr nz, .end_scene1

    ld a, [fx_counter+2]
    inc a
    cp fx7_COUNTER3
    jr nz, .end_scene2

    ld a, [current_state]
    cp STATE_RUN_FX
    jr nz, .end_scene2
    mResetFadeVariables
    mSetStates STATE_FADE_OUT, STATE_END_FX

.end_scene2:
    ld [fx_counter+2], a
    jr .cont

.end_scene1:
    ld [fx_counter+1], a
    jr .cont

.end_scene:
    ld [fx_counter], a

.cont:
	
	ld a, [delay]
	dec a
	ld [delay], a
	jr nz, .vblank
	ld a, DELAY
	ld [delay], a
	call run_fx
	jr .skipvblank
.vblank:
	mWaitVBlank
.skipvblank:
	mJumpCheckEnding fx7_loop

run_fx:

.render_frame:
    ld a,[current_frame]
    ld d,a
    ld a,[current_frame+1]
    ld e,a
    ld hl,VRAM_BGMAP0_START
    ld c,18
.render_line:
    mSetROMBank 3
    rept 20
    ld a,[de]
    ld [hl+],a
    inc de
    endr
    dec c
    ld a,c
    ld [temp_y],a
    ld bc,$000C
    add hl,bc
    ld a,[temp_y]
    ld c,a
    jr nz,.render_line

    ld a,[frames_rendered]
    inc a
    ld [frames_rendered],a
    and $03
    jr nz,.render_frame

.change_frame:
    ld a,[current_index]
    inc a
    and %111111
    ld [current_index],a
    ld h,high(frame_list)
    rl a
    ld l,a
    ld a,[hl+]
    ld [current_frame+1],a
    ld a,[hl+]
    ld [current_frame],a

    mWaitVBlank

	ret


gradient_data: incbin "assets/gradient.td"

section "frame_list", ROM0, ALIGN[8]
frame_list:
    dw tile_1, tile_1, tile_1, tile_1,  tile_2, tile_2, tile_2, tile_2, tile_3, tile_3, tile_3, tile_4, tile_4, tile_4, tile_5, tile_5, tile_5
    dw tile_6, tile_6, tile_7, tile_7, tile_7, tile_8, tile_8, tile_8, tile_9, tile_9, tile_9, tile_10, tile_10, tile_10, tile_11, tile_11, tile_11
    dw tile_10, tile_10, tile_10, tile_9, tile_9, tile_9, tile_8, tile_8, tile_8, tile_7, tile_7, tile_7, tile_6, tile_6, tile_6
    dw tile_5, tile_5, tile_5, tile_4, tile_4, tile_4, tile_3, tile_3, tile_3, tile_2, tile_2, tile_2, tile_1, tile_1, tile_1, tile_1

section "tiles", ROMX, BANK[3], ALIGN[8]
tiles_start:
tile_1: incbin "assets/1.tiles"
tile_2: incbin "assets/2.tiles"
tile_3: incbin "assets/3.tiles"
tile_4: incbin "assets/4.tiles"
tile_5: incbin "assets/5.tiles"
tile_6: incbin "assets/6.tiles"
tile_7: incbin "assets/7.tiles"
tile_8: incbin "assets/8.tiles"
tile_9: incbin "assets/9.tiles"
tile_10: incbin "assets/10.tiles"
tile_11: incbin "assets/11.tiles"
tiles_end:
; =======================

section "Vars", WRAM0
; =======================
; VARIABLES
; =======================
temp_y: ds $01
current_index: ds $01
current_frame: ds $02
frames_rendered: ds $01
delay: ds $01
; =======================