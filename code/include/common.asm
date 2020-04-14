if !def(_COMMON_)
_COMMON_ equ 1

; ======================
; STATES
; ======================
STATE_FADE_IN equ $00
STATE_RUN_FX equ $01
STATE_FADE_OUT equ $02
STATE_END_FX equ $03
STATE_WAIT_LOAD equ $04
; ======================

STACK_TOP equ $FFFE

; ======================
; CARILLON
; ======================

Player_Initialize       equ     $4000
Player_MusicStart       equ     $4003
Player_MusicStop        equ     $4006
Player_SongSelect       equ     $400c
Player_MusicUpdate      equ     $4100
MusicBank               equ     1
SongNumber              equ     0       ; 0 - 7

mResetVars: macro
    xor a
    ld [SCX],a
    ld [SCY],a
    ld [fx_counter], a
    ld [fx_counter+1], a
    ld [should_load_data], a
    ld [load_step], a
    ld [should_play_music], a    
endm


mResetLoader: macro
	xor a
	ld a, [should_load_data]
	ld a, [load_step]
endm

	; 1 = Source
	; 2 = Destination
	; 3 = Size
	; 4 = On Complete
mLoadDataIn4Frames: macro
	ld a, [should_load_data]
	cp $01
	jr nz, .__dont_load_data__\@

.__load_data__\@:
	ld a, [load_step]
	cp $00
	jr z, .__load_step0__\@
	cp $01
	jr z, .__load_step1__\@
	cp $02
	jr z, .__load_step2__\@
	cp $03
	jr z, .__load_step3__\@

STEP_COUNT\@ equ 4

.__load_step0__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*0, \2 +(\3/STEP_COUNT\@)*0, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@

.__load_step1__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*1, \2 +(\3/STEP_COUNT\@)*1, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@

.__load_step2__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*2, \2 +(\3/STEP_COUNT\@)*2, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@

.__load_step3__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*3, \2 +(\3/STEP_COUNT\@)*3, (\3/STEP_COUNT\@)
    xor a
    ld [should_load_data], a
    call \4

.__inc_load_step__\@:
	ld a, [load_step]
	inc a
	ld [load_step], a

.__dont_load_data__\@:

endm

	; 1 = Source
	; 2 = Destination
	; 3 = Size
	; 4 = On Complete
mLoadDataIn5Frames: macro
	ld a, [should_load_data]
	cp $01
	jr nz, .__dont_load_data__\@

.__load_data__\@:
	ld a, [load_step]
	cp $00
	jr z, .__load_step0__\@
	cp $01
	jr z, .__load_step1__\@
	cp $02
	jr z, .__load_step2__\@
	cp $03
	jr z, .__load_step3__\@
	cp $04
	jr z, .__load_step4__\@

STEP_COUNT\@ equ 5
STEP set 0

.__load_step0__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step1__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step2__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step3__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step4__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    xor a
    ld [should_load_data], a
    call \4

.__inc_load_step__\@:
	ld a, [load_step]
	inc a
	ld [load_step], a

.__dont_load_data__\@:

endm

	; 1 = Source
	; 2 = Destination
	; 3 = Size
	; 4 = On Complete
mLoadDataIn6Frames: macro
	ld a, [should_load_data]
	cp $01
	jr nz, .__dont_load_data__\@

.__load_data__\@:
	ld a, [load_step]
	cp $00
	jr z, .__load_step0__\@
	cp $01
	jr z, .__load_step1__\@
	cp $02
	jr z, .__load_step2__\@
	cp $03
	jr z, .__load_step3__\@
	cp $04
	jr z, .__load_step4__\@
	cp $05
	jr z, .__load_step5__\@

STEP_COUNT\@ equ 6
STEP set 0

.__load_step0__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step1__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step2__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step3__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step4__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step5__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    xor a
    ld [should_load_data], a
    call \4

.__inc_load_step__\@:
	ld a, [load_step]
	inc a
	ld [load_step], a

.__dont_load_data__\@:

endm

	; 1 = Source
	; 2 = Destination
	; 3 = Size
	; 4 = On Complete
mLoadDataIn8Frames: macro
	ld a, [should_load_data]
	cp $01
	jp nz, .__dont_load_data__\@

