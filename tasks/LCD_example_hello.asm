;-------------------------------------------------------------------------------
; LCD Example - Print Hello.
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; C header includes
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
;-------------------------------------------------------------------------------
; Reset Code
;-------------------------------------------------------------------------------
            .text
            .global RESET

RESET:      mov.w   #__STACK_END,SP         ; Initialize stackpointer
            mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
            mov.w   #0000h,&PM5CTL0         ; disable power saving mode
;-------------------------------------------------------------------------------
; LCD initialization
; Set up power, set pin functions, clear memry, enable LCD.
; LCDDIV_0 | LCDPRE_4 | LCDMX1 | LCDMX0 | LCDSON | LCDLP | LCDON == 0x041F
;-------------------------------------------------------------------------------
LCD_INIT:   mov      #(VLCD_8 | LCDCPEN | VLCDREF_0), LCDCVCTL
            mov      #0xFFFF, LCDCPCTL0
            mov      #0xFC3F, LCDCPCTL1
            mov      #0x0FFF, LCDCPCTL2
            mov      #LCDCPCLKSYNC, LCDCCPCTL
            mov      #LCDCLRM, LCDCMEMCTL
            mov      #0x041F, LCDCCTL0
;-------------------------------------------------------------------------------
; Print text
;-------------------------------------------------------------------------------
SAY_HI:     mov.b     #0x6F, LCDM10         ; put letter "H" in A1
            mov.b     #0x9F, LCDM6          ; put letter "E" in A2
            mov.b     #0x1c, LCDM4          ; put letter "L" in A3
            mov.b     #0x1c, LCDM19         ; put letter "L" in A4
            mov.b     #0xFC, LCDM15         ; put letter "O" in A5
;-------------------------------------------------------------------------------
; Empty main routine
;-------------------------------------------------------------------------------
MAIN:       nop
            jmp        MAIN
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
