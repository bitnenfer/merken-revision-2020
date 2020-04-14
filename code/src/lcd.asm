section "LCD",ROM0

    include "registers.asm"

wait_vblank::
.wait:
    ld a,[LCDS]
    and a,$03
    cp $01
    jr nz,.wait
    ret

    ; A = LY to compare
wait_lyc::
    ld [LYC],a
.wait:
    ld a,[LCDS]
    bit $02,a
    jr z,.wait
    ret

turn_lcd_off::
    ei
    xor a
    set 0,a
    ld [INT_ENABLE],a
    halt
    ld a,[LCDC]
    res 7,a
    ld [LCDC],a
    di
    xor a
    ld [INT_ENABLE],a
    ret

turn_lcd_on::
    ld a,[LCDC]
    set 7,a
    ld [LCDC],a
    ret