; N64 'Bare Metal' CPU Signed Word Addition Test Demo by krom (Peter Lemon):

PrintString: macro vram,xpos,ypos,fontfile,string,length ; Print Text String To VRAM Using Font At X,Y Position
  lui t0,vram ; T0 = Frame Buffer Pointer
  addi t0,((xpos*4)+((640*ypos)*4)) ; Place text at XY Position
  la t1,fontfile ; T1 = Characters
  la t2,string ; T2 = Text Offset
  li t3,length ; T3 = Number of Text Characters to Print
  DrawChars\@:
    li t4,7 ; T4 = Character X Pixel Counter
    li t5,7 ; T5 = Character Y Pixel Counter

    lb t6,0(t2) ; T6 = Next Text Character
    addi t2,1

    sll t6,8 ; Add Shift to Correct Position in Font (* 256)
    add t6,t1

    DrawCharX\@:
      lw t7,0(t6) ; Load Font Text Character Pixel
      addi t6,4
      sw t7,0(t0) ; Store Font Text Character Pixel into Frame Buffer
      addi t0,4

      bnez t4,DrawCharX\@ ; IF Character X Pixel Counter != 0 GOTO DrawCharX
      subi t4,1 ; Decrement Character X Pixel Counter

      addi t0,$9E0 ; Jump down 1 Scanline, Jump back 1 Char ((SCREEN_X * 4) - (CHAR_X * 4))
      li t4,7 ; Reset Character X Pixel Counter
      bnez t5,DrawCharX\@ ; IF Character Y Pixel Counter != 0 GOTO DrawCharX
      subi t5,1 ; Decrement Character Y Pixel Counter

    subi t0,$4FE0 ; ((SCREEN_X * 4) * CHAR_Y) - CHAR_X * 4
    bnez t3,DrawChars\@ ; Continue to Print Characters
    subi t3,1 ; Subtract Number of Text Characters to Print
    endm

PrintValue: macro vram,xpos,ypos,fontfile,value,length ; Print HEX Chars To VRAM Using Font At X,Y Position
  lui t0,vram ; T0 = Frame Buffer Pointer
  addi t0,((xpos*4)+((640*ypos)*4)) ; Place text at XY Position
  la t1,fontfile ; T1 = Characters
  la t2,value ; T2 = Value Offset
  li t3,length ; T3 = Number of HEX Chars to Print
  DrawHEXChars\@:
    li t4,7 ; T4 = Character X Pixel Counter
    li t5,7 ; T5 = Character Y Pixel Counter

    lb t6,0(t2) ; T6 = Next 2 HEX Chars
    addi t2,1

    srl t7,t6,4 ; T7 = 2nd Nibble
    andi t7,$F
    subi t8,t7,9
    bgtz t8,HEXLetters\@
    addi t7,$30 ; Delay Slot
    j HEXEnd\@
    nop ; Delay Slot

    HEXLetters\@:
    addi t7,7
    HEXEnd\@:

    sll t7,8 ; Add Shift to Correct Position in Font (* 256)
    add t7,t1

    DrawHEXCharX\@:
      lw t8,0(t7) ; Load Font Text Character Pixel
      addi t7,4
      sw t8,0(t0) ; Store Font Text Character Pixel into Frame Buffer
      addi t0,4

      bnez t4,DrawHEXCharX\@ ; IF Character X Pixel Counter != 0 GOTO DrawCharX
      subi t4,1 ; Decrement Character X Pixel Counter

      addi t0,$9E0 ; Jump down 1 Scanline, Jump back 1 Char ((SCREEN_X * 4) - (CHAR_X * 4))
      li t4,7 ; Reset Character X Pixel Counter
      bnez t5,DrawHEXCharX\@ ; IF Character Y Pixel Counter != 0 GOTO DrawCharX
      subi t5,1 ; Decrement Character Y Pixel Counter

    subi t0,$4FE0 ; ((SCREEN_X * 4) * CHAR_Y) - CHAR_X * 4

    li t5,7 ; Reset Character Y Pixel Counter

    andi t7,t6,$F ; T7 = 1st Nibble
    subi t8,t7,9
    bgtz t8,HEXLettersB\@
    addi t7,$30 ; Delay Slot
    j HEXEndB\@
    nop ; Delay Slot

    HEXLettersB\@:
    addi t7,7
    HEXEndB\@:

    sll t7,8 ; Add Shift to Correct Position in Font (* 256)
    add t7,t1

    DrawHEXCharXB\@:
      lw t8,0(t7) ; Load Font Text Character Pixel
      addi t7,4
      sw t8,0(t0) ; Store Font Text Character Pixel into Frame Buffer
      addi t0,4

      bnez t4,DrawHEXCharXB\@ ; IF Character X Pixel Counter != 0 GOTO DrawCharX
      subi t4,1 ; Decrement Character X Pixel Counter

      addi t0,$9E0 ; Jump down 1 Scanline, Jump back 1 Char ((SCREEN_X * 4) - (CHAR_X * 4))
      li t4,7 ; Reset Character X Pixel Counter
      bnez t5,DrawHEXCharXB\@ ; IF Character Y Pixel Counter != 0 GOTO DrawCharX
      subi t5,1 ; Decrement Character Y Pixel Counter

    subi t0,$4FE0 ; ((SCREEN_X * 4) * CHAR_Y) - CHAR_X * 4

    bnez t3,DrawHEXChars\@ ; Continue to Print Characters
    subi t3,1 ; Subtract Number of Text Characters to Print
    endm

  include LIB\N64.INC ; Include N64 Definitions
  dcb 2097152,$00 ; Set ROM Size
  org $80000000 ; Entry Point Of Code
  include LIB\N64_HEADER.ASM  ; Include 64 Byte Header & Vector Table
  incbin LIB\N64_BOOTCODE.BIN ; Include 4032 Byte Boot Code

