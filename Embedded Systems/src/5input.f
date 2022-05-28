HEX

\ FILE CHE GESTISCE L'INPUT QUINDI IL JOYSTICK PER IL MOVIMENTO

\ WORD CHE ABILITA IL FALLING EDGE DETECTOR PER QUEL PARTICOLARE PIN 
\ PIN FENPIN 
: FENPIN SELPIN GPFEN0 @ OR GPFEN0 ! ;

\ WORD CHE PULISCE GPEDS0 - NELLA DOC VIENE INDICATO DI METTERE 1, METTO -1 COSI E' COME SE METTESSI UNO A TUTTI I BIT
: RESETEVENTS -1 GPEDS0 ! ;

\ WORD CHE ABILITA I PIN SCELTI PER IL JOYSTICK
: ENABLEPININPUT MID FENPIN UP FENPIN DOWN FENPIN LEFT FENPIN RIGHT FENPIN ;

\ IL RISULTATO PER OGNUNA DELLE WORD SARA' 0 SE IL TASTO NON E' PRESSATO ALTRIMENTI UN VALORE MAGGIORE DI 0
: MIDBIT   GPEDS0 @ MID SELPIN AND ;	
: UPBIT    GPEDS0 @ UP SELPIN AND ; 	     
: DOWNBIT  GPEDS0 @ DOWN SELPIN AND ;
: LEFTBIT  GPEDS0 @ LEFT SELPIN AND ;
: RIGHTBIT GPEDS0 @ RIGHT SELPIN AND ;

\ OFFSET DI SPOSTAMENTO POINTER
VARIABLE MOV
100 MOV !

\ WORD PER MANTENERE IL PUNTATORE NELLA GRIGLIA
: MOVUP    POINTERY @ 80 =  IF POINTERY @ 100 + POINTERY ! ELSE POINTERY @ 80 - POINTERY ! THEN ; 
: MOVDOWN  POINTERY @ 180 = IF POINTERY @ 100 - POINTERY ! ELSE POINTERY @ 80 + POINTERY ! THEN ;
: MOVLEFT  POINTERX @ 80 =  IF POINTERX @ 100 + POINTERX ! ELSE POINTERX @ 80 - POINTERX ! THEN ;
: MOVRIGHT POINTERX @ 180 = IF POINTERX @ 100 - POINTERX ! ELSE POINTERX @ 80 + POINTERX ! THEN ;

\ MOVIMENTO IN UNA DIREZIONE SIGNFICA CANCELLARE IL PUNTATORE CORRENTE E RIDISEGNARLO IN UNA DELLE DIREZIONI
: UPPOINTER    CLEAR MOVUP DRAWPOINTER ;
: DOWNPOINTER  CLEAR MOVDOWN DRAWPOINTER ;
: LEFTPOINTER  CLEAR MOVLEFT DRAWPOINTER ;
: RIGHTPOINTER CLEAR MOVRIGHT DRAWPOINTER ;

\ VERIFICO IN QUALE DIREZIONE L'INPUT CHIEDE IL MOVIMENTO
: UPMOVE   UPBIT     0 > IF RESETEVENTS UPPOINTER THEN ;
: DOWNMOVE DOWNBIT   0 > IF RESETEVENTS DOWNPOINTER THEN ;
: LEFTMOVE LEFTBIT   0 > IF RESETEVENTS LEFTPOINTER THEN ;
: RIGHTMOVE RIGHTBIT 0 > IF RESETEVENTS RIGHTPOINTER THEN ;



































