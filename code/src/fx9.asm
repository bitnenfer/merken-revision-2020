section "fx9", ROM0

    include "registers.asm"
    include "memory.asm"
    include "common.asm"

    include "assets/gradient.inc"
	include "assets/checker.inc"

DELAY equ 2
fx9_COUNTER1 equ $FF
fx9_COUNTER2 equ $FF
fx9_COUNTER3 equ $F0

fx9::
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
    
    ld h,high(fx9_frame_list)
    ld a,[current_index]
    and a,$01
    rl a
    ld l,a
    ld a,[hl+]
    ld [current_frame],a
    ld a,[hl+]
    ld [current_frame+1],a


    ld a,high(fx9_tiles_start)
    ld [current_frame],a
    ld a,low(fx9_tiles_start)
    ld [current_frame+1],a

    ld a, %11100100
    ld [BGP], a

    ld a, DELAY
    ld [delay], a

    ld a, [LCDC]
    set 3, a
    ld [LCDC], a

    call fx9_loop
	ret

fx9_loop:
	mUpdateMusic
	mDefineFadeLogic
	mUpdateBackground

    ;mLoadIn6SongUpdatesBANK checker_data, VRAM_TILE_START, checker_data_size, 2
    mSetROMBank 2
    mLoadDataIn32Frames checker_data, VRAM_TILE_START, checker_data_size, on_complete

    ld a, [fx_counter]
    inc a
    cp fx9_COUNTER1
    jr nz, .end_scene

    ld a, [fx_counter+1]
    inc a
    cp fx9_COUNTER2
    jr nz, .end_scene1

    ld a, [fx_counter+2]
    inc a
    cp fx9_COUNTER3
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
	mJumpCheckEnding fx9_loop

run_fx:

.render_frame:
    ld a,[current_frame]
    ld d,a
    ld a,[current_frame+1]
    ld e,a
    ld hl,$9C00
    ld c,18
.render_line:
    mSetROMBank 5
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
    ld h,high(fx9_frame_list)
    rl a
    ld l,a
    ld a,[hl+]
    ld [current_frame+1],a
    ld a,[hl+]
    ld [current_frame],a

    mWaitVBlank

	ret

on_complete:
    ret

section "fx9_frame_list_fx9", ROM0, ALIGN[8]
fx9_frame_list::
dw tile_1,tile_1,tile_1,tile_2,tile_2,tile_3,tile_3,tile_4,tile_4,tile_5,tile_5,tile_6,tile_6,tile_7,tile_7,tile_8,tile_8,tile_9,tile_10,tile_11,tile_12,tile_13,tile_14,tile_15,tile_15,tile_16,tile_17,tile_18,tile_19,tile_21,tile_23,tile_25,tile_26,tile_27,tile_27,tile_28,tile_28,tile_29,tile_30,tile_31,tile_32,tile_33,tile_33,tile_34,tile_35,tile_36,tile_36,tile_36,tile_37,tile_38,tile_39,tile_40,tile_41,tile_42,tile_42,tile_43,tile_43,tile_44,tile_44,tile_45,tile_45,tile_46,tile_46,tile_47,tile_47,tile_48,tile_48

section "tilesfx9", ROMX, BANK[5], ALIGN[8]
fx9_tiles_start::
tile_1: incbin  "assets/nsh1.tiles"
tile_2: incbin  "assets/nsh2.tiles"
tile_3: incbin  "assets/nsh3.tiles"
tile_4: incbin  "assets/nsh4.tiles"
tile_5: incbin  "assets/nsh5.tiles"
tile_6: incbin  "assets/nsh6.tiles"
tile_7: incbin  "assets/nsh7.tiles"
tile_8: incbin  "assets/nsh8.tiles"
tile_9: incbin  "assets/nsh9.tiles"
tile_10: incbin "assets/nsh10.tiles"
tile_11: incbin "assets/nsh11.tiles"
tile_12: incbin "assets/nsh12.tiles"
tile_13: incbin "assets/nsh13.tiles"
tile_14: incbin "assets/nsh14.tiles"
tile_15: incbin "assets/nsh15.tiles"
tile_16: incbin "assets/nsh16.tiles"
tile_17: incbin "assets/nsh17.tiles"
tile_18: incbin "assets/nsh18.tiles"
tile_19: incbin "assets/nsh19.tiles"
tile_21: incbin "assets/nsh21.tiles"
tile_23: incbin "assets/nsh23.tiles"
tile_25: incbin "assets/nsh25.tiles"
tile_26: incbin "assets/nsh26.tiles"
tile_27: incbin "assets/nsh27.tiles"
tile_28: incbin "assets/nsh28.tiles"
tile_29: incbin "assets/nsh29.tiles"
tile_30: incbin "assets/nsh30.tiles"
tile_31: incbin "assets/nsh31.tiles"
tile_32: incbin "assets/nsh32.tiles"
tile_33: incbin "assets/nsh33.tiles"
tile_34: incbin "assets/nsh34.tiles"
tile_35: incbin "assets/nsh35.tiles"
tile_36: incbin "assets/nsh36.tiles"
tile_37: incbin "assets/nsh37.tiles"
tile_38: incbin "assets/nsh38.tiles"
tile_39: incbin "assets/nsh39.tiles"
tile_40: incbin "assets/nsh40.tiles"
tile_41: incbin "assets/nsh41.tiles"
tile_42: incbin "assets/nsh42.tiles"
tile_43: incbin "assets/nsh43.tiles"
tile_44: incbin "assets/nsh44.tiles"
tile_45: incbin "assets/nsh45.tiles"
tile_46: incbin "assets/nsh46.tiles"
tile_47: incbin "assets/nsh47.tiles"
tile_48: incbin "assets/nsh48.tiles"
fx9_tiles_end::
; =======================
