section "fx1", ROM0

    include "registers.asm"
    include "memory.asm"
    include "common.asm"

    ; Assets
    include "assets/logo.inc"
    include "assets/gotas.inc"
    include "assets/nintendo.inc"
    include "assets/checker.inc"

SAVE_STACK equ $C400
fx1_COUNTER1 equ $9A
fx1_COUNTER2 equ $20

fx1::
    mResetFadeVariables
    mResetLoader
    mSetStates STATE_RUN_FX, STATE_RUN_FX

    xor a
    ld [SCX], a
    ld [SCY], a
    ld [fx_counter], a
    ld [fx_counter+1], a
    ld [should_load_data], a
    ld [load_step], a
    ld [loaded_line], a
    ld a, 1
    ld [should_play_music], a
    ld a,[is_dmg]
    cp $01
    jr nz, .not_dmg
    
    ; Load a copy of the Nintendo logo because I am lazy.
.is_dmg:
    mSetROMBank 2
    mSafeVRAMMemcpy nintendo_map, $9800, nintendo_map_size
    mSetROMBank 2
    mSafeVRAMMemcpy nintendo_data, $8000, nintendo_data_size

.not_dmg:
    mSetROMBank 2
    mSafeVRAMMemcpy gotas_data, $8F00, gotas_data_size
    mSetROMBank 2
    mSafeVRAMMemcpy gotas_map, $9A40, ($9C00-$9A40)



rept 120
    call stall
    mWaitVBlank
endr

    ld [sp_save], sp            ; Save the original Stack Pointer
    ld sp, SAVE_STACK           ; Set the Stack Pointer to $C400 (temporary stack)
    ld de, logo_map_end-32      ; Set the end of the logo map
                                ; We do this because we're loading backwards.
    ld hl, $9A20                ; Set the starting point for loading our tiles
    push hl                     ; Push both pointers to our temporary stack
    push de
    ld a, [sp_save]             
    ld l, a
    ld a, [sp_save+1]
    ld h, a
    ld sp, hl                   ; Restore the original Stack Pointer
    ld a,[SCY]                  ; We decrement SCY by one and turn it to $FF.
    dec a                       
    ld [SCY],a

    ld a,%11100100
    ld [BGP],a
    mStartMusic

    call fx_loop
    ret 


fx_loop:
    call fx_on_timer
    ld a, [should_play_music]
    cp $01
    jr nz, .dont_play_music
.play_music:
    mUpdateMusicWaitVBlank
.dont_play_music:
    mSetROMBank 2
    mLoadDataIn16Frames logo_data, $8010, logo_data_size, on_load_complete
    mUpdateMusicWaitVBlank

    ld a, [fade_color]
    ld [BGP], a
    ld a, [current_state]
    cp STATE_END_FX
    jr z, .end_loop
    jp fx_loop
.end_loop:
    ret
    
fx_on_timer:
    mDefineFadeLogicWithTables fx1_fade_in_table, fx1_fade_in_table_end, fx1_fade_out_table, fx1_fade_out_table_end

    ld a, [current_state]
    cp STATE_RUN_FX

    ret nz

    ld a, [fx_counter]
    inc a
    cp fx1_COUNTER1
    jr nz, .end_scene

    ld a, [fx_counter+1]
    inc a
    cp fx1_COUNTER2
    jr nz, .end_scene1

    mSetStates STATE_FADE_OUT, STATE_END_FX

.end_scene1:
    ld [fx_counter+1], a
    jr .cont

.end_scene:
    ld [fx_counter], a

.cont:
    ld a, [should_play_music]
    cp $01
    jr nz, .add_delay
    jr .no_delay
.add_delay
rept 2
    mWaitVBlank
    ;call stall
endr
.no_delay
    ld a,[SCY]
    cp $00
    ret z

    cp $50
    jr z, .proceed_load

    cp $8F
    jr nz, .continue_scroll

.stop_load:
    ld a, $01
    ld [wait_for_scroll], a
    jr .continue_scroll

.proceed_load:
    xor a
    ld [wait_for_scroll], a

.continue_scroll:
    ld a,[SCY]
    dec a
    ld [SCY],a


    cp $AE
    ret nc
    cp $AD
    jr nz, .load_line

    ld a, $01
    ld [should_load_data], a 
    ld [should_play_music], a


    xor a
    ld [fx_counter], a

.load_line:
    ld a, [wait_for_scroll]         ; We need to check if 
    cp $01                          ; we have to skip loading
    jr z, .end_load_line            ; a line of tiles or not.
    ld [sp_save], sp                ; If not store original Stack Pointer
    ld sp, SAVE_STACK - 4           ; Set Stack Pointer to temporary stack
    pop de                          ; Pop source address (Logo tile map)
    pop hl                          ; Pop destination address (VRAM tile map)
    ld a, h                         
    cp $96                          
    jr z, .skip_store               ; Do a small bound check so we don't overflow
    ld bc, 20                       ; Set the amount of bytes we want to load
    mSetROMBank 2                   ; Our source tile indices are stored in BANK 2
    call safe_vram_memcpy           ; Copy tiles indices to VRAM.
    ld bc,-32                       ; Prepare our next source and destination addresses
    add hl,bc
    push hl
    ld h, d
    ld l, e
    add hl,bc
    ld d, h
    ld e, l
    push de                         ; Push new source and destination into temp stack.
.skip_store:
    ld a, [sp_save]
    ld l, a
    ld a, [sp_save+1]
    ld h, a
    ld sp, hl                       ; Restore original Stack Pointer
    ld a, [loaded_line]             
    inc a
    ld [loaded_line], a             ; Increment and save the loaded map line 
.end_load_line:
    ret

on_load_complete:
    ret

section "Fx1Data", ROMX, BANK[2]
logo_data: incbin "assets/logo.td"
logo_map: incbin "assets/logo.tm"
logo_map_end:
gotas_data: incbin "assets/gotas.td"
gotas_map: incbin "assets/gotas.tm"
nintendo_data: incbin "assets/nintendo.td"
nintendo_map: incbin "assets/nintendo.tm"

section "fx1vars", WRAM0
loaded_line: ds $01
wait_for_scroll: ds $01


section "FadeOutTableFx1", ROM0, ALIGN[8]
fx1_fade_out_table::
    db %11100100
    db %11100100
    db %11101001
    db %11111001
    db %11111001
    db %11111010
    db %11111010
    db %11111110
    db %11111110
    db %11111111
    db %11111111
fx1_fade_out_table_end::

section "FadeInTableFx1", ROM0, ALIGN[8]
fx1_fade_in_table::
    db %11111111
    db %11111111
    db %11111110
    db %11111110
    db %11111010
    db %11111001
    db %11111001
    db %11101001
    db %11101001
    db %11100100
    db %11100100
fx1_fade_in_table_end::
