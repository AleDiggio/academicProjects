/*
 * 	SEMPLICE ROUTINE ASSEMBLY PER CARICARE LO SFONDO
 *  
 *  r5 = Numero di pixel da riempire
 *
 * 	r2 = Indirizzo in memoria da cui cominciano i byte dello sfondo
 *
 *	r1 = Registro che contiene il valore del rispettivo byte
 *
 *	r0 = Valore del framebuffer
 *
 *
 *
 *
 */

pop {r5}
pop {r0}
pop {r2}
ldr r1,[r2]
str r1, [r0]

load_bg:				/* for(int i = r5; i > 0; i--) */
	cmp r5, #0          /* incrementa l'indirizzo del framebuffer e l'indirizzo dello sfondo di 4 */
	beq end
	add r2, r2, #4
	ldr r1,[r2]
	add r0, r0, #4
	str r1, [r0]
	sub r5, r5, #1
	b load_bg
	end:
		bx lr

