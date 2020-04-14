SECTION "Memory", ROM0

    include "registers.asm"
    include "memory.asm"
    include "common.asm"

    ; We assume the source address is $C100
    ; dma_transfer is stored in HRAM ($FF80)
dma_transfer_start:
    ld a, high(DMA_OAM)
    ld [DMA],a
    ld a,$28
.wait:
    dec a
    ; the assembler is stupid
    ; I can't do proper relative jump 
    ; with constants :) so we just
    ; write the op codes by hand
    db $20
    db $FD
    ;jr nz,$FD
    ret
dma_transfer_end:

init_dma::
    ld de,dma_transfer_start
    ld hl,$FF80
    ld bc,dma_transfer_end-dma_transfer_start
    call unsafe_memcpy
    ld hl,DMA_OAM
    xor a
    ld b,a
.clean_dma_oam:
    ld [hl],b
    inc hl
    ld a,l
    cp $00
    jr nz,.clean_dma_oam
    ret
   
    ;Warning, A is thrashed
    ;de = source address
    ;hl = destination address
    ;bc = buffer size
unsafe_memcpy::
.rep_memstore:
    ld a,[de]
    ld [hl+],a
    dec bc
    inc de
    ld a,c
    cp $00
    jr nz,.rep_memstore
    ld a,b
    cp $00
    jr nz,.rep_memstore
    ret

    ;Warning, A and D are thrashed
    ;a = value
    ;hl = destination address
    ;bc = buffer size
unsafe_memset::
    ld d,a
.rep_memstore:
    ld a,d
    ld [hl+],a
    dec bc
    ld a,c
    cp $00
    jr nz,.rep_memstore
    ld a,b
    cp $00
    jr nz,.rep_memstore
    ret

    ;Warning, A and D are thrashed
    ;e = value
    ;hl = destination address
    ;bc = buffer size
safe_vram_memset::
.check_vram_access:
    ld a,[LCDS]
    and a,$3
    cp $00
    jr nz,.check_vram_access

    ld a,e
.rep_memstore:
    ld [hl+],a
    dec bc
    ld a,c
    cp $00
    jr nz,.check_vram_access
    ld a,b
    cp $00
    jr nz,.check_vram_access
    ret

    ;Warning, A register is thrashed
    ;de = source address
    ;hl = destination address
    ;bc = buffer size
safe_vram_memcpy::
.check_vram_access:
    ld a,[LCDS]
    and a,$3
    cp $00
    jr nz,.check_vram_access

.rep_memstore:
    ld a,[de]
    ld [hl+],a
    dec bc
    inc de
    ld a,c
    cp $00
    jr nz,.check_vram_access
    ld a,b
    cp $00
    jr nz,.check_vram_access
    ret

    ;Warning, A register is thrashed
    ;de = source address
    ;hl = destination address
    ;bc = buffer size
safe_oam_memcpy::
.check_oam_access:
    ld a,[LCDS]
    and a,$3
    cp $3
    jr z,.check_oam_access
    cp $2
    jr z,.check_oam_access

.rep_memstore:
    ld a,[de]
    ld [hl+],a
    dec bc
    inc de
    ld a,c
    cp $00
    jr nz,.check_oam_access
    ld a,b
    cp $00
    jr nz,.check_oam_access
    ret

    ;Warning, A is thrashed
    ;d = value
    ;hl = destination address
    ;bc = buffer size
unsafe_buffer_add::
.loop:
    ld a, [hl]
    add a, d
    ld [hl+], a
    dec bc
    ld a,c
    cp 0
    jr nz,.loop
    ld a,b
    cp 0
    jr nz,.loop
    ret

section "dbg",WRAM0

dbg_tmp: ds 1
memcpy_offset_value:: ds 1
