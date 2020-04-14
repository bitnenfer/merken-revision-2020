    include "macros.z80"

    ORG $0040
    reti ; VBLANK

    ORG $0048
    reti ; LCD STAT

    ORG $0050
    ld a,[SCY]
    inc a
    ld [SCY],a
    reti ; TIMER

    ORG $0058
    reti ; SERIAL

    ORG $0060
    reti ; JOYPAD

    ORG $0100
    
    nop
