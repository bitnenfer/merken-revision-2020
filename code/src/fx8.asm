section "fx8", ROM0

    include "registers.asm"
    include "memory.asm"
    include "common.asm"

	include "assets/gradient.inc"

DELAY equ 2
fx8_COUNTER1 equ $FF
fx8_COUNTER2 equ $FF
fx8_COUNTER3 equ $F0

fx8::
	mResetFadeVariables
    mResetLoader
    mResetVars
    mSetStates STATE_FADE_IN, STATE_RUN_FX
    mEnableLoading

    xor a
    ld [current_index],a
    ld [frames_rendered],a
    ld [fx_counter], a
    ld [fx_counter+1], a
    ld [fx_counter+2], a
    
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

    ld a, [LCDC]
    set 3, a
    ld [LCDC], a

    call fx8_loop
	ret

fx8_loop:
	mUpdateMusic
	mDefineFadeLogic
	mUpdateBackground

    ld a, [fx_counter]
    inc a
    cp fx8_COUNTER1
    jr nz, .end_scene

    ld a, [fx_counter+1]
    inc a
    cp fx8_COUNTER2
    jr nz, .end_scene1

    ld a, [fx_counter+2]
    inc a
    cp fx8_COUNTER3
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
	mJumpCheckEnding fx8_loop

run_fx:

.render_frame:
    ld a,[current_frame]
    ld d,a
    ld a,[current_frame+1]
    ld e,a
    ld hl,$9C00
    ld c,18
.render_line:
    mSetROMBank 4
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


section "frame_list_fx8", ROM0, ALIGN[8]
frame_list:
dw tile_1,tile_1,tile_1,tile_2,tile_2,tile_3,tile_3,tile_4,tile_4,tile_5,tile_5,tile_6,tile_6,tile_7,tile_7,tile_8,tile_8,tile_9,tile_10,tile_11,tile_12,tile_13,tile_14,tile_15,tile_15,tile_16,tile_17,tile_18,tile_19,tile_21,tile_23,tile_25,tile_26,tile_27,tile_27,tile_28,tile_28,tile_29,tile_30,tile_31,tile_32,tile_33,tile_33,tile_34,tile_35,tile_36,tile_36,tile_36,tile_37,tile_38,tile_39,tile_40,tile_41,tile_42,tile_42,tile_43,tile_43,tile_44,tile_44,tile_45,tile_45,tile_46,tile_46,tile_47,tile_47,tile_48,tile_48

section "tilesfx8", ROMX, BANK[4], ALIGN[8]
tiles_start:
tile_1: incbin  "assets/sh1.tiles"
tile_2: incbin  "assets/sh2.tiles"
tile_3: incbin  "assets/sh3.tiles"
tile_4: incbin  "assets/sh4.tiles"
tile_5: incbin  "assets/sh5.tiles"
tile_6: incbin  "assets/sh6.tiles"
tile_7: incbin  "assets/sh7.tiles"
tile_8: incbin  "assets/sh8.tiles"
tile_9: incbin  "assets/sh9.tiles"
tile_10: incbin "assets/sh10.tiles"
tile_11: incbin "assets/sh11.tiles"
tile_12: incbin "assets/sh12.tiles"
tile_13: incbin "assets/sh13.tiles"
tile_14: incbin "assets/sh14.tiles"
tile_15: incbin "assets/sh15.tiles"
tile_16: incbin "assets/sh16.tiles"
tile_17: incbin "assets/sh17.tiles"
tile_18: incbin "assets/sh18.tiles"
tile_19: incbin "assets/sh19.tiles"
tile_21: incbin "assets/sh21.tiles"
tile_23: incbin "assets/sh23.tiles"
tile_25: incbin "assets/sh25.tiles"
tile_26: incbin "assets/sh26.tiles"
tile_27: incbin "assets/sh27.tiles"
tile_28: incbin "assets/sh28.tiles"
tile_29: incbin "assets/sh29.tiles"
tile_30: incbin "assets/sh30.tiles"
tile_31: incbin "assets/sh31.tiles"
tile_32: incbin "assets/sh32.tiles"
tile_33: incbin "assets/sh33.tiles"
tile_34: incbin "assets/sh34.tiles"
tile_35: incbin "assets/sh35.tiles"
tile_36: incbin "assets/sh36.tiles"
tile_37: incbin "assets/sh37.tiles"
tile_38: incbin "assets/sh38.tiles"
tile_39: incbin "assets/sh39.tiles"
tile_40: incbin "assets/sh40.tiles"
tile_41: incbin "assets/sh41.tiles"
tile_42: incbin "assets/sh42.tiles"
tile_43: incbin "assets/sh43.tiles"
tile_44: incbin "assets/sh44.tiles"
tile_45: incbin "assets/sh45.tiles"
tile_46: incbin "assets/sh46.tiles"
tile_47: incbin "assets/sh47.tiles"
tile_48: incbin "assets/sh48.tiles"
tiles_end:
; =======================

section "Varsfx8", WRAM0
; =======================
; VARIABLES
; =======================
temp_y:: ds $01
current_index:: ds $01
current_frame:: ds $02
frames_rendered:: ds $01
delay:: ds $01
; =======================