Start:
  include LIB\N64_INIT.ASM ; Include Initialisation Routine
  include LIB\N64_GFX.INC  ; Include Graphics Macros

  ScreenNTSC 640,480, BPP32|INTERLACE|AA_MODE_2, $A0100000 ; Screen NTSC: 640x480, 32BPP, Interlace, Reample Only, DRAM Origin = $A0100000

  lui t0,$A010 ; T0 = VRAM Start Offset
  addi t1,t0,((640*480*4)-4) ; T1 = VRAM End Offset
  li t2,$000000FF ; T2 = Black
ClearScreen:
  sw t2,0(t0)
  bne t0,t1,ClearScreen
  addi t0,4 ; Delay Slot




  PrintString $A010,88,8,FontRed,RSRTHEX,10 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,232,8,FontRed,RSRTDEC,14 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,384,8,FontRed,RDHEX,7 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,528,8,FontRed,TEST,10 ; Print Text String To VRAM Using Font At X,Y Position


  PrintString $A010,0,16,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  PrintString $A010,8,24,FontRed,ADD,2 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,VALUEWORDA ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  la t1,VALUEWORDB ; T1 = Word Data Offset
  lw t1,0(t1)      ; T1 = Word Data
  add t0,t1 ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,24,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,24,FontBlack,VALUEWORDA,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,360,24,FontBlack,TEXTWORDA,0  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,32,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,32,FontBlack,VALUEWORDB,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,32,FontBlack,TEXTWORDB,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,32,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,32,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD    ; T0 = Word Data Offset
  lw t1,0(t0)     ; T1 = Word Data
  la t0,ADDCHECKA ; T0 = Word Check Data Offset
  lw t2,0(t0)     ; T2 = Word Check Data
  beq t1,t2,ADDPASSA ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,32,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDENDA
  nop ; Delay Slot
  ADDPASSA:
  PrintString $A010,528,32,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDENDA:

  la t0,VALUEWORDB ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  la t1,VALUEWORDC ; T1 = Word Data Offset
  lw t1,0(t1)      ; T1 = Word Data
  add t0,t1 ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,48,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,48,FontBlack,VALUEWORDB,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,48,FontBlack,TEXTWORDB,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,56,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,56,FontBlack,VALUEWORDC,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,320,56,FontBlack,TEXTWORDC,5  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,56,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,56,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD    ; T0 = Word Data Offset
  lw t1,0(t0)     ; T1 = Word Data
  la t0,ADDCHECKB ; T0 = Word Check Data Offset
  lw t2,0(t0)     ; T2 = Word Check Data
  beq t1,t2,ADDPASSB ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,56,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDENDB
  nop ; Delay Slot
  ADDPASSB:
  PrintString $A010,528,56,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDENDB:

  la t0,VALUEWORDC ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  la t1,VALUEWORDD ; T1 = Word Data Offset
  lw t1,0(t1)      ; T1 = Word Data
  add t0,t1 ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,72,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,72,FontBlack,VALUEWORDC,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,320,72,FontBlack,TEXTWORDC,5  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,80,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,80,FontBlack,VALUEWORDD,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,80,FontBlack,TEXTWORDD,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,80,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,80,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD    ; T0 = Word Data Offset
  lw t1,0(t0)     ; T1 = Word Data
  la t0,ADDCHECKC ; T0 = Word Check Data Offset
  lw t2,0(t0)     ; T2 = Word Check Data
  beq t1,t2,ADDPASSC ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,80,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDENDC
  nop ; Delay Slot
  ADDPASSC:
  PrintString $A010,528,80,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDENDC:

  la t0,VALUEWORDD ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  la t1,VALUEWORDE ; T1 = Word Data Offset
  lw t1,0(t1)      ; T1 = Word Data
  add t0,t1 ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,96,FontBlack,DOLLAR,0      ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,96,FontBlack,VALUEWORDD,3  ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,96,FontBlack,TEXTWORDD,8   ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,104,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,104,FontBlack,VALUEWORDE,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,104,FontBlack,TEXTWORDE,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,104,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,104,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD    ; T0 = Word Data Offset
  lw t1,0(t0)     ; T1 = Word Data
  la t0,ADDCHECKD ; T0 = Word Check Data Offset
  lw t2,0(t0)     ; T2 = Word Check Data
  beq t1,t2,ADDPASSD ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,104,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDENDD
  nop ; Delay Slot
  ADDPASSD:
  PrintString $A010,528,104,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDENDD:

  la t0,VALUEWORDE ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  la t1,VALUEWORDF ; T1 = Word Data Offset
  lw t1,0(t1)      ; T1 = Word Data
  add t0,t1 ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,120,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,120,FontBlack,VALUEWORDE,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,120,FontBlack,TEXTWORDE,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,128,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,128,FontBlack,VALUEWORDF,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,312,128,FontBlack,TEXTWORDF,6  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,128,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,128,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD    ; T0 = Word Data Offset
  lw t1,0(t0)     ; T1 = Word Data
  la t0,ADDCHECKE ; T0 = Word Check Data Offset
  lw t2,0(t0)     ; T2 = Word Check Data
  beq t1,t2,ADDPASSE ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,128,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDENDE
  nop ; Delay Slot
  ADDPASSE:
  PrintString $A010,528,128,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDENDE:

  la t0,VALUEWORDF ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  la t1,VALUEWORDG ; T1 = Word Data Offset
  lw t1,0(t1)      ; T1 = Word Data
  add t0,t1 ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,144,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,144,FontBlack,VALUEWORDF,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,312,144,FontBlack,TEXTWORDF,6  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,152,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,152,FontBlack,VALUEWORDG,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,152,FontBlack,TEXTWORDG,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,152,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,152,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD    ; T0 = Word Data Offset
  lw t1,0(t0)     ; T1 = Word Data
  la t0,ADDCHECKF ; T0 = Word Check Data Offset
  lw t2,0(t0)     ; T2 = Word Check Data
  beq t1,t2,ADDPASSF ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,152,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDENDF
  nop ; Delay Slot
  ADDPASSF:
  PrintString $A010,528,152,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDENDF:

  la t0,VALUEWORDA ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  la t1,VALUEWORDG ; T1 = Word Data Offset
  lw t1,0(t1)      ; T1 = Word Data
  add t0,t1 ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,168,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,168,FontBlack,VALUEWORDA,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,360,168,FontBlack,TEXTWORDA,0  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,176,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,176,FontBlack,VALUEWORDG,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,176,FontBlack,TEXTWORDG,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,176,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,176,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD    ; T0 = Word Data Offset
  lw t1,0(t0)     ; T1 = Word Data
  la t0,ADDCHECKG ; T0 = Word Check Data Offset
  lw t2,0(t0)     ; T2 = Word Check Data
  beq t1,t2,ADDPASSG ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,176,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDENDG
  nop ; Delay Slot
  ADDPASSG:
  PrintString $A010,528,176,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDENDG:


  PrintString $A010,8,192,FontRed,ADDI,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,VALUEWORDA ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  addi t0,VALUEIWORDB ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,192,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,192,FontBlack,VALUEWORDA,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,360,192,FontBlack,TEXTWORDA,0  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,200,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,200,FontBlack,IWORDB,3     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,200,FontBlack,TEXTIWORDB,4 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,200,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,200,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD     ; T0 = Word Data Offset
  lw t1,0(t0)      ; T1 = Word Data
  la t0,ADDICHECKA ; T0 = Word Check Data Offset
  lw t2,0(t0)      ; T2 = Word Check Data
  beq t1,t2,ADDIPASSA ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,200,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDIENDA
  nop ; Delay Slot
  ADDIPASSA:
  PrintString $A010,528,200,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDIENDA:

  la t0,VALUEWORDB ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  addi t0,VALUEIWORDC ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,216,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,216,FontBlack,VALUEWORDB,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,296,216,FontBlack,TEXTWORDB,8  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,224,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,224,FontBlack,IWORDC,3     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,336,224,FontBlack,TEXTIWORDC,3 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,224,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,224,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD     ; T0 = Word Data Offset
  lw t1,0(t0)      ; T1 = Word Data
  la t0,ADDICHECKB ; T0 = Word Check Data Offset
  lw t2,0(t0)      ; T2 = Word Check Data
  beq t1,t2,ADDIPASSB ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,224,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDIENDB
  nop ; Delay Slot
  ADDIPASSB:
  PrintString $A010,528,224,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDIENDB:

  la t0,VALUEWORDC ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  addi t0,VALUEIWORDD ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,240,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,240,FontBlack,VALUEWORDC,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,320,240,FontBlack,TEXTWORDC,5  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,248,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,248,FontBlack,IWORDD,3     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,248,FontBlack,TEXTIWORDD,4 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,248,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,248,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD     ; T0 = Word Data Offset
  lw t1,0(t0)      ; T1 = Word Data
  la t0,ADDICHECKC ; T0 = Word Check Data Offset
  lw t2,0(t0)      ; T2 = Word Check Data
  beq t1,t2,ADDIPASSC ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,248,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDIENDC
  nop ; Delay Slot
  ADDIPASSC:
  PrintString $A010,528,248,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDIENDC:

  la t0,IWORDD ; T0 = Word Data Offset
  lw t0,0(t0)  ; T0 = Word Data
  addi t0,VALUEIWORDE ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,264,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,264,FontBlack,IWORDD,3     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,264,FontBlack,TEXTIWORDD,4 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,272,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,272,FontBlack,IWORDE,3     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,320,272,FontBlack,TEXTIWORDE,5 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,272,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,272,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD     ; T0 = Word Data Offset
  lw t1,0(t0)      ; T1 = Word Data
  la t0,ADDICHECKD ; T0 = Word Check Data Offset
  lw t2,0(t0)      ; T2 = Word Check Data
  beq t1,t2,ADDIPASSD ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,272,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDIENDD
  nop ; Delay Slot
  ADDIPASSD:
  PrintString $A010,528,272,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDIENDD:

  la t0,VALUEWORDE ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  addi t0,VALUEIWORDF ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,288,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,288,FontBlack,VALUEWORDE,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,288,288,FontBlack,TEXTWORDE,9  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,296,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,296,FontBlack,IWORDF,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,328,296,FontBlack,TEXTIWORDF,4 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,296,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,296,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD     ; T0 = Word Data Offset
  lw t1,0(t0)      ; T1 = Word Data
  la t0,ADDICHECKE ; T0 = Word Check Data Offset
  lw t2,0(t0)      ; T2 = Word Check Data
  beq t1,t2,ADDIPASSE ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,296,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDIENDE
  nop ; Delay Slot
  ADDIPASSE:
  PrintString $A010,528,296,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDIENDE:

  la t0,VALUEWORDF ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  addi t0,VALUEIWORDG ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,312,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,312,FontBlack,VALUEWORDF,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,312,312,FontBlack,TEXTWORDF,6  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,320,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,320,FontBlack,IWORDG,3     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,320,320,FontBlack,TEXTIWORDG,5 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,320,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,320,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD     ; T0 = Word Data Offset
  lw t1,0(t0)      ; T1 = Word Data
  la t0,ADDICHECKF ; T0 = Word Check Data Offset
  lw t2,0(t0)      ; T2 = Word Check Data
  beq t1,t2,ADDIPASSF ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,320,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDIENDF
  nop ; Delay Slot
  ADDIPASSF:
  PrintString $A010,528,320,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDIENDF:

  la t0,VALUEWORDA ; T0 = Word Data Offset
  lw t0,0(t0)      ; T0 = Word Data
  addi t0,VALUEIWORDG ; T0 = Test Word Data
  la t1,RDWORD ; T1 = RDWORD Offset
  sw t0,0(t1)  ; RDWORD = Word Data
  PrintString $A010,144,336,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,336,FontBlack,VALUEWORDA,3 ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,360,336,FontBlack,TEXTWORDA,0  ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,144,344,FontBlack,DOLLAR,0     ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,152,344,FontBlack,IWORDG,3     ; Print HEX Chars To VRAM Using Font At X,Y Position
  PrintString $A010,320,344,FontBlack,TEXTIWORDG,5 ; Print Text String To VRAM Using Font At X,Y Position
  PrintString $A010,440,344,FontBlack,DOLLAR,0 ; Print Text String To VRAM Using Font At X,Y Position
  PrintValue  $A010,448,344,FontBlack,RDWORD,3 ; Print Text String To VRAM Using Font At X,Y Position
  la t0,RDWORD     ; T0 = Word Data Offset
  lw t1,0(t0)      ; T1 = Word Data
  la t0,ADDICHECKG ; T0 = Word Check Data Offset
  lw t2,0(t0)      ; T2 = Word Check Data
  beq t1,t2,ADDIPASSG ; Compare Result Equality With Check Data
  nop ; Delay Slot
  PrintString $A010,528,344,FontRed,FAIL,3 ; Print Text String To VRAM Using Font At X,Y Position
  j ADDIENDG
  nop ; Delay Slot
  ADDIPASSG:
  PrintString $A010,528,344,FontGreen,PASS,3 ; Print Text String To VRAM Using Font At X,Y Position
  ADDIENDG:


  PrintString $A010,0,352,FontBlack,PAGEBREAK,79 ; Print Text String To VRAM Using Font At X,Y Position


  lui t0,VI_BASE ; Load VI Base Register
