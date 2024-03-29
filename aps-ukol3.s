.data
						; input matrix
A:	.float	 2, 2, 3, 4, 5, 2, 2, 3, 4, 5, 7
row_2:	.float	 7, 9, 9, 10, 11, 7, 9, 9, 10, 11, 14
row_3:	.float	 13, 14, 16, 16, 17, 13, 14, 16, 16, 17, 21
row_4:	.float	 19, 20, 21, 23, 23, 19, 20, 21, 23, 23, 28
row_5:	.float	 25, 26, 27, 28, 30, 25, 26, 27, 28, 30, 35
row_6:	.float	 9, 11, 13, 11, 15, 12, 12, 13, 14, 15, 71
row_7:	.float	 29, 15, 14, 14, 15, 12, 12, 13, 14, 15, 71
row_8:	.float	 39, 14, 15, 15, 15, 12, 12, 13, 14, 15, 71
row_9:	.float	 49, 13, 16, 18, 15, 12, 12, 13, 14, 15, 71
row_A:	.float	 59, 12, 17, 19, 15, 12, 12, 13, 14, 15, 71

						; N * N * sizeof(float)
Y:	.space	400
						; stack
_stack:	.space	128
						; N
N:	.byte	10



; free registry jsou r12,13,14,15

.text


	lhi	r11, 0x3f80			; floating point representation of 1
	movi2fp	f5, r11
	
	lhi	r11, N >> 16			; load N address
	lhi	r2, A >> 16			; load input matrix address
	addui	r2, r2, A & 0xffff
	lb	r11, N & 0xffff(r11)		; get N from memory

	lhi	r29,(_stack>>16)&0xffff	; setup stack
	subui	r1, r11, 1			; N-1 (independent instruction)
	addui	r29,r29,(_stack)&0xffff
	sd	(r29), f2			; push f2,f3
	sd	8(r29), f4			; push f4,f5


loop0:


	lf	f0, (r2)			; base row - first element

	sll	r10, r11, 2			; N * 4 (independed)
	
	divf	f4, f5, f0			; f4 = 1/baserow

						; calculate the pointer to the row following the base row
						; 	baseRow + wordLength*(N + 1)
						; N * 4 (already calculated 2 instructions before)
	addui	r9, r2, 4			; nextRow = baseRow + wordLength
	addu	r9, r9, r10			; nextRow += N * 4
	

	addui	r24, r9, 4			; ulozime si nextRow bokem, pro pristi pruchod to totiz bude baseRow
						; 4 pricitame, protoze i prvni sloupec bude vyresen


						; this is the "middle" loop. It is responsible for processing
						; a single row (calc the ratio) and mult/sub all following rows

	addu	r10, r1,r0			; loop ctrl (N-1 rows to process)



loop1:	
						; first we calculate the ratio to multiply the row with
	lf	f1, (r9)

	subui	r10, r10, 1			; independed instruction (loop1 ctrl)

	multf	f2, f1, f4			; f2 = ratio to multiply row elements

	sw	(r9), r0			; first cell will always be set to zero

	addui	r9, r9, 4			; ordered to perform better
	
	addui	r8, r2, 4			; (independent) base row pointer reset (+1, that we "calculated" already)
	addui	r3, r1, 1			; independed instruction (loop2 ctrl: N+1 cols) + -1 (first cell always 0)

						; now we step in the most-inner loop, to iterate over row elements
						; to multiply and subtract them from the rest of the rows


	lf	f0, (r8)			; base row element
	lf	f1, (r9)			; target row element
	multf	f0, f0, f2			; reordered - performance gain
loop2:	

	addui	r8, r8, 4			; semi-independent (base pointer advance)
	subui	r3, r3, 1			; independent instruction (loop2 ctrl)

	subf	f3, f1, f0
	
	addui	r9, r9, 4			; reordered - performance gain
	lf	f0, (r8)			; (prefetch) base row element
	lf	f1, (r9)			; (prefetch) target row element
	multf	f0, f0, f2			; reordered - performance gain

	sf	-4(r9), f3			; save result


	bnez	r3, loop2

	addu	r9, r9, r25			; aplikace leveho paddingu
	bnez	r10, loop1



	subui	r1, r1, 1			; N--
	addu	r2, r24, r0			; puvodni nextRow ted dame do ukazatele na matrix, protoze baseRow uz jsme zpracovali cely
	addui	r25, r25, 4			; a levy padding taky zajistime	

	bnez	r1, loop0

						; we are done
						; copy the results to Y


	lhi	r3, N >> 16			; load N address
	lhi	r1, A >> 16			; load input matrix address
	lb	r3, N & 0xffff(r3)		; get N from memory
	addui	r1, r1, A & 0xffff
	lhi	r2, Y >> 16			; load output matrix address
	addui	r5, r3, 1			; N+1
	addui	r2, r2, Y & 0xffff

	multu	r3, r3, r5			; N*N+1 elements
	andi	r4, r3, 0x0003			; matrix has N*N+1 dim, 2 is a guaranteed factor
	
	beqz	r4, copy4

	ld	f0, (r1)			; if 4 is not a factor
	addui	r1, r1, 8
	subui	r3, r3, 2
	sd	(r2), f0
	addui	r2, r2, 8
	

copy4:	ld	f0, (r1)
	ld	f2, 8(r1)
	addui	r1, r1, 16
	sd	(r2), f0
	sd	8(r2), f2
	subui	r3, r3, 4
	addui	r2, r2, 16
	bnez	r3, copy4

	

exit:	ld	f2, (r29)			; restore f2-f5 registers
	ld	f4, 8(r29)

	trap	0