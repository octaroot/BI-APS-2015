.data
						; windlx hack (to have nice rows in memory view)
fill:	.space	40-8
						; matrix data
matrix:	.float	 2, 2, 3, 4, 5, 7
row_2:	.float	 7, 9, 9,10,11,14
row_3:	.float	13,14,16,16,17,21
row_4:	.float	19,20,21,23,23,28
row_5:	.float	25,26,27,28,30,35

.text
	addui	r1, r0, 5			; N (user input)
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
loop1:	subui	r7, r7, 1
	addu	r5, r0, r2			; base row pointer reset
						; first we calculate the ratio to multiply the row with

	
	lf	f0, (r5)
	lf	f1, (r6)

	divf	f2, f1, f0			; f2 = ratio to multiply row elements

						; now we step in the most-inner loop, to iterate over row elements
						; to multiply and subtract them from the rest of the rows

	addui	r3, r1, 1			; loop ctrl (N+1 cols)
loop2:	subui	r3, r3, 1
	
	lf	f0, (r5)
	lf	f1, (r6)

	multf	f0, f0, f2
	subf	f0, f1, f0
	
	sf	(r6), f0

	addui	r5, r5, 4
	addui	r6, r6, 4

	bnez	r3, loop2

	addu	r6, r6, r23			; aplikace leveho paddingu

	bnez	r7, loop1






	addu	r2, r22, r0			; puvodni nextRow ted dame do ukazatele na matrix, protoze baseRow uz jsme zpracovali cely
	addui	r23, r23, 4			; a levy padding taky zajistime	
	subui	r1, r1, 1			; N--

	seq	r24, r1, 1

	beqz	r24, loop0


exit:	trap	0