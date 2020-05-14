section "fx5", ROM0
    include "registers.asm"
    include "memory.asm"
    include "common.asm"

    include "assets/checker.inc"

fx5_COUNTER1 equ $FF
fx5_COUNTER2 equ $FF
fx5_COUNTER3 equ $15
SCROLL_DELAY equ 2
DELAY equ 2

fx5::
	ld a, [LCDC]
	res 1, a
	set 3, a
	ld [LCDC], a

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

    ;mLoadIn6SongUpdatesBANK checker_data, VRAM_TILE_START, checker_data_size, 2
    mLoadIn4SongUpdatesBANK checker_map, VRAM_BGMAP0_START, checker_map_size, 2

    ; ld h,high(fx9_frame_list)
    ; ld a,[current_index]
    ; and a,$01
    ; rl a
    ; ld l,a
    ; ld a,[hl+]
    ; ld [current_frame],a
    ; ld a,[hl+]
    ; ld [current_frame+1],a

    ld a,high(fx9_tiles_start)
    ld [current_frame],a
    ld a,low(fx9_tiles_start)
    ld [current_frame+1],a

    ld a, [fade_in_table_fx5]
    ld [fade_color], a

    ld [scroll2_y], a
    ld [scroll_x], a
    ld a,$FF
    ld [fade_line], a
    ld [fx_counter], a
    ld [fx_counter+1], a
    ld [fx_counter+2], a
    ld a,SCROLL_DELAY
    ld [wait_scroll], a
    ld a, $D9-10
    ld [scroll_y], a

    xor a
    ld [started],a

    ld a,$ff
    ld [BGP],a

    ld a, -70

    call fx5_loop
	ret

fx5_loop:
    push af
	mUpdateMusic
    pop af

    ld l,0
    ld [scroll_y],a
    ld d,a

    ; ld a,[scroll2_y]
    xor a
    ld [SCY],a
    ld [SCX],a
    ld a,[scroll2_y]
    dec a
    ld [scroll2_y],a

    push hl
    ld h, HIGH(bounce_table)
    rr a
    ld l, a
    ld a, [hl]
    ld [scroll_x], a
    ld c, a
    pop hl

    ; Set Black BG
    ; ld a,%01100000

    ld a, [scroll_x]
    ld c, a                     ; Save x scroll value for use inside the cylinder
    ld e,HIGH(wave_table)       ; Save the high byte of the wave table address
    ld b,40                     ; The cylinder effect starts at scanline 40
.wait_ly40:
    ld a,[LY]
    cp b
    jr nz,.wait_ly40            ; Wait for scanline 40
    ld a, [fade_line]           
    ld [BGP], a                 ; Set background palette to the first fade color
    ld a, [LCDC]
    res 3, a
    ld [LCDC], a                ; Swap background map to $9800-$9BFF
    ld a,c
    ld [SCX],a                  ; Set LCD scroll X register to our save X scroll
    ld a, b                     
.wait_ly:
    ld a,[LY]
    cp a,b
    jr nz,.wait_ly              ; Wait for the scanline to be equal to B
    ld h,e                      ; Set H to the high byte of the wave table addr.
    ld a,[hl]                   
    add a,d                     ; D holds the Y scroll so we add that to our displacement
    ld [SCY],a                  ; Store it in the LCD scroll Y register
    ld h,HIGH(fade_table1)
    ld a,[hl]                   ; Apply the palette for that current scanline so
    ld [BGP],a                  ; we can make a fading effect along the cylinder
    inc l
    inc b
    ld a,b
    cp a, 99                    ; The effect should only be run until scanline 99
    jr nz,.wait_ly
    ld a,$ff
    ld [BGP],a                  ; We reset the background palette
    ld a, [LCDC]
    set 3, a
    ld [LCDC], a                ; Swap background map to $9C00-$9FFF

    ld a, [wait_scroll]
    dec a
    jr nz, .dont_scroll_y
    inc d
    ld a,d
    ld [scroll_y],a
    ld a, SCROLL_DELAY

.dont_scroll_y:
    ld [wait_scroll], a
    ld a,d
    push af
; LOOP THIS ENDING for life!!
; 	ld a, [fx_counter]
;     inc a
;     cp fx5_COUNTER1
;     jr nz, .end_scene

;     ld a, [fx_counter+1]
;     inc a
;     cp fx5_COUNTER2
;     jr nz, .end_scene1

;     ld a, [fx_counter+2]
;     inc a
;     cp fx5_COUNTER3
;     jr nz, .end_scene2

;     ld a, [current_state]
;     cp STATE_RUN_FX
;     jr nz, .end_scene2
; 	mResetFadeVariables
;     mSetStates STATE_FADE_OUT, STATE_END_FX

; .end_scene2:
;     ld [fx_counter+2], a
;     jr .cont

; .end_scene1:
;     ld [fx_counter+1], a
;     jr .cont

; .end_scene:
;     ld [fx_counter], a

.cont:
    ld a, [current_state]
    cp STATE_END_FX
    jr z, .exit_fx

    mDefineFadeLogic

    ;mDefineFadeLogicWithTables fade_in_table_fx5, fade_in_table_fx5_end, fade_out_table_fx5, fade_out_table_fx5_end
    ;ld a, [fade_color]
    call run_fx
    pop af
    jp fx5_loop

