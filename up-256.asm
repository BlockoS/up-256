; ▀ █ █▀█ ▀▀█ █▀█ █▀█ █ ▀
; █ █ █▄█ █ █ █ █ █ █ █▄█
; █ █ █ ▄▄▄▄█ █▄█ █ ▀ ▀ █
; █▄█ █ █ █ ▄ ▄ ▄ █ ▀▀█ █
; ▄▄▄▄█ █ █▄█ █▄█ █▄▄▄█ █
;
; A Sharp MZ-700 256 bytes 
;     invitro for the 
;      Shadow Party
;     21-23 May  2021
;    shadow-party.org
;
;   code/gfx/msx: MooZ
;      uprough.net
;
;    logo by goto80
org #1200

SCREEN_WIDTH = 40
SCREEN_HEIGHT = 25

hblnk = 0xe008
vblnk = 0xe002

; monitor routines and data address 
start_note = 0x0044
stop_note = 0x0047
freq = 0x11a1
wait_vblk = 0x0da6
wait_key = 0x09b3
chr_x = 0x1171
chr_y = 0x1172

main:
    di
    im 1

background_flag:
    ld hl, 0xd800
    ld (hl), 0x44
    ld de, 0xd801
    ld bc, 40*8
    ldir

    ld (hl), 0x66
    ld bc, 40*9
    ldir

    ld (hl), 0x02
    ld bc, 40*8
    ldir

draw_lion:
    ld hl, 0xd800+(12+3*40)
    ld ix, lion

    ld c, 17
.ly:
    ld e, 2
.l0:
    ld a, (ix)
    inc ix

    ld b, 8
.lx:
    add a, a
    jr nc, .skip
        ld (hl), 0x00
.skip:
    inc hl
    djnz, .lx

    dec e
    jp nz, .l0

    ld de, SCREEN_WIDTH-16
    add hl, de

    dec c
    jr nz, .ly

txt:
    ld hl, msg
    ld de, 0xd000+(7+22*40)
    ld bc, 26
    ldir

    ld a, 0x36
    ld ($e007), a

loop:
    ld de, music
play:
    ld a, (de)
    dec a
    jr z, loop                  ; We will start over as we reached the end of the "song".

    inc de

    ld b, a                     ; Save the rest duration.

    ld a, (de)                  ; Retrieve the note frequency.
    inc de
    ld h, hi(notes)
    ld l, a
    ld a, (hl)
    ld (freq), a
    inc l
    ld a, (hl)    
    ld (freq+1), a

    call start_note

    call frame                  ; Let the note run for 10 frames.

silence:
    call stop_note              ; Stop it and wait until we fetch the next one.

    ld b, delay_cut
    call frame

    jr play

frame:                          ; wait for vblank and modify text
    call wait_vblk

    bit 0, b
    jr z, .l0

    exx                         ; with the international charset the text will
dst equ $+1                     ; switch between standard and "bold" text.
    ld b, 0x00
    ld a, 31
    and c
    ld c, a
    ld hl, 0xd800+22*40+7
    add hl, bc
    ld a, 0x80
    xor (hl)
    ld (hl), a
    inc c
    exx
.l0:
    djnz, frame

    ret

; notes
; g_4 = 1108800 / 440
notes
cx2: defw floor(1108800/69.30)
d_2: defw floor(1108800/73.42)
fx2: defw floor(1108800/92.50)
g_2: defw floor(1108800/98.00)
a_4: defw floor(1108800/440.00)
g_4: defw floor(1108800/493.88)

note_5 = lo(g_4)
note_4 = lo(a_4)
note_3 = lo(g_2)
note_2 = lo(fx2)
note_1 = lo(d_2)
note_0 = lo(cx2)

music_end = 1

ifdef FREQ_60
    delay_cut = 2
    delay_0 = 2
    delay_1 = 13
else                                ; FREQ_50
    delay_cut = 1
    delay_0 = 2
    delay_1 = 11
endif

delay_2 = 2*delay_1+delay_cut

delay_3 = delay_1 - (delay_0+delay_cut)
delay_4 = delay_2 - (delay_0+delay_cut)

; well... this is supposed to sound like sleng teng bass line :p
music:
    defb delay_1, note_0
    defb delay_1, note_1
    defb delay_1, note_1
    defb delay_1, note_1

    defb delay_0, note_5
    defb delay_3, note_0

    defb delay_1, note_1
    defb delay_1, note_1
    defb delay_1, note_1

    defb delay_1, note_0
    defb delay_1, note_1
    defb delay_1, note_1
    defb delay_1, note_1
 
    defb delay_0, note_4
    defb delay_4, note_3   
    defb delay_2, note_2
    
    defb music_end

; lion of Judah
lion:
    defw %0000000000000100
    defw %0000000000001110
    defw %0000000000000100
    defw %1010100001111100
    defw %1111100001111100
    defw %1000100000000100
    defw %1000111000100100
    defw %1000001011100101
    defw %0010101110000101
    defw %0010100111111111
    defw %0100010100100001
    defw %0110000100100000
    defw %0000000100100001
    defw %1000001000111111
    defw %1111110000101000
    defw %0101000000101000
    defw %0101000000101000

msg:
;    defb 'SHADOW PARTY 21-23 05 2021'
    defb 0x13,0x08,0x01,0x04,0x0f,0x17,0x00,0x10,0x01,0x12,0x14,0x19,0x00,0x22,0x21,0x5a,0x22,0x23,0x00,0x20,0x25,0x00,0x22,0x20,0x22,0x21

    defb 0,0
