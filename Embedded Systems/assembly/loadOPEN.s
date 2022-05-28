/*
 * 	ROUTINE ASSEMBLY PER CARICARE L'IMMAGINE DI APERTURA DELLA CASSAFORTE
 *  
 * 
 * r5 = quanti punti devo caricare
 * 
 * r0 = Valore di partenza del framebuffer
 *	
 * r2 = Valore di partenza in memoria dell'immagine 
 *
 * r1 = Valore del pixel i-esimo
 *
 * r3 = Valore attuale del framebuffer
 *
 * r4 = 430 che è la coordinata y dove devo passare alla riga successiva
 *
 */

pop {r5}
pop {r2}
pop {r0}
ldr r1,[r2]
mov r3, r0                 /* Stessa logica del caricamento dello sfondo, ma semplicemnte se ho */
str r1, [r3]               /* caricato 430 pixel, devo passare a y = y + 1 */
ldr r4, #429

load_bg:
		cmp r5, #0
		beq end
		add r2, r2, #4
		ldr r1,[r2]
		cmp r4, #0
		bne continue
		add r0, r0, #0x0001000
		mov r3, r0
		str r1, [r3]
		ldr r4, #429
		b next_pixel
continue:
		add r3, r3, #4
		str r1, [r3]
		sub r4, r4, #1
next_pixel:
		sub r5, r5, #1
		b load_bg
		end:
			bx lr