.__load_data__\@:
	ld a, [load_step]
	cp $00
	jr z, .__load_step0__\@
	cp $01
	jr z, .__load_step1__\@
	cp $02
	jr z, .__load_step2__\@
	cp $03
	jr z, .__load_step3__\@
	cp $04
	jr z, .__load_step4__\@
	cp $05
	jr z, .__load_step5__\@
	cp $06
	jr z, .__load_step6__\@
	cp $07
	jr z, .__load_step7__\@

STEP_COUNT\@ equ 8
STEP set 0

.__load_step0__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step1__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step2__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step3__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step4__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step5__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step6__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step7__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    xor a
    ld [should_load_data], a
    call \4

.__inc_load_step__\@:
	ld a, [load_step]
	inc a
	ld [load_step], a

.__dont_load_data__\@:

endm

	; 1 = Source
	; 2 = Destination
	; 3 = Size
	; 4 = On Complete
mLoadDataIn16Frames: macro
	ld a, [should_load_data]
	cp $01
	jp nz, .__dont_load_data__\@

.__load_data__\@:
	ld a, [load_step]
	cp $00
	jp z, .__load_step0__\@
	cp $01
	jp z, .__load_step1__\@
	cp $02
	jp z, .__load_step2__\@
	cp $03
	jp z, .__load_step3__\@
	cp $04
	jp z, .__load_step4__\@
	cp $05
	jp z, .__load_step5__\@
	cp $06
	jp z, .__load_step6__\@
	cp $07
	jp z, .__load_step7__\@
	cp $08
	jp z, .__load_step8__\@
	cp $09
	jp z, .__load_step9__\@
	cp $0A
	jp z, .__load_step10__\@
	cp $0B
	jp z, .__load_step11__\@
	cp $0C
	jp z, .__load_step12__\@
	cp $0D
	jp z, .__load_step13__\@
	cp $0E
	jp z, .__load_step14__\@
	cp $0F
	jp z, .__load_step15__\@

STEP_COUNT\@ equ 16
STEP set 0

.__load_step0__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step1__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step2__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step3__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step4__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step5__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step6__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step7__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step8__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step9__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step10__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step11__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step12__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step13__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step14__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step15__\@:
    	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    xor a
    ld [should_load_data], a
    call \4

.__inc_load_step__\@:
	ld a, [load_step]
	inc a
	ld [load_step], a

.__dont_load_data__\@:

endm

	; 1 = Source
	; 2 = Destination
	; 3 = Size
	; 4 = On Complete
mLoadDataIn32Frames: macro
	ld a, [should_load_data]
	cp $01
	jp nz, .__dont_load_data__\@

.__load_data__\@:
	ld a, [load_step]
    cp 0
    jp z, .__load_step0__\@
    cp 1
    jp z, .__load_step1__\@
    cp 2
    jp z, .__load_step2__\@
    cp 3
    jp z, .__load_step3__\@
    cp 4
    jp z, .__load_step4__\@
    cp 5
    jp z, .__load_step5__\@
    cp 6
    jp z, .__load_step6__\@
    cp 7
    jp z, .__load_step7__\@
    cp 8
    jp z, .__load_step8__\@
    cp 9
    jp z, .__load_step9__\@
    cp 10
    jp z, .__load_step10__\@
    cp 11
    jp z, .__load_step11__\@
    cp 12
    jp z, .__load_step12__\@
    cp 13
    jp z, .__load_step13__\@
    cp 14
    jp z, .__load_step14__\@
    cp 15
    jp z, .__load_step15__\@
    cp 16
    jp z, .__load_step16__\@
    cp 17
    jp z, .__load_step17__\@
    cp 18
    jp z, .__load_step18__\@
    cp 19
    jp z, .__load_step19__\@
    cp 20
    jp z, .__load_step20__\@
    cp 21
    jp z, .__load_step21__\@
    cp 22
    jp z, .__load_step22__\@
    cp 23
    jp z, .__load_step23__\@
    cp 24
    jp z, .__load_step24__\@
    cp 25
    jp z, .__load_step25__\@
    cp 26
    jp z, .__load_step26__\@
    cp 27
    jp z, .__load_step27__\@
    cp 28
    jp z, .__load_step28__\@
    cp 29
    jp z, .__load_step29__\@
    cp 30
    jp z, .__load_step30__\@
    cp 31
    jp z, .__load_step31__\@

STEP_COUNT\@ equ 32
STEP set 0

