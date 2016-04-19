;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
; Main Code
;-------------------------------------------------------------------------------
            .text
            .global RESET

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
            mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
            mov.w   #0000h,&PM5CTL0
            bis.b   #00000001b,&P1DIR       ; Initialize LED1
            bis.b   #10000000b,&P9DIR       ; Initialize LED2
            bic.b   #00000001b,&P1OUT       ; Deactivate LED1
            bic.b   #10000000b,&P9OUT       ; Deactivate LED2

            bic.b   #00000110b,&P1DIR       ; Initialize Btn1&2
            bis.b   #00000110b,&P1OUT       ; Initialize PullUp-Resistor
            bis.b   #00000110b,&P1REN       ; Initialize PullUp-Resistor

            bic.b   #00000110b,&P1IFG       ; Reset Interrupt Handling Flag for Btn1&2
            bis.b   #00000110b,&P1IES       ; Initialize Interrupt Handling for Btn1&2
            bis.b   #00000110b,&P1IE        ; Activate Interrupt Handling for Btn1&2

            mov.w   #0x0CA7,LCDCCTL0        ; Sets LCD frequency divider Bit to LCDDIV_1,
                                            ; Sets LCD frequency pre-scaler Bit to LCDPRE_4
                                            ; Selects clock 1
                                            ; Sets Mux Rate Bit 2 to  1 (Mux Rate Bit 0 and 1 are 0)
                                            ; Turns the LCD_C Semgents ON
                                            ; Selects Low Power Waveform
                                            ; Turns on the LCD
            mov.w   #0x00C1,LCDCCTL1        ; Sets Frame interrupt Flag
            mov.w   #0x0608,LCDCVCTL        ; Sets VLCD to VLCD_3 and enables Charge Pump
            mov.w   #0xFFFF,LCDCPCTL0       ; Enabling Segments 1-15
            mov.w   #0xFC3F,LCDCPCTL1       ; Enabling Segments 16-21 and 26-31
            mov.w   #0x0FFF,LCDCPCTL2       ; Enabling 32-43
            mov.w   #0x8000,LCDCCPCTL       ; Enabling Charge Pump Synchronisation
            mov.w   #0x0002,LCDCMEMCTL      ; MEMORY RESET
            mov.w   #0x0CA6,LCDCCTL0        ; LCD OFF
            mov.w   #0x0CA7,LCDCCTL0        ; LCD ON

            mov.w   #00000001b,R7           ; Initialize selected segment variable
            mov.w   #LCDM1,R8               ; Save pointer to first display area for later use
            mov.b   R7,0(R8)                ; activate selected segment (no actual segment in this case)
            mov.b   #00000001b,R9           ; Initialize "Button was just pressed" flag

            mov.w   #CCIE,&TA0CCTL0         ; CCR0 Interrupt enabled
            mov.w   #00FFFFh,&TA0CCR0       ; Timer_A Capture Compare
            mov.w   #(TASSEL_2 | MC_1 | ID_3 | TAIE),&TA0CTL
                                            ; TASSEL:   Timer_A Source SELect
                                            ; TASSEL_2: SMCLK (1MHz)
                                            ; MC_0:     halt
                                            ; MC_1:     up_mode
                                            ; MC_2:     coninuous_mode
                                            ; MC_3:     up-down_mode
                                            ; ID_2:     Vorteiler (Input Divider) = 1:4 (2=>4,3=>8,etc)
            nop
            bis.w   #GIE,SR

Mainloop    nop
            jmp     Mainloop

BtnPress    mov.b   #00000010b,R4           ; Initializing with magic number that says "Button 1 (left)"
            and.b   &P1IN,R4                ; Compares the Buttons pressed with initialized magic number
            jnz     Btn1Press               ; check if the left Button is currently being pressed (if not jump)
            bis.b   #00000001b,&P1OUT       ; else branch: turn on light
            bic.b   #00000010b,&P1IES       ; Sets the Button Interrupt Handler to react to the Button being released
Btn1Cont    mov.b   #00000100b,R4           ; Initializing with magic number that says "Button 2 (right)"
            and.b   &P1IN,R4                ; Compares the Buttons pressed with initialized magic number
            jnz     Btn2Press               ; check if the right Button is currently being pressed (if not jump)
            bis.b   #10000000b,&P9OUT       ; else branch: turn on light
            bic.b   #00000100b,&P1IES       ; Sets the Button Interrupt Handler to react to the Button being released
Btn2Cont    bic.b   #00000110b,&P1IFG       ; Resets the "Interrupt Happening" Flag
            mov.w   #(TASSEL_2 | MC_1 | ID_3 | TAIE),&TA0CTL ; Starts the timer to reset the "Button was just pressed" flag
            reti

Btn1Press   bic.b   #00000001b,&P1OUT       ; Turns off the red (left) light
            bis.b   #00000010b,&P1IES       ; Sets the Button Interrupt Handler to react to the Button being pressed
            tst.b   R9                      ; Loads the "Button was just pressed" flag
            jnz     Btn1Cont                ; Checks if the Button was just pressed
            mov.b   #00000000b,0(R8)        ; Clear current display part
            add.w   #0x0001,R8              ; Increment current display segment pointer
            mov.b   R7,0(R8)                ; Display selected segment on current display part
            mov.b   #00000001b,R9           ; Set "Button was just pressed" flag
            jmp     Btn1Cont

Btn2Press   bic.b   #10000000b,&P9OUT       ; Turns off the green (right) light
            bis.b   #00000100b,&P1IES       ; Sets the Button Interrupt Handler to react to the Button being pressed
            tst.b   R9                      ; Loads the "Button was just pressed" flag
            jnz     Btn2Cont                ; Checks if the Button was just pressed
            rla.b   R7                      ; Change selected segment to activate
            jz      ResSegment              ; If segment counter is out of bounds reset it
RSCont      mov.b   R7,0(R8)                ; Update display according to changed Selection above
            mov.b   #00000001b,R9           ; Set "Button was just pressed" flag
            jmp     Btn2Cont

ResSegment  mov.w  #00000001b,R7            ; Reset selected Segment
            jmp     RSCont

;Unused, old
Interrupt1  bis.b   #00000001b,&P1OUT
            bic.b   #10000000b,&P9OUT
            bic.w   #TAIFG,&TA0CTL
            reti

;Unused, old
Interrupt2  bic.b   #00000001b,&P1OUT
            bis.b   #10000000b,&P9OUT
            bic.w   #TAIFG,&TA0CTL
            reti

TimerDone   mov.b   #00000000b,R9           ; Resets the "Button was just pressed" flag
            mov.w   #MC_0,&TA0CTL           ; Stops the Timer
            reti

Nothing     nop
            reti
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET

            .sect   ".int37"
            .short  BtnPress

            .sect   ".int44"
            .short  TimerDone

            .sect   ".int43"
            .short  TimerDone
;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
