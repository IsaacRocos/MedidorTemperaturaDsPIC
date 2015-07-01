;******************************************************************************
; DESCRIPCIÓN: Sensor de temperatura, potenciometro - muestra LCD -envio UART
; DISPOSITIVO: DSPIC30F3013
;******************************************************************************
    .equ __30F3013, 1
    .include "p30F3013.inc"
;******************************************************************************
; BITS DE CONFIGURACIÓN
;******************************************************************************
;..............................................................................
;SE DESACTIVA EL CLOCK SWITCHING Y EL FAIL-SAFE CLOCK MONITOR (FSCM) Y SE
;ACTIVA EL OSCILADOR INTERNO (FAST RC) PARA TRABAJAR
;FSCM: PERMITE AL DISPOSITIVO CONTINUAR OPERANDO AUN CUANDO OCURRA UNA FALLA
;EN EL OSCILADOR. CUANDO OCURRE UNA FALLA EN EL OSCILADOR SE GENERA UNA TRAMPA
;Y SE CAMBIA EL RELOJ AL OSCILADOR FRC
;..............................................................................
    config __FOSC, CSW_FSCM_OFF & FRC
;..............................................................................
;SE DESACTIVA EL WATCHDOG
;..............................................................................
    config __FWDT, WDT_OFF
;..............................................................................
;SE ACTIVA EL POWER ON RESET (POR), BROWN OUT RESET (BOR), POWER UP TIMER (PWRT)
;Y EL MASTER CLEAR (MCLR)
;POR: AL MOMENTO DE ALIMENTAR EL DSPIC OCURRE UN RESET CUANDO EL VOLTAJE DE
;ALIMENTACIÓN ALCANZA UN VOLTAJE DE UMBRAL (VPOR), EL CUAL ES 1.85V
;BOR: ESTE MODULO GENERA UN RESET CUANDO EL VOLTAJE DE ALIMENTACIÓN DECAE
;POR DEBAJO DE UN CIERTO UMBRAL ESTABLECIDO (2.7V)
;PWRT: MANTIENE AL DSPIC EN RESET POR UN CIERTO TIEMPO ESTABLECIDO, ESTO AYUDA
;A ASEGURAR QUE EL VOLTAJE DE ALIMENTACIÓN SE HA ESTABILIZADO (16ms)
;..............................................................................
    config __FBORPOR, PBOR_ON & BORV27 & PWRT_16 & MCLR_EN
;..............................................................................
;SE DESACTIVA EL CÓDIGO DE PROTECCIÓN
;..............................................................................
    config __FGS, CODE_PROT_OFF & GWRP_OFF
;******************************************************************************
; DECLARACIONES GLOBALES
;******************************************************************************
;..............................................................................
;ETIQUETA DE LA PRIMER LINEA DE CÓDIGO
;..............................................................................
    .global __reset
;******************************************************************************
;VARIABLES NO INICIALIZADAS EN EL ESPACIO X DE LA MEMORIA DE DATOS
;******************************************************************************
    .section .xbss, bss, xmemory
        temperatura:    .space 2*4
        potenciometro:  .space 2*4
;******************************************************************************
;CONSTANTES ALMACENADAS EN EL ESPACIO DE LA MEMORIA DE PROGRAMA
;******************************************************************************
    .section .myconstbuffer, code
    .palign 2
    MSJ_TEMP:
    .BYTE   'T','E','M','P',':',' ',' ','.',' ',0xDF,'C', 0x00
    MSJ_POT:
    .BYTE   'P','O','T',':', 0x00
;******************************************************************************
;SECCION DE CODIGO EN LA MEMORIA DE PROGRAMA
;******************************************************************************
.text
    __reset:
        MOV		#__SP_init, W15
        MOV 	#__SPLIM_init, W0
        MOV 	W0, SPLIM
        MOV     #tblpage(MSJ_TEMP),  W0
        MOV     W0, TBLPAG

        CALL    INI_PERIFERICOS

        CLR     W1
        RCALL   _iniciarLCD4bits

        MOV     #tbloffset(MSJ_TEMP), W0
        RCALL   _imprimirLCD

        RCALL    _disponibleLCD
        MOV     #0XC0, W0
        RCALL    _comandoLCD4bits

        MOV     #tbloffset(MSJ_POT), W0
        RCALL   _imprimirLCD

;---------------------------------
;       Configuracion UART
        MOV     #0x0420, W0
        MOV     W0, U1MODE
        NOP
        MOV     #0x8000, W0
        MOV     W0, U1STA
        NOP
        MOV     #11, W0
        MOV     W0, U1BRG
        NOP
;---------------------------------
;       Configuracion ADC
        MOV     #0x0044, W0
        MOV     W0, ADCON1
        NOP
        MOV     #0x6404, W0
        MOV     W0, ADCON2
        NOP
        MOV     #0x0102, W0
        MOV     W0, ADCON3
        NOP
        MOV     #0x0000, W0
        MOV     W0, ADCHS
        NOP
;---------------------------------
;       Configurar Timer 3 - 10 Hz
        BCLR    PORTD, #RD8
        CLR     TMR3
        NOP
        MOV     #23040, W0
        MOV     W0, PR3
        NOP
        MOV     #0x0010, W0
        MOV     W0, T3CON
        NOP

;---------------------------------
;       Configuracion ADC
        MOV     #0x000C, W0
        MOV     W0, ADCSSL
        NOP
        MOV     #0xFFF0, W0
        MOV     W0, ADPCFG
        NOP

        BCLR    IFS0, #T3IF
        NOP
        BCLR    IFS0, #ADIF
        NOP
        BSET    IEC0, #T3IE
        NOP
        BSET    IEC0, #ADIE
        NOP

;---------------------------------
;        Activar Transmision
        BSET    U1MODE, #UARTEN
        BSET    U1STA,  #UTXEN

        BSET    ADCON1, #ADON
        BSET    T3CON,  #TON

;---------------------------------
;        FIN CONFIG - CICLO INF
        FIN_P6:
        NOP
        CALL    _retardo25ms
        GOTO    FIN_P6



;******************************************************************************
;DESCRICION:	ESTA RUTINA INICIALIZA LOS PERIFERICO
;PARAMETROS: 	NINGUNO
;RETORNO: 		NINGUNO
;******************************************************************************
INI_PERIFERICOS:
    CLR     PORTB
    NOP
    CLR     LATB
    NOP
    MOV     #0x000F, W0
    MOV     W0, TRISB
    NOP

    CLR     PORTF
    NOP
    CLR     LATF
    NOP
    CLR     TRISF
    NOP

    CLR     PORTC
    NOP
    CLR     LATC
    NOP
    BCLR    TRISC, #TRISC13
    NOP
    BSET    TRISC, #TRISC14
    NOP

    CLR     PORTD
    NOP
    CLR     LATD
    NOP
    BCLR    TRISD, #TRISD8
    NOP

RETURN
;******************************************************************************



;        mov     #2648  , W2
;        call    BIN_TO_BCD


BIN_TO_BCD:
    PUSH.S
    MOV     #10, W4
    DIVIDE:
        REPEAT  #17          ; EJECUTA DIV.U 18 VECES
        DIV.U    W2, W4      ; Divide W2 ENTRE W4   ; ALMACENA EL COCIENTE en W0,  reciduo en W1 (VALOR A IMPRIMIR)

        CP0     W0
        BRA     Z, FIN_DIV
        MOV     W0 , W2
        GOTO    DIVIDE

    FIN_DIV:
        RETURN


.END