.__load_step0__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step1__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step2__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step3__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step4__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step5__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step6__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step7__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step8__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step9__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step10__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step11__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step12__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step13__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step14__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step15__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step16__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step17__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step18__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step19__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step20__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step21__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step22__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step23__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step24__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step25__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step26__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step27__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step28__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step29__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step30__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step31__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    xor a
    ld [should_load_data], a
    call \4

.__inc_load_step__\@:
	ld a, [load_step]
	inc a
	ld [load_step], a

.__dont_load_data__\@:

endm

	; 1 = Source
	; 2 = Destination
	; 3 = Size
	; 4 = On Complete
mLoadDataIn89Frames: macro
	ld a, [should_load_data]
	cp $01
	jp nz, .__dont_load_data__\@

.__load_data__\@:
	ld a, [load_step]
    cp 0
    jp z, .__load_step0__\@
    cp 1
    jp z, .__load_step1__\@
    cp 2
    jp z, .__load_step2__\@
    cp 3
    jp z, .__load_step3__\@
    cp 4
    jp z, .__load_step4__\@
    cp 5
    jp z, .__load_step5__\@
    cp 6
    jp z, .__load_step6__\@
    cp 7
    jp z, .__load_step7__\@
    cp 8
    jp z, .__load_step8__\@
    cp 9
    jp z, .__load_step9__\@
    cp 10
    jp z, .__load_step10__\@
    cp 11
    jp z, .__load_step11__\@
    cp 12
    jp z, .__load_step12__\@
    cp 13
    jp z, .__load_step13__\@
    cp 14
    jp z, .__load_step14__\@
    cp 15
    jp z, .__load_step15__\@
    cp 16
    jp z, .__load_step16__\@
    cp 17
    jp z, .__load_step17__\@
    cp 18
    jp z, .__load_step18__\@
    cp 19
    jp z, .__load_step19__\@
    cp 20
    jp z, .__load_step20__\@
    cp 21
    jp z, .__load_step21__\@
    cp 22
    jp z, .__load_step22__\@
    cp 23
    jp z, .__load_step23__\@
    cp 24
    jp z, .__load_step24__\@
    cp 25
    jp z, .__load_step25__\@
    cp 26
    jp z, .__load_step26__\@
    cp 27
    jp z, .__load_step27__\@
    cp 28
    jp z, .__load_step28__\@
    cp 29
    jp z, .__load_step29__\@
    cp 30
    jp z, .__load_step30__\@
    cp 31
    jp z, .__load_step31__\@
    cp 32
    jp z, .__load_step32__\@
    cp 33
    jp z, .__load_step33__\@
    cp 34
    jp z, .__load_step34__\@
    cp 35
    jp z, .__load_step35__\@
    cp 36
    jp z, .__load_step36__\@
    cp 37
    jp z, .__load_step37__\@
    cp 38
    jp z, .__load_step38__\@
    cp 39
    jp z, .__load_step39__\@
    cp 40
    jp z, .__load_step40__\@
    cp 41
    jp z, .__load_step41__\@
    cp 42
    jp z, .__load_step42__\@
    cp 43
    jp z, .__load_step43__\@
    cp 44
    jp z, .__load_step44__\@
    cp 45
    jp z, .__load_step45__\@
    cp 46
    jp z, .__load_step46__\@
    cp 47
    jp z, .__load_step47__\@
    cp 48
    jp z, .__load_step48__\@
    cp 49
    jp z, .__load_step49__\@
    cp 50
    jp z, .__load_step50__\@
    cp 51
    jp z, .__load_step51__\@
    cp 52
    jp z, .__load_step52__\@
    cp 53
    jp z, .__load_step53__\@
    cp 54
    jp z, .__load_step54__\@
    cp 55
    jp z, .__load_step55__\@
    cp 56
    jp z, .__load_step56__\@
    cp 57
    jp z, .__load_step57__\@
    cp 58
    jp z, .__load_step58__\@
    cp 59
    jp z, .__load_step59__\@
    cp 60
    jp z, .__load_step60__\@
    cp 61
    jp z, .__load_step61__\@
    cp 62
    jp z, .__load_step62__\@
    cp 63
    jp z, .__load_step63__\@
    cp 64
    jp z, .__load_step64__\@
    cp 65
    jp z, .__load_step65__\@
    cp 66
    jp z, .__load_step66__\@
    cp 67
    jp z, .__load_step67__\@
    cp 68
    jp z, .__load_step68__\@
    cp 69
    jp z, .__load_step69__\@
    cp 70
    jp z, .__load_step70__\@
    cp 71
    jp z, .__load_step71__\@
    cp 72
    jp z, .__load_step72__\@
    cp 73
    jp z, .__load_step73__\@
    cp 74
    jp z, .__load_step74__\@
    cp 75
    jp z, .__load_step75__\@
    cp 76
    jp z, .__load_step76__\@
    cp 77
    jp z, .__load_step77__\@
    cp 78
    jp z, .__load_step78__\@
    cp 79
    jp z, .__load_step79__\@
    cp 80
    jp z, .__load_step80__\@
    cp 81
    jp z, .__load_step81__\@
    cp 82
    jp z, .__load_step82__\@
    cp 83
    jp z, .__load_step83__\@
    cp 84
    jp z, .__load_step84__\@
    cp 85
    jp z, .__load_step85__\@
    cp 86
    jp z, .__load_step86__\@
    cp 87
    jp z, .__load_step87__\@
    cp 88
    jp z, .__load_step88__\@

