.global _start
_start:
	push {v1, lr}

	ldr a1, =PIXEL
    ldr a1, [a1]
    ldr a2, =CHAR1
    ldr a2, [a2]
    ldr a3, =CHAR2
    ldr a3, [a3]
    ldr a4, =CHAR_SIZE
    ldr a4, [a4]
    ldr v1, =COLOR
    ldr v1, [v1]
    orr a4, a4, v1, lsl #0x8
    bl print_char

	pop {v1, lr}
	bx lr

/*
	Stampa il carattere desiderato
	a1 indirizzo di partenza della stampa
	a2 prima parte del carattere
	a3 seconda parte del carattere
	a4 dimensione del carattere (del pixel) + colore
*/
print_char:
	push {v1, v2}
	push {v3, v4}
	push {v5, lr}

	mov v1, a1
	mov v2, a2
	mov v3, a3
	ldr v4, =#0x0
    and v5, a4, #0xFFFFFF00
    lsr v5, #0x8
    and a4, a4, #0x000000FF
	ldr a3, =#0x20
pc11:
	mov a1, v3					
	ldr a2, =#0x1
	and a1, a1, a2
	cmp a1, #0x0
	beq pcjm11

	mov a1, v1
	mov a2, a4
	push {a3, a4}
    mov a4, v5
	bl print_pixel
	pop {a3, a4}
pcjm11:
	add v1, v1, a4, lsl #0x2
	sub a3, a3, #0x1
	lsr v3, #1
	add a1, a3, v4
	ldr a2, =#0x5
	bl module
	cmp a1, #0x2
	bne pcjm12

	ldr a2, =#0x14
	mul a1, a2, a4
	sub v1, v1, a1
	ldr a2, =#0x1000
	mul a1, a2, a4
	add v1, v1, a1
pcjm12:
	mov a1, a3
	cmp a1, #0x0
	bne pc11

	cmp v4, #0x2
	beq pcend

	ldr v4, =#0x2
	ldr a3, =#0x8
	mov v3, v2
	b pc11
pcend:
	pop {v5, lr}
	pop {v3, v4}
	pop {v1, v2}
	bx lr

/*
	Stampa un pixel di dimensioni n
	a1 indirizzo di partenza della stampa
	a2 grandezza pixel
	a4 colore del pixel
*/
print_pixel:
    push {v1, ip}
    mov a3, a2
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

    pop {v1, ip}
	bx lr

/*
	Esegue "a mod b"
	a1 corrisponde ad a
	a2 corrisponde a b
*/
module:
	cmp a1, a2
	blt mjp1
lm1:
	sub a1, a1, a2
	cmp a1, a2
	bge lm1
mjp1:
	bx lr


POS = 0x1E4E0
CHAR1 = 0x1E6B8
CHAR2 = 0x1E710
DIM = 0x1E654
COL = 0x1E598


.data
	PIXEL:     .word 0
	CHAR1:     .word 1
	CHAR2:     .word 2
	CHAR_SIZE: .word 3
	COLOR: 	   .word 4
	