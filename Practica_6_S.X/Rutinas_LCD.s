;******************************************************************************
; DESCRIPCIÓN: RUTINAS RETARDOS: 1s, 15ms
; DISPOSITIVO: DSPIC30F3013
;******************************************************************************
        .include "p30F3013.inc"
;******************************************************************************
; DECLARACIONES GLOBALES
;******************************************************************************
        .global _iniciarLCD4bits
        .global _comandoLCD4bits
        .global _datoLCD4bits
        .global _disponibleLCD
        .global _imprimirLCD
        .global _clearLCD
;******************************************************************************
; SECCIÓN DE DECLARACIÓN DE CONSTANTES CON LA DIRECTIVA .EQU
;******************************************************************************
        .equ RS_LCD,    RF2
        .equ RW_LCD,    RF3
        .equ E_LCD,     RF4
        .equ BF_LCD,    RB7

        .equ PORT_DATA,     PORTB
        .equ PORT_RS_LCD,   PORTF
        .equ PORT_RW_LCD,   PORTF
        .equ PORT_E_LCD,    PORTF

;******************************************************************************
;DESCRICION:	ESTA RUTINA INICIALIZA EL LCD EN MODO DE 4 BITS
;PARAMETROS: 	(W1) 0 : NADA, 1: BLINK, 2: CURSOR
;RETORNO: 		NINGUNO
;******************************************************************************
_iniciarLCD4bits:
    CALL    _retardo15ms
	MOV     #0X33,      W0
	CALL    _comandoLCD4bits

	CALL    _retardo15ms
	MOV     #0X33,      W0
	CALL    _comandoLCD4bits

	CALL    _retardo15ms
	MOV     #0X33,      W0
	CALL    _comandoLCD4bits

	CALL    _disponibleLCD
	MOV     #0X22,      W0
	CALL    _comandoLCD4bits

	CALL    _disponibleLCD
	MOV     #0X28,      W0
	CALL    _comandoLCD4bits

	CALL    _disponibleLCD
	MOV     #0X08,      W0
	CALL    _comandoLCD4bits

	CALL    _disponibleLCD
	MOV     #0X01,      W0
	CALL    _comandoLCD4bits

	CALL    _disponibleLCD
	MOV     #0X06,      W0
	CALL    _comandoLCD4bits

	CALL    _disponibleLCD
	MOV     #0X0C, W0
    ADD     W0, W1, W0
	CALL    _comandoLCD4bits

RETURN
;******************************************************************************
;DESCRICION:	ESTA RUTINA MANDA COMANDOS AL LCD
;PARAMETROS: 	W0, COMANDO
;RETORNO: 		NINGUNO
;******************************************************************************
_comandoLCD4bits:
    PUSH.D    W0
    BCLR    PORT_RS_LCD, #RS_LCD    ;RS = 0 BCLR PORTF, #RF2
    NOP

    ESCRITURA_LCD:
    BCLR    PORT_RW_LCD, #RW_LCD    ;RW = 0
    NOP

    BSET    PORT_E_LCD, #E_LCD      ;E = 1
    NOP

    MOV     W0, W1
    MOV     #0XFF0F, W0
    AND     PORT_DATA           ;PORTB = PORTB & 0XFF0F
    NOP

    MOV     #0X00F0, W0
    AND     W0, W1, W0
    IOR     PORT_DATA           ;PORTB = PORTB | W0
    NOP

    BCLR	PORT_E_LCD,     #E_LCD 	 ;E = 0
    NOP

    NOP
    BSET    PORT_E_LCD,     #E_LCD   ;E = 1
    NOP

    MOV     #0XFF0F, W0
    AND     PORT_DATA                ;PORTB = PORTB & 0XFF0F
    NOP

    MOV     #0X000F, W0
    AND		W0,	W1, W0
    SL		W0, #4, W0

    IOR     PORT_DATA                ;PORTB = PORTB | W0
    NOP
    
    BCLR	PORT_E_LCD, #E_LCD       ;E = 0
    NOP

    POP.D     W0

RETURN
;******************************************************************************
;DESCRICION:	ESTA RUTINA MANDA DATOS AL LCD
;PARAMETROS: 	W0, DATO
;RETORNO: 		NINGUNO
;******************************************************************************
_datoLCD4bits:
    PUSH.D    W0

    BSET    PORT_RS_LCD, #RS_LCD    ;RS = 1   BSET PORTF, #RF2
    NOP

    GOTO    ESCRITURA_LCD
;******************************************************************************
;DESCRICION:	ESTA RUTINA VERIFICA LA BANDERA BF DEL LCD
;PARAMETROS: 	NINGUNO
;RETORNO: 		NINGUNO
;******************************************************************************
_disponibleLCD:
    PUSH.D  W0

    BCLR    PORT_RS_LCD, #RS_LCD  ;RS = 0
    NOP

    MOV		#0X00F0, W0
    IOR 	TRISB                   ;TRISB = TRISB & Wo
    NOP

    BSET    PORT_RW_LCD, #RW_LCD    ;RW = 1
    NOP

    BSET    PORT_E_LCD, #E_LCD      ;E = 1
    NOP

    ESPERAR_LCD:
    BTSC    PORT_DATA,      #BF_LCD ;IF( RB7 == 0 )[...] ELSE GOTO ESPERAR
    GOTO    ESPERAR_LCD

    BCLR	PORT_E_LCD, #E_LCD      ;E  = 0
    NOP

    BCLR    PORT_RW_LCD, #RW_LCD    ;RW = 0
    NOP

    MOV		#0XFF0F,    W0
    AND 	TRISB                   ;TRISB = TRISB & Wo
    NOP

    POP.D   W0
RETURN
;******************************************************************************
;DESCRICION:	ESTA RUTINA IMPRIME MENSAJE EN EL LCD
;PARAMETROS: 	W0 - APUNTADOR A LA CADENA
;RETORNO: 		NINGUNO
;******************************************************************************
_imprimirLCD:
    PUSH.D  W0
    MOV     W0, W1
    CLR     W0
    IMP_C:
    TBLRDL.B    [W1++], W0
    CP0     W0
    BRA     Z, FIN_IMP_LCD

    RCALL   _disponibleLCD
    RCALL   _datoLCD4bits

    GOTO    IMP_C

    FIN_IMP_LCD:
    POP.D   W0

RETURN
;******************************************************************************
;DESCRICION:	LIMPIA LCD
;PARAMETROS: 	NINGUNO
;RETORNO: 		NINGUNO
;******************************************************************************
_clearLCD:
    PUSH.D  W0
    MOV     #0x0001, W1

	CALL    _disponibleLCD
	MOV     #0X01,      W0
	CALL    _comandoLCD4bits

    POP.D   W0
RETURN