STEP_COUNT\@ equ 89
STEP set 0

.__load_step0__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step1__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step2__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step3__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step4__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step5__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step6__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step7__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step8__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step9__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step10__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step11__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step12__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step13__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step14__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step15__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step16__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step17__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step18__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step19__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step20__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step21__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step22__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step23__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step24__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step25__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step26__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step27__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step28__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step29__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step30__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step31__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step32__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step33__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step34__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step35__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step36__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step37__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step38__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step39__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step40__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step41__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step42__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step43__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step44__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step45__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step46__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step47__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step48__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step49__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step50__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step51__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step52__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step53__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step54__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step55__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step56__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step57__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step58__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step59__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step60__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step61__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step62__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step63__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step64__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step65__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step66__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step67__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step68__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step69__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step70__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step71__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step72__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step73__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step74__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step75__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step76__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step77__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step78__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step79__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step80__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step81__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step82__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step83__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step84__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step85__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step86__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step87__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1
.__load_step88__\@:
   	mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
	xor a
	ld [should_load_data], a
	call \4



.__inc_load_step__\@:
	ld a, [load_step]
	inc a
	ld [load_step], a

.__dont_load_data__\@:

endm

    ; 1 = Source
    ; 2 = Destination
    ; 3 = Size
    ; 4 = On Complete
mLoadDataIn16FramesWithBubbles: macro
    ld a, [should_load_data]
    cp $01
    jp nz, .__dont_load_data__\@

BUBBLE\@ equ 5

.__load_data__\@:
    ld a, [load_step]
    cp $00+BUBBLE\@ 
    jp z, .__load_step0__\@
    cp $01+BUBBLE\@ 
    jp z, .__load_step1__\@
    cp $02+BUBBLE\@ 
    jp z, .__load_step2__\@
    cp $03+BUBBLE\@ 
    jp z, .__load_step3__\@
    cp $04+BUBBLE\@ 
    jp z, .__load_step4__\@
    cp $05+BUBBLE\@ 
    jp z, .__load_step5__\@
    cp $06+BUBBLE\@ 
    jp z, .__load_step6__\@
    cp $07+BUBBLE\@ 
    jp z, .__load_step7__\@
    cp $08+BUBBLE\@ 
    jp z, .__load_step8__\@
    cp $09+BUBBLE\@ 
    jp z, .__load_step9__\@
    cp $0A+BUBBLE\@ 
    jp z, .__load_step10__\@
    cp $0B+BUBBLE\@ 
    jp z, .__load_step11__\@
    cp $0C+BUBBLE\@ 
    jp z, .__load_step12__\@
    cp $0D+BUBBLE\@ 
    jp z, .__load_step13__\@
    cp $0E+BUBBLE\@ 
    jp z, .__load_step14__\@
    cp $0F+BUBBLE\@ 
    jp z, .__load_step15__\@

    jp .__inc_load_step__\@

STEP_COUNT\@ equ 16
STEP set 0

.__load_step0__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step1__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step2__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step3__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step4__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step5__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step6__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jp .__inc_load_step__\@
STEP set STEP + 1

