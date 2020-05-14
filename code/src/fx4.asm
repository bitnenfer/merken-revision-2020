section "fx4", ROM0

    include "registers.asm"
    include "memory.asm"
    include "common.asm"

fx4_COUNTER1 equ $FF
fx4_COUNTER2 equ $FF
fx4_COUNTER3 equ $20
fx4_SCROLL_DELAY equ 3

fx4::
    mSetStates STATE_RUN_FX, STATE_RUN_FX
    xor a
    ld [offset], a
    ld [fx_counter], a
    ld [fx_counter+1], a
	call fx4_loop
	ret

fx4_loop:
    ld a, [tmp]
    inc a
    ld [tmp], a

	mUpdateMusic
	mDefineFadeLogic

	ld a,[current_state]
	cp STATE_FADE_OUT
	jr nz,.dont_update_background
	mUpdateBackground

.dont_update_background
    ld a,[offset]                   ; I load the offset value
    ld c, a                         ; I save the offset value in C for further use
    add a, 4                        ; Increment offset
    ld [offset], a                  ; Store the offset in memory
    ld b, 25                        ; Prepare to wait for scanline 25
.wait0:
    ld a, [LY]                      ; Load the current scanline
    cp b                            ; Compare it to 25
    jr nz, .wait0                   ; If the LCD hasn't reached it we repeat
    ld h, HIGH(sine_wave_table8)    ; Load the high byte of the sine table address
    add a, c                        ; Add to A (our current scanline) the offset
    ld l, a                         ; Load L with A value
    ld a, [hl]                      ; Load to A the value in the sine table
    add a, $DD                      ; Add $DD to increment the displacement
    ld [SCY], a                     ; Store our displacement in the LCD scroll Y reg
    inc b                           ; Increment B and prepare 
                                    ; to process the next scanline
    ld a, b                         ; Check if the LCD scanline has reached VBLANK
    cp $90
    jr z, .end
    jr .wait0                       ; If not repeat

.end:

	ld a, [fx_counter]
    inc a
    cp fx4_COUNTER1
    jr nz, .end_scene

    ld a, [fx_counter+1]
    inc a
    cp fx4_COUNTER2
    jr nz, .end_scene1

	mResetFadeVariables
    mSetStates STATE_FADE_OUT, STATE_END_FX

.end_scene1:
    ld [fx_counter+1], a
    jr .cont

.end_scene:
    ld [fx_counter], a

.cont:

    ld a, [tmp]
    ld h, HIGH(sine_wave_table8)
    ld l, a
    ld a, [hl]
    ld [SCX], a

	call fx_animate_text
 	call dma_transfer
    
    mJumpCheckEnding fx4_loop

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

section "fx4Vars", WRAM0
offset: ds $01