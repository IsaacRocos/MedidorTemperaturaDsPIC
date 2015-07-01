;******************************************************************************
; DESCRIPCIÓN: ESTE ARCHIVO CONTIENE ISR (INTERRUPT SERVICE ROUTINE)
; DISPOSITIVO: DSPIC30F3013
;******************************************************************************
    .equ __30F3013, 1
    .include "p30F3013.inc"
;******************************************************************************
; DECLARACIONES GLOBALES
;******************************************************************************
    .global _activarT3
    .global __ADCInterrupt
    .global __AD1Interrupt
    .global __ADC1Interrupt
    .global __ADC2Interrupt
    .global __T3Interrupt

;******************************************************************************
;DESCRICION:	ESTA RUTINA INICIALIZA INTERRUPCION T3 (TIMER 3)
;PARAMETROS: 	NINGUNO
;RETORNO: 		NINGUNO
;******************************************************************************
_activarT3:
    BCLR    IFS0, #T3IF
    BSET    IEC0, #T3IE
RETURN

;******************************************************************************
;DESCRICION:	ISR T3 (TIMER 3)
;******************************************************************************
__T3Interrupt:
    ;BTG    LATD, #RD8
    BTG     LATD, #LATD8
    NOP
    BCLR   IFS0, #T3IF
RETFIE
;******************************************************************************
;DESCRICION:	ISR ADC
;******************************************************************************
__ADCInterrupt:
    BCLR    IFS0, #ADIF
    NOP
RETFIE
;******************************************************************************
;DESCRICION:	ISR ADC
;******************************************************************************
__AD1Interrupt:
    BCLR    IFS0, #ADIF
    NOP
RETFIE
;******************************************************************************
;DESCRICION:	ISR ADC
;******************************************************************************
__ADC1Interrupt:
    BCLR    IFS0, #ADIF
    NOP
RETFIE

;******************************************************************************
;DESCRICION:	ISR ADC
;******************************************************************************
__ADC2Interrupt:
    BCLR    IFS0, #ADIF
    NOP
RETFIE




INTERRUPCION_ADC:
    MOV     ADCBUF0,    W0
    MOV     W0,         W2  ; BIN_to_BCD usa W2 como dividendo
    AND     #0X003F
    MOV     W0,         W1
    LSR     #6
    MOV     W0,         W3
    BSET    W3,#7
    MOV     W1,         U1TXREG
    NOP
    MOV     W3,         U1TXREG
    ;CALL   _BIN_TO_BCD
    MOV     ADCBUF1,           W0
    MOV     W0,         W2  ; BIN_to_BCD usa W2 como dividendo
    ;CALL   _BIN_TO_BCD
   
    BCLR    IFS0, #ADIF
    NOP
RETFIE