.__load_step7__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step8__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step9__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step10__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step11__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step12__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step13__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step14__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    jr .__inc_load_step__\@
STEP set STEP + 1

.__load_step15__\@:
        mSafeVRAMMemcpy \1+(\3/STEP_COUNT\@)*STEP, \2 +(\3/STEP_COUNT\@)*STEP, (\3/STEP_COUNT\@)
    xor a
    ld [should_load_data], a
    call \4

.__inc_load_step__\@:
    ld a, [load_step]
    inc a
    ld [load_step], a

.__dont_load_data__\@:

endm

mInitializeMusic: macro
	ld a, MusicBank
	ld [ROMB0], a
	call Player_Initialize
endm

mSelectSong: macro
	ld a, \1
	call Player_SongSelect
endm

mStartMusic: macro
	ld a, MusicBank
	ld [ROMB0], a
	call Player_MusicStart
endm

mStopMusic: macro
	ld a, MusicBank
	ld [ROMB0], a
	call Player_MusicStop
endm

mSetROMBank: macro
    ld a, \1
    ld [ROMB0], a
endm

mUpdateMusic: macro
	ld a,MusicBank
	ld [ROMB0],a
	call Player_MusicUpdate
endm

mUpdateMusicWaitVBlank: macro
    mUpdateMusic
    mWaitVBlank
endm

mSaveRegisters: macro
    push af
    push hl
    push de
    push bc
endm

mRestoreRegisters: macro
    pop bc
    pop de
    pop hl
    pop af
endm

mEnableVBlank: macro
	ld a, [INT_ENABLE]
	set 0, a
	ld [INT_ENABLE], a
endm

mDisableVBlank: macro
	ld a, [INT_ENABLE]
	res 0, a
	ld [INT_ENABLE], a
endm

; Arg 1 = Source
; Arg 2 = Destination
; Arg 3 = Size
mMemcpy: macro
    ld de, \1
    ld hl, \2
    ld bc, \3
    call unsafe_memcpy
endm


; Arg 1 = Source
; Arg 2 = Destination
; Arg 3 = Size
mSafeVRAMMemcpy: macro
	ld de, \1
    ld hl, \2
    ld bc, \3
    call safe_vram_memcpy
endm

; Arg 1 = Source
; Arg 2 = Destination
; Arg 3 = Size
mSafeVRAMMemcpyMusic: macro
	call Player_MusicUpdate
	ld de, \1
    ld hl, \2
    ld bc, \3
    call safe_vram_memcpy
endm

; Arg 1 = Value
; Arg 2 = Destination
; Arg 3 = Size
mSafeVRAMMemset: macro
    ld e, \1
    ld hl, \2
    ld bc, \3
    call safe_vram_memset
endm

mIfEqualJp: macro
	cp \1
    jp z, \2
endm

mIfNotEqualJp: macro
	cp \1
    jp nz, \2
endm

mIfEqualOrGreaterThanJp: macro
	cp \1
    jp nc, \2
endm

mIfLowerThanJp: macro
	cp \1
    jp c, \2
endm

mWaitVBlank: macro
.loop\@:
    ld a, [LY]
    cp $90
	jr nz, .loop\@
endm

mResetFadeVariables: macro
	xor a
	ld [fade_in_offset], a
	ld [fade_out_offset], a
endm

mSetStates: macro
	mResetFadeVariables
    ld a, \1
	ld [current_state], a
	ld a, \2
    ld [next_state], a
endm

mWaitForState: macro
.loop\@:
    ld a, [current_state]
    cp \1
	jr nz, .loop\@
endm

mWaitForStateAndFade: macro
	ld a, [fade_color]
	ld [BGP], a
    ld a, [current_state]
    cp \1
	;jr nz, $F5 ; <- apparently RGBDS doesn't like this
	db $20, $F5 
endm

mSetNextState: macro
    ld a, \1
    ld [next_state], a
endm

mDefineFadeLogic: macro
	ld a,[current_state]
	cp STATE_FADE_IN
	jr z,.fade_in
	cp STATE_FADE_OUT
	jr z,.fade_out
	jr .end_fade_logic
.fade_in
	ld a,[fade_in_offset]
	inc a
	cp LOW(fade_in_table_end)
	jr nz,.store_fade_in
	ld a, [next_state]
	ld [current_state],a
	jr .end_fade_logic	
