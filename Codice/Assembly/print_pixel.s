.global _start
_start:
	push {ip, lr}

	ldr a1, =PIXEL
	ldr a1, [a1]
	ldr a2, =PIXEL_SIZE
	ldr a2, [a2]
	mov a3, a2
	ldr a4, =#0x00000FFF
	and a2, a2, a4
	ldr a4, =#0x00FFF000
	and a3, a3, a4
	lsr a3, #0xC
	ldr a4, =COLOR
	ldr a4, [a4]
    bl print_pixel
	
	pop {ip, lr}
	bx lr

/*
	Stampa un pixel di dimensioni n
	a1 indirizzo di partenza della stampa
	a2 grandezza pixel verticale
	a3 grandezza pixel orizzontale
	a4 colore del pixel
*/
print_pixel:
	mov v1, a3
pp1:
	mov a3, v1
pp2:
	str a4, [a1], #0x4
	subs a3, a3, #0x1
	bne pp2

	mov a3, v1, lsl #0x2
	subs a1, a1, a3
	add a1, a1, #0x1000
	subs a2, a2, #0x1
	bne pp1

	bx lr

.data
	PIXEL:      .word 0
	PIXEL_SIZE: .word 1
	COLOR:      .word 2
