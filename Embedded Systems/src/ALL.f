
HEX

\ Sistemi Embedded 18/19
\ Daniele Peri - Universita' degli Studi di Palermo
\
\ Some definitions for ANS compliance
\
\ v. 20181215

: JF-HERE   HERE ;
: JF-CREATE   CREATE ;
: JF-FIND   FIND ;
: JF-WORD   WORD ;

: HERE   JF-HERE @ ;
: ALLOT   HERE + JF-HERE ! ;

: [']   ' LIT , ; IMMEDIATE
: '   JF-WORD JF-FIND >CFA ; 

: CELL+  4 + ;

: ALIGNED   3 + 3 INVERT AND ;
: ALIGN JF-HERE @ ALIGNED JF-HERE ! ;

: CREATE   JF-WORD JF-CREATE DOCREATE , ;
: (DODOES-INT)  ALIGN JF-HERE @ LATEST @ >CFA ! DODOES> ['] LIT ,  LATEST @ >DFA , ; 
: (DODOES-COMP)  (DODOES-INT) ['] LIT , , ['] FIP! , ['] EXIT , ; 
: DOES>COMP   ['] LIT , HERE 3 CELLS + , ['] (DODOES-COMP) , ['] EXIT , ;
: DOES>INT   (DODOES-INT) LATEST @ HIDDEN ] ;
: DOES>   STATE @ 0= IF DOES>INT ELSE DOES>COMP THEN ; IMMEDIATE



HEX

\ FILE CHE SERVE PER INIZIALIZZARE LE COSTANTI CHE VERRANNO UTILIZZATE E CHE DIPENDONO DALLE CONFIGURAZIONI HARDWARE 
\ SPECIFICHE E ALCUNE WORD DI UTILITA'




\ UNICI VALORI DA CAMBIARE PER TUTTO IL PROGRAMMA CHE DIPENDONO DALLA CONFIGURAZIONE DEI PIN E DELL'HARDWARE UTILIZZATO
\ UNICO VINCOLO FRAMEBUFFER 1024x768
\ HO INSERITO DEGLI SPAZI PER DIFFERENZIARE DAL RESTO

3F000000 CONSTANT BASEADDRESS

\ VALORE DI INIZIO DEL FRAMEBUFFER 1024x768
1E8FA000 CONSTANT FRAMEBUFFER

\ INDIRIZZO IN MEMORIA DOVE COMINCIA IL FILE BINARIO CARICATO E I SINGOLI ELEMENTI 
00200000 CONSTANT STARTBG  				\ BACKGROUND 
STARTBG 2FFD00 + CONSTANT STARTFONT		\ FONT
STARTFONT 400 +  CONSTANT STARTOPEN     \ IMMAGINE CASSAFORTE APERTA

\ QUANDO SI SCRIVE IL VALORE NELLE COSTANTI DEI PIN VA IN HEX
1B CONSTANT REDLED		\ PIN 27
17 CONSTANT GREENLED    \ PIN 23

15 CONSTANT MID    \ PIN 21
13 CONSTANT UP     \ PIN 19 
D CONSTANT DOWN    \ PIN 13
16 CONSTANT LEFT   \ PIN 22
11 CONSTANT RIGHT  \ PIN 17 







\ GPIO ALTERNATE FUNCTION SELECT REGISTER 0
BASEADDRESS 200000 + CONSTANT GPFSEL0

\ GPIO OUTPUT SET\CLEAR REGISTERS 0
GPFSEL0 1C + CONSTANT GPSET0
GPFSEL0 28 + CONSTANT GPCLR0

\ GPIO EVENT DETECT STATUS AND FALLING EDGE REGISTERS
GPFSEL0 40 + CONSTANT GPEDS0
GPFSEL0 58 + CONSTANT GPFEN0

\ COLORI PIXEL
00FF0000 CONSTANT RED
0000FF00 CONSTANT GREEN
00000000 CONSTANT BLACK
00FFFFFF CONSTANT WHITE
00FBFBFB CONSTANT LIGHTGREY
00FFFCC0 CONSTANT LIGHTYELLOW
00FFA55F CONSTANT ORANGE

\ SYSTEM TIMER
BASEADDRESS 3004 + CONSTANT SYSTCLO

\ Con 4 elementi la base dello stack in cima
: BASEONTOP   ROT ROT 2SWAP SWAP ;  

\ Calcola il tempo passato, in microsecondi, tra due diverse letture del registro SYSTCLO.
: TIMEPASSED SWAP - ;

\ Loop fino a quando non è passato più tempo di quello specificato in microsecondi.
\ TEMPO (secondi) DELAY
: DELAY   F4240 * SYSTCLO @ BEGIN 2DUP SYSTCLO @ TIMEPASSED <= UNTIL 2DROP ;
\ TEMPO (microsecondi) DELAYMS 
: DELAYMS SYSTCLO @ BEGIN 2DUP SYSTCLO @ TIMEPASSED <= UNTIL 2DROP ;

\ WORD PER OTTENER UN NUMERO RANDOM
\ MAXVAL RAND
: RAND SYSTCLO @ SWAP MOD ;

\ WORD PER CREARE LA MASCHERA DI BIT PER ANALIZZARE/SETTARE QUEL PIN PARTICOLARE
\ PIN SELPIN 
: SELPIN 1 SWAP LSHIFT ;



HEX

\ FILE DOVE VENGONO DEFINITE LE WORD DI GESTIONE DEL DISPLAY

\ X Y COLOR COLORPOINT  ( Word che colora di COLOR il punto X Y)
: COLORPOINT FRAMEBUFFER 2SWAP 1000 * SWAP 4 * + + 2DUP ! ;

\ X Y VALFB (RESTITUISCE IL VALORE DEL FRAMEBUFFER IN QUEL PUNTO X Y)
: VALFB 0 FRAMEBUFFER 2SWAP 1000 * SWAP 4 * + + SWAP DROP ;

\ WORD CHE TRACCIA UN SEGMENTO ORIZZONTALE TRA DUE PUNTI 
\ X1 X2 Y COLOR ORIZ
VARIABLE DISTX
: ORIZ 2SWAP SWAP 2DUP - DISTX ! 2SWAP COLORPOINT BEGIN 4 + 2DUP ! DISTX @ 1 - DUP DISTX ! 0 = UNTIL 2DROP DROP ;

\ WORD CHE TRACCIA UN SEGMENTO VERTICALE TRA DUE PUNTI 
\ Y1 Y2 X COLOR VERT
VARIABLE DISTY
: VERT 2SWAP SWAP 2DUP - DISTY ! 2SWAP ROT SWAP COLORPOINT BEGIN 1000 + 2DUP ! DISTY @ 1 - DUP DISTY ! 0 = UNTIL 2DROP DROP ;

\ WORD CHE DATI DUE PUNTI (X,Y) DISEGNA IL SEGMENTO CHE LI CONGIUNGE
\ X1 Y1 X2 Y2 COLOR SEGMENT
\ x = k, y = k, y = x e y = -x
VARIABLE X1
VARIABLE Y1
VARIABLE X2
VARIABLE Y2
VARIABLE COLOR
: SEGMENT COLOR ! Y2 ! X2 ! Y1 ! X1 ! 
	Y1 @ Y2 @ - 0 = IF  X1 @ X2 @ Y1 @ COLOR @ ORIZ  ELSE 
	X1 @ X2 @ - 0 = IF  Y1 @ Y2 @ X1 @ COLOR @ VERT  ELSE
	THEN THEN ;

\ ARRAY ( NON FUNZIONA ARRAY ) DEL PUNTATORE CORRENTE POINTER 1 CELLS + @ PER LEGGERE L'N-ESIMO VALORE
\ IL PUNTATORE PARTE DAL CENTRO DEL TASTIERINO DELLO SFONDO (quadrato 100x100)
VARIABLE POINTERX
VARIABLE POINTERY
100 POINTERX !
100 POINTERY !

VARIABLE OFFSET
VARIABLE CROSSX
VARIABLE CROSSY
VARIABLE COLORCROSS
9 OFFSET !

\ WORD CHE DISEGNA UNA CROCE NEL PUNTO X Y DI OFFSET "OFFSET" 
\ X Y OFFSET COLOR DRAWCROSS
: DRAWCROSS COLORCROSS ! OFFSET ! CROSSY ! CROSSX ! CROSSX @ CROSSY @ OFFSET @ - CROSSX @ CROSSY @ OFFSET @ + COLORCROSS @ SEGMENT CROSSX @ OFFSET @ - CROSSY @ CROSSX @ OFFSET @ + CROSSY @ COLORCROSS @ SEGMENT ;

VARIABLE SQUAREX
VARIABLE SQUAREY
VARIABLE COLORSQUARE

\ WORD CHE DISEGNA UN QUADRATO NEL PUNTO X Y DI OFFSET "OFFSET"
\ X Y OFFSET COLOR DRAWSQUARE
: DRAWSQUARE COLORSQUARE ! OFFSET ! SQUAREY ! SQUAREX ! SQUAREX @ OFFSET @ - SQUAREY @ OFFSET @ - SQUAREX @ OFFSET @ + SQUAREY @ OFFSET @ - COLORSQUARE @ SEGMENT SQUAREX @ OFFSET @ - SQUAREY @ OFFSET @ - SQUAREX @ OFFSET @ - SQUAREY @ OFFSET @ + COLORSQUARE @ SEGMENT SQUAREX @ OFFSET @ + SQUAREY @ OFFSET @ - SQUAREX @ OFFSET @ + SQUAREY @ OFFSET @ + COLORSQUARE @ SEGMENT SQUAREX @ OFFSET @ - SQUAREY @ OFFSET @ + SQUAREX @ OFFSET @ + SQUAREY @ OFFSET @ + COLORSQUARE @ SEGMENT ;

\ WORD CHE DISEGNA IL PUNTATORE
\ DRAWPOINTER in (POINTERX, POINTERY)
: DRAWPOINTER POINTERX @ POINTERY @ 7 BLACK DRAWSQUARE POINTERX @ POINTERY @ 11 GREEN DRAWCROSS ;

\ WORD PER DISEGNARE I BLOCCHI VERDI PER IL FEEDBACK A SCHERMO
\ X Y COLOR DRAWCHECK
VARIABLE CHECKBOXX 
VARIABLE CHECKBOXY

\ CANCELLA IL VECCHIO PUNTATORE PER FARE IL MOVIMENTO
: CLEAR POINTERX @ POINTERY @ 7 LIGHTGREY DRAWSQUARE POINTERX @ POINTERY @ 11 LIGHTGREY DRAWCROSS ;



HEX

\ FILE CHE CONTIENE LE WORD PER CHIAMARE LE SUBROUTINE ASSEMBLY

\ WORD PER CARICARE IL BACKGROUND (loadBG.s)
CREATE  BG 
e49d5004 , e49d0004 ,
e49d2004 , e5921000 ,
e5801000 , e3550000 ,
0a000005 , e2822004 ,
e5921000 , e2800004 ,
e5801000 , e2455001 ,
eafffff7 , e12fff1e ,
: BACKGROUND STARTBG FRAMEBUFFER C0000 BG JSR DROP ;

\ WORD CHE PERMETTE DI DISEGNARE UN CARATTERE DATO IL SUO COD ASCII IN UNA POSIZIONE X Y DI COLORE COLOR E DIMENSIONE DIMENSION
\ X Y COLOR INDEX_ASCII DIMENSION DRAWCHAR (fontASSEMBLY.s)
CREATE BITMAP_CHAR 
e49d3004 , e49d0004 , e49d1004 , e49d2004 , e3a04000 , e2844a01 ,
e3a05000 , e0060394 , e5d17000 , e2811001 , e1a09000 , e3570000 ,
0a00000a , e2078001 , e3580000 , 0a000002 , e92d402a , eb00000b ,
e8bd402a , e1a070a7 , e3570000 , 0a000001 , e0899103 , eafffff4 ,
e2855001 , e3550008 , 0a000001 , e0800006 , eaffffea , e12fff1e ,
e52d9004 , e3a05000 , e92d0208 , e5892000 , e2899004 , e2433001 ,
e3530000 , 0a000000 , eafffff9 , e8bd0208 , e2855001 , e1550003 ,
0a000001 , e0899004 , eafffff2 , e49d9004 , e12fff1e ,
: DRAWCHAR >R >R >R VALFB R> R> R> BASEONTOP SWAP BITMAP_CHAR JSR DROP ;   

\ WORD CHE DATO IL CODICE ASCII RESTITUISCE L'INIDIRIZZO DI MEMORIA DEL PRIMO BIT DELLA BITMAP
\ INDEX_ASCII FINDCHAR
: FINDCHAR  8 * STARTFONT + ;

\ WORD PER CARICARE L'IMMAGINE DI APERTURA DELLA CASSAFORTE (loadOPEN.s)
\ 1B6000 E' L'OFFSET DEL FRAMEBUFFER PER COMINCIARE DAL PUNTO (X,Y) VOLUTO
CREATE  OPEN 
e49d5004 , e49d2004 , e49d0004 ,
e5921000 , e1a03000 , e5831000 ,
e59f4040 , e3550000 , 0a00000d ,
e2822004 , e5921000 , e3540000 ,
1a000004 , e2800a01 , e1a03000 ,
e5831000 , e59f4018 , ea000002 ,
e2833004 , e5831000 , e2444001 ,
e2455001 , eaffffef , e12fff1e ,
000001ad ,
: OPENSAFE FRAMEBUFFER 1B6000 + STARTOPEN 22A4C OPEN JSR DROP ;



 HEX

\ FILE CHE GESTISCE L'OUTPUT, QUINDI LED E MOSTRARE A SCHERMO

\ WORD CHE DATO IL NUMERO DEL PIN IN HEX LO CONFIGURA IN OUTPUT 
\ CALCOLA IL GPFSEL REGISTER APPROPRIATO
\ OGNI REGISTRO GESTISCE 10 PIN, QUINDI IL QUOTO PER 10 MI DIRA' L'OFFSET DEL REGISTRO CORRETTO E IL RESTO SARA'
\ IL VALORE MOD 10 CIOE' BASTA MOLTIPLICARE PER 3 E SARA' IL NUMERO DEL BIT CHE SARA' IL MENO SIGNIFICATIVO DELLA TERNA PER LA CONFIG
\ PIN OUTPIN 
: OUTPIN A /MOD 4 * GPFSEL0 + SWAP 3 * SELPIN SWAP DUP ROT ROT @ OR SWAP ! ; 

\ WORD PER CHE ABILITA I PIN SCELTI PER L'OUTPUT DEL LED E LI CONFIGURA IN OUTPUT 
: ENABLEPINOUTPUT REDLED OUTPIN GREENLED OUTPIN ;

\ COLOR LED ON-OFF
: LED GPSET0 GPCLR0 ;    
: ON DROP ! ; 
: OFF NIP ! ; 

\ WORD DEI COLORI DEL LED
: ROSSO REDLED SELPIN ;					
: VERDE GREENLED SELPIN ;

\ WORD PER DUPLICARE LA TERNA SULLO STACK
: 3DUP DUP 2OVER ROT ;  

\ WORD PER FARE SEMPLICEMENTE ON-OFF 1 SECONDO (NO DELAY DOPO OFF)
: BLINK 3DUP ON 1 DELAY OFF ;

\ N COLORE LED BLINKS 20000 MICROSECONDI
VARIABLE TIMES
: BLINKS BASEONTOP TIMES ! BEGIN 3DUP 3DUP ON 20000 DELAYMS OFF 20000 DELAYMS TIMES @  1 - DUP TIMES ! 0 = UNTIL DROP 2DROP ; 

\ WORD CHE DATA UNA CIFRA LA STAMPA NEL PUNTO X Y
\ X Y COLOR CIFRA DIMENSION PRINTCIFRA
: PRINTCIFRA SWAP 30 + FINDCHAR SWAP DRAWCHAR ;

\ WORD CHE DATO UN NUMERO RESTITUISCE LE SUE CIFRE
VARIABLE COUNTERCIFRE
: NUMTOCIFRE 0 COUNTERCIFRE ! BEGIN 10 /MOD DUP COUNTERCIFRE @ 1 + COUNTERCIFRE ! 0 = UNTIL DROP ;

\ WORD CHE STAMPA UN NUMERO QUALSIASI NEL PUNTO X Y - SERVONO DUE CONTATORI, UNO PER IL PAR STACK E L'ALTRO PER STAMPARE LE CIFRE
\ X Y COLOR NUMERO DIMENSION PRINTNUM
VARIABLE CIFRAX
VARIABLE CIFRAY
VARIABLE CIFRACOLOR
VARIABLE CIFRADIM
: PRINTNUM  CIFRADIM ! SWAP CIFRACOLOR ! SWAP CIFRAY ! SWAP CIFRAX ! NUMTOCIFRE
			BEGIN CIFRAX @ SWAP CIFRAY @ SWAP CIFRACOLOR @ SWAP CIFRADIM @ PRINTCIFRA CIFRAX @ CIFRADIM @ 8 * + CIFRAX ! COUNTERCIFRE @ 1 - DUP COUNTERCIFRE ! 0 = UNTIL ;

\ WORD CHE DATA UNA STRINGA DI CODICI ASCII RESTITUISCE NELLO STACK I CODICI DEI SINGOLI CARATTERI 
VARIABLE CTRLETTER
\ : STRLEN 0 CTRLETTER ! BEGIN DROP CTRLETTER @ 1 + CTRLETTER ! DUP 0 = UNTIL ;

\ WORD CHE DATA UNA STRINGA COME SEQUENZA DI CODICI ASCII E LA SUA LUNGHEZZA LA STAMPA DA (X,Y) 
\ ASCII1 ASCII2 ASCII3... STRLEN X Y COLOR DIMENSION PRINTF
VARIABLE PRINTX
VARIABLE PRINTY
VARIABLE PRINTCOLOR
VARIABLE PRINTDIM
VARIABLE STRLEN
VARIABLE CTR
: PRINTF    PRINTDIM ! PRINTCOLOR ! PRINTY ! PRINTX ! DUP STRLEN ! CTR ! BEGIN >R CTR @ 1 - DUP CTR ! 0 = UNTIL 
			BEGIN PRINTX @ PRINTY @ PRINTCOLOR @ R> FINDCHAR PRINTDIM @ DRAWCHAR PRINTX @ PRINTDIM @ 8 * + PRINTX ! STRLEN @ 1 - DUP STRLEN ! 0 = UNTIL ;

\ WORD PER STAMPARE "APERTA!" IN 550 x 600, 226 258
: OPENMESSAGE 41 50 45 52 54 41 21 7 226 258 LIGHTGREY 4 PRINTF ; 
 


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



HEX 

\ FILE PER LANCIARE IL GIOCO

\ WORD DA UTILIZZARE SOLO LA PRIMA VOLTA 
: START ENABLEPININPUT ENABLEPINOUTPUT BACKGROUND 1 DELAY BUILDSEQUENCE ;

\ ROUTINE DI GIOCO
: STARTGAME DRAWPOINTER BEGIN 7500 DELAYMS UPMOVE 7500 DELAYMS DOWNMOVE 7500 DELAYMS LEFTMOVE 7500 DELAYMS RIGHTMOVE 7500 DELAYMS MIDCLICK 7500 DELAYMS ENDGAME @ 0 = UNTIL UPDATESCORE 2BC FA LIGHTGREY ATTEMPTS @ TODECIMAL 4 PRINTNUM  ;

\ FUNZIONE DI RESET
: RESET RESETEVENTS BACKGROUND 2BC 1A4 LIGHTGREY BESTATTEMPTS @ TODECIMAL 4 PRINTNUM BUILDSEQUENCE 100 POINTERX ! 100 POINTERY ! 1 ENDGAME ! 1 NUMCELLATES ! 80 CHECKY ! 0 ATTEMPTS ! ;
 

\ PER LANCIARE IL GIOCO LA PRIMA VOLTA: START STARTGAME, POI RESET STARTGAME






