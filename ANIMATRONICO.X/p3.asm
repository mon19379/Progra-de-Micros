; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
  #include "p16f887.inc"

; CONFIG1
; __config 0xE0D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
;*******************************************************************************
;VARIABLES
;*******************************************************************************    
PR_VAR        UDATA
SERV	      RES 1
SERV1	      RES 1
SERV2	      RES 1
SERV3	      RES 1
FLAGS	      RES 1
W_TEMP	      RES 1 
STATUS_TEMP   RES 1
BOCA_1	      RES 1
BOCA_2	      RES 1
SWITCH	      RES 1
CAMBIORX    RES	  1
	      
	      
	
	
;******************************************************************************
; INICIO
;******************************************************************************
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
;*******************************************************************************
; TODO ADD INTERRUPTS HERE IF USED
;*******************************************************************************
    ISR_VECT    CODE    0x0004
    
PUSH:
    BCF     INTCON,  GIE
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP  ;MANDO AL STACK
    
    
ISR:
    BTFSC   PIR1, ADIF
    CALL    RUT_ADC
;   BTFSC   INTCON, T0IF                  
;   CALL    RUT_TMR0 
    BTFSC   PIR1, TMR1IF    ;SE REVISA LA BANDERA DE INTERRUPCION
    CALL    RUT_TMR1	    ; SI NO ESTA EN CERO LLAMA LA RUTINA
    BTFSC   PIR1, RCIF
    CALL    RUT_RECIEVE
   
    
  
    
   
POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    BSF     INTCON, GIE ;SACO INFO DEL STACK
    RETFIE



;******************************************************************************
; SUBRUTINAS INT
;******************************************************************************
  RUT_TMR1: 
    
	MOVLW   .248	    
	MOVWF   TMR1H
	MOVLW   .47	    
	MOVWF   TMR1L           
	BCF	PIR1, TMR1IF    ;SE REINICIAN LAS CONDICIONES INICIALES DEL TIMER
	
	
	MAPEO:
	 RRF     SERV1, W
	 ANDLW   b'01111111'
	 ADDLW   .32
	 MOVWF   CCPR1L
	 RRF     SERV2, W
	 ANDLW   b'01111111'
	 ADDLW   .32
	 MOVWF   CCPR2L
	 
	 RETURN
  RUT_ADC:
	BTFSC   FLAGS, 0
	GOTO    SERVO2
	
    SERVO1:
	BSF     ADCON0, 2
	MOVFW	ADRESH 
	MOVWF   SERV1
	BCF     PIR1, ADIF
	BSF	ADCON0, 1
	BSF     FLAGS, 0
     RETURN
    
    SERVO2:
	BCF     ADCON0, 2
	MOVFW	ADRESH 
	MOVWF   SERV2
	BCF     PIR1, ADIF
	BSF	ADCON0, 1
	BCF     FLAGS, 0
     RETURN
  
     RUT_RECIEVE:
	MOVFW   RCREG
	SUBLW	.48	
	MOVWF   PORTB
	RETURN 
 ;******************************************************************************
;PRINCIPAL
;*******************************************************************************
MAIN_PROG CODE      0x0100             ; let linker place main program
START
 
 CALL CONFIG_IO
 CALL CONFIG_ADC
 CALL CONFIG_TMR2
 CALL CONFIG_TMR1
 CALL CONFIG_INT
 CALL CONFIG_CCP1
 CALL CONFIG_CCP2
 CALL CONFIG_TMR0
 CALL CONFIG_RX
 CALL  CONFIG_TX
 
 LOOP:
    GOTO LOOP



    
    
    
  
  
;*******************************************************************************
; CONFIGURACIONES
;*******************************************************************************
 CONFIG_IO:
    BSF	    STATUS, 5 
    BCF	    STATUS, 6 ; BANCO 1 
   
   
    BSF     TRISA, 0 
    BSF     TRISA, 1
    CLRF    TRISB ;TODOS LOS BITS DEL PUERTO C Y D EN 0, SALIDAS
    CLRF    TRISC
    CLRF    TRISD
    
    BSF	    STATUS, 5
    BSF	    STATUS, 6 ;BANCO 3
  
    BSF     ANSEL, 0
    BSF     ANSEL, 1
    CLRF    ANSELH ;ENTRADAS DIGITALES
    
    BCF	    STATUS, 5
    BCF	    STATUS, 6; BANCO 0
    
  
    CLRF    PORTB
    CLRF    PORTC ;SE PONENN EN CERO TODOS LOS BITS DEL PUERTO B Y C
    CLRF    PORTD
    RETURN
    
    