Loop:
  WaitScanline $200 ; Wait For Scanline To Reach Vertical Blank
  WaitScanline $202

  li t1,$00000800 ; Even Field
  sw t1,VI_Y_SCALE(t0)

  WaitScanline $200 ; Wait For Scanline To Reach Vertical Blank
  WaitScanline $202

  li t1,$02000800 ; Odd Field
  sw t1,VI_Y_SCALE(t0)

  j Loop
  nop ; Delay Slot

ADD: db "ADD"
ADDI: db "ADDI"

RDHEX: db "RD (Hex)"
RSRTHEX: db "RS/RT (Hex)"
RSRTDEC: db "RS/RT (Decimal)"
TEST: db "Test Result"
FAIL: db "FAIL"
PASS: db "PASS"

DOLLAR: db "$"

TEXTWORDA: db "0"
TEXTWORDB: db "123456789"
TEXTWORDC: db "123456"
TEXTWORDD: db "123451234"
TEXTWORDE: db "-123451234"
TEXTWORDF: db "-123456"
TEXTWORDG: db "-123456789"

TEXTIWORDB: db "12345"
TEXTIWORDC: db "1234"
TEXTIWORDD: db "12341"
TEXTIWORDE: db "-12341"
TEXTIWORDF: db "-1234"
TEXTIWORDG: db "-12345"

