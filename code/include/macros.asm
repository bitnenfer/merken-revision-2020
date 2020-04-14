if !def(_MACROS_)

_MACROS_ equ 1
ORG: MACRO 
    SECTION "ORG_\@", ROM0[\1]
    ENDM

INCLUDE_ASSET: MACRO
\1: 
    incbin \2
    ENDM

PUT_TEXT_LOGO: MACRO

LOGO_X set \1
LOGO_Y set \2
LOGO_W set \3
CHAR_START set \4

    ld a,CHAR_START+0
    ld [SPRITE0_TILE],a
    ld a, LOGO_X + LOGO_W * 0
    ld [SPRITE0_X], a
    ld a, LOGO_Y
    ld [SPRITE0_Y], a

    ld a,CHAR_START+1
    ld [SPRITE1_TILE],a
    ld a, LOGO_X + LOGO_W * 1
    ld [SPRITE1_X], a
    ld a, LOGO_Y
    ld [SPRITE1_Y], a

    ld a,CHAR_START+2
    ld [SPRITE2_TILE],a
    ld a, LOGO_X + LOGO_W * 2
    ld [SPRITE2_X], a
    ld a, LOGO_Y
    ld [SPRITE2_Y], a

    ld a,CHAR_START+3
    ld [SPRITE3_TILE],a
    ld a, LOGO_X + LOGO_W * 3
    ld [SPRITE3_X], a
    ld a, LOGO_Y
    ld [SPRITE3_Y], a

    ld a,CHAR_START+4
    ld [SPRITE4_TILE],a
    ld a, LOGO_X + LOGO_W * 4
    ld [SPRITE4_X], a
    ld a, LOGO_Y
    ld [SPRITE4_Y], a

    ld a,CHAR_START+3
    ld [SPRITE5_TILE],a
    ld a, LOGO_X + LOGO_W * 5
    ld [SPRITE5_X], a
    ld a, LOGO_Y
    ld [SPRITE5_Y], a

    ld a,CHAR_START+5
    ld [SPRITE6_TILE],a
    ld a, LOGO_X + LOGO_W * 6
    ld [SPRITE6_X], a
    ld a, LOGO_Y
    ld [SPRITE6_Y], a

    ld a,CHAR_START+4
    ld [SPRITE7_TILE],a
    ld a, LOGO_X + LOGO_W * 7
    ld [SPRITE7_X], a
    ld a, LOGO_Y
    ld [SPRITE7_Y], a

    ld a,CHAR_START+6
    ld [SPRITE8_TILE],a
    ld a, LOGO_X + LOGO_W * 8
    ld [SPRITE8_X], a
    ld a, LOGO_Y
    ld [SPRITE8_Y], a

    ld a,$FF
    ld [OBJP0],a

    ; Enable Sprites
    ld a,[LCDC]
    set 1,a
    ld [LCDC],a

	ENDM

endc