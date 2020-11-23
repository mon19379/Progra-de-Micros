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

NH	      RES 1
NL	      RES 1
NH1	      RES 1
NL1	      RES 1
FLAG	      RES 1
FLAGADC	      RES 1
W_TEMP	      RES 1
STATUS_TEMP   RES 1
INFO	      RES 1	
INFO2	      RES 1
INFOX	      RES 1
INFOY	      RES 1
CENTX	      RES 1
DECEX	      RES 1
UNX	      RES 1
CENTY	      RES 1
DECEY	      RES 1
UNY	      RES 1
INDICADOR     RES 1
RECX	      RES 1
RECY	      RES 1
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
    BTFSC   INTCON, T0IF
    CALL    RUT_TMR0
    BTFSC   PIR1, TMR2IF
    CALL    RUT_SEND
    BTFSC   PIR1, RCIF
    CALL    RUT_RECIEVE
    BTFSC   PIR1, ADIF
    CALL    RUT_ADC
  
    
   
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
    RUT_TMR0:
	MOVLW	.248
	MOVWF	TMR0
	BCF	INTCON, T0IF
	CALL    DISPLAYS
	CALL    SPLITX
	CALL    SPLITY
    RETURN 
    
    RUT_ADC:
	BTFSC	 FLAGADC, 0
	GOTO	 VAL_Y
	
    VAL_X:
	BANKSEL ADCON0
	BSF     ADCON0, CHS0
	BCF     ADCON0, CHS1
	MOVFW	ADRESH 
	MOVWF   INFOX
	BCF     PIR1, ADIF
	BSF	ADCON0, 1
	BSF     FLAGADC, 0
     RETURN
    
    VAL_Y:
	BANKSEL ADCON0
	BCF     ADCON0, CHS1
	BCF     ADCON0, CHS0
	MOVFW	ADRESH 
	MOVWF   INFOY
	BCF     PIR1, ADIF
	BSF	ADCON0, 1
	BCF     FLAGADC, 0
     RETURN
	
    
    RUT_SEND:
	BCF     PIR1,TMR2IF
	BTFSC   PIR1, TXIF
	CALL    TX
	RETURN

    RUT_RECIEVE:
	MOVLW   .1
	SUBWF   INFO2, W
	BTFSC   STATUS, Z
	GOTO    RECIBIRY
    RECIBIRX: 
	MOVFW   RCREG
	MOVWF   RECX
	INCF    INFO2 
	RETURN 
    RECIBIRY:
	MOVFW   RCREG
	MOVWF   RECY
	CLRF    INFO2
	RETURN
    
    
    TABLA:    ;TABLA PARA LOS VALORES DE LOS DISPLAY DE 7 SEGMENTOS
    ANDLW   B'00001111'
    ADDWF   PCL, F
    RETLW   b'10001000' ; 0
    RETLW   b'11101011'	; 1
    RETLW   b'01001100'	; 2
    RETLW   b'01001001'	; 3
    RETLW   b'00101011'	; 4
    RETLW   b'00011001'	; 5
    RETLW   b'00011000'	; 6
    RETLW   b'11001011'	; 7
    RETLW   b'00001000' ; 8
    RETLW   b'00001011' ; 9
    RETLW   b'00000010' ; A
    RETLW   b'00110000' ; b
    RETLW   b'10010100' ; C
    RETLW   b'01100000' ; d
    RETLW   b'00010100' ; E
    RETLW   b'00010110' ; F

    
;******************************************************************************
;PRINCIPAL
;*******************************************************************************
MAIN_PROG CODE      0x0100             ; let linker place main program
START
 
    CALL    CONFIG_IO
    CALL    CONFIG_ADC
    CALL    CONFIG_TMR0
    CALL    CONFIG_TMR2
    CALL    CONFIG_TX
    CALL    CONFIG_RX
    CALL    CONFIG_INT
    CALL    CONFIG_VAR

LOOP:
    GOTO LOOP	    
TX:
    MOVLW   .3
    SUBWF   INDICADOR, W
    BTFSC   STATUS, Z
    GOTO    ESP
    MOVLW   .2
    SUBWF   INDICADOR, W
    BTFSC   STATUS, Z
    GOTO    CY
    MOVLW   .1
    SUBWF   INDICADOR, W
    BTFSC   STATUS, Z
    GOTO    COMA
CX: 
    MOVFW   INFOX
    MOVWF   TXREG
    INCF    INDICADOR 
    RETURN 
COMA:
    MOVLW   .44
    MOVWF   TXREG
    INCF    INDICADOR
    RETURN
CY:
    MOVFW   INFOY
    MOVWF   TXREG
    INCF    INDICADOR
    RETURN
ESP:
    MOVLW   .10
    MOVWF   TXREG
    CLRF    INDICADOR 
    RETURN

;*******************************************************************************
; DISPLAY
;*******************************************************************************
    
    
SPLITX:
    
    MOVFW RECX
    MOVWF NH
    SWAPF RECX, W
    MOVWF NL
    RETURN   
    
SPLITY:
    MOVFW RECY
    MOVWF NH1
    SWAPF RECY, W
    MOVWF NL1
    RETURN
    
DISPLAYS:
   BCF   PORTB, RB7
   BCF   PORTB, RB6
   BCF   PORTB, RB5
   BCF   PORTB, RB4
   BTFSC FLAG, 0
   GOTO	 DISPLAYY
 
