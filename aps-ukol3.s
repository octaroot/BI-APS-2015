.data
						; windlx hack (to have nice rows in memory view)
fill:	.space	40
						; matrix data
matrix:	.float	 2, 2, 3, 4, 5, 2, 2, 3, 4, 5, 7
row_2:	.float	 7, 9, 9, 10, 11, 7, 9, 9, 10, 11, 14
row_3:	.float	 13, 14, 16, 16, 17, 13, 14, 16, 16, 17, 21
row_4:	.float	 19, 20, 21, 23, 23, 19, 20, 21, 23, 23, 28
row_5:	.float	 25, 26, 27, 28, 30, 25, 26, 27, 28, 30, 35
row_6:	.float	 9, 11, 13, 11, 15, 12, 12, 13, 14, 15, 71
row_7:	.float	 29, 15, 14, 14, 15, 12, 12, 13, 14, 15, 71
row_8:	.float	 39, 14, 15, 15, 15, 12, 12, 13, 14, 15, 71
row_9:	.float	 49, 13, 16, 18, 15, 12, 12, 13, 14, 15, 71
row_A:	.float	 59, 12, 17, 19, 15, 12, 12, 13, 14, 15, 71

.text
	addui	r1, r0, 10			; N (user input)
	addu	r11, r0, r1			; clone
	
	lhi	r2, matrix >> 16		; load matrix address
	addui	r2, r2, matrix & 0xffff


	addu	r23, r0, r0			; vynulujeme pametovy padding

loop0:

						; calculate the pointer to the row following the base row
						; 	baseRow + wordLength*(N + 1)
	sll	r7, r11, 2			; N * 4
	addui	r6, r2, 4			; nextRow = baseRow + wordLength
	addu	r6, r6, r7			; nextRow += N * 4
	

	addui	r22, r6, 4			; ulozime si nextRow bokem, pro pristi pruchod to totiz bude baseRow
						; 4 pricitame, protoze i prvni sloupec bude vyresen


						; this is the "middle" loop. It is responsible for processing
						; a single row (calc the ratio) and mult/sub all following rows

	subui	r7, r1,	1			; loop ctrl (N-1 rows to process)
loop1:	
						; first we calculate the ratio to multiply the row with
	lf	f0, (r2)
	lf	f1, (r6)

	subui	r7, r7, 1			; independed instruction (loop1 ctrl)

	divf	f2, f1, f0			; f2 = ratio to multiply row elements

	sw	(r6), r0			; first cell will always be set to zero

	addui	r6, r6, 4			; ordered to perform better
	
	addui	r5, r2, 4			; (independent) base row pointer reset (+1, that we "calculated" already)
	addui	r3, r1, 0			; independed instruction (loop2 ctrl: N+1 cols) + -1 (first cell always 0)

						; now we step in the most-inner loop, to iterate over row elements
						; to multiply and subtract them from the rest of the rows


loop2:	
	
	lf	f0, (r5)
	lf	f1, (r6)

	addui	r5, r5, 4			; semi-independent (base pointer advance)

	multf	f0, f0, f2
	
	subui	r3, r3, 1			; independent instruction (loop2 ctrl)

	subf	f0, f1, f0
	
	addui	r6, r6, 4			; ordered to perform better
	sf	-4(r6), f0			; (but we do need a constant here)



	bnez	r3, loop2

	addu	r6, r6, r23			; aplikace leveho paddingu
	bnez	r7, loop1






	addu	r2, r22, r0			; puvodni nextRow ted dame do ukazatele na matrix, protoze baseRow uz jsme zpracovali cely
	addui	r23, r23, 4			; a levy padding taky zajistime	
	subui	r1, r1, 1			; N--

	seq	r24, r1, 1

	beqz	r24, loop0


exit:	trap	0