CONFIG_ADC:
    
    BSF	    STATUS, 5
    BCF	    STATUS, 6 ;BANCO 1
    CLRF    ADCON1
    BSF     PIE1, ADIE
    
    BCF	    STATUS, 5
    BCF	    STATUS, 6; BANCO 0
    MOVLW   b'01000011'
    MOVWF   ADCON0
    BSF     PIR1, ADIF
    RETURN
    
CONFIG_TMR0:
    BSF	    STATUS, 5
    BCF	    STATUS, 6 ;BANCO 1
    
    
    MOVLW   b'11010111'  ;SE APAGAN LAS PULLUPS Y SE LE PONE PRESCALER DE 1:256
    MOVWF   OPTION_REG   
   
    BCF     STATUS, 5 
    BCF     STATUS, 6
    BCF INTCON, T0IF    ;CONFIGURACIÓN DEL OVERFLOW INTERUPT FLAG
    
    RETURN
    
    
CONFIG_TMR1:
    BCF	    STATUS, 5
    BCF	    STATUS, 6; BANCO 0
   
    BCF	    T1CON, T1CKPS1
    BCF	    T1CON, T1CKPS0  ;PRESCALER DE 1:8
    BSF	    T1CON, TMR1ON  ;TIMER 1 ENCENDIDO
    BSF	    STATUS, 5
    BCF	    STATUS, 6 ;BANCO 1
    BSF     PIR1, TMR1IE
    BCF	    PIR1, TMR1IF   ;SE APAGA LA BANDERA DE INTERRUPCION
    
    RETURN
    
    
CONFIG_TMR2:
    BCF	    STATUS, 5
    BCF	    STATUS, 6; BANCO 0
   
    MOVLW   B'11111111'
    MOVWF   T2CON
    BSF	    STATUS, 5 
    BCF	    STATUS, 6 ; BANCO 1 
    
    MOVLW   .187    
    MOVWF   PR2
    RETURN
    
CONFIG_CCP1:
    BANKSEL CCP1CON
    BCF	    CCP1CON, 7
    BCF	    CCP1CON, 6		
    BCF	    CCP1CON, 5		
    BCF	    CCP1CON, 4		
    BSF	    CCP1CON, 3
    BSF	    CCP1CON, 2
    BCF	    CCP1CON, 1
    BCF	    CCP1CON, 0
    
CONFIG_CCP2:
    BANKSEL CCP2CON
    BCF	    CCP2CON, 5		
    BCF	    CCP2CON, 4		
    BSF	    CCP2CON, 3
    BSF	    CCP2CON, 2
    BSF	    CCP2CON, 1
    BSF	    CCP2CON, 0
RETURN     
    
CONFIG_INT:
    BCF	    STATUS, 5
    BCF	    STATUS, 6; BANCO 0
    BSF	    INTCON, GIE
    BSF     INTCON, PEIE
    BSF     INTCON, T0IE
    BSF	    STATUS, 5 
    BCF	    STATUS, 6 ; BANCO 1 
    BSF	    PIE1, RCIE		

    
    RETURN
   
 CONFIG_TX:
    BANKSEL TRISA
    BCF	    TXSTA, TX9    
    BCF	    TXSTA, SYNC	    
    BSF	    TXSTA, BRGH	    

    BANKSEL ANSEL
    BCF	    BAUDCTL, BRG16  
    
    BANKSEL TRISA
    MOVLW   .25
    MOVWF   SPBRG	    
    CLRF    SPBRGH	    
    BSF	    TXSTA, TXEN    
    BANKSEL PORTA
RETURN
    
CONFIG_RX:
    BANKSEL PORTA
    BSF	    RCSTA, SPEN
    BCF	    RCSTA, RX9
    BSF	    RCSTA, CREN
RETURN
    
    

    
    END