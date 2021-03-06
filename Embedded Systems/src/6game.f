HEX

\ FILE PER DEFINIRE IL FUNZIONAMENTO INTERNO DEL GIOCO

\ CREAZIONE SEQUENZA PER IL TESORO
VARIABLE CELLATES1
VARIABLE CELLATES2
VARIABLE CELLATES3

\ 9 RAND VALORE TRA 0 E 8
: VAL1 9 RAND CELLATES1 ! ;
: VAL2 BEGIN 9 RAND CELLATES2 ! CELLATES2 @ CELLATES1 @ <> UNTIL ;
: VAL3 BEGIN 9 RAND CELLATES3 ! CELLATES3 @ CELLATES2 @ <> CELLATES3 @ CELLATES1 @ <> - 0 = UNTIL ;  

\ WORD PER GENERARE TRE VALORI RANDOM SICURAMENTE DIVERSI TRA DI LORO
: BUILDSEQUENCE VAL1 VAL2 VAL3 ;

\ WORD CHE RESTITUISCE LA CELLA IN CUI SI TROVA IL PUNTATORE
: POINTERTOCELL
	POINTERX @ POINTERY @ VALFB 80 80 VALFB =   IF  0  ELSE 
	POINTERX @ POINTERY @ VALFB 100 80 VALFB =  IF  1  ELSE 
	POINTERX @ POINTERY @ VALFB 180 80 VALFB =  IF  2  ELSE 
	POINTERX @ POINTERY @ VALFB 80 100 VALFB =  IF  3  ELSE 
	POINTERX @ POINTERY @ VALFB 100 100 VALFB = IF  4  ELSE 
	POINTERX @ POINTERY @ VALFB 180 100 VALFB = IF  5  ELSE 
	POINTERX @ POINTERY @ VALFB 80 180 VALFB =  IF  6  ELSE 
	POINTERX @ POINTERY @ VALFB 100 180 VALFB = IF  7  ELSE 
	POINTERX @ POINTERY @ VALFB 180 180 VALFB = IF  8  ELSE 
	THEN THEN THEN THEN THEN THEN THEN THEN THEN ;

\ WORD CHE MI RESTITUISCE LA CELLA ATTUALE DEL TESORO DELLA SEQUENZA DA TROVARE
\ LASTCELL E' UN FLAG PER SAPERE SE E' LA 3 QUINDI L'ULTIMA
VARIABLE NUMCELLATES
1 NUMCELLATES !
: CELLATESFIND
	NUMCELLATES @ 1 =  IF  CELLATES1 @  ELSE 
	NUMCELLATES @ 2 =  IF  CELLATES2 @  ELSE
	NUMCELLATES @ 3 =  IF  CELLATES3 @  ELSE
	THEN THEN THEN ;

\ VARIABILE PER GESTIRE I BLOCCHI DI FEEDBACK DELLA SQUENZA A SCHERMO
VARIABLE CHECKY
80 CHECKY !

\ VARIABILE DI FLAG PER INDICARE LA FINE DEL GIOCO
VARIABLE ENDGAME
1 ENDGAME !

\ VARIABLE PER MEMORIZZARE I TENTATIVI EFFETTUATI E L'ANALOGA PER IL MIGLIOR PUNTEGGIO
VARIABLE ATTEMPTS
0 ATTEMPTS !

VARIABLE BESTATTEMPTS 
FF BESTATTEMPTS !

\ CLICK CENTRALE VERIFICHIAMO SE ABBIAMO TROVATO LA CELLA CORRETTA DELLA SEQUENZA
\ LED VERDE CORRETA, LED ROSSO SBAGLIATA
\ TRE POSSIBILI ALTERNATIVE: CELLA SBAGLIATA - CELLA GIUSTA MA NON ULTIMA DELLA SEQUENZA - CELLA GIUSTA E ULTIMA
: MIDCLICK MIDBIT 0 > IF RESETEVENTS   
		CELLATESFIND POINTERTOCELL = IF 
			NUMCELLATES @ 3 = IF 
				380 180 F GREEN DRAWSQUARE 5 VERDE LED BLINKS 0 OPENSAFE OPENMESSAGE ENDGAME !  
			ELSE ATTEMPTS @ 1 + ATTEMPTS ! NUMCELLATES @ 1 + NUMCELLATES ! 380 CHECKY @ F GREEN DRAWSQUARE VERDE LED BLINK CHECKY @ 80 + CHECKY ! THEN 
		ELSE ATTEMPTS @ 1 + ATTEMPTS ! ROSSO LED BLINK THEN     
		THEN ;

\ WORD PER CONVERTIRE I TENTATIVI FATTI IN "DECIMALE"
\ TUTTO IL PROGRAMMA LAVORO IN ESADECIMALE, L'UNICO PROBLEMA SI CREA QUANDO BISOGNA STAMPARE A SCHERMO UN NUMERO HEX IN DEC
\ UTILIZZO UNA SCAPPATOIA PER NON DOVER PREOCCUPARMI DI PASSARE LA BASE IN DECIMALE
\ < 13 ALLORA +6, > 13 + C
\ ATTEMPTS\BESTATTEMPTS TO DECIMAL
VARIABLE TOCONVERT
: TODECIMAL TOCONVERT ! TOCONVERT @ 9 <= TOCONVERT @ 14 >= + 0 = IF TOCONVERT @ 6 + ELSE TOCONVERT @ 9 > IF TOCONVERT @ C + ELSE TOCONVERT @ THEN THEN ;

\ WORD PER CONFRONTARE LO SCORE ATTUALE CON IL MIGLIORE E IN CASO SCAMBIARLI
: UPDATESCORE ATTEMPTS @ BESTATTEMPTS @ < IF ATTEMPTS @ BESTATTEMPTS ! THEN ;



