section "fx6", ROM0
    include "registers.asm"
    include "memory.asm"
    include "common.asm"

    include "assets/underwater.inc"

TABLE_SIZE equ $3F

fx6::
	mResetFadeVariables
    mResetLoader
    mResetVars
    mSetStates STATE_FADE_IN, STATE_RUN_FX
    mEnableLoading


    ld a, [LCDC]
	res 1, a
	res 3, a
	res 5, a
	ld [LCDC], a

   ; set duration
    ld a,$FF
    ld [duration],a
    ld a,$02
    ld [duration+1],a

    ; set water_y
    xor a
    ld [water_y],a
    ld [water_x],a
    ld a,150
    ld [control_y],a
    ld a,1
    ld [update_duration], a

    ; load wave data
    ld de, wave_data
    ld hl, wave
    ld bc, TABLE_SIZE + 1
    call unsafe_memcpy

    mLoadIn8SongUpdatesBANK underwater_data, $8000, underwater_data_size, 3
    mLoadIn4SongUpdatesBANK underwater_map, $9800, underwater_map_size, 3

	call fx6_loop
	ret

fx6_loop:
	mUpdateMusic
	mDefineFadeLogic
	mUpdateBackground
	ld a, [should_quit]
	cp $01
	jr z, .call_vb
	call run_fx
	jr .go_to_bottom
.call_vb:
	mWaitVBlank
.go_to_bottom:
	mJumpCheckEnding fx6_loop

run_fx:
	; mWaitVBlank

	ld a, [update_duration]
	cp $00
	jr z, .move_water_down
    ; Check duration
    ld a,[duration]
    ld l,a
    ld a,[duration+1]
    ld h,a
    dec hl
    ld a,l
    ld [duration],a
    ld a,h
    ld [duration+1],a
    cp $00
    jr nz,.duration_not_complete
    ld a,l
    cp $00
    jr nz,.duration_not_complete
    
    xor a
    ld [update_duration], a


.move_water_down:
    ld a, [control_y]
    inc a
    cp 150
    jr nz, .save_control_y
    ld a, 1
    ld [should_quit], a
    ld a,%11100100
    ld [BGP], a
    mSetStates STATE_FADE_OUT, STATE_END_FX
    ret

.save_control_y:
    ld [control_y], a
    jr .dont_increment_water

.duration_not_complete:
    ld a,[control_y]
    cp 50
    jr c, .dont_increment_water
    dec a
    ld [control_y],a

.dont_increment_water:

    ld a,%11100100
    ld [BGP],a                  ; Set the background palette to default gradient
    xor a
    ld [SCX],a
    ld [SCY],a                  ; Reset LCD's scroll X and Y registers.
    ld a,[water_y]              ; Load water Y offset which handles the top wave
    inc a
    and TABLE_SIZE              ; Increment and mask it so it doesn't overflow
    ld [water_y],a              ; Store it in memory
    ld hl,wave
    add a,l
    ld l,a
    ld a,[hl]                   ; Use this offset to retrieve a wave value
    ld c,a                      ; Move it to C so it can be added to the 
    ld a,[control_y]            ;  water Y position. (control_y)    
    add a,c
    ld b,a                      ; Add it and save it in B for scanline check
.waity0:
    ld a,[LY]
    cp b
    jr nz,.waity0               ; Wait for scanline to be equal to B
    ld a,%10010000              ; Once we've reached the scanline == B
    ld [BGP],a                  ; We set the background palette to a light color
    ; Horizontal wave movement
.repeat_hwave:
    ld a,[LY]
    inc a
    ld b,a
    cp $90
    jr nc,.end_horizontal_wave
.waity1:
    ld a,[LY]
    cp b
    jr nz,.waity1
    ; apply effect
    ld l,a
    ld a,[water_x]
    add a,l
    and TABLE_SIZE
    ld l,a
    ld a,[hl]
    ld [SCX],a
    sub a, 10
    ld [SCY],a
    jr .repeat_hwave
.end_horizontal_wave:
    ld a,[water_x]
    inc a
    ld [water_x],a
    ret

section "WaveDatafx6", ROM0, ALIGN[8]
wave_data: 
    db $00,$00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03
    db $03,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02,$01,$01,$00,$00,$00
    db $00,$00,$00,$FF,$FF,$FE,$FE,$FE,$FE,$FD,$FD,$FD,$FD,$FD,$FD,$FD
    db $FD,$FD,$FD,$FD,$FD,$FD,$FD,$FE,$FE,$FE,$FF,$FF,$FF,$00,$00,$00

section "UNDERWATER_VARS", WRAM0, ALIGN[8]
wave: ds TABLE_SIZE + 5
water_y: ds $01
water_x: ds $01
control_y: ds $01
duration: ds $02
fade_step: ds $01
fade_time: ds $01
update_duration: ds $01
should_quit: ds $01

section "Under", ROMX, BANK[3]
underwater_data: incbin "assets/underwater.td"
underwater_map: incbin "assets/underwater.tm"