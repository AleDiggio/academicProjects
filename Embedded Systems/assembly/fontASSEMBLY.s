/*
 * ROUTINE ASSEMBLY CHE PERMETTE DI STAMPARE UN CARATTERE IN UNA DETERMINATA POSIZIONE DEL FRAMEBUFFER
 *
 * In memoria è stato caricato il binario del font 8x8, cioè ogni carattere è rappresentato da 8 byte dove ogni
 * singolo byte rappresenta la riga, un pixel a 1 significa "da accendere" e 0 viceversa
 * 
 *
 * r0 valore del FRAMEBUFFER (quindi punto sullo schermo) dove disegnare il carattere
 *
 * r1 indirizzo di memoria del desiderato carattere
 *
 * r2 colore
 *
 * r3 dimensione del carattere
 *
 * r4 valore per fare y = y + 1 = 0x1000
 * 
 *
 * La dimensione quello che fa è di fatto andare a clonare righe e colonne tot volte
 * 
 * Di fatto disegno il carattere "specchiato" perchè comincio ad analizzare il bit meno significativo
 *
 *
 */


bitmap:
	pop  {r3}
	pop  {r0}  
	pop  {r1}
	pop  {r2}
	ldr r4, =0x1000
	mov  r5, #0                      /* Indice di riga */
	mul  r6, r4, r3                  /* r6 = dim * 1000  quanto devo incrementare il framebuffer per passare alla riga successiva */
	byteloop:   
		ldrb r7, [r1] 		         /* Carica il byte della riga di indice r5 */
		add r1, r1, #1               /* Incrementa l'indirizzo di un byte per il successivo */
		mov r9, r0			         /* r9 = valore del FB corrente */
		cmp r7, #0                   /* Se il byte è zero si può passare a quello successivo (no pixel da accendere) */
		beq next_byte         
		bitloop:
			and r8, r7, #1            /* Tramite un AND con 1 analizzo il bit meno significativo */
			cmp r8, #0                /* Se il bit è zero passo al successivo */
			beq next_bit          
			push {r1, r3, r5, lr}     /* Pusho il link register per salvarne il valore */
			bl singlebit         
			pop {r1, r3, r5, lr}      
			
		next_bit:
			lsr r7, r7, #1    	       /* Shift logico a destra di una posizione per analizzare il bit successivo */
			cmp r7, #0
			beq next_byte              /* Se il risultato zero sono finiti i bit da accendere e quindi si passa al byte successivo */
			add r9, r9, r3, lsl #2     /* Per passare al prossimo bit devo incrementare FB di 4 * la dimensione  */    
			b bitloop
		
	next_byte:
		add r5, r5, #1             
		cmp r5, #8   		           /* Se l'indice di riga è 8 allora ho finito */
		beq end
		add r0, r0, r6                 /* Per passare al prossimo byte devo incrementare FB di 1000 * la dimensione */
		b byteloop
	end:	
		bx lr

singlebit:
	push {r9}
	mov r5, #0                         /* Contatore per gestire quante righe per lo stesso bit analizzare in base alla dimensione */
	next_col:
		push {r3, r9}   			   /* Pusho r3 e r9 per gestire il fattore dimensione */
		col_loop:
			str r2, [r9]               /* r9 = valore del framebuffer al momento della chiamata */
			add r9, r9, #4             /* Incremento il framebuffer di 4 ( x = x + 1 ) */
			sub r3, r3, #1
			cmp r3, #0                      
			beq next_row               /* In base alla dimensione specificata ripeto il valore n volte o passo alla riga successiva */
			b col_loop
	next_row:
		pop {r3, r9}
		add r5, r5, #1                    
		cmp r5, r3                              
		beq bend
		add r9, r9, r4                 /* Se non ho finito incremento y = y + 1 e di fatto riscrivo un'altra riga */   
		b next_col
			
	bend:
		pop {r9}
		bx lr