PAGEBREAK: db "--------------------------------------------------------------------------------"

  align 8 ; Align 64-bit
VALUEWORDA: dw 0
VALUEWORDB: dw 123456789
VALUEWORDC: dw 123456
VALUEWORDD: dw 123451234
VALUEWORDE: dw -123451234
VALUEWORDF: dw -123456
VALUEWORDG: dw -123456789

ADDCHECKA: dw $075BCD15
ADDCHECKB: dw $075DAF55
ADDCHECKC: dw $075D99A2
ADDCHECKD: dw $00000000
ADDCHECKE: dw $F8A2665E
ADDCHECKF: dw $F8A250AB
ADDCHECKG: dw $F8A432EB

VALUEIWORDB: equ 12345
VALUEIWORDC: equ 1234
VALUEIWORDD: equ 12341
VALUEIWORDE: equ -12341
VALUEIWORDF: equ -1234
VALUEIWORDG: equ -12345
IWORDB: dw 12345
IWORDC: dw 1234
IWORDD: dw 12341
IWORDE: dw -12341
IWORDF: dw -1234
IWORDG: dw -12345

ADDICHECKA: dw $00003039
ADDICHECKB: dw $075BD1E7
ADDICHECKC: dw $00021275
ADDICHECKD: dw $00000000
ADDICHECKE: dw $F8A443CC
ADDICHECKF: dw $FFFDED87
ADDICHECKG: dw $FFFFCFC7

RDWORD: dw 0

FontBlack: incbin FontBlack8x8.bin
FontGreen: incbin FontGreen8x8.bin
FontRed: incbin FontRed8x8.bin