DISPLAYX:
    BTFSC FLAG, 1
    GOTO DISPLAYX2
    
DISPLAYX1:
   MOVFW NL
   CALL TABLA
   MOVWF PORTD
   BSF  PORTB, RB7
   BSF	FLAG, 1;TOGGLE CON ESTEROIDES
   RETURN
   
 
DISPLAYX2:
   MOVFW NH
   CALL TABLA
   MOVWF PORTD
   BSF  PORTB, RB6
   BSF	FLAG, 0 ;TOGGLE
   BCF  FLAG, 1
   RETURN
  
DISPLAYY:
    BTFSC FLAG, 1
    GOTO DISPLAYY2
DISPLAYY1:
   MOVFW NH1
   CALL TABLA
   MOVWF PORTD
   BSF  PORTB, RB5
   BSF	FLAG, 1;TOGGLE CON ESTEROIDES
   RETURN
   
 
DISPLAYY2:
   MOVFW NL1
   CALL TABLA
   MOVWF PORTD
   BSF  PORTB, RB4
   BCF	FLAG, 0 ;TOGGLE
   BCF  FLAG, 1
   RETURN
   
  
    

   
;*******************************************************************************
; CONFIGURACIONES
;*******************************************************************************
 
CONFIG_IO:
    BSF	    STATUS, 5 
    BCF	    STATUS, 6 ; BANCO 1 
   
   
    BSF	    TRISA, 0
    BSF     TRISA, 1
    CLRF    TRISB ;TODOS LOS BITS DEL PUERTO C Y D EN 0, SALIDAS
    CLRF    TRISC
    CLRF    TRISD
    
    BSF	    STATUS, 5
    BSF	    STATUS, 6 ;BANCO 3
    
    BSF	    ANSEL, 0 ;BIT 0 ENTRADA ANALÓGICA, LAS DEMAS DIGITALES
    BSF     ANSEL, 1
    CLRF    ANSELH ;ENTRADAS DIGITALES
    
    BCF	    STATUS, 5
    BCF	    STATUS, 6; BANCO 0
    
    CLRF   PORTC
    CLRF   PORTB
    CLRF   PORTD
    CLRF   PORTA
    RETURN

CONFIG_TMR0:
    BSF	    STATUS, 5
    BCF	    STATUS, 6 ;BANCO 1
    
    MOVLW   b'10000000'  ;SE APAGAN LAS PULLUPS Y SE LE PONE PRESCALER DE 1:256
    MOVWF   OPTION_REG   
    
  
    RETURN
    
    
CONFIG_ADC:
    BSF	    STATUS, 5
    BCF	    STATUS, 6 ;BANCO 1
    CLRF    ADCON1
    BCF	    STATUS, 5
    BCF	    STATUS, 6; BANCO 0
    MOVLW   b'01000011'
    MOVWF   ADCON0
    BSF     PIE1, ADIE
    BSF     PIR1, ADIF
    RETURN

CONFIG_TX:
    BSF	    STATUS, 5
    BCF	    STATUS, 6 ;BANCO 1
    
    ;BSF     PIE1, TXIE
    BCF     TXSTA, SYNC
    BSF     TXSTA, BRGH
    BSF     TXSTA, TXEN
    
    BANKSEL  BAUDCTL
    BCF	     BAUDCTL, BRG16
    
    BANKSEL  SPBRG
    MOVLW    .25
    MOVWF    SPBRG
    CLRF     SPBRGH  ;BAUD
    RETURN
    
CONFIG_TMR2:
    BCF	    STATUS, 5
    BCF	    STATUS, 6; BANCO 0
   
    MOVLW   B'11111111'
    MOVWF   T2CON
    BSF	    STATUS, 5 
    BCF	    STATUS, 6 ; BANCO 1 
    BSF     PIE1, TMR2IE
    MOVLW   .20    ;250ms
    MOVWF   PR2
    RETURN
    
CONFIG_RX:
    BCF	    STATUS, 5
    BCF	    STATUS, 6; BANCO 0
    
    BSF     RCSTA, SPEN
    BCF     RCSTA, RX9
    BSF     RCSTA, CREN
    BANKSEL PIE1
    BSF	    PIE1, RCIE
    RETURN
    
    
CONFIG_INT:
    BCF	    STATUS, 5
    BCF	    STATUS, 6; BANCO 0
    BSF	    INTCON, GIE
    BSF     INTCON, PEIE
    BSF	    INTCON, T0IE
    BCF     PIR1, TMR2IF
    RETURN

CONFIG_VAR:
    CLRF    NH	     
    CLRF    NL	    
    CLRF    NH1	     
    CLRF    NL1	      
    CLRF    FLAG	     
    CLRF    FLAGADC	      
    CLRF    W_TEMP	     
    CLRF    STATUS_TEMP   
    CLRF    INFO	 	
    CLRF    INFO2	      
    CLRF    INFOX	    
    CLRF    INFOY	      
    CLRF    CENTX	      
    CLRF    DECEX	      
    CLRF    UNX
    CLRF    CENTY
    CLRF    DECEY
    CLRF    UNY
    CLRF    INDICADOR
    CLRF    RECY
    CLRF    RECX
    BANKSEL PORTA
RETURN
    END
    