.exit_fx:
	pop af
	ret

run_fx:
    xor a
    ld [SCY],a
    ld [SCX],a

    ; ld a, [fade_color]
    ; ld h, a
    ; ld l, 16
    ; ld a,[hl]
    ld a, [fade_color]
    ld [BGP],a
.render_frame:
    ld a,[current_frame]
    ld d,a
    ld a,[current_frame+1]
    ld e,a
    ld hl,$9C00
    ld c,18
.render_line:
    ld a,[LY]
    cp 0
    ret z
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

    ;mWaitVBlank

    ret

start_fx:
    xor a
    ld [SCY],a
    ld [SCX],a

    ld a, [fade_color]
    ld h, a
    ld l, 16
    ld a,[hl]
    ld [BGP],a
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

    ;mWaitVBlank

    ret

section "Fx5Vars", WRAM0
scroll_y: ds $01
scroll_x: ds $01
scroll2_y: ds $01
fade_line: ds $01
wait_scroll: ds $01
started: ds $01

section "FadeInTableFx5", ROM0, ALIGN[8]
fade_in_table_fx5: db $14, $14, $14, $14, $15, $15, $15, $15, $16, $16, $16, $16, $17, $17, $17, $17, $18, $18, $18, $18
fade_in_table_fx5_end:

section "FadeOutTableFx5", ROM0, ALIGN[8]
fade_out_table_fx5: db $18, $18, $18, $18, $17, $17, $17, $17, $16, $16, $16, $16, $15, $15, $15, $15, $14, $14, $14, $14
fade_out_table_fx5_end:

section "WaveData", ROM0[$1300]
wave_table:
    db $E2,$E9,$EF,$F3,$F6,$F9,$FB,$FC,$FE,$FE,$FF,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$01,$02,$02,$04,$05,$07,$0A,$0D,$11,$17

PA0 set %11111111
PA1 set %11111010
PA2 set %11101001
PA3 set %11101000
PA4 set %10101000
PA5 set %10010100

NPA equ 228

section "FadeData1", ROM0[$1400]
fade_table1:
    db PA0,PA0,PA1,PA1,PA1,PA2,PA1,PA2,PA2,PA2,PA3,PA2,PA3,PA3,NPA,PA3
    db NPA,PA3,NPA,NPA,NPA,NPA,NPA,NPA,NPA,NPA,NPA,NPA,NPA,NPA,NPA,PA5
    db PA5,PA5,PA5,NPA,NPA,NPA,NPA,NPA,NPA,NPA,NPA,NPA,NPA,NPA,NPA,NPA
    db NPA,PA3,NPA,PA3,PA3,PA2,PA3,PA2,PA2,PA1,PA2,PA0,PA0,PA0,PA0,PA0

section "bounceData", ROM0, ALIGN[8]
bounce_table:
    db $00,$01,$02,$03,$04,$04,$04,$04,$04,$03,$02,$01,$00,$00,$FF,$FE
    db $FD,$FC,$FC,$FC,$FC,$FC,$FD,$FE,$FF,$00,$01,$02,$03,$04,$04,$04
    db $04,$04,$03,$03,$02,$00,$00,$FF,$FE,$FD,$FC,$FC,$FC,$FC,$FC,$FD
    db $FE,$FF,$00,$00,$02,$03,$04,$04,$04,$04,$04,$04,$03,$02,$01,$00
    db $FF,$FE,$FD,$FC,$FC,$FC,$FC,$FC,$FD,$FE,$FF,$00,$00,$01,$03,$03
    db $04,$04,$04,$04,$04,$03,$02,$01,$00,$FF,$FE,$FD,$FC,$FC,$FC,$FC
    db $FC,$FD,$FE,$FF,$00,$00,$01,$02,$03,$04,$04,$04,$04,$04,$03,$02
    db $01,$00,$FF,$FE,$FD,$FC,$FC,$FC,$FC,$FC,$FD,$FD,$FE,$00,$00,$01
    db $02,$03,$04,$04,$04,$04,$04,$03,$02,$01,$00,$00,$FE,$FD,$FC,$FC
    db $FC,$FC,$FC,$FC,$FD,$FE,$00,$00,$01,$02,$03,$04,$04,$04,$04,$04
    db $03,$02,$01,$00,$00,$FF,$FD,$FD,$FC,$FC,$FC,$FC,$FC,$FD,$FE,$FF
    db $00,$01,$02,$03,$04,$04,$04,$04,$04,$03,$02,$01,$00,$00,$FF,$FE
    db $FD,$FC,$FC,$FC,$FC,$FC,$FD,$FE,$FF,$00,$01,$02,$03,$04,$04,$04
    db $04,$04,$03,$03,$01,$00,$00,$FF,$FE,$FD,$FC,$FC,$FC,$FC,$FC,$FD
    db $FE,$FF,$00,$00,$02,$03,$04,$04,$04,$04,$04,$04,$03,$02,$00,$00
    db $FF,$FE,$FD,$FC,$FC,$FC,$FC,$FC,$FD,$FE,$FF,$00,$00,$02,$03

section "Fx5Data", ROMX, BANK[2]
checker_data:: incbin "assets/checker.td"
checker_map: incbin "assets/checker.tm"
checker2_map:: incbin "assets/checker2.tm"