.fade_out
	ld a,[fade_out_offset]
	inc a
	cp LOW(fade_out_table_end)
	jr nz,.store_fade_out
	ld a, [next_state]
	ld [current_state],a
	jr .end_fade_logic	
.store_fade_in:
	ld [fade_in_offset],a
	ld l, a
	ld h, HIGH(fade_in_table)
	ld a, [hl]
	ld [fade_color], a
	jr .end_fade_logic	
.store_fade_out:
	ld [fade_out_offset],a
	ld l, a
	ld h, HIGH(fade_out_table)
	ld a, [hl]
	ld [fade_color], a
.end_fade_logic:

endm

mDefineFadeLogicDirectBGP: macro
    ld a,[current_state]
    cp STATE_FADE_IN
    jr z,.fade_in
    cp STATE_FADE_OUT
    jr z,.fade_out
    jr .end_fade_logic
.fade_in
    ld a,[fade_in_offset]
    inc a
    cp LOW(fade_in_table_end)
    jr nz,.store_fade_in
    ld a, [next_state]
    ld [current_state],a
    jr .end_fade_logic  
.fade_out
    ld a,[fade_out_offset]
    inc a
    cp LOW(fade_out_table_end)
    jr nz,.store_fade_out
    ld a, [next_state]
    ld [current_state],a
    jr .end_fade_logic  
.store_fade_in:
    ld [fade_in_offset],a
    ld l, a
    ld h, HIGH(fade_in_table)
    ld a, [hl]
    ld [BGP], a
    jr .end_fade_logic  
.store_fade_out:
    ld [fade_out_offset],a
    ld l, a
    ld h, HIGH(fade_out_table)
    ld a, [hl]
    ld [BGP], a
.end_fade_logic:

endm

; 1 = Fade In Table Start
; 2 = Fade In Table End
; 3 = Fade Out Table Start
; 4 = Fade Out Table End
mDefineFadeLogicWithTables: macro
    ld a,[current_state]
    cp STATE_FADE_IN
    jr z,.fade_in\@
    cp STATE_FADE_OUT
    jr z,.fade_out\@
    jr .end_fade_logic\@
.fade_in\@
    ld a,[fade_in_offset]
    inc a
    cp LOW(\2)
    jr nz,.store_fade_in\@
    ld a, [next_state]
    ld [current_state],a
    jr .end_fade_logic\@
.fade_out\@
    ld a,[fade_out_offset]
    inc a
    cp LOW(\4)
    jr nz,.store_fade_out\@
    ld a, [next_state]
    ld [current_state],a
    jr .end_fade_logic\@ 
.store_fade_in\@:
    ld [fade_in_offset],a
    ld l, a
    ld h, HIGH(\1)
    ld a, [hl]
    ld [fade_color], a
    jr .end_fade_logic\@  
.store_fade_out\@:
    ld [fade_out_offset],a
    ld l, a
    ld h, HIGH(\3)
    ld a, [hl]
    ld [fade_color], a
.end_fade_logic\@:

endm

mEnableLoading: macro
    ld a, 1
    ld [should_load_data], a
endm

mDisableLoading: macro
    ld a, 0
    ld [should_load_data], a
endm

mUpdateBackground: macro
    ld a, [fade_color]
    ld [BGP], a
    ld [OBJP0], a
endm

mJumpCheckEnding: macro
    ld a, [current_state]
    cp STATE_END_FX
    ret z
    jp \1    
endm

mLoadIn8SongUpdatesBANK: macro

SIZE\@ equ (\3/ 8)
STEP\@ set 0

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1
    
    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1
endm


mLoadIn6SongUpdatesBANK: macro

SIZE\@ equ (\3/ 6)
STEP\@ set 0

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1
    
    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1
endm

mLoadIn4SongUpdatesBANK: macro

SIZE\@ equ (\3/ 4)
STEP\@ set 0

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1
    
    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

    mSetROMBank \4
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

endm


mLoadIn2SongUpdatesBANK2: macro

SIZE\@ equ (\3/ 2)
STEP\@ set 0

    mSetROMBank 2
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1
    
    mSetROMBank 2
    mSafeVRAMMemcpy \1+SIZE\@*STEP\@, \2+SIZE\@*STEP\@, SIZE\@
    mUpdateMusic
STEP\@ set STEP\@+1

endm

endc